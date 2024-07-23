local orbers = {"orb", "baba", "keke", "wall", "text", "rock", "flag", "tile"}

for i, j in ipairs(orbers) do

	table.insert(editor_objlist_order,"orb_" .. j)

	editor_objlist["orb_" .. j] =
	{
	 	name = "orb_" .. j,
	 	sprite_in_root = false,
	 	unittype = "text",
	 	tags = {"text"},
	 	tiling = -1,
	 	type = -7,
	 	layer = 20,
	 	colour = {4, 0},
	  colour_active = {4, 1}
	}

end

formatobjlist()

function dorb()
	for i, j in ipairs(codeunits) do
		local unit = mmf.newObject(j)
		local x,y = unit.values[XPOS],unit.values[YPOS]
		local name = unit.strings[UNITNAME]

		local ids = {}
		table.insert(ids, {j})

		if string.sub(name, 1, 4) == "orb_" and name ~= "orb_orb" then
			local orbcode = ""
			for ox = -1, 1 do
				for oy = -1, 1 do
					if not (ox == 0 and oy == 0) then
						local here = findallhere(x + ox, y + oy)
						local orbhere = false
						for k, l in ipairs(here) do
							local lunit = mmf.newObject(l)
							if lunit ~= nil and lunit.strings[UNITNAME] == "orb_orb" then
								orbcode = orbcode .. "1"
								orbhere = true
								table.insert(ids, {l})
								break
							end
						end
						if not orbhere then
							orbcode = orbcode .. "0"
						end
					end
				end
			end
			local orbname = string.sub(name, 5)

			if orbcode == "01011010" then
				addoption({orbname, "is", "you"}, {}, ids, true)
			end

			if orbcode == "00111010" then
				addoption({orbname, "is", "win"}, {}, ids, true)
			end

			if orbcode == "10100101" then
				addoption({orbname, "is", "stop"}, {}, ids, true)
			end

			if orbcode == "11100000" then
				addoption({orbname, "is", "push"}, {}, ids, true)
			end

			if orbcode == "11100010" then
				addoption({orbname, "is", "move"}, {}, ids, true)
			end

			if orbcode == "11111111" then
				addoption({orbname, "is", "sink"}, {}, ids, true)
			end

			if orbcode == "10111101" then
				addoption({orbname, "is", "defeat"}, {}, ids, true)
			end

			--not inthe original mod
			if orbcode == "10001100" then
				addoption({orbname, "is", "propertythatactuallydoesnothingandhasnocode"}, {}, ids, false)
			end
		end
	end
end

function reversecheck(unitid,dir,x,y,ox_,oy_)
	local result = dir
	local name = ""
	local ox = ox_ or 0
	local oy = oy_ or 0
	
	if (unitid ~= 2) and (unitid ~= 1) then
		local unit = mmf.newObject(unitid)
		name = getname(unit)
	elseif (unitid == 2) then
		name = "empty"
	elseif (unitid == 1) then
		name = "level"
	end
	
	if (hasfeature_count(name,"is","reverse",unitid,x,y) % 2 == 1) or string.sub(name, 1, 4) == "orb_" then
		result = reversedir(dir)
		
		if (ox ~= 0) or (oy ~= 0) then
			ox = 0 - ox_
			oy = 0 - oy_
		end
	end
	
	return result,ox,oy
end