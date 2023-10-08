local ConfigService = require("api/ConfigService")
local all_modems = require("vuci.modem"):get_all_modems()
local util = require("vuci.util")
local event_type = require("vuci.event_type")

local EventsReporting = ConfigService:new({
	anonymous = true
})

function EventsReporting:get_used_params()
	local p = require("vuci.param")
	return p:get_params_by_service("events_reporting")
end
local EMAIL_TIMEOUT = 30

local ERR_CODES = {
	EMAIL_SEND_FAILED = 1,
	EMAIL_GROUP_NOT_FOUND = 2,
	EMAIL_SEND_TIMEOUT = 3,
	EMAIL_GROUP_INVALID_CFG = 4,
}

function EventsReporting:send_email(email_user, subject, message, all_recipients, timeout)
	local nixio = require("nixio")
	local cmd = {"/usr/sbin/sendmail", "-t"}
	if email_user.secure_conn == "1" then
		table.insert(cmd, "-H")
		table.insert(cmd, "exec openssl s_client -quiet -connect "..util.shellquote(email_user.smtp_ip..":"..email_user.smtp_port).." -tls1_2 -starttls smtp")
	else
		table.insert(cmd, "-S")
		table.insert(cmd, email_user.smtp_ip..":"..email_user.smtp_port)
	end
	table.insert(cmd, "-f")
	table.insert(cmd, email_user.senderemail)
	if email_user.credentials == "1" then
		table.insert(cmd, "-au"..email_user.username)
		table.insert(cmd, "-ap"..email_user.password)
	end
	if type(all_recipients) == "table" then
		all_recipients = table.concat(all_recipients, ",")
	end

	-- call sendmail using fork, exec, pipe, dup to pass data to sendmail (same as 'echo <email_info> | sendmail ...')
	-- fork 2 childs - 'sleep <timeout>' and 'echo <email_info> | sendmail ..'
	-- this way it is possible to implement process timeout - exit after whichever process exits first
	-- if sleep exits first that means the timeout was reached
	-- if sendmail exits first that means the email was sent succesfully or error happened and error code was returned
	local fd0, fd1 = nixio.pipe()
	local sendmail_pid = nixio.fork()
	if sendmail_pid > 0 then
		-- parent
		fd0:close()
		fd1:write("subject:"..subject.."\nfrom:"..email_user.senderemail.."\nto:"..all_recipients.."\n"..message.."\n")
		fd1:close()

		local sleep_pid = nixio.fork()
		if sleep_pid > 0 then
			-- parent
			local pid_exited, status, code  = nixio.waitpid() -- wait for any child proccess to exit
			if pid_exited == sleep_pid then
				nixio.kill(sendmail_pid, 15) -- SIGTERM
				return ERR_CODES.EMAIL_SEND_TIMEOUT -- sendmail timeout err code 3
			end
			return code
		elseif sleep_pid == 0 then
			-- child2
			nixio.exec("/bin/sleep", tostring(timeout))
		else
			error("fork() error")
		end
	elseif sendmail_pid == 0 then
		-- child1
		fd1:close()

		-- redirect stdin to fd0
		nixio.dup(fd0, io.stdin)

		-- exec sendmail
		nixio.exec(unpack(cmd))
	else
		error("fork() error")
	end
end

function EventsReporting:send_test_email(email_data)
	local v = require "lualibparam"
	local data = email_data or self.arguments.data

	if string.find(data.message, "%%et") then
		data.message = string.gsub(data.message, "%%et", data.event)
	end
	if string.find(data.message, "%%ex") then
		data.message = string.gsub(data.message, "%%ex", "Test email")
	end
	local result = v.expand_params(data.message, data.info_modem_id)
	data.message = util.trim(result)

	local group
	self:table_foreach("user_groups", "email", function(s)
		if s.name == data.group then
			group = s
			return false -- break
		end
	end)

	if not group.smtp_ip or not group.smtp_port or not group.senderemail or
	(group.credentials == "1" and (not group.username or not group.password)) then
		return self:add_critical_error(ERR_CODES.EMAIL_GROUP_INVALID_CFG, "Email account configuration is invalid")
	end

	local code = self:send_email(group, data.subject, data.message, data.recipients, EMAIL_TIMEOUT)

	if code == 0 then
		return self:ResponseOK("Email sent successfully")
	elseif code == ERR_CODES.EMAIL_SEND_TIMEOUT then
		return self:add_critical_error(ERR_CODES.EMAIL_SEND_TIMEOUT, "Email sending timed out")
	else
		return self:add_critical_error(ERR_CODES.EMAIL_SEND_FAILED, "Failed to send the email")
	end
