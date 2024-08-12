--[[LOGIC TYPE GUIDE:
-4 = Distance Connect
-3 = Send
-2 = Recieve
-1 = Connect
0 = Noun
1 = Verb
2 = Prop
3 = Infix
4 = Start
5 = Direction Output
6 = Prefix
7 = Not
8 = Omni Output
9 = Omni Connecter
10 = Omni Start
11 = Halt
12 = Omni Halt
13 = Distance Omni Connecter
]]


function dologic(flowunits)
	for a,b in ipairs(units) do
		local bunitid = b.fixed
		local bname = b.strings[UNITNAME]

		for i, j in ipairs(flowunits) do
			if testcond(j[2],j[1]) then
				local unit = mmf.newObject(j[1])
				if unit ~= nil then
 					if (string.sub(unit.strings[UNITNAME], 1, 6) ~= "logic_") and (b.fixed == j[1]) then
						bname = "logic_"..bname
						if logic_types[bname] == nil then
							logic_types[bname] = 0
						end
					end
				end
			end
		end
		
		if string.sub(bname, 1, 6) == "logic_" then
			if logic_types[bname] == 4 or logic_types[bname] == 10 then
				local next = findadjacentlogicsindir(b.values[XPOS], b.values[YPOS], {0, 7}, b.values[DIR])

				if logic_types[bname] == 10 then
					next = findadjacentlogics(b.values[XPOS], b.values[YPOS], {0, 7})
				end

				if (next ~= nil) then
					for c,d in ipairs(next) do
						parselogic(d, "start", {{bunitid}}, nil, nil, flowunits)
					end
				end
			end
		end
	end
end

function findhalt(unit,checked)
	local ends = findadjacentlogics(unit.values[XPOS], unit.values[YPOS], {11,12})
	local output = false

	if #ends ~= 0 then
		for e,f in ipairs(ends) do
			local funit = mmf.newObject(f)
			local fname = funit.strings[UNITNAME]
			local type = logic_types[fname]
		
			if type == 12 then
				output = true
				addoption({"%$£^$%&(*%^&","$£^%&(*^%$","*&^%$£$%^&*&^%^&^%%"},{},{{f}},false,nil,{})
			elseif type == 11 then
				local halted = findadjacentlogicsindir(funit.values[XPOS],funit.values[YPOS],nil,funit.values[DIR],{})

				for a,b in ipairs(halted) do
					if b == unit.fixed then
						output = true
						addoption({"%$£^$%&(*%^&","$£^%&(*^%$","*&^%$£$%^&*&^%^&^%%"},{},{{f}},false,nil,{})
					end
				end
			end
		end
	end
	return output
end

function findadjacentlogicsindir(x,y,arg,dir,flowunits)
	local output = {}
	local ndrs = ndirs[dir+1]
	local ox = ndrs[1]
	local oy = ndrs[2]
	local allhere = findallhere(x + ox, y + oy)
	
	for a,b in ipairs(allhere) do
		if b ~= nil then
			local bunit = mmf.newObject(b)
			local bname = bunit.strings[UNITNAME]
			local btype = bunit.strings[UNITTYPE]

			if flowunits ~= nil then
				for c,d in ipairs(flowunits) do
					if b == d then
						bname = "logic_"..bname
						btype = "logic"
					end
				end
			end

			if (btype == "logic") then
				local allow = false

				if (arg ~= nil) then
					for c,d in ipairs(arg) do
						if logic_types[bname] == d then
							allow = true
							break
						end
					end
				else
					allow = true
				end

				if allow then
					table.insert(output, b)
				end
			end
		end
	end

	return output
end

