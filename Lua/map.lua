function revealpaths(dataid)
	local gdata = mmf.newObject(dataid)
	local world = generaldata.strings[WORLD]
	local level = generaldata.strings[CURRLEVEL]
	
	local removethesepaths = {}
	local removetheseunits = {}
	
	for i,unitid in ipairs(paths) do
		local unit = mmf.newObject(unitid)
		local x,y = unit.values[XPOS],unit.values[YPOS]
		local status = unit.values[COMPLETED]
		
		if (status > 0) and (unit.values[PATH_TARGET] == 0) then
			local newid = MF_create(unit.strings[PATH_OBJECT])
			local new = mmf.newObject(newid)
			
			new.values[ONLINE] = 1
			new.values[XPOS] = unit.values[XPOS]
			new.values[YPOS] = unit.values[YPOS]
			new.x = Xoffset + new.values[XPOS] * tilesize * spritedata.values[TILEMULT] + tilesize * 0.5 * spritedata.values[TILEMULT]
			new.y = Yoffset + new.values[YPOS] * tilesize * spritedata.values[TILEMULT] + tilesize * 0.5 * spritedata.values[TILEMULT]
			new.values[DIR] = unit.values[DIR]
			new.values[COMPLETED] = 3 - math.min(unit.values[PATH_GATE], 1) * 2
			new.strings[LEVELFILE] = ""
			
			addunit(newid)
			
			unit.values[PATH_TARGET] = newid
			
			local prizes = tonumber(MF_read("save",world .. "_prize","total")) or 0
			local clears = tonumber(MF_read("save",world .. "_clears","total")) or 0
			local bonus = tonumber(MF_read("save",world .. "_bonus","total")) or 0
			local localprizes = tonumber(MF_read("save",world .. "_prize",level)) or 0
			
			if (new.strings[UNITTYPE] == "text") or isglyph(new) then
				updatecode = 1
			end
			
			--MF_alert(tostring(prizes) .. ", " .. tostring(clears) .. ", " .. tostring(unit.values[PATH_GATE]) .. ", " .. tostring(unit.values[PATH_REQUIREMENT]))
			
			if (unit.values[PATH_GATE] == 1) and (prizes >= unit.values[PATH_REQUIREMENT]) then
				if (status < 3) then
					new.values[COMPLETED] = -2
					new.values[A] = unit.values[PATH_REQUIREMENT]
					unit.values[COMPLETED] = 3
				else
					new.values[COMPLETED] = 3
					opengate(newid)
				end
			elseif (unit.values[PATH_GATE] == 2) and (clears >= unit.values[PATH_REQUIREMENT]) then
				if (status < 3) then
					new.values[COMPLETED] = -3
					new.values[A] = unit.values[PATH_REQUIREMENT]
					unit.values[COMPLETED] = 3
				else
					new.values[COMPLETED] = 3
					opengate(newid)
				end
			elseif (unit.values[PATH_GATE] == 3) and (bonus >= unit.values[PATH_REQUIREMENT]) then
				if (status < 3) then
					new.values[COMPLETED] = -4
					new.values[A] = unit.values[PATH_REQUIREMENT]
					unit.values[COMPLETED] = 3
				else
					new.values[COMPLETED] = 3
					opengate(newid)
				end
			elseif (unit.values[PATH_GATE] == 4) and (localprizes >= unit.values[PATH_REQUIREMENT]) then
				if (status < 3) then
					new.values[COMPLETED] = -5
					new.values[A] = unit.values[PATH_REQUIREMENT]
					unit.values[COMPLETED] = 3
				else
					new.values[COMPLETED] = 3
					opengate(newid)
				end
			end
			
			if (unit.values[PATH_GATE] == 0) then
				unit.flags[DEAD] = true
				table.insert(removetheseunits, unitid)
			end
			
			local newtest = mmf.newObject(newid)
			
			if (newtest ~= nil) then
				if (generaldata.strings[WORLD] ~= generaldata.strings[BASEWORLD]) then
					local newname = getname(new)
					
					local hidethis = hasfeature(newname,"is","hide",newid,x,y)
					
					if (hidethis ~= nil) then
						new.visible = false
					end
				end
				
				if (new.values[TILING] == 1) then
					dynamic(newid)
				end
			end
			
			table.insert(removethesepaths, i)
		end
	end
	
	local roffset = 0
	
	for a,b in ipairs(removethesepaths) do
		table.remove(paths, b - roffset)
		roffset = roffset + 1
	end
	
	for a,b in ipairs(removetheseunits) do
		MF_cleanremove(b)
	end
end