function delunit(unitid)
	local unit = mmf.newObject(unitid)

	-- MF_alert("DELUNIT " .. unit.strings[UNITNAME])

	if (unit ~= nil) then
		local name = getname(unit)
		local x,y = unit.values[XPOS],unit.values[YPOS]
		local unitlist = unitlists[name]
		local unitlist_ = unitlists[unit.strings[UNITNAME]] or {}
		local unittype = unit.strings[UNITTYPE]

		if (unittype == "text" or unittype == "node") or (name == "glyph") then
			updatecode = 1
		end

		x = math.floor(x)
		y = math.floor(y)

		if (unitlist ~= nil) then
			for i,v in pairs(unitlist) do
				if (v == unitid) then
					v = {}
					table.remove(unitlist, i)
					break
				end
			end
		end

		if (unitlist_ ~= nil) then
			for i,v in pairs(unitlist_) do
				if (v == unitid) then
					v = {}
					table.remove(unitlist_, i)
					break
				end
			end
		end

		-- TÄMÄ EI EHKÄ TOIMI
		local tileid = x + y * roomsizex

		if (unitmap[tileid] ~= nil) then
			for i,v in pairs(unitmap[tileid]) do
				if (v == unitid) then
					v = {}
					table.remove(unitmap[tileid], i)
				end
			end

			if (#unitmap[tileid] == 0) then
				unitmap[tileid] = nil
			end
		end

		if (unittypeshere[tileid] ~= nil) then
			local uth = unittypeshere[tileid]

			local n = unit.strings[UNITNAME]

			if (uth[n] ~= nil) then
				uth[n] = uth[n] - 1

				if (uth[n] == 0) then
					uth[n] = nil
				end
			end
		end

		if ((unit.strings[UNITTYPE] == "text") or (unit.strings[UNITTYPE] == "logic")) and (codeunits ~= nil) then
			for i,v in pairs(codeunits) do
				if (v == unitid) then
					v = {}
					table.remove(codeunits, i)
				end
			end
			
			if (unit.values[TYPE] == 5) then
				for i,v in pairs(letterunits) do
					if (v == unitid) then
						v = {}
						table.remove(letterunits, i)
					end
				end
			end
		end

        if (string.sub(unit.strings[UNITNAME], 1, 6) == "glyph_") and (glyphunits ~= nil) then
			for i,v in pairs(glyphunits) do
				if (v == unitid) then
					v = {}
					table.remove(glyphunits, i)
				end
			end
        end

		if (unit.values[TILING] > 1) and (animunits ~= nil) then
			for i,v in pairs(animunits) do
				if (v == unitid) then
					v = {}
					table.remove(animunits, i)
				end
			end
		end

		if (unit.values[TILING] == 1) and (tiledunits ~= nil) then
			for i,v in pairs(tiledunits) do
				if (v == unitid) then
					v = {}
					table.remove(tiledunits, i)
				end
			end
		end

		if (#wordunits > 0) and (unit.values[TYPE] == 0) and (unit.strings[UNITTYPE] ~= "text") then
			for i,v in pairs(wordunits) do
				if (v[1] == unitid) then
					local currentundo = undobuffer[1]
					table.insert(currentundo.wordunits, unit.values[ID])
					updatecode = 1
					v = {}
					table.remove(wordunits, i)
				end
			end
		end

		if (#symbolunits > 0) and (unit.values[TYPE] == 0) and not isglyph(unit) then
			for i,v in pairs(symbolunits) do
				if (v[1] == unitid) then
					local currentundo = undobuffer[1]
					table.insert(currentundo.symbolunits, unit.values[ID])
					updatecode = 1
					v = {}
					table.remove(symbolunits, i)
				end
			end
		end

		if (#wordrelatedunits > 0) then
			for i,v in pairs(wordrelatedunits) do
				if (v[1] == unitid) then
					local currentundo = undobuffer[1]
					table.insert(currentundo.wordrelatedunits, unit.values[ID])
					updatecode = 1
					v = {}
					table.remove(wordrelatedunits, i)
				end
			end
		end

		if (#symbolrelatedunits > 0) then
			for i,v in pairs(symbolrelatedunits) do
				if (v[1] == unitid) then
					local currentundo = undobuffer[1]
					table.insert(currentundo.symbolrelatedunits, unit.values[ID])
					updatecode = 1
					v = {}
					table.remove(symbolrelatedunits, i)
				end
			end
		end

		if (#visiontargets > 0) then
			for i,v in pairs(visiontargets) do
				if (v == unitid) then
					local currentundo = undobuffer[1]
					--table.insert(currentundo.visiontargets, unit.values[ID])
					v = {}
					table.remove(visiontargets, i)
				end
			end
		end
	else
		MF_alert("delunit(): no object found with id " .. tostring(unitid) .. " (delunit)")
	end

	for i,v in ipairs(units) do
		if (v.fixed == unitid) then
			v = {}
			table.remove(units, i)
		end
	end

	for i,data in pairs(updatelist) do
		if (data[1] == unitid) and (data[2] ~= "convert") then
			data[2] = "DELETED"
		end
	end
end

function getname(unit,meta_)
	local result = unit.strings[UNITNAME]
	local meta = meta_ or false

	if (meta == false) and string.sub(result, 1, 6) == "event_" then
		return "event"
	end

	if (meta == false) and (unit.strings[UNITTYPE] == "text") then
		result = "text"
	end

        if (meta == false) and (unit.strings[UNITTYPE] == "node") then
		result = "node"
	end

	if (meta == false) and (string.sub(result, 1, 6) == "glyph_") then
		result = "glyph"
	end
	
	if (meta == false) and (unit.strings[UNITTYPE] == "logic") then
		result = "logic"
	end

	if (meta == false) and (unit.strings[UNITTYPE] == "obj") then
		result = "obj"
	end

	return result
end

function findtype(typedata,x,y,unitid_,just_testing_)
	local result = {}
	local unitid = 0
	local tileid = x + y * roomsizex
	local name = typedata[1]
	local conds = typedata[2]

	local just_testing = just_testing_ or false

	if (unitid_ ~= nil) then
		unitid = unitid_
	end

	if (unitmap[tileid] ~= nil) then
		for i,v in ipairs(unitmap[tileid]) do
			if (v ~= unitid) then
				local unit = mmf.newObject(v)

				if (unit.strings[UNITNAME] == name) or ((unit.strings[UNITTYPE] == "text") and (name == "text")) or ((unit.strings[UNITTYPE] == "node") and (name == "node")) or (isglyph(unit) and (name == "glyph")) or (string.sub(unit.strings[UNITNAME], 1, 6) == "event_" and (name == "event")) then
					if testcond(conds,v) then
						table.insert(result, v)

						if just_testing then
							return result
						end
					end
				end
			end
		end
	end

	return result
end

function update(unitid,x,y,dir_)
	if (unitid ~= nil) then
		local unit = mmf.newObject(unitid)

		local unitname = unit.strings[UNITNAME]
		local dir,olddir = unit.values[DIR],unit.values[DIR]
		local tiling = unit.values[TILING]
		local unittype = unit.strings[UNITTYPE]
		local oldx,oldy = unit.values[XPOS],unit.values[YPOS]

		if (dir_ ~= nil) then
			dir = dir_
		end

		if (x ~= oldx) or (y ~= oldy) or (dir ~= olddir) then
			updateundo = true

			addundo({"update",unitname,oldx,oldy,olddir,x,y,dir,unit.values[ID]},unitid)

			local ox,oy = x-oldx,y-oldy

			if (math.abs(ox) + math.abs(oy) == 1) and (unit.values[MOVED] == 0) then
				unit.x = unit.x + ox * tilesize * spritedata.values[TILEMULT] * generaldata2.values[ZOOM] * 0.25
				unit.y = unit.y + oy * tilesize * spritedata.values[TILEMULT] * generaldata2.values[ZOOM] * 0.25
			end

			unit.values[XPOS] = x
			unit.values[YPOS] = y
			unit.values[DIR] = dir
			unit.values[MOVED] = 1
			unit.values[POSITIONING] = 0

			updateunitmap(unitid,oldx,oldy,x,y,unit.strings[UNITNAME])

			if (tiling == 1) then
				dynamic(unitid)
				dynamicat(oldx,oldy)
			end

			if (unittype == "text") or isglyph(unit) or (unittype == "node") or (unittype == "logic") then
				updatecode = 1
			end

			if (featureindex["word"] ~= nil or featureindex["break"] ~= nil) then
				checkwordchanges(unitid,unitname)
			end
			if (featureindex["symbol"] ~= nil) then
				checksymbolchanges(unitid,unitname)
			end
		end

	else
		MF_alert("Tried to update a nil unit")
	end
end

function updatedir(unitid,dir,noundo_)
	if (unitid ~= nil) then
		local unit = mmf.newObject(unitid)
		local x,y = unit.values[XPOS],unit.values[YPOS]
		local unitname = unit.strings[UNITNAME]
		local unittype = unit.strings[UNITTYPE]
		local olddir = unit.values[DIR]

		local noundo = noundo_ or false

		if (dir ~= olddir) then
			if (noundo == false) then
				updateundo = true
				addundo({"update",unitname,x,y,olddir,x,y,dir,unit.values[ID]},unitid)
			end
			unit.values[DIR] = dir

			if (unittype == "text") or isglyph(unit) or (unittype == "node") or (unittype == "logic") then
				updatecode = 1
			end
		end
	else
		MF_alert("Tried to updatedir a nil unit")
	end
end

function findall(name_,ignorebroken_,just_testing_)
	local result = {}
	local name = name_[1]
	local meta = true

	local checklist = unitlists[name]

	if (name == "text") then
		checklist = codeunits
		meta = false
	elseif (name == "obj") then
		meta = false
	elseif (name == "glyph") then
		checklist = glyphunits
		meta = false
	elseif (name == "node") then
        	checklist = {}
        	meta = false
        	for name, list in pairs(unitlists) do
           	 if (string.sub(name, 1, 5) == "node_") then
             	   for i, unitid in ipairs(list) do
              	      table.insert(checklist, unitid)
           	     end
         	   end
        	end
    	elseif (name == "event") then
		local q = {}
		for i, j in ipairs(codeunits) do
			local unit = mmf.newObject(j)
			if getname(unit) == "event" then
				table.insert(q, j)
			end
		end
		checklist = q
		meta = false
	elseif (name == "logic") then
		checklist = codeunits
		meta = false
	end

	local ignorebroken = ignorebroken_ or false
	local just_testing = just_testing_ or false

	if (checklist ~= nil) then
		for i,unitid in ipairs(checklist) do
			local unit = mmf.newObject(unitid)
			local unitname = getname(unit,meta)

			local oldbroken = unit.broken
			if ignorebroken then
				unit.broken = 0
			end

			if (unitname == name)  then
				if testcond(name_[2],unitid) then
					table.insert(result, unitid)

					if just_testing then
						return result
					end
				end
			end

			unit.broken = oldbroken
		end
	end

	return result
end

function inside(name,x,y,dir_,unitid,leveldata_)
	local ins = {}
	local tileid = x + y * roomsizex
	local maptile = unitmap[tileid] or {}
	local dir = dir_

	local leveldata = leveldata_ or {}

	if (dir == 4) then
		dir = fixedrandom(0,3)
	end

	if (featureindex[name] ~= nil) then
		for i,rule in ipairs(featureindex[name]) do
			local baserule = rule[1]
			local conds = rule[2]

			local target = baserule[1]
			local verb = baserule[2]
			local object = baserule[3]

			if (target == name) and (verb == "has") and (findnoun(object,nlist.short) or (unitreference[object] ~= nil) or getmat_text(object)) then
				table.insert(ins, {object,conds})
			end
		end
	end

	if (#ins > 0) then
		for i,v in ipairs(ins) do
			local object = v[1]
			local conds = v[2]
			if testcond(conds,unitid,x,y) then
				if (object ~= "text") and (object ~= "glyph") and (object ~= "event") and (object ~= "node") and (string.sub(object,1,5) ~= "text_") then
					for a,mat in pairs(objectlist) do
						if (a == object) and (object ~= "empty") then
							if (object ~= "all") and (object ~= "logic") and (object ~= "obj") and (string.sub(object, 1, 5) ~= "group") then
								create(object,x,y,dir,nil,nil,nil,nil,leveldata)
							elseif (object == "logic") and getmat("logic_" .. name) ~= nil then
								create("logic_" .. name,x,y,dir,nil,nil,nil,nil,leveldata)
							elseif (object == "all") then
								createall(v,x,y,unitid,nil,leveldata)
							elseif (object == "obj") then
								if getmat_text("obj_" .. uname) then
									create("obj_" .. uname,x,y,dir,nil,nil,nil,nil,leveldata)
								elseif getmat_text("obj_obj") then
									create("obj_obj",x,y,dir,nil,nil,nil,nil,leveldata)
								end
							end
						end
					end
				elseif (string.sub(object,1,5) == "text_") then
					create(object,x,y,dir,nil,nil,nil,nil,leveldata)
				elseif (object == "text") or (object == "event") or (object == "node") or (object == "glyph") then
					create(object .. "_" .. name,x,y,dir,nil,nil,nil,nil,leveldata)
				end
			end
		end
	end
end


function cantmove(name,unitid,dir,x,y)
	local still = hasfeature(name,"is","still",unitid,x,y)

	if (still ~= nil) then
		return true
	end

	if (dir ~= nil) then
		local opts = {"lockedright","lockedup","lockedleft","lockeddown"}
		local checkdir = dir
		if (featureindex["reverse"] ~= nil) then
			checkdir = reversecheck(unitid,dir,x,y)
		end
		local opt = opts[checkdir+1]

		if (opt ~= nil) then
			still = hasfeature(name,"is",opt,unitid,x,y)

			if (still ~= nil) then
				return true
			end

      if unitid ~= 1 and unitid ~= 2 then
        local unit = mmf.newObject(unitid)
        local customdirprop = ""
        if unit.values[DIR] == checkdir then
          customdirprop = "forward"
        end
        if unit.values[DIR] == (checkdir + 1) % 4 then
          customdirprop = "aroundleft"
        end
        if unit.values[DIR] == (checkdir + 2) % 4 then
          customdirprop = "backward"
        end
        if unit.values[DIR] == (checkdir + 3) % 4 then
          customdirprop = "aroundright"
        end
        still = hasfeature(name,"is","locked" .. customdirprop,unitid,x,y)
        if still ~= nil then
          return true
        end
      end
		end
	end

	if (unitid ~= 2) and (unitid ~= 1) and (featureindex["grab"] ~= nil) then
		local unit = mmf.newObject(unitid)

		if (unit.grabbed ~= nil) and (unit.grabbed ~= 0) then
			return true
		end
	end

	return false
end

function findnoun(noun_,list_)
	local noun = noun_ or ""
	if string.sub(noun, 1, 6) == "event_" then
		noun = "event"
	end
	local list = list_ or nlist.full

	for i,v in ipairs(list) do
		if (v == noun) or ((v == "group") and (string.sub(noun, 1, 5) == "group")) or ((v == "node") and (string.sub(noun, 1, 5) == "node_")) or ((v == "glyph") and (string.sub(noun, 1, 6) == "glyph_")) or ((v == "logic") and (string.sub(noun, 1, 6) == "logic_")) or ((v == "obj") and (string.sub(noun, 1, 4) == "obj_")) then
			return true
		end
	end

	return false
end

function checkwordchanges(unitid,unitname)
	if (#wordunits > 0) then
		for i,v in ipairs(wordunits) do
			if (v[1] == unitid) then
				updatecode = 1
				return
			end
		end
	end
	
	if (#wordrelatedunits > 0) then
		for i,v in ipairs(wordrelatedunits) do
			if (v[1] == unitid) then
				updatecode = 1
				return
			end
		end
	end

	if (#breakunits > 0) then
		for i,v in ipairs(breakunits) do
			if (v[1] == unitid) then
				updatecode = 1
				return
			end
		end
	end
	
	if (#breakrelatedunits > 0) then
		for i,v in ipairs(breakrelatedunits) do
			if (v[1] == unitid) then
				updatecode = 1
				return
			end
		end
	end
end