function findadjacentlogics(x,y,arg,flowunits)
	local output = {}
	local allhere = {}

	local temp = findallhere(x + 1, y)
	if (temp ~= nil) then
		for a,b in ipairs(temp) do
			table.insert(allhere, b)
		end
	end

	local temp = findallhere(x - 1, y)
	if (temp ~= nil) then
	for a,b in ipairs(temp) do
			table.insert(allhere, b)
		end
	end
	
	temp = findallhere(x, y + 1)
	if (temp ~= nil) then
		for a,b in ipairs(temp) do
			table.insert(allhere, b)
		end
	end
	
	temp = findallhere(x, y - 1)
	if (temp ~= nil) then
		for a,b in ipairs(temp) do
			table.insert(allhere, b)
		end
	end
	
	for a,b in ipairs(allhere) do
		if b ~= nil then
			local bunit = mmf.newObject(b)
			local bname = bunit.strings[UNITNAME]
			local btype = bunit.strings[UNITTYPE]

			if flowunits ~= nil then
				for c,d in ipairs(flowunits) do
					if b == d then
						bname = "logic_"..bname
						btype = "logic"
					end
				end
			end

			if (btype == "logic") then
				local allow = false
				if (arg ~= nil) then
					for c,d in ipairs(arg) do
						if logic_types[bname] == d then
							allow = true
							break
						end
					end
				else
					allow = true
				end

				if allow then
					table.insert(output, b)
				end
			end
		end
	end

	return output
end

function findlogicsatpos(x,y,arg,flowunits)
	local output = {}
	local allhere = findallhere(x, y)
	
	for a,b in ipairs(allhere) do
		if b ~= nil then
			local bunit = mmf.newObject(b)
			local bname = bunit.strings[UNITNAME]
			local btype = bunit.strings[UNITTYPE]

			if flowunits ~= nil then
				for c,d in ipairs(flowunits) do
					if b == d then
						bname = "logic_"..bname
						btype = "logic"
					end
				end
			end

			if (btype == "logic") then
				local allow = false

				if (arg ~= nil) then
					for c,d in ipairs(arg) do
						if logic_types[bname] == d then
							allow = true
							break
						end
					end
				else
					allow = true
				end

				if allow then
					table.insert(output, b)
				end
			end
		end
	end

	return output
end

function clonetable(t)
	local t2 = {}
		for k,v in pairs(t) do
			t2[k] = v
    		end
	return t2
end