end


function EventsReporting:GET_TYPE_options()
	self:ResponseOK({
		params = self:get_used_params(),
		events = event_type:get_all_events()
	})
end

local opt_enable

function EventsReporting:require_validation()
	local _enable = self:get_abs_value(self.config, self.sid, "enable") or self.current_data_block["enable"]
	local _require = { "event", "eventMark", "action" }
	local require_options = {}
	local additional_require_options = {}

	if _enable == "1" then
		local action = self:get_abs_value(self.config, self.sid, "action") or self.current_data_block["action"]
		if all_modems and #all_modems > 1 then
			if action and action == "sendEmail" then
				additional_require_options = {"info_modem_id"}
			elseif action and action == "sendSMS" then
				additional_require_options = {"send_modem_id", "info_modem_id"}
			end
		end
		if action and action == "sendEmail" then
			require_options = { "subject", "message", "emailgroup", "recipEmail"}
		elseif action and action == "sendSMS" then
			local recipient_require = nil
			local recipient_format_value = self:get_abs_value(self.config, self.sid, "recipient_format") or self.current_data_block["recipient_format"]
			if recipient_format_value and recipient_format_value == "single" then
				recipient_require = "telnum"
			elseif recipient_format_value and recipient_format_value == "group" then
				recipient_require = "group"
			end
			require_options = {"message", "recipient_format", recipient_require}
		end
		for _, v in ipairs(additional_require_options) do
			table.insert(_require, v)
		end
		for _, v in ipairs(require_options) do
			table.insert(_require, v)
		end
		opt_enable.require = { ["1"] = _require }
	end
end

EventsReporting.PUT_validate_section_hook = EventsReporting.require_validation
EventsReporting.POST_validate_section_hook = EventsReporting.require_validation

local Rules = EventsReporting:section("events_reporting", "rule")
function Rules:filter(options)
	return options.action ~= "sendRMS"
