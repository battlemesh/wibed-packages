#!/usr/bin/lua

local PATH_SYS_CLAS_80211 = "/sys/class/ieee80211/"

local WIBED_CONFIG_FILENAME = "wibed"

local luci_sys     = require("luci.sys")


local wibed_io       = wibed_io       or require("wibed_io")
local wibed_network  = wibed_network  or require("wibed_network")
local wibed_tools    = wibed_tools    or require("wibed_tools")


local wibed_wireless = wibed_wireless or {}

local get_device_mac
local get_radio_iwinfo
local get_radio_phy
local get_radios_band
local get_radios_band_2g
local get_radios_band_2g_only
local get_radios_band_5g
local get_radios_band_5g_only
local get_radios_band_dual
local get_wireless_phy_devices
local get_wireless_radio_devices
local initial_setup
local is_phy_device
local is_radio_device
local is_radio_band
local is_radio_band_2g
local is_radio_band_2g_only
local is_radio_band_5g
local is_radio_band_5g_only
local is_radio_band_dual



-- Get the MAC address (lowercase) of a wireless device
local function get_device_mac(wdev)

  -- Check if the device is a radio wireless device and get its phy
  if is_radio_device(wdev) then
    wdev = get_radio_phy(wdev)
  end

  -- Check if the device is a phy wireless device
  if is_phy_device(wdev) then
    local f = io.open(PATH_SYS_CLAS_80211 .. wdev .. "/macaddress")
    if f then
      -- read the MAC address (17 characters: 12 MAC + 5 colons)
      local mac = f:read(17)
      f:close()
      if wibed_network.is_valid_mac(mac) then
        return string.lower(mac)
      end
    end
  end

  return nil
end


-- Get the device iwinfo object instance of a radio device
function get_radio_iwinfo(radiodev)

    if is_radio_device(radiodev) then
    return luci_sys.wifi.getiwinfo(radiodev)
  end

  return nil
end


-- Get the corresponding phy device of a radio device
function get_radio_phy(radiodev)

  if is_radio_device(radiodev) then
    local number = string.match(radiodev, "%d+")
    return ("phy" .. number)
  end

  return nil
end


-- Get an array with the radios capable of the given band
function get_radios_band(band)

  if band == "2g" then
    return get_radios_band_2g()
  elseif band == "5g" then
    return get_radios_band_5g()
  elseif band == "2g_only" then
    return get_radios_band_2g_only()
  elseif band == "5g_only" then
    return get_radios_band_5g_only()
  elseif band == "dual" then
    return get_radios_band_dual()
  end

  return {}
end


-- Get an array with the 2.4 GHz capable radios
function get_radios_band_2g()

  local radios = {}

  for k,v in pairs(get_wireless_radio_devices()) do
    if is_radio_band_2g(v) then
      table.insert(radios, v)
    end
  end

  return radios
end

-- Get an array with the 2.4 GHz only radios
function get_radios_band_2g_only()

  local radios = {}

  for k,v in pairs(get_wireless_radio_devices()) do
    if is_radio_band_2g_only(v) then
      table.insert(radios, v)
    end
  end

  return radios
end

-- Get an array with the 5 GHz capable radios
function get_radios_band_5g()

  local radios = {}

  for k,v in pairs(get_wireless_radio_devices()) do
    if is_radio_band_5g(v) then
      table.insert(radios, v)
    end
  end
  return radios
end


-- Get an array with the 5 GHz capable radios
function get_radios_band_5g_only()

  local radios = {}

  for k,v in pairs(get_wireless_radio_devices()) do
    if is_radio_band_5g_only(v) then
      table.insert(radios, v)
    end
  end
  return radios
end

-- Get an array with the dual-band capable radios
function get_radios_band_dual()

  local radios = {}

  for k,v in pairs(get_wireless_radio_devices()) do
    if is_radio_band_dual(v) then
      table.insert(radios, v)
    end
  end

  return radios
end


-- Check if the device is a phy device
function is_phy_device(device)
  return wibed_tools.is_item_in_array(device, get_wireless_phy_devices())
end


