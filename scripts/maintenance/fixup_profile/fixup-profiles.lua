local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local io = _tl_compat and _tl_compat.io or io; local ipairs = _tl_compat and _tl_compat.ipairs or ipairs; local math = _tl_compat and _tl_compat.math or math; local os = _tl_compat and _tl_compat.os or os; local package = _tl_compat and _tl_compat.package or package; local pairs = _tl_compat and _tl_compat.pairs or pairs; local pcall = _tl_compat and _tl_compat.pcall or pcall; local string = _tl_compat and _tl_compat.string or string; local table = _tl_compat and _tl_compat.table or table; package.path = package.path .. ";scripts/maintenance/fixup_profile/?.lua";

local JSON = require("dlink.jansson")
local Fixer = require("fixer")

local function system(cmd)
   local pipe = io.popen(cmd)
   local ret = pipe:read("*a"):gsub("%s*$", "")

   return ret
end

function file_exists(name)
   local f = io.open(name, "r")

   if f == nil then
      return false
   end

   io.close(f)
   return true
end


local function realpath(path)
   return system("realpath " .. path)
end

local function find_sdk_root()
   local path = system("pwd")

   while path and #path > 1 do
      if file_exists(path .. "/.sdk_root") then
         return path
      end

      path = realpath(path .. '/..')
   end

   return "/"
end

local function is_regularfile(path)
   local filetype = system(string.format('stat -c "%%F" %s 2>/dev/null', path)):gsub("%s+$", "")

   return filetype == 'regular file'
end

local function parse_profile(profile)
   local map = {}

   for line in profile:gmatch("[^\n]+") do
      local key, value = line:match('^([%w_]+)=(.*)$')

      if value == 'y' then
         map[key] = true
      elseif tonumber(value) ~= nil then
         map[key] = math.tointeger(tonumber(value))
      elseif value then
         map[key] = value:match('^"([^"]+)')
      else
         key = line:match('^# ([%w_]+) is not set$')

         if key then map[key] = false end
      end
   end

   return map
end

local dofile_ok, FixerInstance = pcall(function() return dofile(arg[1]) end)
table.remove(arg, 1)

if not dofile_ok then
   print(string.format("Error loading user-provided script"))
   print(FixerInstance)
   os.exit(1)
end

local modes = {
   'dir',
   'dap',
   'firewall',
   'switch',
}

local sdk_root = find_sdk_root()

local function readfile(path)
   local file = io.open(path)
   local text = file:read('*all')
   file:close()

   return text
end

local function writefile(path, content)
   local file = io.open(path, "w")
   file:write(content)
   file:close()
end

local function update_profile(name, path, updates)
   local md5_before = system('md5sum ' .. path)

   local profile = io.open(path, "a")

   for key, value in pairs(updates) do
      local line

      if not value then
         line = string.format('# %s is not set', key)
      elseif value == true then
         line = string.format('%s=y', key)
      elseif type(value) == 'number' then
         line = string.format('%s=%d', key, value)
      else
         line = string.format('%s="%s"', key, value)
      end

      profile:write(line .. "\n")
   end

   profile:close()
   system('scripts/update_profiles.sh ' .. name)

   local md5_after = system('md5sum ' .. path)
   return md5_after ~= md5_before
end

local Color = {}










local function color(colorname, msg)
   local colors = {
      black = '\27[30m',
      red = '\27[31m',
      green = '\27[32m',
      yellow = '\27[33m',
      blue = '\27[34m',
      magenta = '\27[35m',
      cyan = '\27[36m',
      white = '\27[37m',
   }

   return string.format("%s%s\27[m", colors[colorname], msg)
end

local function log_profile(name, msg)
   print(string.format("%-35s: %s", name, msg))
end

local ls_profiles = system('find ./profiles/ -mindepth 1 -maxdepth 1 -type d | sort'):gsub('./profiles/', '')

for profile_name in ls_profiles:gmatch("[^\n]+") do

   local fixer = setmetatable({}, { __index = FixerInstance })
   local profile_path = string.format("%s/profiles/%s/%s", sdk_root, profile_name, profile_name)


   fixer.name = profile_name
   fixer.profile = parse_profile(readfile(profile_path))


   local pre_ok, pre_result_ok = fixer:try_pre()

   if not pre_ok then
      print(color('red', "Fixer:pre() raised an exception on " .. profile_name))
      print("", pre_result_ok)
   end

   if pre_ok and pre_result_ok then

      local mode_status = {}

      for _, mode in ipairs(modes) do
         local confpath = string.format('%s/profiles/%s/%s_config.default', sdk_root, profile_name, mode)


         if is_regularfile(confpath) then
            local ok, config = pcall(function() return JSON.load(readfile(confpath)) end)

            if ok then

               local reconfig_ok, err = fixer:try_reconfig(mode, config)

               if reconfig_ok then
                  local updated = JSON.load(readfile(confpath)):equal(config) == false

                  if updated then
                     table.insert(mode_status, color('green', mode))
                     writefile(confpath, config:dump({ indent = 4, sort = true }) .. "\n")
                  else
                     table.insert(mode_status, color('yellow', mode))
                  end
               else
                  print(color('red', 'reconfig error: ' .. tostring(err)))
               end
            else
               print(string.format("Cannot load defconfig '%s'", confpath))
               table.insert(mode_status, color('red', mode))
            end
         end
      end


      local reprofile_ok, updates = fixer:try_reprofile()
      local profile_updated = false

      if reprofile_ok then
         if updates then
            profile_updated = update_profile(profile_name, profile_path, updates)
            table.insert(mode_status, color(profile_updated and 'green' or 'yellow', 'PROFILE'))
         end
      else
         print(color('red', 'reprofile error: ' .. tostring(updates)))
      end

      log_profile(profile_name, table.concat(mode_status, ', '))
   else
      log_profile(profile_name, color('white', 'skipped'))
   end
end
