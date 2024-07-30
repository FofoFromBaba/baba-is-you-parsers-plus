function addunit(id,undoing_,levelstart_)
	local unitid = #units + 1

	units[unitid] = {}
	units[unitid] = mmf.newObject(id)

	local unit = units[unitid]
	local undoing = undoing_ or false
	local levelstart = levelstart_ or false

	getmetadata(unit)

	local truename = unit.className

	if (changes[truename] ~= nil) then
		dochanges(id)
	end

	if (unit.values[ID] == -1) then
		unit.values[ID] = newid()
	end

	if (unit.values[XPOS] > 0) and (unit.values[YPOS] > 0) then
		addunitmap(id,unit.values[XPOS],unit.values[YPOS],unit.strings[UNITNAME])
	end

	if (unit.values[TILING] == 1) then
		table.insert(tiledunits, unit.fixed)
	end

	if (unit.values[TILING] > 1) then
		table.insert(animunits, unit.fixed)
	end

	local name = getname(unit)
	local name_ = unit.strings[NAME]
	local name__ = unit.strings[UNITNAME]
	unit.originalname = unit.strings[UNITNAME]

	if (unitlists[name] == nil) then
		unitlists[name] = {}
	end

	if (string.sub(name_, 1, 5) == "text_" or string.sub(name_, 1, 5) == "node_") or (string.sub(name_, 1, 6) == "logic_") then
		unit.flags[META] = true
	end

	table.insert(unitlists[name], unit.fixed)

	if (name ~= name__) then
		if (unitlists[name__] == nil) then
			unitlists[name__] = {}
		end
		table.insert(unitlists[name__], unit.fixed)
	end

	if (unit.strings[UNITTYPE] ~= "text" and unit.strings[UNITTYPE] ~= "node") or ((unit.strings[UNITTYPE] == "text") and (unit.values[TYPE] == 0)) or ((unit.strings[UNITTYPE] == "node") and node_types[string.sub(unit.strings[UNITNAME], 6, -1)] == 0) then
		objectlist[name_] = 1
	end

	local validglyph = false
	if isnoun(name__) then
		validglyph = true
	end
	if (string.sub(name__, 1, 6) == "glyph_") and validglyph then
		objectlist[string.sub(name__, 7)] = 1
	end

	if (string.sub(name__, 1, 6) == "event_" and event_text_types[string.sub(name__, 7)] == "noun") then
		objectlist[string.sub(name__, 7)] = 1
	end

	if (unit.strings[UNITTYPE] == "text") or (unit.strings[UNITTYPE] == "logic") then
		table.insert(codeunits, unit.fixed)
		updatecode = 1
		
		if (unit.values[TYPE] == 0) or string.sub(name_,1,6) == "logic_" then 
			local matname = string.sub(unit.strings[UNITNAME], 6)
			if unit.strings[UNITTYPE] == "logic" then
				matname = string.sub(unit.strings[UNITNAME], 7)
			end
			if (unitlists[matname] == nil) then
				unitlists[matname] = {}
			end
		elseif (unit.values[TYPE] == 5) then
			table.insert(letterunits, unit.fixed)
		end
	end

    if (string.sub(name__, 1, 6) == "glyph_") then
		table.insert(glyphunits, unit.fixed)
		local matname = string.sub(unit.strings[UNITNAME], 7)
			if (unitlists[matname] == nil) then
				unitlists[matname] = {}
			end
        updatecode = 1
	end

	unit.colour = {}

	if (unit.strings[UNITNAME] ~= "level") and (unit.className ~= "specialobject") then
		local cc1,cc2 = setcolour(unit.fixed)
		unit.colour = {cc1,cc2}
	end

	unit.back_init = 0
	unit.broken = 0

	if (unit.className ~= "path") and (unit.className ~= "specialobject") then
		statusblock({id},undoing)
		MF_animframe(id,math.random(0,2))
	end

	unit.active = false
	unit.new = true
	unit.colours = {}
	unit.currcolour = 0
	unit.followed = -1
	unit.holder = 0
	unit.xpos = unit.values[XPOS]
	unit.ypos = unit.values[YPOS]

	if (spritedata.values[VISION] == 1) and (undoing == false) then
		local hasvision = hasfeature(name,"is","3d",id,unit.values[XPOS],unit.values[YPOS])
		if (hasvision ~= nil) then
			table.insert(visiontargets, id)
		elseif (spritedata.values[CAMTARGET] == unit.values[ID]) then
			visionmode(0,0,nil,{unit.values[XPOS],unit.values[YPOS],unit.values[DIR]})
		end
	end

	if (spritedata.values[VISION] == 1) and (spritedata.values[CAMTARGET] ~= unit.values[ID]) then
		if (unit.values[ZLAYER] <= 15) then
			if (unit.values[ZLAYER] > 10) then
				setupvision_wall(unit.fixed)
			end

			MF_setupvision_single(unit.fixed)
		end
	end

	if generaldata.flags[LOGGING] and (generaldata.flags[RESTARTED] == false) then
		if levelstart then
			dolog("init_object","event",unit.strings[UNITNAME] .. ":" .. tostring(unit.values[XPOS]) .. ":" .. tostring(unit.values[YPOS]))
		elseif (undoing == false) then
			dolog("new_object","event",unit.strings[UNITNAME] .. ":" .. tostring(unit.values[XPOS]) .. ":" .. tostring(unit.values[YPOS]))
		end
	end
