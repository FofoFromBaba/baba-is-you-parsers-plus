
table.insert(editor_objlist_order, "text_event")

editor_objlist["text_event"] =
{
  name = "text_event",
  sprite_in_root = false,
  unittype = "text",
  tags = {"text","abstract"},
  tiling = -1,
  type = 0,
  layer = 20,
  colour = {5, 2},
  colour_active = {5, 3},
}

formatobjlist()

local vvvvvv = {"baba", "flag", "start", "destroy", "turn", "on", "become", "move", "tile", "event", "text",
"keke", "you", "win", "hot", "rock", "wall", "push", "stop", "melt", "water", "lava", "sink", "make", "box", "pull",
"be", "key", "door", "open", "shut", "skull", "defeat", "grass", "belt", "shift", "lonely", "power", "powered", "when", "group", "eat", "near", "never", "not",
 "backslash", "then", "forward", "backward", "aroundleft", "aroundright", "up", "down", "left", "right", "repeat", "1", "2", "3", "4", "5", "6", "7", "8", "9", "glyph"}

local fakecolors = {}
fakecolors["destroy"] = {colour = {2,1}, colour_active = {2,2}}
fakecolors["never"] = {colour = {2,1}, colour_active = {2,2}}
fakecolors["become"] = {colour = {0,2}, colour_active = {0,3}}
fakecolors["be"] = {colour = {0,2}, colour_active = {0,3}}
fakecolors["when"] = {colour = {0,2}, colour_active = {0,3}}
fakecolors["openparen"] = {colour = {0,2}, colour_active = {0,3}}
fakecolors["closeparen"] = {colour = {0,2}, colour_active = {0,3}}
fakecolors["start"] = {colour = {0,2}, colour_active = {0,3}}
fakecolors["backslash"] = {colour = {0,2}, colour_active = {0,3}}
fakecolors["then"] = {colour = {0,2}, colour_active = {0,3}}
fakecolors["repeat"] = {colour = {0,2}, colour_active = {0,3}}
fakecolors["aroundleft"] = {colour = {1,2}, colour_active = {1,4}}
fakecolors["aroundright"] = {colour = {1,2}, colour_active = {1,4}}
fakecolors["forward"] = {colour = {1,2}, colour_active = {1,4}}
fakecolors["backward"] = {colour = {1,2}, colour_active = {1,4}}
fakecolors["glyph"] = {colour = {3,2}, colour_active = {3,3}}
for i, j in ipairs(vvvvvv) do
  local eventj = "event_" .. j
  table.insert(editor_objlist_order, eventj)
  if editor_objlist_reference["text_" .. j] ~= nil then
    local eref = editor_objlist[editor_objlist_reference["text_" .. j]]
    editor_objlist[eventj] =
    {
    	name = eventj,
    	sprite_in_root = false,
    	unittype = "text",
    	tags = {"text","abstract", "events"},
    	tiling = -1,
    	type = 0,
    	layer = 20,
    	colour = eref.colour,
    	colour_active = eref.colour_active
    }
  elseif fakecolors[j] ~= nil then
    editor_objlist[eventj] =
    {
      name = eventj,
      sprite_in_root = false,
      unittype = "text",
      tags = {"text","abstract", "events"},
      tiling = -1,
      type = 0,
      layer = 20,
      colour = fakecolors[j].colour,
      colour_active = fakecolors[j].colour_active,
    }
  else
    editor_objlist[eventj] =
    {
    	name = eventj,
    	sprite_in_root = false,
    	unittype = "text",
    	tags = {"text","abstract", "events"},
    	tiling = -1,
    	type = 0,
    	layer = 1,
    	colour = {0,1},
    	colour_active = {0,2},
    }
  end
end



formatobjlist()

table.insert(mod_hook_functions.rule_baserules, function()
	addbaserule("event","is","push")
end)

formatobjlist()