end

	opt_enable = Rules:option("enable")
		function opt_enable:validate(value)
			return self.dt:is_bool(value)
		end

	local opt_event = Rules:option("event")
		function opt_event:validate(value)
			local events = {}
			for event in pairs(event_type:get_all_events()) do
				table.insert(events, event)
			end
			return self.dt:check_array(value, events)
		end

	local opt_eventMark = Rules:option("eventMark")
		function opt_eventMark:validate(value)
			local current_event = self:get_abs_value(self.config, self.sid, "event")
			if not current_event then
				return false, "event not set"
			end
			local events = event_type:get_all_events()
			if not events[current_event] then
				return false, "event type not found"
			end
			return self.dt:check_array(value, events[current_event])
		end
		function opt_eventMark:get()
			local event = self:table_get(self.config, self.sid, "event")
			local event_mark = self:table_get(self.config, self.sid, "eventMark")
			if event and event_mark and event == "Reboot" and event_mark == "sms" then
				return "sms reboot"
			end
			return event_mark
		end
		function opt_eventMark:set(value)
			local event = self:get_abs_value(self.config, self.sid, "event")
			if event and value and event == "Reboot" and value == "sms reboot" then
				self:table_set(self.config, self.sid, "eventMark", "sms")
			else
				self:table_set(self.config, self.sid, "eventMark", value)
			end
		end

	local opt_action = Rules:option("action")
		function opt_action:validate(value)
			local check = {"sendEmail"}
			if all_modems and #all_modems > 0 then
				table.insert(check, "sendSMS")
			end
			return self.dt:check_array(value, check)
		end

	local opt_info_modem_id = Rules:option("info_modem_id")
		function opt_info_modem_id:validate(value)
			if all_modems and #all_modems > 1 then
				return self.dt:check_modem(value)
			end
			return false, "info_modem_id is available only if device has more than one modem"
		end

	local opt_send_modem_id = Rules:option("send_modem_id")
		function opt_send_modem_id:validate(value)
			if all_modems and #all_modems > 1 then
				return self.dt:check_modem(value)
			end
			return false, "send_modem_id is available only if device has more than one modem"
		end

	local opt_subject = Rules:option("subject")
		opt_subject.maxlength = 256
		function opt_subject:validate(value)
			return self.dt:fieldvalidation(value, "^[a-zA-Z0-9!@#$%%&*+/=?^_`{|}~%. %-]+$")
		end

	local opt_message = Rules:option("message")
		function opt_message:validate(value)
			return self.dt:string(value)
		end

	local opt_recipient_format = Rules:option("recipient_format")
		function opt_recipient_format:validate(value)
			return self.dt:check_array(value, {
				"single", "group"
			})
		end

	local opt_telnum = Rules:option("telnum")
		-- Disabled till WebUI fixes its creation of empty configurations.
		-- opt_telnum.cfg_require = true
		function opt_telnum:validate(value)
			return self.dt:phonedigit(value)
		end

	local opt_group = Rules:option("group")
		function opt_group:validate(value)
			local ok = false
			self:table_foreach("user_groups", "phone", function (s)
				if s.name == value then ok = true end
			end)
			return ok, "phone group not found"
		end

	local opt_emailgroup = Rules:option("emailgroup")
		function opt_emailgroup:validate(value)
			local ok = false
			self:table_foreach("user_groups", "email", function (s)
				if s.name == value then ok = true end
			end)
			return ok, "Email account not found", ERR_CODES.EMAIL_GROUP_NOT_FOUND
		end

	local opt_recipEmail = Rules:option("recipEmail", {list = true})
		-- Disabled till WebUI fixes its creation of empty configurations.
		-- opt_recipEmail.cfg_require = true
		function opt_recipEmail:validate(value)
			return self.dt:email(value)
		end

local EmailTest = EventsReporting:action("send_test_email", function (self, data)
	self:send_test_email(data)
end)

	local aopt_event = EmailTest:option("event")
		aopt_event.require = true
		aopt_event.validate = opt_event.validate

	local aopt_subject = EmailTest:option("subject")
		aopt_subject.require = true
		aopt_subject.validate = opt_subject.validate
		aopt_subject.maxlength = 256

	local aopt_message = EmailTest:option("message")
		aopt_message.require = true
		aopt_message.validate = opt_message.validate

	local aopt_recipients = EmailTest:option("recipients")
		aopt_recipients.require = true
		function aopt_recipients:validate(value)
			if type(value) == "table" then
				for _, v in ipairs(value) do
					local ok, err = self.dt:email(v)
					if not ok then return ok, err end
				end
				return true
			end
			return self.dt:email(value)
		end

	local aopt_group = EmailTest:option("group")
		aopt_group.require = true
		aopt_group.validate = opt_emailgroup.validate

	local aopt_info_modem_id = EmailTest:option("info_modem_id")
		function aopt_info_modem_id:validate(value)
			if all_modems and #all_modems > 1 then
				return self.dt:check_modem(value)
			end
			return false, "info_modem_id is available only if device has more than one modem"
		end

function EventsReporting:POST_validate_hook()
	local interfaces = 0
	self:table_foreach("events_reporting", "rule", function (_)
		interfaces = interfaces + 1
	end)
	if interfaces >= 90 then
		self:add_critical_error(STD_CODES.UCI_CREATE_ERROR, "Can't create more instances. Only 90 instances are allowed")
	end
end

return EventsReporting