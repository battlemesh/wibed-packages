#!/usr/bin/lua

local KERNEL_HOSTNAME = "/proc/sys/kernel/hostname"
local OPENWRT_CONFIG_SYSTEM_FILENAME = "system"
local WIBED_CONFIG_FILENAME = "wibed"

local io = require("io")
local ubus = require("ubus")
local uci = require("uci")

--[[
local wibed_network  = wibed_network  or require("wibed_network")
local wibed_uci      = wibed_uci      or require("wibed_uci")
]]--

local wibed_system = wibed_system or {}

-- Local functions declaration
local get_hostname
local set_hostname


-- Get the device hostname
function get_hostname()

	local hostname = nil

  -- First try retrieving it from Ubus
	local conn = ubus.connect()
	if conn then
		local status = conn:call("system", "board", {})
		for k, v in pairs(status) do
			if k == "hostname" then
				hostname = v
			end
		end
		conn:close()
		return hostname
	end

  -- Try UCI otherwise
	local cursor = uci.cursor()
	cursor:foreach("system", "system", function(s)
			hostname = cursor:get("system", s[".name"], "hostname")
			if hostname ~= nil then
				return
			end
		end)
	return hostname

end




-- Set the device hostname
function set_hostname(hostname)

  -- Check for appropriate type and length
	if type(hostname) == "string" then
	  if string.len(hostname) > 0 and string.len(hostname) < 254 then

      -- Check for valid characters (a-Z, 0-9, dot, hyphen and underscore)
      if hostname == string.match(hostname,'[a-zA-Z0-9_.-]*') then

        -- Check that there are no leading nor trailing dots, hyphens or underscores
        if string.sub(hostname,1,1) == string.match(string.sub(hostname,1,1),'[a-zA-Z0-9]*') and string.sub(hostname,-1,-1) == string.match(string.sub(hostname,-1,-1),'[a-zA-Z0-9]*') then

          -- Update system config
          wibed_uci.set_option_nonamesec(OPENWRT_CONFIG_SYSTEM_FILENAME, "system", 0, "hostname", hostname)

          -- Update kernel
          local file = io.open(KERNEL_HOSTNAME, "w+")
          if file then
            file:write(hostname)
            file:close()
          end
        end
	    end
	  end
	end

	return

end



wibed_system.get_hostname = get_hostname
wibed_system.set_hostname = set_hostname

return wibed_system
