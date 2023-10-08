#!/bin/sh

. /lib/functions.sh

set_rules() {
  if [ $(uci -q get rpcd.${1}.group) = "$2" ]; then
    $(uci -q delete rpcd.${1}.read)
    $(uci -q delete rpcd.${1}.write)

    for rule in $3; do
      rule=$(echo "$rule" | tr + \*)
      $(uci -q add_list rpcd.${1}.read=${rule})
    done
    for rule in $4; do
      rule=$(echo "$rule" | tr + \*)
      $(uci -q add_list rpcd.${1}.write=${rule})
    done
  fi
}

parse_rules() {
  local tmp_rules=""
  for rule in $@; do
    if [ "$rule" != "+" ]; then
      tmp_rules="${tmp_rules} ${rule}+"
    else
      tmp_rules="${tmp_rules} ${rule}"
    fi
  done
  echo $tmp_rules
}

group="$1"

if [ "$group" = "admin" -o "$group" = "user" ]; then
  read_rules=$(parse_rules $(uci -q get rpcd.${group}.read | tr \* +))
  read_access=$(uci -q get rpcd.${group}.target_read)
  write_rules=$(parse_rules $(uci -q get rpcd.${group}.write | tr \* +))
  write_access=$(uci -q get rpcd.${group}.target_write)

  parsed_read_rules=""
  parsed_write_rules=""

  read_all="0"
  write_all="0"

  for rule in $read_rules; do
    if [ "$read_access" = "deny" ]; then
      parsed_read_rules="${parsed_read_rules} !${rule}"
    elif [ "$read_access" = "allow" ]; then
      parsed_read_rules="${parsed_read_rules} ${rule}"
    fi
    [ "$rule" = "+" ] && read_all="1"
  done

  if [ "$read_access" = "deny" ]; then
    parsed_read_rules="${parsed_read_rules} !superuser +"
  elif [ "$read_access" = "allow" ]; then
    parsed_read_rules="${parsed_read_rules} !superuser core"
  fi

  if [ "$read_all" -eq "1" ]; then
    [ "$read_access" = "allow" ] && parsed_read_rules="!superuser +"
    [ "$read_access" = "deny" ] && parsed_read_rules="!superuser core"
  fi

  for rule in $write_rules; do
    if [ "$write_access" = "deny" ]; then
      parsed_write_rules="${parsed_write_rules} !${rule}"
    elif [ "$write_access" = "allow" ]; then
      parsed_write_rules="${parsed_write_rules} ${rule}"
    fi
    [ "$rule" = "+" ] && write_all="1"
  done

  if [ "$read_all" -eq "1" ] && [ "$write_all" -eq "1" ]; then
    if [ "$read_access" = "deny" ] || [ "$write_access" = "deny" ]; then
      parsed_write_rules="!superuser core"
    else
      parsed_write_rules="!superuser +"
    fi
  elif [ "$read_all" -eq "1" ]; then
    if [ "$read_access" = "deny" ] && [ "$write_access" = "deny" ]; then
      parsed_write_rules="!superuser core"
    elif [ "$read_access" = "deny" ] || [ "$write_access" = "allow" ]; then
      parsed_write_rules="${parsed_write_rules} !superuser core"
    else
      parsed_write_rules="${parsed_write_rules} !superuser +"
    fi
  elif [ "$write_all" -eq "1" ]; then
    if [ "$write_access" = "deny" ]; then
      parsed_write_rules="!superuser core"
    else
      parsed_write_rules="$parsed_read_rules"
    fi
  else
    if [ "$write_access" = "deny" ]; then
      for rule in $read_rules; do
        [ "$read_access" = "allow" ] && parsed_write_rules="${parsed_write_rules} ${rule}"
        [ "$read_access" = "deny" ] && parsed_write_rules="${parsed_write_rules} !${rule}"
      done
    fi

    if [ "$read_access" = "deny" ] && [ "$write_access" = "deny" ]; then
      parsed_write_rules="${parsed_write_rules} !superuser +"
    else
      parsed_write_rules="${parsed_write_rules} !superuser core"
    fi
  fi

  config_load rpcd
  config_foreach set_rules login "$group" "${parsed_read_rules}" "${parsed_write_rules}"
  uci commit rpcd
fi