-- Check if a radio device can operate on the given band
function is_radio_band(radiodev, band)

  if is_radio_device(radiodev) then
    if band == "2g" then
      return is_radio_band_2g(radiodev)
    elseif band == "5g" then
      return is_radio_band_5g(radiodev)
    elseif band == "dual" then
      return is_radio_band_dual(radiodev)
    end
  end
  return nil
end


-- Check if a radio device can operate on the 2.4 GHz band
function is_radio_band_2g(radiodev)

  if is_radio_device(radiodev) then
    local iw = get_radio_iwinfo(radiodev)
    for k, v in pairs(iw.hwmodelist) do
      if (k == "b" or k == "g") and v == true then
        return true
      end
    end

    return false
  end
  return nil
end

-- Check if a radio device operates *only* on the 2.4 GHz band
function is_radio_band_2g_only(radiodev)

  if is_radio_device(radiodev) then
    if is_radio_band_2g and not is_radio_band_5g then
      return true
    end
    return false
  end
  return nil
end

-- Check if a radio device operates *only* on the 2.4 GHz band
function is_radio_band_5g_only(radiodev)

  if is_radio_device(radiodev) then
    if is_radio_band_5g and not is_radio_band_2g then
      return true
    end
    return false
  end
  return nil
end

-- Check if a radio device can operate on the 5 GHz band
function is_radio_band_5g(radiodev)

  if is_radio_device(radiodev) then
    local iw = get_radio_iwinfo(radiodev)
    for k, v in pairs(iw.hwmodelist) do
      if (k == "a" or k == "ac") and v == true then
        return true
      end
    end

    return false
  end
  return nil
end


-- Check if a radio device can operate on the 5 GHz band
function is_radio_band_dual(radiodev)

  if is_radio_device(radiodev) then
    if is_radio_band_2g(radiodev) and is_radio_band_5g(radiodev) then
      return true
    else
      return false
    end
  else
    return false
  end

  return nil
end




-- Check if the device is a radio device
function is_radio_device(device)
  return wibed_tools.is_item_in_array(device, get_wireless_radio_devices())
end



-- Get a sorted array with the wireless (IEEE 802.11) physical devices (e.g. phy0, phy1, phy2)
function get_wireless_phy_devices()
  local pdevices = {}

  for k, v in pairs(wibed_io.ls(PATH_SYS_CLAS_80211)) do
    table.insert(pdevices, v)
  end

  table.sort(pdevices)

  return pdevices
end



-- Get a sorted array with the wireless (IEEE 802.11) radio devices (e.g. radio0, radio1, radio2)
function get_wireless_radio_devices()

  local rdevices = {}

	local conn = ubus.connect()
	if conn then
		local status = conn:call("network.wireless", "status", {})

    -- Check all the devices returned by the Ubus call
		for k, v in pairs(status) do
      table.insert(rdevices, k)
    end

		conn:close()
	end

  table.sort(rdevices)
  return rdevices

end



wibed_wireless.get_device_mac = get_device_mac
wibed_wireless.get_radio_iwinfo = get_radio_iwinfo
wibed_wireless.get_radio_phy = get_radio_phy
wibed_wireless.get_radios_band = get_radios_band
wibed_wireless.get_radios_band_2g = get_radios_band_2g
wibed_wireless.get_radios_band_2g_only = get_radios_band_2g_only
wibed_wireless.get_radios_band_5g = get_radios_band_5g
wibed_wireless.get_radios_band_5g_only = get_radios_band_5g_only
wibed_wireless.get_radios_band_dual = get_radios_band_dual
wibed_wireless.get_wireless_radio_devices = get_wireless_radio_devices
wibed_wireless.get_wireless_phy_devices = get_wireless_phy_devices
wibed_wireless.initial_setup = initial_setup
wibed_wireless.is_phy_device = is_phy_device
wibed_wireless.is_radio_device = is_radio_device
wibed_wireless.is_radio_band = is_radio_band
wibed_wireless.is_radio_band_2g = is_radio_band_2g
wibed_wireless.is_radio_band_2g_only = is_radio_band_2g_only
wibed_wireless.is_radio_band_5g = is_radio_band_5g
wibed_wireless.is_radio_band_5g_only = is_radio_band_5g_only
wibed_wireless.is_radio_band_dual = is_radio_band_dual

return wibed_wireless
