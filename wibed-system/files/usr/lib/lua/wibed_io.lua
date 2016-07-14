#!/usr/bin/lua

local nixiofs = require("nixio.fs")

local wibed_io = wibed_io or {}

-- Local functions declaration
local ls
local is_file



-- Check if a file exists
function is_file (filename)
  return nixiofs.stat(filename, 'type') == 'reg'
end



-- Create a new (empty) file
function new_file (filename)
  nixiofs.writefile(filename, '')
  return is_file(filename)
end


-- List a directory
function ls (dirname)

  local dircontent = {}

  local i, t, popen = 0, {}, io.popen

  for filename in popen('ls "'..dirname..'"'):lines() do
    table.insert(dircontent, filename)
  end

  return dircontent

end





wibed_io.is_file = is_file
wibed_io.new_file = new_file
wibed_io.ls = ls


return wibed_io