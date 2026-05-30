local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local ipairs = _tl_compat and _tl_compat.ipairs or ipairs; local pcall = _tl_compat and _tl_compat.pcall or pcall; local string = _tl_compat and _tl_compat.string or string; local table = _tl_compat and _tl_compat.table or table; local JSON = require("dlink.jansson")







local Fixer = {}









































function Fixer:pre()

   return true
end

function Fixer:reconfig(_mode, _config)
end

function Fixer:reprofile()
end


function Fixer:try_pre()
   return pcall(function() return self:pre() end)
end

function Fixer:try_reconfig(mode, config)
   return pcall(function() self:reconfig(mode, config) end)
end

function Fixer:try_reprofile()
   return pcall(function() return self:reprofile() end)
end





function Fixer.remove_path(node, path)
   local KV = {}




   local subnodes = {}

   for token in path:gmatch("[^.]+") do
      table.insert(subnodes, 1, { key = token, parent = node })
      node = node:get(token)

      if not JSON.typeof(node):match('json.') then
         break
      end
   end

   for _, kv in ipairs(subnodes) do
      kv.parent:set(kv.key, nil)

      if kv.parent:size() > 0 then
         break
      end
   end
end

return Fixer