end

function createall(matdata,x_,y_,id_,dolevels_,leveldata_)
	local all = {}
	local empty = false
	local dolevels = dolevels_ or false

	local leveldata = leveldata_ or {}

	if (x_ == nil) and (y_ == nil) and (id_ == nil) then
		if (matdata[1] ~= "empty") and (findnoun(matdata[1],nlist.brief) == false) then
			all = findall(matdata)
		elseif (matdata[1] == "empty") then
			all = findempty(matdata[2])
			empty = true
		end
	end
	local test = {}

	if (x_ ~= nil) and (y_ ~= nil) and (id_ ~= nil) then
		local check = findtype(matdata,x_,y_,id_)

		if (#check > 0) then
			for i,v in ipairs(check) do
				if (v ~= 0) then
					table.insert(test, v)
				end
			end
		end
	end

	if (#all > 0) then
		for i,v in ipairs(all) do
			table.insert(test, v)
		end
	end

	if (dolevels == false) then
		local delthese = {}

		if (#test > 0) then
			for i,v in ipairs(test) do
				if (empty == false) then
					local vunit = mmf.newObject(v)
					local x,y,dir = vunit.values[XPOS],vunit.values[YPOS],vunit.values[DIR]

					if (vunit.flags[CONVERTED] == false) then
						for b,unit in pairs(objectlist) do
							if (findnoun(b) == false) and (b ~= matdata[1]) then
								local protect = hasfeature(matdata[1],"is","not " .. b,v,x,y)

								if (protect == nil) then
									local mat = findtype({b},x,y,v)
									--local tmat = findtext(x,y)

									if (#mat == 0) then
										local nunitid,ningameid = create(b,x,y,dir,nil,nil,nil,nil,leveldata)
										addundo({"convert",matdata[1],mat,ningameid,vunit.values[ID],x,y,dir})

										if (matdata[1] == "text") or (matdata[1] == "level") or (matdata[1] == "glyph") then
											table.insert(delthese, v)
										end
									end
								end
							end
						end
					end
				else
					local x = v % roomsizex
					local y = math.floor(v / roomsizex)
					local dir = emptydir(x,y)

					if (dir == 4) then
						dir = fixedrandom(0,3)
					end

					local blocked = {}

					local valid = true
					if (emptydata[v] ~= nil) then
						if (emptydata[v]["conv"] ~= nil) and emptydata[v]["conv"] then
							valid = false
						end
					end

					if valid then
						if (featureindex["empty"] ~= nil) then
							for i,rules in ipairs(featureindex["empty"]) do
								local rule = rules[1]
								local conds = rules[2]

								if (rule[1] == "empty") and (rule[2] == "is") and (string.sub(rule[3], 1, 4) == "not ") then
									if testcond(conds,1,x,y) then
										local target = string.sub(rule[3], 5)
										blocked[target] = 1
									end
								end
							end
						end

						if (blocked["all"] == nil) then
							for b,mat in pairs(objectlist) do
								if (findnoun(b) == false) and (blocked[b] == nil)  then
									local nunitid,ningameid = create(b,x,y,dir,nil,nil,nil,nil,leveldata)
									addundo({"convert",matdata[1],mat,ningameid,2,x,y,dir})
								end
							end
						end
					end
				end
			end
		end

		for a,b in ipairs(delthese) do
			delete(b)
		end
	end

	if (matdata[1] == "level") and dolevels then
		local blocked = {}

		if (featureindex["level"] ~= nil) then
			for i,rules in ipairs(featureindex["level"]) do
				local rule = rules[1]
				local conds = rules[2]

				if (rule[1] == "level") and (rule[2] == "is") and (string.sub(rule[3], 1, 4) == "not ") then
					if testcond(conds,1,x,y) then
						local target = string.sub(rule[3], 5)
						blocked[target] = 1
					end
				end
			end
		end

		if (blocked["all"] == nil) and ((matdata[2] == nil) or testcond(matdata[2],1)) then
			for b,unit in pairs(objectlist) do
				if (findnoun(b,nlist.brief) == false) and (b ~= "empty") and (b ~= "level") and (blocked[target] == nil) then
					table.insert(levelconversions, {b, {}})
				end
			end
		end
	end
end

function createall_single(unitid,conds,x_,y_,id_,dolevels_,leveldata_)
	local all = {}
	local empty = false
	local dolevels = dolevels_ or false
	local delthis = false

	local leveldata = leveldata_ or {}

	local vunit
	local x,y,dir,name,id = x_,y_,4,"",id_

	if (unitid ~= 2) then
		vunit = mmf.newObject(unitid)
		x,y,dir,id = vunit.values[XPOS],vunit.values[YPOS],vunit.values[DIR],vunit.values[ID]
		name = getname(vunit)
	else
		name = "empty"
		dir = emptydir(x,y)
		if (dir == 4) then
			dir = fixedrandom(0,3)
		end
	end

	for b,unit in pairs(objectlist) do
		if (findnoun(b) == false) and (b ~= name) then
			local protect = hasfeature(name,"is","not " .. b,unitid,x,y)

			if (protect == nil) then
				local mat = findtype({b},x,y,unitid)
				--local tmat = findtext(x,y)

				if (#mat == 0) then
					local nunitid,ningameid = create(b,x,y,dir,nil,nil,nil,nil,leveldata)
					addundo({"convert",name,mat,ningameid,id,x,y,dir})

					local nunit = mmf.newObject(nunitid)

					if (unitid ~= 2) then
						nunit.originalname = vunit.originalname
					else
						nunit.originalname = "empty"
					end

					if (name == "text") or (name == "level") or (name =="glyph") then
						delthis = true
					end
				end
			end
		end
	end

	if (name == "level") and dolevels then
		local blocked = {}

		if (featureindex["level"] ~= nil) then
			for i,rules in ipairs(featureindex["level"]) do
				local rule = rules[1]
				local conds = rules[2]

				if (rule[1] == "level") and (rule[2] == "is") and (string.sub(rule[3], 1, 4) == "not ") then
					if testcond(conds,1,x,y) then
						local target = string.sub(rule[3], 5)
						blocked[target] = 1
					end
				end
			end
		end

		if (blocked["all"] == nil) and ((conds == nil) or testcond(conds,1)) then
			for b,unit in pairs(objectlist) do
				if (findnoun(b,nlist.brief) == false) and (b ~= "empty") and (b ~= "level") and (blocked[target] == nil) then
					table.insert(levelconversions, {b, {}})
				end
			end
		end
	end

	return delthis
end