function parselogic(unitid,prev,ids,basicrule,conds,flowunits,verbarg)
	local currentids = ids

	if currentids == nil then
		currentids = {}
	end

	local currentconds = conds

	if currentconds == nil then
		currentconds = {}
	end

	local currentrule = basicrule

	if currentrule == nil then
		currentrule = {}
	end

	local unit = mmf.newObject(unitid)
	if unit == nil then
		return
	end

	local name = unit.strings[UNITNAME]
	local type = logic_types[name]

	for a,b in ipairs(flowunits) do
		if unitid == b then
			name = "logic_"..name
			type = 0
		end
	end

	local nextrule = clonetable(currentrule)
	local nextconds = clonetable(currentconds)
	local nextids = clonetable(currentids)

	for a,b in ipairs(nextids) do
		for c,d in ipairs(b) do
			if d == unitid then
				return
			end
		end
	end

	table.insert(nextids, {unitid})

	if (type == -1) then
		local next = findadjacentlogicsindir(unit.values[XPOS], unit.values[YPOS], {-4, -3, -1, 1, 3, 6, 9, 13}, unit.values[DIR], flowunits)
		for a,b in ipairs(next) do
			if b ~= nil then
				parselogic(b,"connect", nextids, nextrule, nextconds, flowunits)
			end
		end
	elseif (type == -2) then
		local next = findadjacentlogics(unit.values[XPOS], unit.values[YPOS], {-4, -3, -1, 1, 3, 6, 9, 13}, flowunits)
		for a,b in ipairs(next) do
			if b ~= nil then
				local bunit = mmf.newObject(b)
				if logic_types[bunit.strings[UNITNAME]] ~= 5 and logic_types[bunit.strings[UNITNAME]] ~= 8 then
					local channel = string.sub(name, 14)

					if string.sub(bunit.strings[UNITNAME], 11) ~= channel or logic_types[bunit.strings[UNITNAME]] ~= -3 then
						parselogic(b,"connect", nextids, nextrule, nextconds, flowunits)
					end
				end
			end
		end
	elseif (type == -3) then
		for a,b in ipairs(units) do
			local channel = string.sub(name,11)
			if logic_types[b.strings[UNITNAME]] == -2 and string.sub(b.strings[UNITNAME], 14) == channel then
				parselogic(b.fixed,"send", nextids, nextrule, nextconds, flowunits)
			end
		end
	elseif (type == -4) then
		local dir = unit.values[DIR]
		local drs = ndirs[dir + 1]
		local ox,oy = drs[1],drs[2]
		local x,y = unit.values[XPOS],unit.values[YPOS]
		x = x + ox
		y = y + oy

		local logicshere = {}

		local nologics = true
		while x > 0 and x < roomsizex and y > 0 and y < roomsizey and nologics do
			logicshere = findlogicsatpos(x, y, nil, flowunits)

			if #logicshere ~= 0 then
				nologics = false
			end
			x = x + ox
			y = y + oy
		end

		for a,b in ipairs(logicshere) do
			if b ~= nil then
				local bunit = mmf.newObject(b)
				local validtypes = {-4, -3, -1, 1, 3, 6, 9, 13}
				for c,d in ipairs(validtypes) do
					if logic_types[bunit.strings[UNITNAME]] == d then
						parselogic(b,"connect", nextids, nextrule, nextconds, flowunits)
					end
				end
			end
		end
	elseif (type == 0) then
		if prev == "start" then
			local connecter = findadjacentlogics(unit.values[XPOS], unit.values[YPOS], {-4, -3, -1, 9, 13}, flowunits)
			table.insert(nextrule, string.sub(unit.strings[UNITNAME], 7))
			if connecter ~= nil then
				for a,b in ipairs(connecter) do
					local bunit = mmf.newObject(b)

					if bunit ~= nil then
						parselogic(b, "noun", nextids, nextrule, nextconds, flowunits)
					end
				end
			end
		elseif prev == "not" then
			local connecter = findadjacentlogics(unit.values[XPOS], unit.values[YPOS], {-4, -3, -1, 9, 13}, flowunits)
			table.insert(nextrule, "not "..string.sub(unit.strings[UNITNAME], 7))
			if connecter ~= nil then
				for a,b in ipairs(connecter) do
					local bunit = mmf.newObject(b)

					if bunit ~= nil then
						parselogic(b, "noun", nextids, nextrule, nextconds, flowunits)
					end
				end
			end
		elseif prev == "verb" then
			table.insert(nextrule, string.sub(name, 7))

			local hasconnect = false
			local hasboolean = false
			local unhalted = true

			if (#nextconds == 0) then
				hasboolean = true
			end

			for c,d in ipairs(nextids) do
				for a,b in ipairs(d) do
					local bunit = mmf.newObject(b)
					if bunit ~= nil then
						if logic_types[bunit.strings[UNITNAME]] == -1 or logic_types[bunit.strings[UNITNAME]] == 9 or logic_types[bunit.strings[UNITNAME]] == -2 or logic_types[bunit.strings[UNITNAME]] == -4 or logic_types[bunit.strings[UNITNAME]] == 13 then
							hasconnect = true
						end
						if logic_types[bunit.strings[UNITNAME]] == 5 or logic_types[bunit.strings[UNITNAME]] == 8 then
							hasboolean = true
						end
						if findhalt(bunit) then
							unhalted = false
						end
					end
				end
			end

			if hasconnect and hasboolean and unhalted then
				addoption(nextrule,nextconds,nextids,true,nil,{"logic"})
			end
		elseif prev == "notverb" then
			table.insert(nextrule, "not "..string.sub(name, 7))

			local hasconnect = false
			local hasboolean = false
			local unhalted = true

			if (#nextconds == 0) then
				hasboolean = true
			end

			for c,d in ipairs(nextids) do
				for a,b in ipairs(d) do
					local bunit = mmf.newObject(b)
					if bunit ~= nil then
						if logic_types[bunit.strings[UNITNAME]] == -1 or logic_types[bunit.strings[UNITNAME]] == 9 or logic_types[bunit.strings[UNITNAME]] == -2 or logic_types[bunit.strings[UNITNAME]] == -4 or logic_types[bunit.strings[UNITNAME]] == 13 then
							hasconnect = true
						end
						if logic_types[bunit.strings[UNITNAME]] == 5 or logic_types[bunit.strings[UNITNAME]] == 8 then
							hasboolean = true
						end
						if findhalt(bunit) then
							unhalted = false
						end
					end
				end
			end

			if hasconnect and hasboolean and unhalted then
				addoption(nextrule,nextconds,nextids,true,nil,{"logic"})
			end
		end
	elseif (type == 1) then
		local arg = logic_argtypes[name]
		table.insert(arg, 7)
		local logicend = findadjacentlogics(unit.values[XPOS], unit.values[YPOS], logic_argtypes[name], flowunits)

		table.insert(nextrule, string.sub(unit.strings[UNITNAME], 7))
		if logicend ~= nil then
			for a,b in ipairs(logicend) do
				local bunit = mmf.newObject(b)

				if bunit ~= nil then
					parselogic(b, "verb", nextids, nextrule, nextconds, flowunits, logic_argtypes[name])
				end
			end
		end
	elseif (type == 2) then
		if prev == "verb" then
			table.insert(nextrule, string.sub(name, 7))

			local hasconnect = false
			local hasboolean = false
			local unhalted = true

			if (#nextconds == 0) then
				hasboolean = true
			end

			for c,d in ipairs(nextids) do
				for a,b in ipairs(d) do
					local bunit = mmf.newObject(b)
					if bunit ~= nil then
						if logic_types[bunit.strings[UNITNAME]] == -1 or logic_types[bunit.strings[UNITNAME]] == 9 or logic_types[bunit.strings[UNITNAME]] == -2 or logic_types[bunit.strings[UNITNAME]] == -4 or logic_types[bunit.strings[UNITNAME]] == 13 then
							hasconnect = true
						end
						if logic_types[bunit.strings[UNITNAME]] == 5 or logic_types[bunit.strings[UNITNAME]] == 8 then
							hasboolean = true
						end
						if findhalt(bunit) then
							unhalted = false
						end
					end
				end
			end

			if hasconnect and hasboolean and unhalted then
				addoption(nextrule,nextconds,nextids,true,nil,{"logic"})
			end
		elseif prev == "notverb" then
			table.insert(nextrule, "not "..string.sub(name, 7))

			local hasconnect = false
			local hasboolean = false
			local unhalted = true

			if (#nextconds == 0) then
				hasboolean = true
			end

			for c,d in ipairs(nextids) do
				for a,b in ipairs(d) do
					local bunit = mmf.newObject(b)
					if bunit ~= nil then
						if logic_types[bunit.strings[UNITNAME]] == -1 or logic_types[bunit.strings[UNITNAME]] == 9 or logic_types[bunit.strings[UNITNAME]] == -2 or logic_types[bunit.strings[UNITNAME]] == -4 or logic_types[bunit.strings[UNITNAME]] == 13 then
							hasconnect = true
						end
						if logic_types[bunit.strings[UNITNAME]] == 5 or logic_types[bunit.strings[UNITNAME]] == 8 then
							hasboolean = true
						end
						if findhalt(bunit) then
							unhalted = false
						end
					end
				end
			end

			if hasconnect and hasboolean and unhalted then
				addoption(nextrule,nextconds,nextids,true,nil,{"logic"})
			end
		end
	elseif (type == 3) then
		local temp = findadjacentlogics(unit.values[XPOS], unit.values[YPOS], {5, 8}, flowunits)
		local params = findadjacentlogics(unit.values[XPOS], unit.values[YPOS], logic_argtypes[name], flowunits)

		if temp ~= nil then
			for a,b in ipairs(temp) do
				local bunit = mmf.newObject(b)
				if bunit ~= nil then
					nextconds = clonetable(currentconds)
					local bname = bunit.strings[UNITNAME]
					local cond = string.sub(name,7)

					if string.sub(bname,-5) == "false" then
						cond = "not "..cond
					end

					local paramnames = {}
					for c,d in ipairs(params) do
						local dunit = mmf.newObject(d)
						if dunit ~= nil then
							table.insert(nextids, {d})
							local dname = string.sub(dunit.strings[UNITNAME], 7)
							table.insert(paramnames,dname)
						end
					end

					if #paramnames > 0 then
						table.insert(nextconds, {cond, paramnames})
						parselogic(b,"cond", nextids, nextrule, nextconds, flowunits)
					end
				end
			end
		end
	elseif (type == 5) then
		local next = findadjacentlogicsindir(unit.values[XPOS], unit.values[YPOS], {-4, -3, -1, 1, 3, 6, 9, 13}, unit.values[DIR], flowunits)
		for a,b in ipairs(next) do
			if b ~= nil then
				parselogic(b,"connect", nextids, nextrule, nextconds, flowunits)
			end
		end
	elseif (type == 6) then
		local temp = findadjacentlogics(unit.values[XPOS], unit.values[YPOS], {5, 8}, flowunits)

		if temp ~= nil then
			for a,b in ipairs(temp) do
				local bunit = mmf.newObject(b)
				if bunit ~= nil then
					nextconds = clonetable(currentconds)
					local bname = bunit.strings[UNITNAME]
					local cond = string.sub(name,7)

					if string.sub(bname,-5) == "false" then
						cond = "not "..cond
					end

					table.insert(nextconds, {cond,{}})
					parselogic(b,"cond", nextids, nextrule, nextconds, flowunits)
				end
			end
		end
	elseif (type == 7) then
		if prev == "start" then
			local next = findadjacentlogics(unit.values[XPOS], unit.values[YPOS], {0}, flowunits)
			for a,b in ipairs(next) do
				if b ~= nil then
					parselogic(b,"not", nextids, nextrule, nextconds, flowunits)
				end
			end
		elseif prev == "verb" then
			if verbarg ~= nil then
				local next = findadjacentlogics(unit.values[XPOS], unit.values[YPOS], verbarg, flowunits)
				for a,b in ipairs(next) do
					if b ~= nil then
						parselogic(b,"notverb", nextids, nextrule, nextconds, flowunits)
					end
				end
			end
		end
	elseif (type == 8) then
		local next = findadjacentlogics(unit.values[XPOS], unit.values[YPOS], {-4, -3, -1, 1, 3, 6, 9, 13}, flowunits)
		for a,b in ipairs(next) do
			if b ~= nil then
				parselogic(b,"connect", nextids, nextrule, nextconds, flowunits)
			end
		end
	elseif (type == 9) then
		local next = findadjacentlogics(unit.values[XPOS], unit.values[YPOS], {-4, -3, -1, 1, 3, 6, 9, 13}, flowunits)
		for a,b in ipairs(next) do
			if b ~= nil then
				local bunit = mmf.newObject(b)
				if logic_types[bunit.strings[UNITNAME]] ~= 5 and logic_types[bunit.strings[UNITNAME]] ~= 8 then
					parselogic(b,"connect", nextids, nextrule, nextconds, flowunits)
				end
			end
		end
	elseif (type == 13) then
		for i=1,4 do
			local drs = ndirs[i]
			local ox,oy = drs[1],drs[2]
			local x,y = unit.values[XPOS],unit.values[YPOS]
			x = x + ox
			y = y + oy	
	
			local logicshere = {}

			local nologics = true
			while x > 0 and x < roomsizex and y > 0 and y < roomsizey and nologics do
				logicshere = findlogicsatpos(x, y, nil, flowunits)

				if #logicshere ~= 0 then
					nologics = false
				end
				x = x + ox
				y = y + oy
			end

			for a,b in ipairs(logicshere) do
				if b ~= nil then
					local bunit = mmf.newObject(b)
					local validtypes = {-4, -3, -1, 1, 3, 6, 9, 13}
					for c,d in ipairs(validtypes) do
						if logic_types[bunit.strings[UNITNAME]] == d then
							parselogic(b,"connect", nextids, nextrule, nextconds, flowunits)
						end
					end
				end
			end
		end
	end
end