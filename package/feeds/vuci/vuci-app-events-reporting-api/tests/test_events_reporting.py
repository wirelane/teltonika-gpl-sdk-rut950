from utility_integration import Env, WrapTest
from utils.ssh import get_ssh, open_ssh_connection, is_process_running
from utils.general_api import get_modems, generate_require_error_messages
import sys
sys.path.append("../../../../tests")
BASE_URL = "/events_reporting/config"
OPTIONS_URL = "/events_reporting/options"
EMAIL_USERS_URL = "/recipients/email_users/config"
SEND_EMAIL_URL = "/events_reporting/actions/send_test_email"
EMAIL_GROUP_NAME = "ev_rep_test"
EMPTY_EMAIL_GROUP_NAME = "ev_rep_em_test"

ERR_CODES = {
    "EMAIL_SEND_FAILED": 1,
    "EMAIL_GROUP_NOT_FOUND": 2,
    "EMAIL_SEND_TIMEOUT": 3,
    "EMAIL_GROUP_INVALID_CFG": 4,
}

class test_events_reporting(WrapTest):
    @classmethod
    def setUpClass(cls) -> None:
        cls.ssh = get_ssh()
        res = cls.ssh.send_cmd("ping -c 1 1.1.1.1 &> /dev/null ; echo $?")
        cls.internet_connection = res.strip() == "0"

    @classmethod
    def tearDownClass(cls) -> None:
        cls.ssh.logout()

    def create_email_user(self):
        x = self.post_data(EMAIL_USERS_URL, {
            "name": EMAIL_GROUP_NAME,
            "secure_conn": "1",
            "smtp_ip": "111.222.111.222",
            "smtp_port": "123",
            "credentials": "1",
            "username": "test",
            "password": "test",
            "senderemail": "example@teltonika.lt"
        })
        x.assert_code(201)
        self.EMAIL_USER_SID = x.resp.json()["data"]["id"]

    def create_empty_email_user(self):
        x = self.post_data(EMAIL_USERS_URL, {
            "name": EMPTY_EMAIL_GROUP_NAME,
        })
        x.assert_code(201)
        self.EMPTY_EMAIL_USER_SID = x.resp.json()["data"]["id"]

    def chunks(self, lst, n):
        """Yield successive n-sized chunks from lst."""
        for i in range(0, len(lst), n):
            yield lst[i:i + n]

    def del_empty_email_user(self):
        x = self.delete(f"{EMAIL_USERS_URL}/{self.EMPTY_EMAIL_USER_SID}")
        x.assert_code(200)

    def del_email_user(self):
        x = self.delete(f"{EMAIL_USERS_URL}/{self.EMAIL_USER_SID}")
        x.assert_code(200)

    def create_section(self, body={"enable": "0"}):
        modems = get_modems(self)
        if "action" in body and body["action"] == "sendSMS" and len(modems) > 1:
            body.update({
                "send_modem_id": modems[0]["id"],
                "info_modem_id": modems[0]["id"]
            })
        if "action" in body and body["action"] == "sendEmail" and len(modems) > 1:
            body.update({
                "info_modem_id": modems[0]["id"]
            })
        x = self.post_data(BASE_URL, body)
        x = self.post_data(BASE_URL, {"enable": "0"})
        x.assert_code(201)
        return x.resp.json()["data"]["id"]

    def create_enabled_section(self):
        modems = get_modems(self)
        payload = {
            "enable": "1",
            "event": "Reboot",
            "eventMark": "all",
            "action": "sendSMS",
            "message": "testing",
            "recipient_format": "single",
            "telnum": "+66666666666"
        }
        if len(modems) > 1:
            payload.update({
                "send_modem_id": modems[0]["id"],
                "info_modem_id": modems[0]["id"],
            })
        x = self.post_data(BASE_URL, payload)
        x.assert_code(201)
        return x.resp.json()["data"]["id"]

    def del_section(self, sid):
        x = self.delete(f"{BASE_URL}/{sid}")
        x.assert_code(200)

    def test_custom_options_validations_saving(self):
        sid = None
        with self.subTest("create section"):
            sid = self.create_section()
            self.create_email_user()

        with self.subTest("main test"):
            # "action" option
            x = self.put_data(f"{BASE_URL}/{sid}", {"action": "sendEmail"})
            x.assert_code(200)
            modems = get_modems(self)
            if len(modems) > 0:
                x = self.put_data(f"{BASE_URL}/{sid}", {"action": "sendSMS"})
                x.assert_code(200)

            x = self.put_data(f"{BASE_URL}/{sid}", {"action": "pp"})
            x.assert_code(422)

            # "*_modem_id" options
            if len(modems) > 1:
                for md in modems:
                    x = self.put_data(
                        f"{BASE_URL}/{sid}", {"info_modem_id": md["id"], "send_modem_id": md["id"]})
                    x.assert_code(200)
            else:
                x = self.put_data(
                    f"{BASE_URL}/{sid}", {"info_modem_id": "bb", "send_modem_id": "ll"})
                x.assert_code(422)

            # "emailgroup" option
            x = self.put_data(f"{BASE_URL}/{sid}",
                              {"emailgroup": "argaergaer"})
            x.assert_code(422)

            x = self.put_data(f"{BASE_URL}/{sid}",
                              {"emailgroup": EMAIL_GROUP_NAME})
            x.assert_code(200)
            self.assertEqual(x.resp.json()["data"]
                             ["emailgroup"], EMAIL_GROUP_NAME)

            section = self.get_section("events_reporting", sid)["values"]
            del section[".name"]
            self.assertEqual(section["emailgroup"], EMAIL_GROUP_NAME)

            x = self.put_data(f"{BASE_URL}/{sid}",
                              {"emailgroup": ""})
            x.assert_code(200)
            section = self.get_section("events_reporting", sid)["values"]
            self.assertNotIn("senderEmail", section)
            self.assertNotIn("password", section)
            self.assertNotIn("userName", section)
            self.assertNotIn("smtpPort", section)
            self.assertNotIn("smtpIP", section)
            self.assertNotIn("secureConnection", section)

            x = self.put_data(f"{BASE_URL}/{sid}",
                              {"emailgroup": "sgfhsgf4115"})
            x.assert_code(422)

        with self.subTest("del section"):
            self.del_section(sid)
            self.del_email_user()

    def test_send_email_failure(self):
        with self.subTest("create email user"):
            self.create_email_user()

        with self.subTest("create empty email user"):
            self.create_empty_email_user()

        with self.subTest("main test"):
            x = self.post_data(SEND_EMAIL_URL, {
                "event": "SMS",
                "group": "invalid_group",
                "message": "test message",
                "subject": "testing",
                "recipients": [
                    "example@teltonika.lt"
                ]
            })
            x.assert_error("group", "Email account not found", ERR_CODES["EMAIL_GROUP_NOT_FOUND"])

            x = self.post_data(SEND_EMAIL_URL, {
                "event": "SMS",
                "group": EMPTY_EMAIL_GROUP_NAME,
                "message": "test message",
                "subject": "testing",
                "recipients": [
                    "example@teltonika.lt"
                ]
            })
            x.assert_error(None, "Email account configuration is invalid", ERR_CODES["EMAIL_GROUP_INVALID_CFG"])

            x = self.post_data(SEND_EMAIL_URL, {
                "event": "SMS",
                "group": EMAIL_GROUP_NAME,
                "message": "test message",
                "subject": "testing",
                "recipients": [
                    "example@teltonika.lt"
                ]
            })
            x.assert_code(422)
            if self.internet_connection:
                x.assert_error(None, "Email sending timed out", ERR_CODES["EMAIL_SEND_TIMEOUT"])
            else:
                x.assert_error(None, "Failed to send the email", ERR_CODES["EMAIL_SEND_FAILED"])

        with self.subTest("del empty email user"):
            self.del_empty_email_user()

        with self.subTest("del email user"):
            self.del_email_user()

    def test_invalid_event(self):
        x = self.post_data(BASE_URL, {"event": "sugma", "eventMark": "bowls"})
        x.assert_code(422)

    def test_events_reporting_daemon_is_running(self):
        sid = None
        with self.subTest("create section"):
            sid = self.create_enabled_section()

        with self.subTest("main test"):
            self.assertTrue(is_process_running(self.ssh, "events_reporting"), "Expected events_reporting to be running")

        with self.subTest("del section"):
            self.del_section(sid)

    def test_available_events_saving(self):
        # Using /bulk for faster response because a lot of events exist
        x = self.get(OPTIONS_URL)
        x.assert_code(200)
        self.event_list = {}
        self.event_list = x.resp.json()["data"]["events"]
        s1 = {
            "enable": "",
            "event": "",
            "eventMark": "",
            "action": "",
            "info_modem_id": "",
            "send_modem_id": "",
            "subject": "",
            "message": "",
            "recipient_format": "",
            "telnum": "",
            "group": "",
            "emailgroup": "",
            "recipEmail": "",
            ".type": "rule"
        }

        sid = None
        with self.subTest("create section"):
            sid = self.create_section(s1)

        with self.subTest("main test"):
            events_data = []
            for event, ev_marks in self.event_list.items():
                for ev_mark in ev_marks:
                    events_data.append(
                        {
                            "method": "PUT",
                            "endpoint": BASE_URL,
                            "data": [
                                {"id": sid, "event": event, "eventMark": ev_mark,
                                    ".type": "rule", "enable": "0"}
                            ],
                        }
                    )

            for chunk in self.chunks(events_data, 100):
                bulk = {"data": chunk}
                x = self.post("/bulk", bulk)
                res_body = x.resp.json()
                for i, req in enumerate(bulk["data"]):
                    res_data = res_body["data"][i]["data"]
                    self.assertDictEqual(req["data"][0], res_data[0])

        with self.subTest("del section"):
            self.del_section(sid)
    
    def test_enable_require_dependency(self):
        sid = None
        with self.subTest("create section"):
            sid = self.create_section()

        with self.subTest("check dependecy"):
            modems = get_modems(self)
            x = self.put_data(f"{BASE_URL}/{sid}", {
                "enable": "1"
            })
            self.assertListEqual(x.json["errors"], generate_require_error_messages('enable', sid, ['event', 'eventMark', 'action']))
            if len(modems) > 1:
                x = self.put_data(f"{BASE_URL}/{sid}", {
                    "enable": "1",
                    "action": "sendEmail"
                })
                self.assertListEqual(x.json["errors"], generate_require_error_messages('enable', sid, ['event', 'eventMark', 'info_modem_id', 'subject', 'message', 'emailgroup', 'recipEmail']))
                x = self.put_data(f"{BASE_URL}/{sid}", {
                    "enable": "1",
                    "action": "sendSMS"
                })
                self.assertListEqual(x.json["errors"], generate_require_error_messages('enable', sid, ['event', 'eventMark', 'send_modem_id', 'info_modem_id', 'message', 'recipient_format']))
                x = self.put_data(f"{BASE_URL}/{sid}", {
                    "enable": "1",
                    "action": "sendSMS",
                    "recipient_format": "single"
                })
                self.assertListEqual(x.json["errors"], generate_require_error_messages('enable', sid, ['event', 'eventMark', 'send_modem_id', 'info_modem_id', 'message', 'telnum']))
                x = self.put_data(f"{BASE_URL}/{sid}", {
                    "enable": "1",
                    "action": "sendSMS",
                    "recipient_format": "group"
                })
                self.assertListEqual(x.json["errors"], generate_require_error_messages('enable', sid, ['event', 'eventMark', 'send_modem_id', 'info_modem_id', 'message', 'group']))
            else:
                x = self.put_data(f"{BASE_URL}/{sid}", {
                    "enable": "1",
                    "action": "sendEmail"
                })
                self.assertListEqual(x.json["errors"], generate_require_error_messages('enable', sid, ['event', 'eventMark', 'subject', 'message', 'emailgroup', 'recipEmail']))
            if len(modems) == 1:
                x = self.put_data(f"{BASE_URL}/{sid}", {
                    "enable": "1"
                })
                self.assertListEqual(x.json["errors"], generate_require_error_messages('enable', sid, ['event', 'eventMark', 'action']))
                x = self.put_data(f"{BASE_URL}/{sid}", {
                    "enable": "1",
                    "action": "sendSMS"
                })
                self.assertListEqual(x.json["errors"], generate_require_error_messages('enable', sid, ['event', 'eventMark', 'message', 'recipient_format']))
                x = self.put_data(f"{BASE_URL}/{sid}", {
                    "enable": "1",
                    "action": "sendSMS",
                    "recipient_format": "single"
                })
                self.assertListEqual(x.json["errors"], generate_require_error_messages('enable', sid, ['event', 'eventMark', 'message', 'telnum']))
                x = self.put_data(f"{BASE_URL}/{sid}", {
                    "enable": "1",
                    "action": "sendSMS",
                    "recipient_format": "group"
                })
                self.assertListEqual(x.json["errors"], generate_require_error_messages('enable', sid, ['event', 'eventMark', 'message', 'group']))

        with self.subTest("del section"):
            self.del_section(sid)
