function code(alreadyrun_)
	local playrulesound = false
	local alreadyrun = alreadyrun_ or false
	poweredstatus = {}

	local event_rules = event_code()
	if (updatecode == 1) or event_rules then
		HACK_INFINITY = HACK_INFINITY + 1
		--MF_alert("code being updated!")

		if generaldata.flags[LOGGING] then
			logrulelist.new = {}
		end

		MF_removeblockeffect(0)
		wordrelatedunits = {}

		do_mod_hook("rule_update",{alreadyrun})

		if (HACK_INFINITY < 200) then
			local checkthese = {}
			local wordidentifier = ""
			wordunits,wordidentifier,wordrelatedunits = findwordunits()
			symbolunits,symbolidentifier,symbolrelatedunits = findsymbolunits()
			local wordunitresult = {}

			if (#wordunits > 0) then
				for i,v in ipairs(wordunits) do
					if testcond(v[2],v[1]) then
						wordunitresult[v[1]] = 1
						table.insert(checkthese, v[1])
					else
						wordunitresult[v[1]] = 0
					end
				end
			end

			local breakidentifier = ""
			breakunits,breakidentifier,breakrelatedunits = findbreakunits()
			local breakunitresult = {}
			
			if (#breakunits > 0) then
				for i,v in ipairs(breakunits) do
					if testcond(v[2],v[1]) then
						breakunitresult[v[1]] = 1
						table.insert(checkthese, v[1])
					else
						breakunitresult[v[1]] = 0
					end
				end
			end

			features = {}
			featureindex = {}
			condfeatureindex = {}
			visualfeatures = {}
			notfeatures = {}
			groupfeatures = {}

			local firstwords = {}
			local alreadyused = {}

			do_mod_hook("rule_baserules")

			for i,v in ipairs(baserulelist) do
				addbaserule(v[1],v[2],v[3],v[4])
			end

			formlettermap()
			
			for name, list in pairs(unitlists) do
				if (string.sub(name, 1, 5) == "node_") then
					for i, unitid in ipairs(list) do
						table.insert(checkthese, unitid)
					end
				end
			end

			if (#codeunits > 0) then
				for i,v in ipairs(codeunits) do
					table.insert(checkthese, v)
				end
			end

			if (#checkthese > 0) or (#letterunits > 0) or (#glyphunits > 0) then
				for iid,unitid in ipairs(checkthese) do
					local unit = mmf.newObject(unitid)
					local x,y = unit.values[XPOS],unit.values[YPOS]
					local ox,oy,nox,noy = 0,0
					local tileid = x + y * roomsizex
					local name = unit.strings[UNITNAME]
					if string.sub(name, 1, 5) == "node_" then
						name = "node"
					end

					setcolour(unit.fixed)

					if (alreadyused[tileid] == nil) and (unit.values[TYPE] ~= 5) and (unit.flags[DEAD] == false) then
						for i=1,2 do
							local drs = dirs[i+2]
							local ndrs = dirs[i]
							ox = drs[1]
							oy = drs[2]
							nox = ndrs[1]
							noy = ndrs[2]

							--MF_alert("Doing firstwords check for " .. unit.strings[UNITNAME] .. ", dir " .. tostring(i))

							local hm = codecheck(unitid,ox,oy,i,nil,wordunitresult)
							local hm2 = codecheck(unitid,nox,noy,i,nil,wordunitresult)

							if (#hm == 0) and (#hm2 > 0) then
								--MF_alert("Added " .. unit.strings[UNITNAME] .. " to firstwords, dir " .. tostring(i))

								if not isglyph(unit) then
									table.insert(firstwords, {{unitid}, i, 1, unit.strings[UNITNAME], unit.values[TYPE], {}})
								else
									table.insert(firstwords, {{unitid}, i, 1, "glyph", 0, {}})
								end

								if (alreadyused[tileid] == nil) then
									alreadyused[tileid] = {}
								end

								alreadyused[tileid][i] = 1
							end
						end
					end
				end

				--table.insert(checkthese, {unit.strings[UNITNAME], unit.values[TYPE], unit.values[XPOS], unit.values[YPOS], 0, 1, {unitid})

				for a,b in pairs(letterunits_map) do
					for iid,data in ipairs(b) do
						local x,y,i = data[3],data[4],data[5]
						local unitids = data[7]
						local width = data[6]
						local word,wtype = data[1],data[2]

						local unitid = unitids[1]

						local tileid = x + y * roomsizex

						if (alreadyused[tileid] == nil) or ((alreadyused[tileid] ~= nil) and (alreadyused[tileid][i] == nil)) then
							local drs = dirs[i+2]
							local ndrs = dirs[i]
							ox = drs[1]
							oy = drs[2]
							nox = ndrs[1] * width
							noy = ndrs[2] * width

							local hm = codecheck(unitid,ox,oy,i)
							local hm2 = codecheck(unitid,nox,noy,i)

							if (#hm == 0) and (#hm2 > 0) then
								-- MF_alert(word .. ", " .. tostring(width))

								table.insert(firstwords, {unitids, i, width, word, wtype, {}})

								if (alreadyused[tileid] == nil) then
									alreadyused[tileid] = {}
								end

								alreadyused[tileid][i] = 1
							end
						end
					end
				end


                		local check = doglyphs(symbolunits)
				event_code()
				if NODE_LEGACY_PARSING then
					parselegacyarrows(breakunitresult)
				else
					parsearrows(breakunitresult)
				end
				docode(firstwords,wordunits)
				dorb()
				subrules()
				grouprules()
				playrulesound = postrules(alreadyrun)
				updatecode = 0

				if check == "stop" then
					return
				end

				local newwordunits,newwordidentifier,wordrelatedunits = findwordunits()
				local newsymbolunits,newsymbolidentifier,newsymbolrelatedunits = findsymbolunits()
				local newbreakunits,newbreakidentifier,breakrelatedunits = findbreakunits()

				--MF_alert("ID comparison: " .. newwordidentifier .. " - " .. wordidentifier)

				if (newwordidentifier ~= wordidentifier or newbreakidentifier ~= breakidentifier) then
					updatecode = 1
					code(true)
				elseif (newsymbolidentifier ~= symbolidentifier) then
					updatecode = 1
					code(true)
				else
					--domaprotation()
				end
			end
		else
			MF_alert("Level destroyed - code() run too many times")
			destroylevel("infinity")
			return
		end

		if (alreadyrun == false) then
			effects_decors()

			if (featureindex["broken"] ~= nil) then
				brokenblock(checkthese)
			end

			if (featureindex["3d"] ~= nil) then
				updatevisiontargets()
			end

			if generaldata.flags[LOGGING] then
				updatelogrules()
			end
		end

		do_mod_hook("rule_update_after",{alreadyrun})
	end

	if (alreadyrun == false) then
		local rulesoundshort = ""
		alreadyrun = true
		if playrulesound and (generaldata5.values[LEVEL_DISABLERULEEFFECT] == 0) then
			local pmult,sound = checkeffecthistory("rule")
			rulesoundshort = sound
			local rulename = "rule" .. tostring(math.random(1,5)) .. rulesoundshort
			MF_playsound(rulename)
		end
	end
end

function parselegacyarrows(breakunitresult)
	isarrow = {}
	firstarrows = {}
	hoverhints = {}
	for name, list in pairs(unitlists) do
		if (string.sub(name, 1, 5) == "node_") then
			for i, unitid in ipairs(list) do
				setcolour(unitid)
				local unit = mmf.newObject(unitid)
				isarrow[unitid] = true
				if node_types[string.sub(unit.strings[UNITNAME], 6, -1)] == 0 then
					table.insert(firstarrows, unitid)
				end
			end
		end
	end
	pointsto = {}
	--pointedby = {}
	nottedarrows = {}
	for unitid, _ in pairs(isarrow) do
		local unit = mmf.newObject(unitid)
		local dir = unit.values[DIR]
		local drs = ndirs[dir + 1]
		local ox,oy = drs[1],drs[2]
		local xpos,ypos = unit.values[XPOS],unit.values[YPOS]
		xpos = xpos + ox
		ypos = ypos + oy
		local done = false
		while xpos > 0 and xpos < roomsizex and ypos > 0 and ypos < roomsizey do
			for i, unitid2 in ipairs(findallhere(xpos, ypos)) do
				if breakunitresult[unitid2] == 1 then
					done = true
					break
				end
				if isarrow[unitid2] then
					pointsto[unitid] = unitid2
					--[[pointedby[unitid2] = pointedby[unitid2] or {}
					table.insert(pointedby[unitid2], unit)]]
					local unit = mmf.newObject(unitid)
					if string.sub(unit.strings[UNITNAME], 6, -1) == "not" then
						nottedarrows[unitid2] = unitid
					end
					done = true
					break
				end
			end
			if done then
				break
			end
			xpos = xpos + ox
			ypos = ypos + oy
		end
	end

	rulestoapply = {}
	bannedfirstarrows = {}
	for i, unitid in ipairs(firstarrows) do
		local targetnotted = nottedarrows[unitid]
		local unit = mmf.newObject(unitid)
		local target = nil
		local targetunitid = {unitid}
		local checkfornot = unitid
		local hasnot = true
		while checkfornot ~= nil do
			hasnot = not hasnot
			checkfornot = nottedarrows[checkfornot]
			table.insert(targetunitid, checkfornot)
		end
		if hasnot then
			target = "not " .. string.sub(unit.strings[UNITNAME], 6, -1)
		else
			target = string.sub(unit.strings[UNITNAME], 6, -1)
		end
		local parsed = {[unitid] = true}
		unitid = pointsto[unitid]
		local effects = {}
		local effectunitids = {}
		local conds = {}
		local condunitids = {}
		local currsubgroup = nil
		local currsubgroupunitid = nil
		local currsubgroupargtype = nil
		local currsubgroupargextra = nil
		local currsubgroupargs = {}
		local currsubgroupargunitids = {}
		local subgrouptype = nil
		local notted = false
		local notunitids = {}
		local nils = {}
		while unitid ~= nil do
			if parsed[unitid] then
				break
			end
			unit = mmf.newObject(unitid)
			local name = string.sub(unit.strings[UNITNAME], 6, -1)
			local texttype = node_types[name]
			if dirnames[name] ~= nil then
				name = dirnames[name][unit.values[DIR] + 1]
			end
			if texttype == -1 then
				table.insert(nils, unitid)
			else
				if currsubgroup == nil then
					if texttype == 0 or texttype == 2 then
						if notted then
							table.insert(effects, {"is", "not " .. name})
						else
							table.insert(effects, {"is", name})
						end
						local toadd = {unitid, table.unpack(nils)}
						for i, v in ipairs(notunitids) do
							table.insert(toadd, 1, v)
						end
						table.insert(effectunitids, {{}, toadd})
						notted = false
						notunitids = {}
					elseif texttype == 1 or texttype == 7 then
						if notted then
							if texttype == 1 then
								break
							end
							currsubgroup = "not " .. name
						else
							currsubgroup = name
						end

						currsubgroupunitid = {unitid, table.unpack(nils)}
						for i, v in ipairs(notunitids) do
							table.insert(currsubgroupunitid, v)
						end
						notted = false
						notunitids = {}
						
						currsubgroupargtype = node_argtypes[name] or {0}
						currsubgroupargextra = node_argextras[name] or {}
						subgrouptype = texttype
					elseif texttype == 6 then
						if #effects == 0 or notted then
							break
						end
						for i, v in ipairs(effects) do
							table.insert(rulestoapply, {{target, v[1], v[2]}, table_copy(conds), {targetunitid, effectunitids[i][1], effectunitids[i][2], table.unpack(condunitids)}, {"noderule"}})
						end
						effects = {}
						conds = {}
						effectunitids = {}
						condunitids = {{unitid}}
					elseif texttype == 4 then
						notted = not notted
						table.insert(notunitids, unitid)
					elseif texttype == 3 then
						if notted then
							table.insert(conds, {"not " .. name, {}})
						else
							table.insert(conds, {name})
						end
						local toadd = {unitid, table.unpack(nils)}
						for i, v in ipairs(notunitids) do
							table.insert(toadd, 1, v)
						end
						table.insert(condunitids, toadd)
						notted = false
						notunitids = {}
					else
						break
					end
				else
					if texttype == 0 or texttype == 2 then
						local allowed = false
						for i, v in ipairs(currsubgroupargtype) do
							if texttype == v then
								allowed = true
								break
							end
						end
						for i, v in ipairs(currsubgroupargextra) do
							if name == v then
								allowed = true
								break
							end
						end
						if allowed then
							bannedfirstarrows[unitid] = true
							if notted then
								table.insert(currsubgroupargs, "not " .. name)
							else
								table.insert(currsubgroupargs, name)
							end
							local toadd = {unitid, table.unpack(nils)}
							for i, v in ipairs(notunitids) do
								table.insert(toadd, 1, v)
							end
							table.insert(currsubgroupargunitids, toadd)
							notted = false
							notunitids = {}
						else
							break
						end
					elseif texttype == 6 then
						if #currsubgroupargs == 0 or notted then
							break
						end
						if subgrouptype == 1 then
							for i, v in ipairs(currsubgroupargs) do
								table.insert(effects, {currsubgroup, v})
								table.insert(effectunitids, {currsubgroupunitid, {v}})
							end
						else
							table.insert(conds, {currsubgroup, currsubgroupargs})
							table.insert(condunitids, currsubgroupunitid)
							for _, v in ipairs(currsubgroupargunitids) do
								table.insert(condunitids, v)
								-- table.insert(condunitids, {})
							end
							table.insert(condunitids, {unitid})
						end
						currsubgroup = nil
						currsubgroupunitid = nil
						currsubgroupargtype = nil
						currsubgroupargextra = nil
						currsubgroupargs = {}
						currsubgroupargunitids = {}
					elseif texttype == 4 then
						notted = not notted
						table.insert(notunitids, unitid)
					else
						break
					end
				end
				nils = {}
			end
			parsed[unitid] = true
			unitid = pointsto[unitid]
		end
		if currsubgroup ~= nil and #currsubgroupargs > 0 then
			if subgrouptype == 1 then
				for i, v in ipairs(currsubgroupargs) do
					table.insert(effects, {currsubgroup, v})
					table.insert(effectunitids, {currsubgroupunitid, currsubgroupargunitids[i]})
				end
			else
				table.insert(conds, {currsubgroup, currsubgroupargs})
				table.insert(condunitids, {currsubgroupunitid})
				for _, v in ipairs(currsubgroupargunitids) do
					table.insert(condunitids, v)
					-- table.insert(condunitids, {})
				end
			end
		end
		-- condunitids[#condunitids] = nil
		for i, v in ipairs(effects) do
			table.insert(rulestoapply, {{target, v[1], v[2]}, table_copy(conds), {targetunitid, effectunitids[i][1], effectunitids[i][2], table.unpack(condunitids)}})
		end
	end
	for i, v in ipairs(rulestoapply) do
		local firstarrow = v[3][1][#(v[3][1])]
		if bannedfirstarrows[firstarrow] == nil then
			if string.sub(v[1][3], 1, 4) == "not " then
				addoption(v[1], v[2], v[3], nil, nil, {"noderule"})
			else
				addoption(v[1], v[2], v[3], nil, nil, {"noderule"})
			end
		end
	end
end

function parsearrows(breakunitresult)
	isarrow = {}
	firstarrows = {}
	hoverhints = {}
	for name, list in pairs(unitlists) do
		if (string.sub(name, 1, 5) == "node_") then
			for i, unitid in ipairs(list) do
				setcolour(unitid)
				local unit = mmf.newObject(unitid)
				isarrow[unitid] = true
				if node_types[string.sub(unit.strings[UNITNAME], 6, -1)] == 0 then
					table.insert(firstarrows, unitid)
				end
			end
		end
	end
	pointedby = {}
	nilfinder = {}
	notunitids = {}
	notnils = {}
	local nils
	for unitid, _ in pairs(isarrow) do
		local unit = mmf.newObject(unitid)
		local dir = unit.values[DIR]
		local drs = ndirs[dir + 1]
		local ox,oy = drs[1],drs[2]
		local xpos,ypos = unit.values[XPOS],unit.values[YPOS]
		xpos = xpos + ox
		ypos = ypos + oy
		local done = false
		nils = {}
		nots = {}
		while xpos > 0 and xpos < roomsizex and ypos > 0 and ypos < roomsizey do
			for i, unitid2 in ipairs(findallhere(xpos, ypos)) do
				if breakunitresult[unitid2] == 1 then
					done = true
					break
				end
				if isarrow[unitid2] then
					local unit2 = mmf.newObject(unitid2)
					if node_types[unit2.strings[UNITNAME]:sub(6, -1)] == -1 then
						dir = unit2.values[DIR]
						drs = ndirs[dir + 1]
						ox,oy = drs[1],drs[2]
						table.insert(nils, unitid2)
					elseif node_types[unit.strings[UNITNAME]:sub(6, -1)] == 4 then
						pointedby[unitid2] = pointedby[unitid2] or {}
						table.insert(pointedby[unitid2], unitid)
						nilfinder[unitid2] = nilfinder[unitid2] or {}
						table.insert(nilfinder[unitid2], table_copy(nils))
						notunitids[unitid2] = notunitids[unitid2] or {}
						table.insert(notunitids[unitid2], unitid)
						notnils[unitid2] = notnils[unitid2] or {}
						for _, nilunitid in ipairs(nils) do
							table.insert(notnils[unitid2], nilunitid)
						end
						nils = {}
						done = true
					else
						pointedby[unitid2] = pointedby[unitid2] or {}
						table.insert(pointedby[unitid2], unitid)
						nilfinder[unitid2] = nilfinder[unitid2] or {}
						table.insert(nilfinder[unitid2], table_copy(nils))
						done = true
						nils = {}
					end
				end
			end
			if done then
				break
			end
			xpos = xpos + ox
			ypos = ypos + oy
		end
	end

	for i, unitid in ipairs(firstarrows) do
		local unit = mmf.newObject(unitid)
		local targetname = unit.strings[UNITNAME]:sub(6, -1)
		local nots = notunitids[unitid] or {}
		if (#nots % 2) == 1 then
			targetname = "not " .. targetname
		end
		local extraunitids = table_copy(nots)
		for _, nilunitid in ipairs(notnils[unitid] or {}) do
			table.insert(extraunitids, nilunitid)
		end
		for j, verbunitid in ipairs(pointedby[unitid] or {}) do
			local verbunit = mmf.newObject(verbunitid)
			local verbnils = nilfinder[unitid][j]
			if node_types[verbunit.strings[UNITNAME]:sub(6, -1)] == 1 then
				-- find the objects and conditions
				local actions = {}
				local actionunitids = {}
				local conditions = {}
				local condunitids = {}
				for k, childunitid in ipairs(pointedby[verbunitid] or {}) do
					local childunit = mmf.newObject(childunitid)
					local childtype = node_types[childunit.strings[UNITNAME]:sub(6, -1)]
					local childnils = nilfinder[verbunitid][k]
					local childnots = notunitids[childunitid] or {}
					local childnotnils = notnils[childunitid]
					local childname = getnodename(childunit)
					local nextup = {childunitid}
					for _, v in ipairs(childnils or {}) do
						table.insert(nextup, v)
					end
					for _, v in ipairs(childnots or {}) do
						table.insert(nextup, v)
					end
					for _, v in ipairs(childnotnils or {}) do
						table.insert(nextup, v)
					end
					if (#childnots % 2) == 1 then
						childname = "not " .. childname
					end
					if childtype == 0 or childtype == 2 then
						local legal = false
						for _, v in ipairs(node_argtypes[verbunit.strings[UNITNAME]:sub(6, -1)] or {}) do
							if v == childtype then
								legal = true
								break
							end
						end
						for _, v in ipairs(node_argextras[verbunit.strings[UNITNAME]:sub(6, -1)] or {}) do
							if v == childname then
								legal = true
								break
							end
						end
						if legal then
							table.insert(actions, childname)
							table.insert(actionunitids, nextup)
						end
					elseif childtype == 3 then
						table.insert(condunitids, {childunitid})
						table.insert(conditions, {childname, {}})
					elseif childtype == 7 then
						local args = {}
						for l, argunitid in ipairs(pointedby[childunitid] or {}) do
							local argunit = mmf.newObject(argunitid)
							local arg_type = node_types[argunit.strings[UNITNAME]:sub(6, -1)]
							local argname = getnodename(argunit)
							local argnots = notunitids[argunitid] or {}
							if (#argnots % 2) == 1 then
								argname = "not " .. argname
							end
							local extraargunitids = table_copy(argnots)
							for _, nilunitid in ipairs(notnils[argunitid] or {}) do
								table.insert(extraargunitids, nilunitid)
							end
							for _, nilunitid in ipairs(nilfinder[childunitid][l] or {}) do
								table.insert(extraargunitids, nilunitid)
							end
							local legal = false
							for _, v in ipairs(node_argtypes[childunit.strings[UNITNAME]:sub(6, -1)] or {}) do
								if v == arg_type then
									legal = true
									break
								end
							end
							for _, v in ipairs(node_argextras[childunit.strings[UNITNAME]:sub(6, -1)] or {}) do
								if v == argname then
									legal = true
									break
								end
							end
							if legal then
								table.insert(args, argname)
								table.insert(condunitids, {argunitid, table.unpack(extraargunitids)})
							end
						end
						if #args > 0 then
							table.insert(conditions, {childname, args})
							table.insert(condunitids, nextup)
						end
					end
				end
				for l, action in ipairs(actions) do
					local ids = {{unitid}, extraunitids, {verbunitid}, verbnils, table.unpack(actionunitids)}
					for _, toadd in ipairs(condunitids) do
						table.insert(ids, toadd)
					end
					addoption({targetname, verbunit.strings[UNITNAME]:sub(6, -1), action}, table_copy(conditions), table_copy(ids), nil, nil, {"noderule"})
				end
			end
		end
	end
end

function getnodename(unit)
	local name = unit.strings[UNITNAME]:sub(6, -1)
	if dirnames[name] then
		name = dirnames[name][unit.values[DIR]]
	end
	return name
end

function findbreakunits()
	local result = {}
	local alreadydone = {}
	local checkrecursion = {}
	local related = {}
	
	local identifier = ""
	local fullid = {}
	
	if (featureindex["break"] ~= nil) then
		for i,v in ipairs(featureindex["break"]) do
			local rule = v[1]
			local conds = v[2]
			local ids = v[3]
			
			local name = rule[1]
			local subid = ""
			
			if (rule[2] == "is") then
				if (objectlist[name] ~= nil) and (alreadydone[name] == nil) then
					local these = findall({name,{}})
					alreadydone[name] = 1
					
					if (#these > 0) then
						for a,b in ipairs(these) do
							local bunit = mmf.newObject(b)
							local valid = true
							
							if (featureindex["broken"] ~= nil) then
								if (hasfeature(getname(bunit),"is","broken",b,bunit.values[XPOS],bunit.values[YPOS]) ~= nil) then	
									valid = false
								end
							end
							
							if valid then
								table.insert(result, {b, conds})
								subid = subid .. name
								-- LISÄÄ TÄHÄN LISÄÄ DATAA
							end
						end
					end
				end
				
				if (#subid > 0) then
					for a,b in ipairs(conds) do
						local condtype = b[1]
						local params = b[2] or {}
						
						subid = subid .. condtype
						
						if (#params > 0) then
							for c,d in ipairs(params) do
								subid = subid .. tostring(d)
								
								related = findunits(d,related,conds)
							end
						end
					end
				end
				
				table.insert(fullid, subid)
				
				--MF_alert("Going through " .. name)
				
				if (#ids > 0) then
					if (#ids[1] == 1) then
						local firstunit = mmf.newObject(ids[1][1])
						
						local notname = name
						if (string.sub(name, 1, 4) == "not ") then
							notname = string.sub(name, 5)
						end
						
						if (firstunit.strings[UNITNAME] ~= "text_" .. name) and (firstunit.strings[UNITNAME] ~= "text_" .. notname) and (firstunit.strings[UNITNAME] ~= "node_" .. name) and (firstunit.strings[UNITNAME] ~= "node_" .. notname) then
							--MF_alert("Checking recursion for " .. name)
							table.insert(checkrecursion, {name, i})
						end
					end
				else
					MF_alert("No ids listed in Word-related rule! rules.lua line 1302 - this needs fixing asap (related to grouprules line 1118)")
				end
			end
		end
		
		table.sort(fullid)
		for i,v in ipairs(fullid) do
			-- MF_alert("Adding " .. v .. " to id")
			identifier = identifier .. v
		end
		
		--MF_alert("Identifier: " .. identifier)
		
		for a,checkname_ in ipairs(checkrecursion) do
			local found = false
			
			local checkname = checkname_[1]
			
			local b = checkname
			if (string.sub(b, 1, 4) == "not ") then
				b = string.sub(checkname, 5)
			end
			
			for i,v in ipairs(featureindex["break"]) do
				local rule = v[1]
				local ids = v[3]
				local tags = v[4]
				
				if (rule[1] == b) or (rule[1] == "all") or ((rule[1] ~= b) and (string.sub(rule[1], 1, 3) == "not")) then
					for c,g in ipairs(ids) do
						for a,d in ipairs(g) do
							local idunit = mmf.newObject(d)
							
							-- Tässä pitäisi testata myös Group!
							if (idunit.strings[UNITNAME] == "text_" .. rule[1]) or (rule[1] == "all") then
								--MF_alert("Matching objects - found")
								found = true
							elseif (string.sub(rule[1], 1, 5) == "group") then
								--MF_alert("Group - found")
								found = true
							elseif (rule[1] ~= checkname) and (string.sub(rule[1], 1, 3) == "not") then
								--MF_alert("Not Object - found")
								found = true
							end
						end
					end
					
					for c,g in ipairs(tags) do
						if (g == "mimic") then
							found = true
						end
					end
				end
			end
			
			if (found == false) then
				--MF_alert("Wordunit status for " .. b .. " is unstable!")
				identifier = "null"
				wordunits = {}
				
				for i,v in pairs(featureindex["break"]) do
					local rule = v[1]
					local ids = v[3]
					
					--MF_alert("Checking to disable: " .. rule[1] .. " " .. ", not " .. b)
					
					if (rule[1] == b) or (rule[1] == "not " .. b) then
						v[2] = {{"never",{}}}
					end
				end
				
				if (string.sub(checkname, 1, 4) == "not ") then
					local notrules_word = notfeatures["break"]
					local notrules_id = checkname_[2]
					local disablethese = notrules_word[notrules_id]
					
					for i,v in ipairs(disablethese) do
						v[2] = {{"never",{}}}
					end
				end
			end
		end
	end
	
	--MF_alert("Current id (end): " .. identifier)
	
	return result,identifier,related
end

function ruleblockeffect()
	local handled = {}

	for i,rules in pairs(features) do
		local rule = rules[1]
		local conds = rules[2]
		local ids = rules[3]
		local tags = rules[4]
		local blocked = false
		local glyphrule = false
		if (tags[1] == "glyphrule") then
			glyphrule = true
		end

		for a,b in ipairs(conds) do
			if (b[1] == "never") then
				blocked = true
				break
			end
		end

		--MF_alert(rule[1] .. " " .. rule[2] .. " " .. rule[3] .. ": " .. tostring(blocked))

		if blocked then
			for a,d in ipairs(ids) do
				for c,b in ipairs(d) do
					if (handled[b] == nil) and not glyphrule then
						local runit = mmf.newObject(b)

						local blockid = MF_create("Ingame_blocked")
						local bunit = mmf.newObject(blockid)

						bunit.x = runit.x
						bunit.y = runit.y

						bunit.values[XPOS] = runit.values[XPOS]
						bunit.values[YPOS] = runit.values[YPOS]
						bunit.layer = 1
						bunit.values[ZLAYER] = 20
						bunit.values[TYPE] = b

						bunit.scaleX = spritedata.values[TILEMULT] * generaldata2.values[ZOOM]
						bunit.scaleY = spritedata.values[TILEMULT] * generaldata2.values[ZOOM]

						bunit.visible = runit.visible

						local c1,c2 = getuicolour("blocked")
						MF_setcolour(blockid,c1,c2)

						handled[b] = 2
					elseif (handled[b] == nil) then
						local runit = mmf.newObject(b)
						MF_setcolour(b,0,1)

						local blockid = MF_create("Ingame_blocked")
						local bunit = mmf.newObject(blockid)

						bunit.x = runit.x
						bunit.y = runit.y

						bunit.values[XPOS] = runit.values[XPOS]
						bunit.values[YPOS] = runit.values[YPOS]
						bunit.layer = 1
						bunit.values[ZLAYER] = 20
						bunit.values[TYPE] = b

						bunit.scaleX = spritedata.values[TILEMULT] * generaldata2.values[ZOOM]
						bunit.scaleY = spritedata.values[TILEMULT] * generaldata2.values[ZOOM]

						bunit.visible = runit.visible

						local c1,c2 = getuicolour("blocked")
						MF_setcolour(blockid,0,0)

						handled[b] = 2
					end
				end
			end
		else
			for a,d in ipairs(ids) do
				for c,b in ipairs(d) do
					if (handled[b] == nil) then
						handled[b] = 1
					elseif (handled[b] == 2) then
						MF_removeblockeffect(b)
						if glyphrule then
							setcolour(b, "active")
						end
					end
				end
			end
		end
	end
end


--events code

event_text_types = {}
event_text_types["baba"] = "noun"
event_text_types["flag"] = "noun"
event_text_types["tile"] = "noun"
event_text_types["keke"] = "noun"
event_text_types["text"] = "noun"
event_text_types["event"] = "noun"
event_text_types["glyph"] = "noun"
event_text_types["rock"] = "noun"
event_text_types["wall"] = "noun"
event_text_types["lava"] = "noun"
event_text_types["water"] = "noun"
event_text_types["box"] = "noun"
event_text_types["key"] = "noun"
event_text_types["door"] = "noun"
event_text_types["skull"] = "noun"
event_text_types["belt"] = "noun"
event_text_types["grass"] = "noun"

event_text_types["group"] = "nounjective"

event_text_types["destroy"] = "adjective"
event_text_types["you"] = "adjective"
event_text_types["win"] = "adjective"
event_text_types["push"] = "adjective"
event_text_types["stop"] = "adjective"
event_text_types["hot"] = "adjective"
event_text_types["melt"] = "adjective"
event_text_types["sink"] = "adjective"
event_text_types["pull"] = "adjective"
event_text_types["open"] = "adjective"
event_text_types["shut"] = "adjective"
event_text_types["defeat"] = "adjective"
event_text_types["power"] = "adjective"
event_text_types["shift"] = "adjective"

event_text_types["turn"] = "verb"
event_text_types["move"] = "verb"
event_text_types["become"] = "verb"
event_text_types["make"] = "verb"
event_text_types["be"] = "verb"
event_text_types["eat"] = "verb"

event_text_types["down"] = "direction"
event_text_types["up"] = "direction"
event_text_types["right"] = "direction"
event_text_types["left"] = "direction"
event_text_types["aroundleft"] = "direction"
event_text_types["aroundright"] = "direction"
event_text_types["forward"] = "direction"
event_text_types["backward"] = "direction"

event_text_types["on"] = "condition"
event_text_types["near"] = "condition"
event_text_types["when"] = "condition"

event_text_types["repeat"] = "loop"

event_text_types["not"] = "not"

event_text_types["never"] = "never"

event_text_types["backslash"] = "backslash"

event_text_types["then"] = "then"

event_text_types["lonely"] = "prefix"
event_text_types["powered"] = "prefix"
event_text_types["moved"] = "prefix"

event_text_types["0"] = "number"
event_text_types["1"] = "number"
event_text_types["2"] = "number"
event_text_types["3"] = "number"
event_text_types["4"] = "number"
event_text_types["5"] = "number"
event_text_types["6"] = "number"
event_text_types["7"] = "number"
event_text_types["8"] = "number"
event_text_types["9"] = "number"

event_text_types["refers"] = "condition"
event_text_types["node"] = "noun"

verb_allowed_types = {}
verb_allowed_types["turn"] = {"direction"}
verb_allowed_types["move"] = {"direction"}
verb_allowed_types["repeat"] = {"number"}
verb_allowed_types["when"] = {"prefix", "adjective", "nounjective"}
verb_allowed_types["not when"] = {"prefix", "adjective", "nounjective"}
verb_allowed_types["be"] = {"noun", "adjective", "nounjective"}
verb_allowed_types["never"] = {"adjective", "verb", "nounjective"}
verb_allowed_types["adjective"] = {"adjective"}

number_extensions = {"power", "group", "powered"}

never_opposites = {}
never_opposites["not destroy"] = "safe"

function event_code()

	local starts = findall({"event_start", {}})
	if (#starts == 0) then
		return
	end

	local event_list = {}

	for i, j in ipairs(starts) do

		local unit = mmf.newObject(j)

		local x, y = unit.values[XPOS], unit.values[YPOS]

		local thex = x
		local they = y + 1

		local applicable, applicable_ids = find_events(x + 1, y, "noun", true)

		-- if no nouns were detected, dont parse
		if (#applicable > 0) then

			local limit = 0
			local done = false

			local conditions = {}

			local ids = {{j}}
			for i, k in ipairs(applicable_ids) do
				table.insert(ids, {k})
			end

			local backslash = false
			local notted = false
			local notcount = 0
			local blockstack = {}
			local done_lines = {}
			local id_mark = {}

			while limit < 70 and not done do


				local allhere = findallhere(thex, they)

				local isbackslashed = false

				if (#allhere > 0) then

					for i, k in ipairs(allhere) do

						local kunit = mmf.newObject(k)

						local name = getname(kunit, true)


						local valid = false
						if not backslash then
							if (string.sub(name, 1, 6) == "event_") then
								valid = true
							end
						else
							if (string.sub(name, 1, 5) == "text_") then
								valid = true
							end
						end

						if valid then

							local copied_conditions = {}

							for i, q in ipairs(conditions) do
								table.insert(copied_conditions, q)
							end


							local eventname = name

							--Handle \
							if not backslash then
								eventname = string.sub(name, 7)
							else
								eventname = string.sub(name, 6)
							end

							local event_type = event_text_types[eventname]
							if backslash and event_type == nil then
								if kunit.values[TYPE] == 1 then
									event_type = "verb"
								end
								if kunit.values[TYPE] == 2 or string.sub(kunit.strings[NAME], 1, 5) == "group" then
									event_type = "adjective"
								end
								if kunit.values[TYPE] == 7 then
									event_type = "condition"
								end
							end
							--End handling \

							--Number extension stuff, for GROUP and POWER

							local number_ids = {}

							for a, b in ipairs(number_extensions) do
								if eventname == b then
									local targets, target_ids = find_event_targets(thex + 1, they, "repeat")

									if #targets > 0 then
										for a, b in ipairs(target_ids) do
											table.insert(number_ids, b)
										end
										eventname = eventname .. targets[1]
									end
								end
							end


							if notted then
								if event_type == "condition" then
									notted = false
									if notcount % 2 == 0 then
										eventname = "not " .. eventname
									end
									notcount = 0
								elseif event_type == "not" then
									notcount = notcount + 1
								else
									done = true
									event_type = "NO!"
									notcount = 0
									table.remove(ids, #ids)
								end
							end


							if event_type == "adjective" or event_type == "nounjective" then

								table.insert(ids, {k})
								table.insert(event_list, {applicable, {eventname, ""}, copied_conditions, ids})

							elseif event_type == "condition" then

								local targets, target_ids = find_event_targets(thex + 1, they, eventname, true)

								if #targets > 0 then
									if eventname ~= "when" and eventname ~= "not when" then
										for a, b in ipairs(target_ids) do
											table.insert(ids, b)
										end
										table.insert(ids, {k})
										table.insert(conditions, {eventname, targets})
										table.insert(blockstack, {eventname, they})
									else

										--when code. warning: ETREMELY jank
										local worked = false
										for a, b in ipairs(targets) do
											local etype = event_text_types[b]
											if string.sub(b, 1, 5) == "group" or string.sub(b, 1, 5) == "power" then
												etype = "NO!" --See what i said about it being extremely jank?
											end
											if string.sub(b, 1, 7) == "powered" then
												etype = "prefix"
											end
											if etype == nil then
												local kunit = mmf.newObject(target_ids[a][1])
												etype = kunit.values[TYPE]
												if etype == 3 then
													etype = "prefix"
												end
												if etype == 2 or string.sub(kunit.strings[NAME], 1, 5) == "group" then
													etype = "adjective"
												end
											end
											--timedmessage(b)
											if etype == "prefix" then
												worked = true
												table.insert(conditions, {eventname, {b}})
											elseif etype == "adjective" then
												worked = true
												table.insert(conditions, {"feeling", {b}})
											end
										end
										if worked then
											for a, b in ipairs(target_ids) do
												table.insert(ids, b)
											end
											table.insert(ids, {k})
											table.insert(blockstack, {eventname, they})
											table.insert(done_lines, they)
										else
											done = true
										end

										--when code over
									end
								else
									done = true
								end
							elseif event_type == "verb" then

								local targets, target_ids = find_event_targets(thex + 1, they, eventname)


								if #targets > 0 then
									for a, b in ipairs(target_ids) do
										table.insert(ids, b)
									end
									table.insert(ids, {k})
									table.insert(event_list, {applicable, {eventname, targets}, copied_conditions, ids})
								else
									done = true
								end

							elseif event_type == "never" then
								--Handle never. This will take forever

								--Step 1: move forward
								local targets, target_ids = find_event_targets(thex + 1, they, eventname)
								local never_succeed = false
								if #targets > 0 then
									for a, target in ipairs(targets) do
										if event_text_types[target] == "verb" then
											local target2s, target2_ids = find_event_targets(thex + 2, they, target)

											if #target2s > 0 then
												never_succeed = true
												for a, b in ipairs(target2_ids) do
													table.insert(ids, b)
												end
												for b, target2 in ipairs(target2s) do
													table.insert(event_list, {applicable, {target, {"not " .. target2}}, copied_conditions, ids})
												end
											else
												done = true
											end
										elseif event_text_types[target] == "adjective" then
											local target2s, target2_ids = find_events(thex + 1, they, "adjective")

											if #target2s > 0 then
												never_succeed = true
												for a, b in ipairs(target2_ids) do
													table.insert(ids, {b})
												end
												for b, target2 in ipairs(target2s) do
													table.insert(event_list, {applicable, {"not " .. target2, ""}, copied_conditions, ids})
												end
											else
												done = true
											end
										end

									end
								else
									done = true
								end
								if never_succeed then
									table.insert(ids, {k})
									for a, b in ipairs(target_ids) do
										table.insert(ids, b)
									end
								end

							elseif event_type == "not" then
								table.insert(ids, {k})
								thex = thex + 1
								notted = true
							elseif event_type == "backslash" then
								table.insert(ids, {k})
								thex = thex + 1
								isbackslashed = true
								backslash = true
							elseif event_type == "then" then
								if #blockstack > 0 then
									table.insert(ids, {k})
									if blockstack[#blockstack][1] ~= "repeat" then
										table.remove(conditions, #conditions)
										table.remove(blockstack, #blockstack)
									else

										if blockstack[#blockstack][2] > 1 then
											blockstack[#blockstack][2] = blockstack[#blockstack][2] - 1
											they = blockstack[#blockstack][3]
										else
											table.remove(blockstack, #blockstack)
										end
									end

								else
									done = true
								end
							elseif event_type == "loop" then
								local targets, target_ids = find_event_targets(thex + 1, they, eventname)

								if #targets > 0 then
									for a, b in ipairs(target_ids) do
										table.insert(ids, b)
									end
									table.insert(ids, {k})

									-- i dont feel like handling threads with repeat so
									table.insert(blockstack, {eventname, tonumber(targets[1]), they})

									id_mark = {#ids, #event_list}
								else
									done = true
								end

							else
								done = true
							end

							if not done and #number_ids > 0 then

								for a, b in ipairs(number_ids) do
									table.insert(ids, b)
								end
							end


						else
							done = true
							local amount_to_run = #blockstack + 0
							for ____ = 1, amount_to_run do
									if blockstack[#blockstack][1] ~= "repeat" then
										table.remove(blockstack, #blockstack)
										table.remove(conditions, #conditions)
									else
										if blockstack[#blockstack][2] > 1 then
											blockstack[#blockstack][2] = blockstack[#blockstack][2] - 1
											they = blockstack[#blockstack][3]
											done = false
											break
										else
											table.remove(blockstack, #blockstack)
										end
									end
							end


							if notted then
									notcount = 0
									notted = false
									table.remove(ids, #ids)
							end



						end

					end


				else --nothing to parse anymore!
					done = true
					if notted then
							notcount = 0
							notted = false
							table.remove(ids, #ids)
					end

					--run "Then" for each block still on the blcokstack.
					local amount_to_run = #blockstack + 0
					for ____ = 1, amount_to_run do
							if blockstack[#blockstack][1] ~= "repeat" then
								table.remove(blockstack, #blockstack)
								table.remove(conditions, #conditions)
							else
								if blockstack[#blockstack][2] > 1 then
									blockstack[#blockstack][2] = blockstack[#blockstack][2] - 1
									they = blockstack[#blockstack][3]
									done = false
									break
								else
									table.remove(blockstack, #blockstack)
								end
							end
					end
				end



				if not isbackslashed and not notted then
					they = they + 1
					thex = x
					backslash = false
				end


			end

		end

	end


	for i, w in ipairs(event_list) do

		local nouns = w[1]
		local verb = w[2]
		local conds = w[3]
		local ids = w[4]

		--Replace all "X WHEN Y" conditions with "Y X" prefixes
		for i, j in ipairs(conds) do
			if j[1] == "when" then
				conds[i][1] = conds[i][2][1]
				conds[i][2] = {}
			end
			if j[1] == "not when" then
				conds[i][1] = "not " .. conds[i][2][1]
				conds[i][2] = {}
			end
		end

		for i, j in ipairs(nouns) do
			--WE DID IT
			if verb[2] == "" then
				if string.sub(verb[1], 1, 4) ~= "not " then
					addoption({j, "is", verb[1]},conds,ids, true)
				else
					if never_opposites[verb[1]] ~= nil then
						addoption({j, "is", never_opposites[verb[1]]},conds,ids, true)
					else
						addoption({j, "is", verb[1]},conds,ids, true)
					end
				end
			else

				for i, k in ipairs(verb[2]) do
					if verb[1] == "move" then
						if string.sub(k, 1, 4) ~= "not " then
							if k ~= "forward" then
								addoption({j, "is", "nudge" .. k},conds,ids, true)
							else
								addoption({j, "is", "auto"},conds,ids, true)
							end
						else
							addoption({j, "is", "locked" .. string.sub(k, 5)},conds,ids, true)
						end
					elseif verb[1] == "turn" then
						if k ~= "aroundleft" and k ~= "aroundright" then
							addoption({j, "is", k},conds,ids, true)
						else
							if k == "aroundleft" then
								addoption({j, "is", "turn"},conds,ids, true)
							else
								addoption({j, "is", "deturn"},conds,ids, true)
							end
						end
					elseif verb[1] == "be" then
						addoption({j, "is", k},conds,ids, true)
					else
						if string.sub(k, 1, 4) ~= "not " then
							addoption({j, verb[1], k},conds,ids, true)
						end
					end
				end

			end
		end

	end

	return (#event_list > 0)

end

function find_events(x, y, type, havenot)

	local the_ids, the_targets = {}, {}

	local hasbackslash = false
	local backslashid = nil

	for i, k in ipairs(findallhere(x, y)) do

		local kunit = mmf.newObject(k)
		local name = getname(kunit, true)

		if string.sub(name, 1, 6) == "event_" then

			local realname = string.sub(name, 7)

			if realname == "backslash" then
				backslashid = k
				hasbackslash = true
			end

			if event_text_types[realname] == type or type == nil or (event_text_types[realname] == "nounjective" and (type == "noun" or type == "adjective")) then
				table.insert(the_targets, realname)
				table.insert(the_ids, k)
			end

			if event_text_types[realname] == "not" and havenot then
				local re_targets, re_ids = find_events(x + 1, y, type, true)
				if #re_targets > 0 then
					for a, b in ipairs(re_targets) do
						if string.sub(b, 1, 4) == "not " then
							table.insert(the_targets, string.sub(b, 5))
						else
							table.insert(the_targets, "not " .. b)
						end
					end
					for a, b in ipairs(re_ids) do
						table.insert(the_ids, b)
					end
					table.insert(the_ids, k)
				end
			end

		end

	end

	if hasbackslash then
		for i, k in ipairs(findallhere(x + 1, y)) do

			local kunit = mmf.newObject(k)
			local name = getname(kunit, true)

			if string.sub(name, 1, 5) == "text_" then

				local realname = string.sub(name, 6)

				local event_type = event_text_types[realname]
				if event_type == nil then
					if kunit.values[TYPE] == 0 then
						event_type = "noun"
					end
					if kunit.values[TYPE] == 2 then
						event_type = "adjective"
					end
					if kunit.values[TYPE] == 4 then
						event_type = "not"
					end
				end
				if event_type == type or type == nil then

					table.insert(the_targets, realname)
					table.insert(the_ids, k)
					table.insert(the_ids, backslashid)
				end

				if event_type == "not" and havenot then
					local re_targets, re_ids = find_events(x + 2, y, type, true)
					if #re_targets > 0 then
						for a, b in ipairs(re_targets) do
							if string.sub(b, 1, 4) == "not " then
								table.insert(the_targets, string.sub(b, 5))
							else
								table.insert(the_targets, "not " .. b)
							end
						end
						for a, b in ipairs(re_ids) do
							table.insert(the_ids, b)
						end
						table.insert(the_ids, k)
						table.insert(the_ids, backslashid)
					end
				end

			end

		end
	end

	return the_targets, the_ids
end

function find_event_targets(x, y, eventname, havenot_)

	local havenot = havenot_ or false

	local targets = {}
	local target_ids = {}

	local isbackslashed = false
	local backslashid = nil

	for i, m in ipairs(findallhere(x, y)) do
		local munit = mmf.newObject(m)
		local name = getname(munit, true)



		if string.sub(name, 1, 6) == "event_" then

			local realname = string.sub(name, 7)



			local valid = false

			if verb_allowed_types[eventname] ~= nil then
				for a, b in ipairs(verb_allowed_types[eventname]) do

					if b == event_text_types[realname] or ((event_text_types[realname] == "noun" or event_text_types[realname] == "adjective") and b == "nounjective") then
						valid = true
					end

				end
			else
				if event_text_types[realname] == "noun" or event_text_types[realname] == "nounjective" then
					valid = true
				end
			end

			if event_text_types[realname] == "not" and havenot_ then
				local re_targets, re_ids = find_event_targets(x + 1, y, eventname, true)
				if #re_targets > 0 then

					for a, b in ipairs(re_targets) do
						if string.sub(b, 1, 4) == "not " then
							table.insert(targets, string.sub(b, 5))
						else
							table.insert(targets, "not " .. b)
						end
					end

					for a, b in ipairs(re_ids) do
						table.insert(target_ids, b)
					end

					table.insert(target_ids, {m})
				end
			end

			if event_text_types[realname] == "backslash" then
				isbackslashed = true
				backslashid = m
			end


			if valid then
				for a, b in ipairs(number_extensions) do
					if realname == b then
						local target2s, target2_ids = find_event_targets(x + 1, y, "repeat")
						if #target2s > 0 then
							for a, b in ipairs(target2_ids) do
								table.insert(target_ids, b)
							end
							realname = realname .. target2s[1]
						end
					end
				end

				table.insert(target_ids, {m})
				table.insert(targets, realname)
			end

		end
	end

	if isbackslashed then
		for i, m in ipairs(findallhere(x + 1, y)) do
			local munit = mmf.newObject(m)
			local name = getname(munit, true)



			if string.sub(name, 1, 5) == "text_" then

				local realname = string.sub(name, 6)

				local event_type = event_text_types[realname]
				if event_type == nil then
					if munit.values[TYPE] == 0 then
						event_type = "noun"
					end
					if munit.values[TYPE] == 1 then
						event_type = "verb"
					end
					if munit.values[TYPE] == 2 then
						event_type = "adjective"
					end
					if munit.values[TYPE] == 3 then
						event_type = "prefix"
					end
				end


				local valid = false

				if verb_allowed_types[eventname] ~= nil then
					for a, b in ipairs(verb_allowed_types[eventname]) do

						if b == event_type or ((event_type == "noun" or event_type == "adjective") and b == "nounjective") then
							valid = true
						end

					end
				else
					if event_type == "noun" or event_type == "nounjective" then
						valid = true
					end
				end

				if event_text_types[realname] == "not" then
					local re_targets, re_ids = find_event_targets(x + 1, y, eventname, true)
					if #re_targets > 0 then

						for a, b in ipairs(re_targets) do
							if string.sub(b, 1, 4) == "not " then
								table.insert(targets, string.sub(b, 5))
							else
								table.insert(targets, "not " .. b)
							end
						end

						for a, b in ipairs(re_ids) do
							table.insert(target_ids, b)
						end

						table.insert(target_ids, {m})
					end
				end


				if valid then
					table.insert(target_ids, {m})
					table.insert(targets, realname)
					table.insert(target_ids, {backslashid})
				end

			end
		end
	end

	return targets, target_ids
end


function addoption(option,conds_,ids,visible,notrule,tags_)
	--MF_alert(option[1] .. ", " .. option[2] .. ", " .. option[3])

	local visual = true

	if (visible ~= nil) then
		visual = visible
	end

	local conds = {}

	if (conds_ ~= nil) then
		conds = conds_
	else
		MF_alert("nil conditions in rule: " .. option[1] .. ", " .. option[2] .. ", " .. option[3])
	end
	local tags = tags_ or {}
	local shownrule = nil
	if (string.sub(option[1], 1, 5) == "text_") then
		if shownrule == nil then
			shownrule = copyrule({option, conds, ids, tags})
		end
		table.insert(conds, {"references", {" " .. string.sub(option[1], 6)}})
		option[1] = "text"
	elseif (string.sub(option[1], 1, 6) == "glyph_") then
		if shownrule == nil then
			shownrule = copyrule({option, conds, ids, tags})
		end
		table.insert(conds, {"references", {" " .. string.sub(option[1], 7)}})
		option[1] = "glyph"
	elseif (string.sub(option[1], 1, 6) == "event_") then
		if shownrule == nil then
			shownrule = copyrule({option, conds, ids, tags})
		end
		table.insert(conds, {"references", {" " .. string.sub(option[1], 7)}})
		option[1] = "event"
	elseif (string.sub(option[1], 1, 5) == "node_") then
		if shownrule == nil then
			shownrule = copyrule({option, conds, ids, tags})
		end
		table.insert(conds, {"references", {" " .. string.sub(option[1], 6)}})
		option[1] = "node"
	end
	if (string.sub(option[1], 1, 5) == "not text_") then
		if shownrule == nil then
			shownrule = copyrule({option, conds, ids, tags})
		end
		option[1] = "all"
	elseif (string.sub(option[1], 1, 6) == "not glyph_") then
		if shownrule == nil then
			shownrule = copyrule({option, conds, ids, tags})
		end
		option[1] = "all"
	elseif (string.sub(option[1], 1, 6) == "not event_") then
		if shownrule == nil then
			shownrule = copyrule({option, conds, ids, tags})
		end
		option[1] = "all"
	elseif (string.sub(option[1], 1, 5) == "not node_") then
		if shownrule == nil then
			shownrule = copyrule({option, conds, ids, tags})
		end
		option[1] = "all"
	end
	if ((option[1] == "text") or (option[3] == option[1])) and (string.sub(option[3], 1, 5) == "text_") and (option[2] == "is") then
		local newconds = {}
		newconds = copyconds(newconds, conds)
		addoption({option[3], "is", "text"}, newconds,ids,false,notrule,tags_)
	elseif ((option[1] == "glyph") or (option[3] == option[1])) and (string.sub(option[3], 1, 6) == "glyph_") and (option[2] == "is") then
		local newconds = {}
		newconds = copyconds(newconds, conds)
		addoption({option[3], "is", "glyph"}, newconds,ids,false,notrule,tags_)
	elseif ((option[1] == "event") or (option[3] == option[1])) and (string.sub(option[3], 1, 6) == "event_") and (option[2] == "is") then
		local newconds = {}
		newconds = copyconds(newconds, conds)
		addoption({option[3], "is", "event"}, newconds,ids,false,notrule,tags_)
	elseif ((option[1] == "node") or (option[3] == option[1])) and (string.sub(option[3], 1, 5) == "node_") and (option[2] == "is") then
		local newconds = {}
		newconds = copyconds(newconds, conds)
		addoption({option[3], "is", "event"}, newconds,ids,false,notrule,tags_)
	end

	if (option[1] == "level") and (option[2] == "become") and (option[3] == "level") then
		shownrule = copyrule({option, conds, ids, tags})
		table.insert(conds, {"never", {}})

	end

	if (#option == 3) then
		local rule = {option,conds,ids,tags}
		table.insert(features, rule)
		local target = option[1]
		local verb = option[2]
		local effect = option[3]

		if (featureindex[effect] == nil) then
			featureindex[effect] = {}
		end

		if (featureindex[target] == nil) then
			featureindex[target] = {}
		end

		if (featureindex[verb] == nil) then
			featureindex[verb] = {}
		end

		table.insert(featureindex[effect], rule)
		table.insert(featureindex[verb], rule)

		if (target ~= effect) then
			table.insert(featureindex[target], rule)
		end

		if visual then
			local visualrule = copyrule(rule)
			if (shownrule == nil) then
				table.insert(visualfeatures, visualrule)
			else
				table.insert(visualfeatures, shownrule)
			end
		end

		local groupcond = false

		if (string.sub(target, 1, 5) == "group") or (string.sub(effect, 1, 5) == "group") or (string.sub(target, 1, 9) == "not group") or (string.sub(effect, 1, 9) == "not group") then
			groupcond = true
		end

		if (notrule ~= nil) then
			local notrule_effect = notrule[1]
			local notrule_id = notrule[2]

			if (notfeatures[notrule_effect] == nil) then
				notfeatures[notrule_effect] = {}
			end

			local nr_e = notfeatures[notrule_effect]

			if (nr_e[notrule_id] == nil) then
				nr_e[notrule_id] = {}
			end

			local nr_i = nr_e[notrule_id]

			table.insert(nr_i, rule)
		end

		if (#conds > 0) then
			local addedto = {}

			for i,cond in ipairs(conds) do
				local condname = cond[1]
				if (string.sub(condname, 1, 4) == "not ") then
					condname = string.sub(condname, 5)
				end

				if (condfeatureindex[condname] == nil) then
					condfeatureindex[condname] = {}
				end

				if (addedto[condname] == nil) then
					table.insert(condfeatureindex[condname], rule)
					addedto[condname] = 1
				end

				if (cond[2] ~= nil) and cond[1] ~= "refers" then
					if (#cond[2] > 0) then
						local newconds = {}

						--alreadyused[target] = 1

						for a,b in ipairs(cond[2]) do
							local alreadyused = {}

							if (b ~= "all") and (b ~= "not all") then
								alreadyused[b] = 1
								table.insert(newconds, b)
							elseif (b == "all") then
								for a,mat in pairs(objectlist) do
									if (alreadyused[a] == nil) and (findnoun(a,nlist.short) == false) then
										table.insert(newconds, a)
										alreadyused[a] = 1
									end
								end
							elseif (b == "not all") then
								table.insert(newconds, "empty")
								table.insert(newconds, "text")
								table.insert(newconds, "glyph")
								table.insert(newconds, "event")
								table.insert(newconds, "node")
							end

							if (string.sub(b, 1, 5) == "group") or (string.sub(b, 1, 9) == "not group") then
								groupcond = true
							end
						end

						cond[2] = newconds
					end
				end
			end
		end

		if groupcond then
			table.insert(groupfeatures, rule)
		end

		local targetnot = string.sub(target, 1, 4)
		local targetnot_ = string.sub(target, 5)

		if (targetnot == "not ") and (objectlist[targetnot_] ~= nil) and (string.sub(targetnot_, 1, 5) ~= "group") and (string.sub(effect, 1, 5) ~= "group") and (string.sub(effect, 1, 9) ~= "not group") or (((string.sub(effect, 1, 5) == "group") or (string.sub(effect, 1, 9) == "not group")) and (targetnot_ == "all")) then
			if (targetnot_ ~= "all") then
				for i,mat in pairs(objectlist) do
					if (i ~= targetnot_) and (findnoun(i) == false) then
						local rule = {i,verb,effect}
						local newconds = {}
						for a,b in ipairs(conds) do
							table.insert(newconds, b)
						end
						addoption(rule,newconds,ids,false,{effect,#featureindex[effect]},tags)
					end
				end
			else
				local mats = {"empty","text","glyph","event","node"}

				for m,i in pairs(mats) do
					local rule = {i,verb,effect}
					local newconds = {}
					for a,b in ipairs(conds) do
						table.insert(newconds, b)
					end
					addoption(rule,newconds,ids,false,{effect,#featureindex[effect]},tags)
				end
			end
		end
	end
end

function codecheck(unitid,ox,oy,cdir_,ignore_end_,wordunitresult_)
	local unit = mmf.newObject(unitid)
	local ux,uy = unit.values[XPOS],unit.values[YPOS]
	local x = unit.values[XPOS] + ox
	local y = unit.values[YPOS] + oy
	local result = {}
	local letters = false
	local justletters = false
	local cdir = cdir_ or 0
	local wordunitresult = wordunitresult_ or {}

	local ignore_end = false
	if (ignore_end_ ~= nil) then
		ignore_end = ignore_end_
	end

	if (cdir == 0) then
		MF_alert("CODECHECK - CDIR == 0 - why??")
	end

	local tileid = x + y * roomsizex

	if (unitmap[tileid] ~= nil) then
		for i,b in ipairs(unitmap[tileid]) do
			local v = mmf.newObject(b)
			local w = 1

			if (v.values[TYPE] ~= 5) and (v.flags[DEAD] == false) then
				if (v.strings[UNITTYPE] == "text") then
					table.insert(result, {{b}, w, v.strings[NAME], v.values[TYPE], cdir})
				else
					if (#wordunits > 0) then
						local valid = false

						if (wordunitresult[b] ~= nil) and (wordunitresult[b] == 1) then
							valid = true
						elseif (wordunitresult[b] == nil) then
							for c,d in ipairs(wordunits) do
								if (b == d[1]) and testcond(d[2],d[1]) then
									valid = true
									break
								end
							end
						end

						if valid then
							if v.strings[UNITTYPE] == "node" then
								table.insert(result, {{b}, w, "node", v.values[TYPE], cdir})
							elseif not isglyph(v) then
								table.insert(result, {{b}, w, v.strings[UNITNAME], v.values[TYPE], cdir})
							elseif (v.strings[UNITTYPE] == "obj") then
								table.insert(result, {{b}, w, "obj", v.values[TYPE], cdir})
							else
								table.insert(result, {{b}, w, "glyph", 0, cdir})
							end
						end
					end
				end
			else
				justletters = true
			end
		end
	end

	if (letterunits_map[tileid] ~= nil) then
		for i,v in ipairs(letterunits_map[tileid]) do
			local unitids = v[7]
			local width = v[6]
			local word = v[1]
			local wtype = v[2]
			local dir = v[5]

			if (string.len(word) > 5) and (string.sub(word, 1, 5) == "text_") then
				word = string.sub(v[1], 6)
			end

			local valid = true
			if ignore_end and ((x ~= v[3]) or (y ~= v[4])) and (width > 1) then
				valid = false
			end

			if (cdir ~= 0) and (width > 1) then
				if ((cdir == 1) and (ux > v[3]) and (ux < v[3] + width)) or ((cdir == 2) and (uy > v[4]) and (uy < v[4] + width)) then
					valid = false
				end
			end

			--MF_alert(word .. ", " .. tostring(valid) .. ", " .. tostring(dir) .. ", " .. tostring(cdir))

			if (dir == cdir) and valid then
				table.insert(result, {unitids, width, word, wtype, dir})
				letters = true
			end
		end
	end

	return result,letters,justletters
end

function grouprules()
	groupmembers = {}
	local groupmembers_quick = {}

	local isgroup = {}
	local isnotgroup = {}
	local xgroup = {}
	local xnotgroup = {}
	local groupx = {}
	local notgroupx = {}
	local groupxgroup = {}
	local groupxgroup_diffname = {}
	local groupisnotgroup = {}
	local notgroupisgroup = {}

	local evilrecursion = false
	local notgroupisgroup_diffname = {}

	local memberships = {}

	local combined = {}

	for i,v in ipairs(groupfeatures) do
		local rule = v[1]
		local conds = v[2]

		local type_isgroup = false
		local type_isnotgroup = false
		local type_xgroup = false
		local type_xnotgroup = false
		local type_groupx = false
		local type_notgroupx = false
		local type_recursive = false

		local groupname1 = ""
		local groupname2 = ""

		if (string.sub(rule[1], 1, 5) == "group") then
			type_groupx = true
			groupname1 = rule[1]
		elseif (string.sub(rule[1], 1, 9) == "not group") then
			type_notgroupx = true
			groupname1 = string.sub(rule[1], 5)
		end

		if (string.sub(rule[3], 1, 5) == "group") then
			type_xgroup = true
			groupname2 = rule[3]

			if (rule[2] == "is") then
				type_isgroup = true
			end
		elseif (string.sub(rule[3], 1, 9) == "not group") then
			type_xnotgroup = true
			groupname2 = string.sub(rule[3], 5)

			if (rule[2] == "is") then
				type_isnotgroup = true
			end
		end

		if (conds ~= nil) and (#conds > 0) then
			for a,cond in ipairs(conds) do
				local params = cond[2] or {}
				for c,param in ipairs(params) do
					if (string.sub(param, 1, 5) == "group") or (string.sub(param, 1, 9) == "not group") then
						type_recursive = true
						break
					end
				end
			end
		end

		if type_isgroup then
			if (type_groupx == false) and (type_notgroupx == false) then
				table.insert(isgroup, {v, type_recursive})

				if (memberships[rule[3]] == nil) then
					memberships[rule[3]] = {}
				end

				if (memberships[rule[3]][rule[1]] == nil) then
					memberships[rule[3]][rule[1]] = {}
				end

				table.insert(memberships[rule[3]][rule[1]], {v, type_recursive})
			elseif (type_notgroupx == false) then
				if (groupname1 == groupname2) then
					table.insert(groupxgroup, {v, type_recursive})
				else
					table.insert(groupxgroup_diffname, {v, type_recursive})
				end
			else
				if (groupname1 == groupname2) then
					table.insert(notgroupisgroup, {v, type_recursive})
				else
					evilrecursion = true
					table.insert(notgroupisgroup_diffname, {v, type_recursive})
				end
			end
		elseif type_xgroup then
			if (type_groupx == false) and (type_notgroupx == false) then
				table.insert(xgroup, {v, type_recursive})
			else
				table.insert(groupxgroup, {v, type_recursive})
			end
		elseif type_isnotgroup then
			if (type_groupx == false) and (type_notgroupx == false) then
				if (isnotgroup[rule[1]] == nil) then
					isnotgroup[rule[1]] = {}
				end

				table.insert(isnotgroup[rule[1]], {v, type_recursive})

				if (xnotgroup[rule[1]] == nil) then
					xnotgroup[rule[1]] = {}
				end

				table.insert(xnotgroup[rule[1]], {v, type_recursive})
			elseif (type_notgroupx == false) then
				if (groupname1 == groupname2) then
					table.insert(groupisnotgroup, {v, type_recursive})
				else
					table.insert(groupxgroup_diffname, {v, type_recursive})
				end
			else
				if (groupname1 == groupname2) then
					table.insert(groupxgroup, {v, type_recursive})
				else
					evilrecursion = true
					table.insert(notgroupisgroup_diffname, {v, type_recursive})
				end
			end
		elseif type_xnotgroup then
			if (xnotgroup[rule[1]] == nil) then
				xnotgroup[rule[1]] = {}
			end

			table.insert(xnotgroup[rule[1]], {v, type_recursive})
		elseif type_groupx then
			table.insert(groupx, {v, type_recursive})
		elseif type_notgroupx then
			table.insert(notgroupx, {v, type_recursive})
		end
	end

	local diffname_done = false
	local diffname_used = {}

	while (diffname_done == false) do
		diffname_done = true

		for i,v_ in ipairs(groupxgroup_diffname) do
			if (diffname_used[i] == nil) then
				local v = v_[1]
				local recursion = v_[2] or false

				local rule = v[1]
				local conds = v[2]
				local ids = v[3]
				local tags = v[4]

				local gn1 = rule[1]
				local gn2 = rule[3]

				local notrule = false
				if (string.sub(gn2, 1, 4) == "not ") then
					notrule = true
				end

				local newconds = {}
				newconds = copyconds(newconds,conds)

				for a,b_ in ipairs(isgroup) do
					local b = b_[1]
					local brec = b_[2] or recursion or false
					local grule = b[1]
					local gconds = b[2]

					if (grule[3] == gn1) then
						diffname_used[i] = 1
						diffname_done = false

						newconds = copyconds(newconds,gconds)

						local newrule = {grule[1],"is",gn2}

						if (notrule == false) then
							table.insert(isgroup, {{newrule,newconds,ids,tags}, brec})
						else
							if (isnotgroup[grule[1]] == nil) then
								isnotgroup[grule[1]] = {}
							end

							table.insert(isnotgroup[grule[1]], {{newrule,newconds,ids,tags}, brec})
						end
					end
				end
			end
		end
	end

	if evilrecursion then
		diffname_done = false
		local evilrec_id = ""
		local evilrec_id_base = ""
		local evilrec_memberships_base = {}
		local evilrec_memberships_quick = {}

		local evilrec_limit = 0

		for i,v in pairs(memberships) do
			evilrec_id_base = evilrec_id_base .. i
			for a,b in pairs(v) do
				evilrec_id_base = evilrec_id_base .. a

				if (evilrec_memberships_quick[i] == nil) then
					evilrec_memberships_quick[i] = {}
				end

				evilrec_memberships_quick[i][a] = b

				if (evilrec_memberships_base[i] == nil) then
					evilrec_memberships_base[i] = {}
				end

				evilrec_memberships_base[i][a] = b
			end
		end

		evilrec_id = evilrec_id_base

		while (diffname_done == false) and (evilrec_limit < 10) do
			local foundmembers = {}
			local foundid = evilrec_id_base

			for i,v in pairs(evilrec_memberships_base) do
				foundid = foundid .. i
				for a,b in pairs(v) do
					foundid = foundid .. a
				end
			end

			for i,v_ in ipairs(notgroupisgroup_diffname) do
				local v = v_[1]
				local recursion = v_[2] or false

				local rule = v[1]
				local conds = v[2]
				local ids = v[3]
				local tags = v[4]

				local notrule = false
				local gn1 = string.sub(rule[1], 5)
				local gn2 = rule[3]

				if (string.sub(gn2, 1, 4) == "not ") then
					notrule = true
					gn2 = string.sub(gn2, 5)
				end

				if (foundmembers[gn2] == nil) then
					foundmembers[gn2] = {}
				end

				for a,b in pairs(objectlist) do
					if (findnoun(a) == false) and ((evilrec_memberships_quick[gn1] == nil) or ((evilrec_memberships_quick[gn1] ~= nil) and (evilrec_memberships_quick[gn1][a] == nil))) then
						if (foundmembers[gn2][a] == nil) then
							foundmembers[gn2][a] = {}
						end

						table.insert(foundmembers[gn2][a], {v, recursion})
					end
				end
			end

			for i,v in pairs(foundmembers) do
				foundid = foundid .. i
				for a,b in pairs(v) do
					foundid = foundid .. a
				end
			end

			-- MF_alert(foundid .. " == " .. evilrec_id)

			if (foundid == evilrec_id) then
				diffname_done = true

				for i,v in pairs(foundmembers) do
					for a,d in pairs(v) do
						for c,b_ in ipairs(d) do
							local b = b_[1]
							local brule = b[1]
							local rec = b_[2] or false

							local newrule = {a,"is",brule[3]}
							local newconds = {}
							newconds = copyconds(newconds,b[2])
							local newids = concatenate(b[3])
							local newtags = concatenate(b[4])

							if (string.sub(brule[3], 1, 4) ~= "not ") then
								table.insert(isgroup, {{newrule,newconds,newids,newtags}, rec})
							else
								if (isnotgroup[a] == nil) then
									isnotgroup[a] = {}
								end

								table.insert(isnotgroup[a], {{newrule,newconds,newids,newtags}, rec})
							end
						end
					end
				end
			else
				evilrec_memberships_quick = {}
				evilrec_id = foundid

				for i,v in pairs(evilrec_memberships_base) do
					evilrec_memberships_quick[i] = {}

					for a,b in pairs(v) do
						evilrec_memberships_quick[i][a] = b
					end
				end

				for i,v in pairs(foundmembers) do
					evilrec_memberships_quick[i] = {}

					for a,b in pairs(v) do
						evilrec_memberships_quick[i][a] = b
					end
				end

				evilrec_limit = evilrec_limit + 1
			end
		end

		if (evilrec_limit >= 10) then
			HACK_INFINITY = 200
			destroylevel("infinity")
			return
		end
	end

	memberships = {}

	for i,v_ in ipairs(isgroup) do
		local v = v_[1]
		local recursion = v_[2] or false

		local rule = v[1]
		local conds = v[2]
		local ids = v[3]
		local tags = v[4]

		local name_ = rule[1]
		local namelist = {}

		if (string.sub(name_, 1, 4) ~= "not ") then
			namelist = {name_}
		elseif (name_ ~= "not all") then
			for a,b in pairs(objectlist) do
				if (findnoun(a) == false) and (a ~= string.sub(name_, 5)) then
					table.insert(namelist, a)
				end
			end
		end

		for index,name in ipairs(namelist) do
			local never = false

			local prevents = {}

			if (isnotgroup[name] ~= nil) then
				for a,b_ in ipairs(isnotgroup[name]) do
					local b = b_[1]
					local brule = b[1]

					local grouptype = string.sub(brule[3], 5)

					if (grouptype == rule[3]) then
						recursion = b_[2] or recursion
						local pconds,crashy,neverfound = invertconds(b[2])

						if (neverfound == false) then
							for a,cond in ipairs(pconds) do
								table.insert(prevents, cond)
							end
						else
							never = true
							break
						end
					end
				end
			end

			if (never == false) then
				local fconds = {}
				fconds = copyconds(fconds,conds)
				fconds = copyconds(fconds,prevents)

				table.insert(groupmembers, {name,fconds,rule[3],recursion})

				if (groupmembers_quick[name .. "_" .. rule[3]] == nil) then
					groupmembers_quick[name .. "_" .. rule[3]] = {}
				end

				table.insert(groupmembers_quick[name .. "_" .. rule[3]], {name,fconds,rule[3],recursion})

				if (memberships[rule[3]] == nil) then
					memberships[rule[3]] = {}
				end

				table.insert(memberships[rule[3]], {name,fconds})

				for a,b_ in ipairs(groupx) do
					local b = b_[1]
					recursion = b_[2] or recursion

					local grule = b[1]
					local gconds = b[2]
					local gids = b[3]
					local gtags = b[4]

					if (grule[1] == rule[3]) then
						local newrule = {name,grule[2],grule[3]}
						local newconds = {}
						local newids = concatenate(ids,gids)
						local newtags = concatenate(tags,gtags)

						newconds = copyconds(newconds,conds)
						newconds = copyconds(newconds,gconds)

						if (#prevents == 0) then
							table.insert(combined, {newrule,newconds,newids,newtags})
						else
							newconds = copyconds(newconds,prevents)
							table.insert(combined, {newrule,newconds,newids,newtags})
						end
					end
				end
			end
		end
	end

	for i,v_ in ipairs(groupxgroup) do
		local v = v_[1]
		local recursion = v_[2] or false

		local rule = v[1]
		local conds = v[2]
		local ids = v[3]
		local tags = v[4]

		local gn1 = rule[1]
		local gn2 = rule[3]

		local never = false

		local notrule = false
		if (string.sub(gn1, 1, 4) == "not ") then
			notrule = true
			gn1 = string.sub(gn1, 5)
		end

		local prevents = {}
		if (xnotgroup[gn1] ~= nil) then
			for a,b_ in ipairs(xnotgroup[gn1]) do
				local b = b_[1]
				local brule = b[1]

				if (brule[1] == rule[1]) and (brule[2] == rule[2]) and (brule[3] == "not " .. rule[3]) then
					recursion = b_[2] or recursion

					local pconds,crashy,neverfound = invertconds(b[2])

					if (neverfound == false) then
						for a,cond in ipairs(pconds) do
							table.insert(prevents, cond)
						end
					else
						never = true
						break
					end
				end
			end
		end

		if (never == false) then
			local team1 = {}
			local team2 = {}

			if (notrule == false) then
				if (memberships[gn1] ~= nil) then
					for a,b in ipairs(memberships[gn1]) do
						table.insert(team1, b)
					end
				end
			else
				local ignorethese = {}

				if (memberships[gn1] ~= nil) then
					for a,b in ipairs(memberships[gn1]) do
						ignorethese[b[1]] = 1

						local iconds,icrash,inever = invertconds(b[2])

						if (inever == false) then
							table.insert(team1, {b[1],iconds})
						end
					end
				end

				for a,b in pairs(objectlist) do
					if (findnoun(a) == false) and (ignorethese[a] == nil) then
						table.insert(team1, {a})
					end
				end
			end

			if (memberships[gn2] ~= nil) then
				for a,b in ipairs(memberships[gn2]) do
					table.insert(team2, b)
				end
			end

			for a,b in ipairs(team1) do
				for c,d in ipairs(team2) do
					local newrule = {b[1],rule[2],d[1]}
					local newconds = {}
					newconds = copyconds(newconds,conds)

					if (b[2] ~= nil) then
						newconds = copyconds(newconds,b[2])
					end

					if (d[2] ~= nil) then
						newconds = copyconds(newconds,d[2])
					end

					if (#prevents > 0) then
						newconds = copyconds(newconds,prevents)
					end

					local newids = concatenate(ids)
					local newtags = concatenate(tags)

					table.insert(combined, {newrule,newconds,newids,newtags})
				end
			end
		end
	end

	if (#notgroupx > 0) then
		for name,v in pairs(objectlist) do
			if (findnoun(name) == false) then
				for a,b_ in ipairs(notgroupx) do
					local b = b_[1]
					local recursion = b_[2] or false

					local rule = b[1]
					local conds = b[2]
					local ids = b[3]
					local tags = b[4]

					local newconds = {}
					newconds = copyconds(newconds,conds)

					local groupname = string.sub(rule[1], 5)
					local valid = true

					if (groupmembers_quick[name .. "_" .. groupname] ~= nil) then
						for c,d in ipairs(groupmembers_quick[name .. "_" .. groupname]) do
							recursion = d[4] or recursion

							local iconds,icrash,inever = invertconds(d[2])
							newconds = copyconds(newconds,iconds)

							if inever then
								valid = false
								break
							end
						end
					end

					if valid then
						local newrule = {name,rule[2],rule[3]}
						local newids = {}
						local newtags = {}
						newids = concatenate(newids,ids)
						newtags = concatenate(newtags,tags)

						table.insert(combined, {newrule,newconds,newids,newtags})
					end
				end
			end
		end
	end

	for i,v_ in ipairs(xgroup) do
		local v = v_[1]
		local recursion = v_[2] or false

		local rule = v[1]
		local conds = v[2]
		local ids = v[3]
		local tags = v[4]

		if (string.sub(rule[1], 1, 5) ~= "group") and (string.sub(rule[1], 1, 9) ~= "not group") and (rule[2] ~= "is") then
			local team2 = {}

			if (memberships[rule[3]] ~= nil) then
				for a,b in ipairs(memberships[rule[3]]) do
					table.insert(team2, b)
				end
			end

			for a,b in ipairs(team2) do
				local newrule = {rule[1],rule[2],b[1]}
				local newconds = {}
				newconds = copyconds(newconds,conds)

				if (b[2] ~= nil) then
					newconds = copyconds(newconds,b[2])
				end

				local newids = concatenate(ids)
				local newtags = concatenate(tags)

				table.insert(combined, {newrule,newconds,newids,newtags})
			end
		end
	end

	for i,k in pairs(xnotgroup) do
		for c,v_ in ipairs(k) do
			local v = v_[1]
			local recursion = v_[2] or false

			local rule = v[1]
			local conds = v[2]
			local ids = v[3]
			local tags = v[4]

			if (string.sub(rule[1], 1, 5) ~= "group") and (string.sub(rule[1], 1, 9) ~= "not group") and (rule[2] ~= "is") then
				local team2 = {}

				local gn2 = string.sub(rule[3], 5)

				if (memberships[gn2] ~= nil) then
					for a,b in ipairs(memberships[gn2]) do
						table.insert(team2, b)
					end
				end

				for a,b in ipairs(team2) do
					local newrule = {rule[1],rule[2],"not " .. b[1]}
					local newconds = {}
					newconds = copyconds(newconds,conds)

					if (b[2] ~= nil) then
						newconds = copyconds(newconds,b[2])
					end

					local newids = concatenate(ids)
					local newtags = concatenate(tags)

					table.insert(combined, {newrule,newconds,newids,newtags})
				end
			end
		end
	end

	for i,v_ in ipairs(groupisnotgroup) do
		local v = v_[1]
		local recursion = v_[2] or false

		local rule = v[1]
		local conds = v[2]
		local ids = v[3]
		local tags = v[4]

		local team1 = {}

		if (memberships[rule[1]] ~= nil) then
			for a,b in ipairs(memberships[rule[1]]) do
				table.insert(team1, b)
			end
		end

		for a,b in ipairs(team1) do
			local newrule = {b[1],"is","crash"}
			local newconds = {}
			newconds = copyconds(newconds,conds)

			if (b[2] ~= nil) then
				newconds = copyconds(newconds,b[2])
			end

			local newids = concatenate(ids)
			local newtags = concatenate(tags)

			table.insert(combined, {newrule,newconds,newids,newtags})
		end
	end

	for i,v_ in ipairs(notgroupisgroup) do
		local v = v_[1]
		local recursion = v_[2] or false

		local rule = v[1]
		local conds = v[2]
		local ids = v[3]
		local tags = v[4]

		local team1 = {}

		local gn1 = string.sub(rule[1], 5)

		local ignorethese = {}

		if (memberships[gn1] ~= nil) then
			for a,b in ipairs(memberships[gn1]) do
				ignorethese[b[1]] = 1

				local iconds,icrash,inever = invertconds(b[2])

				if (inever == false) then
					table.insert(team1, {b[1],iconds})
				end
			end
		end

		for a,b in pairs(objectlist) do
			if (findnoun(a) == false) and (ignorethese[a] == nil) then
				table.insert(team1, {a})
			end
		end

		for a,b in ipairs(team1) do
			local newrule = {b[1],"is","crash"}
			local newconds = {}
			newconds = copyconds(newconds,conds)

			if (b[2] ~= nil) then
				newconds = copyconds(newconds,b[2])
			end

			local newids = concatenate(ids)
			local newtags = concatenate(tags)

			table.insert(combined, {newrule,newconds,newids,newtags})
		end
	end

	for i,v in ipairs(combined) do
		addoption(v[1],v[2],v[3],false,nil,v[4])
	end
end

function findwordunits()
	local result = {}
	local alreadydone = {}
	local checkrecursion = {}
	local related = {}

	local identifier = ""
	local fullid = {}

	if (featureindex["word"] ~= nil) then
		for i,v in ipairs(featureindex["word"]) do
			local rule = v[1]
			local conds = v[2]
			local ids = v[3]

			local name = rule[1]
			local subid = ""

			if (rule[2] == "is") then
				if ((objectlist[name] ~= nil) or (name == "obj") or ((name == "glyph") and (#glyphunits > -1))) and (name ~= "text") and (alreadydone[name] == nil) then
					local these = findall({name,{}})
					alreadydone[name] = 1

					if (#these > 0) then
						for a,b in ipairs(these) do
							local bunit = mmf.newObject(b)
							local unitname = ""
							if name == "text" then
								unitname = bunit.strings[UNITNAME]
							else
								unitname = name
							end
							local valid = true

							if (featureindex["broken"] ~= nil) then
								if (hasfeature(getname(bunit),"is","broken",b,bunit.values[XPOS],bunit.values[YPOS]) ~= nil) then
									valid = false
								end
							end

							if valid then
								table.insert(result, {b, conds})
								subid = subid .. unitname
								-- LISÄÄ TÄHÄN LISÄÄ DATAA
							end
						end
					end
				end

				if (#subid > 0) then
					for a,b in ipairs(conds) do
						local condtype = b[1]
						local params = b[2] or {}

						subid = subid .. condtype

						if (#params > 0) then
							for c,d in ipairs(params) do
								subid = subid .. tostring(d)

								related = findunits(d,related,conds)
							end
						end
					end
				end

				table.insert(fullid, subid)

				--MF_alert("Going through " .. name)

				if (#ids > 0) then
					if (#ids[1] == 1) then
						local firstunit = mmf.newObject(ids[1][1])

						local notname = name
						if (string.sub(name, 1, 4) == "not ") then
							notname = string.sub(name, 5)
						end

						if (firstunit.strings[UNITNAME] ~= "text_" .. name) and (firstunit.strings[UNITNAME] ~= "text_" .. notname) then
							--MF_alert("Checking recursion for " .. name)
							table.insert(checkrecursion, {name, i})
						end
					end
				else
					MF_alert("No ids listed in Word-related rule! rules.lua line 1302 - this needs fixing asap (related to grouprules line 1118)")
				end
			end
		end

		table.sort(fullid)
		for i,v in ipairs(fullid) do
			-- MF_alert("Adding " .. v .. " to id")
			identifier = identifier .. v
		end

		--MF_alert("Identifier: " .. identifier)

		for a,checkname_ in ipairs(checkrecursion) do
			local found = false

			local checkname = checkname_[1]

			local b = checkname
			if (string.sub(b, 1, 4) == "not ") then
				b = string.sub(checkname, 5)
			end

			for i,v in ipairs(featureindex["word"]) do
				local rule = v[1]
				local ids = v[3]
				local tags = v[4]

				if (rule[1] == b) or ((rule[1] == "glyph") and (string.sub(b, 1, 6) == "glyph_")) or (rule[1] == "all") or ((rule[1] ~= b) and (string.sub(rule[1], 1, 3) == "not")) then
					for c,g in ipairs(ids) do
						for a,d in ipairs(g) do
							local idunit = mmf.newObject(d)
							local start = rule[1]
							if tags[2] == "metaglyph" then
								start = tags[3]
							elseif tags[2] == "metatext" then
								start = tags[3]
							end

							-- Tässä pitäisi testata myös Group!
							if (((tags[2] == "metatext") or (tags[2] == "metaglyph")) and (idunit.strings[UNITNAME] == start)) or (idunit.strings[UNITNAME] == "text_" .. start) or ((idunit.strings[UNITNAME] == "glyph_" .. start) and (tags[1] == "glyphrule")) or ((idunit.strings[UNITNAME] == start) and (tags[1] == "glyphrule")) or ((start == "all") and (name ~= "glyph")) then
								--MF_alert("Matching objects - found")
								found = true
							elseif (string.sub(start, 1, 5) == "group") then
								--MF_alert("Group - found")
								found = true
							elseif (start ~= checkname) and (((string.sub(start, 1, 3) == "not") and (start ~= "glyph")) or ((start == "not all") and (start == "glyph"))) then
								--MF_alert("Not Object - found")
								found = true
							end
						end
					end

					for c,g in ipairs(tags) do
						if (g == "mimic") then
							found = true
						end
					end
				end
			end

			if (found == false) then
				--MF_alert("Wordunit status for " .. b .. " is unstable!")
				identifier = "null"
				wordunits = {}

				for i,v in pairs(featureindex["word"]) do
					local rule = v[1]
					local ids = v[3]

					--MF_alert("Checking to disable: " .. rule[1] .. " " .. ", not " .. b)

					if (rule[1] == b) or (rule[1] == "not " .. b) then
						v[2] = {{"never",{}}}
					end
				end

				if (string.sub(checkname, 1, 4) == "not ") then
					local notrules_word = notfeatures["word"]
					local notrules_id = checkname_[2]
					local disablethese = notrules_word[notrules_id]

					for i,v in ipairs(disablethese) do
						v[2] = {{"never",{}}}
					end
				end
			end
		end
	end

	--MF_alert("Current id (end): " .. identifier)

	return result,identifier,related
end

function postrules(alreadyrun_)
	local protects = {}
	local newruleids = {}
	local ruleeffectlimiter = {}
	local playrulesound = false
	local alreadyrun = alreadyrun_ or false

	for i,unit in ipairs(units) do
		unit.active = false
	end

	local limit = #features

	for i,rules in ipairs(features) do
		if (i <= limit) then
			local rule = rules[1]
			local conds = rules[2]
			local ids = rules[3]

			if (rule[1] == rule[3]) and (rule[2] == "is") then
				table.insert(protects, i)
			end

			if (ids ~= nil) then
				local works = true
				local idlist = {}
				local effectsok = false

				if (#ids > 0) then
					for a,b in ipairs(ids) do
						table.insert(idlist, b)
					end
				end

				if (#idlist > 0) and works then
					for a,d in ipairs(idlist) do
						for c,b in ipairs(d) do
							if (b ~= 0) then
								local bunit = mmf.newObject(b)

								if (bunit.strings[UNITTYPE] == "text" or bunit.strings[UNITTYPE] == "node") or (string.sub(bunit.strings[UNITNAME], 1, 6) == "glyph_") then
									bunit.active = true
									setcolour(b,"active")
								end
								newruleids[b] = 1

								if (ruleids[b] == nil) and (#undobuffer > 1) and (alreadyrun == false) and (generaldata5.values[LEVEL_DISABLERULEEFFECT] == 0) then
									if (ruleeffectlimiter[b] == nil) then
										local x,y = bunit.values[XPOS],bunit.values[YPOS]
										local c1,c2 = getcolour(b,"active")
										--MF_alert(b)
										MF_particles_for_unit("bling",x,y,5,c1,c2,1,1,b)
										ruleeffectlimiter[b] = 1
									end

									if (rule[2] ~= "play") then
										playrulesound = true
									end
								end
							end
						end
					end
				elseif (#idlist > 0) and (works == false) then
					for a,visualrules in pairs(visualfeatures) do
						local vrule = visualrules[1]
						local same = comparerules(rule,vrule)

						if same then
							table.remove(visualfeatures, a)
						end
					end
				end
			end

			local rulenot = 0
			local neweffect = ""

			local nothere = string.sub(rule[3], 1, 4)

			if (nothere == "not ") then
				rulenot = 1
				neweffect = string.sub(rule[3], 5)
			end

			if (rulenot == 1) then
				local newconds,crashy = invertconds(conds,nil,rule[3])

				local newbaserule = {rule[1],rule[2],neweffect}

				local target = rule[1]
				local verb = rule[2]

				local targetlists = {}
				table.insert(targetlists, target)

				if (verb == "is") and (neweffect == "text") and (featureindex["write"] ~= nil) then
					table.insert(targetlists, "write")
				end

				if (verb == "is") and (neweffect == "glyph") and (featureindex["inscribe"] ~= nil) then
					table.insert(targetlists, "inscribe")
				end

				for e,g in ipairs(targetlists) do
					for a,b in ipairs(featureindex[g]) do
						local same = comparerules(newbaserule,b[1])

						if same or ((g == "inscribe") and (target == b[1][1]) and (b[1][2] == "inscribe")) or ((g == "write") and (target == b[1][1]) and (b[1][2] == "write")) or ((((neweffect == "text") and (string.sub(b[1][3], 1, 5)=="text_")) or ((neweffect == "glyph") and (string.sub(b[1][3], 1, 6)=="glyph_"))) and (target == b[1][1]) and (verb == b[1][2])) then
							--MF_alert(rule[1] .. ", " .. rule[2] .. ", " .. neweffect .. ": " .. b[1][1] .. ", " .. b[1][2] .. ", " .. b[1][3])
							local theseconds = b[2]

							if (#newconds > 0) then
								if (newconds[1] ~= "never") then
									for c,d in ipairs(newconds) do
										table.insert(theseconds, d)
									end
								else
									theseconds = {"never",{}}
								end
							end

							if crashy then
								addoption({rule[1],"is","crash"},theseconds,ids,false,nil,rules[4])
							end

							b[2] = theseconds
						end
					end
				end
			end
		end
	end

	if (#protects > 0) then
		for i,v in ipairs(protects) do
			local rule = features[v]

			local baserule = rule[1]
			local conds = rule[2]

			local target = baserule[1]

			local newconds = {{"never",{}}}

			if (conds[1] ~= "never") then
				if (#conds > 0) then
					newconds = {}

					for a,b in ipairs(conds) do
						local condword = b[1]
						local condgroup = {}

						if (string.sub(condword, 1, 1) == "(") then
							condword = string.sub(condword, 2)
						end

						if (string.sub(condword, -1) == ")") then
							condword = string.sub(condword, 1, #condword - 1)
						end

						local newcondword = "not " .. condword

						if (string.sub(condword, 1, 3) == "not") then
							newcondword = string.sub(condword, 5)
						end

						if (a == 1) then
							newcondword = "(" .. newcondword
						end

						if (a == #conds) then
							newcondword = newcondword .. ")"
						end

						if (b[2] ~= nil) then
							for c,d in ipairs(b[2]) do
								table.insert(condgroup, d)
							end
						end

						table.insert(newconds, {newcondword, condgroup})
					end
				end

				if (featureindex[target] ~= nil) then
					for a,rules in ipairs(featureindex[target]) do
						local targetrule = rules[1]
						local targetconds = rules[2]
						local object = targetrule[3]

						if (targetrule[1] == target) and (((targetrule[2] == "is") and (target ~= object)) or ((targetrule[2] == "inscribe") and (string.sub(object, 1, 4) ~= "not ")) or ((targetrule[2] == "write") and (string.sub(object, 1, 4) ~= "not "))) and ((getmat(object) ~= nil) or (getmat_text(object) ~= false) or (object == "revert") or ((targetrule[2] == "inscribe") and (string.sub(object, 1, 4) ~= "not ")) or ((targetrule[2] == "write") and (string.sub(object, 1, 4) ~= "not "))) and (string.sub(object, 1, 5) ~= "group") then
							if (#newconds > 0) then
								if (newconds[1] == "never") then
									targetconds = {}
								end

								for c,d in ipairs(newconds) do
									table.insert(targetconds, d)
								end
							end

							rules[2] = targetconds
						end
					end
				end
			end
		end
	end

	ruleids = newruleids

	if (spritedata.values[VISION] == 0) then
		ruleblockeffect()
	end

	return playrulesound
end



function docode(firstwords)
	local donefirstwords = {}
	local existingfinals = {}
	local limiter = 0

	if (#firstwords > 0) then
		for k,unitdata in ipairs(firstwords) do
			if (type(unitdata[1]) == "number") then
				timedmessage("Old rule format detected. Please replace modified .lua files to ensure functionality.")
			end

			local unitids = unitdata[1]
			local unitid = unitids[1]
			local dir = unitdata[2]
			local width = unitdata[3]
			local word = unitdata[4]
			local wtype = unitdata[5]
			local existing = unitdata[6] or {}
			local existing_wordid = unitdata[7] or 1
			local existing_id = unitdata[8] or ""

			if (string.sub(word, 1, 5) == "text_") then
				word = string.sub(word, 6)
			end

			local unit = mmf.newObject(unitid)
			local x,y = unit.values[XPOS],unit.values[YPOS]
			local tileid_id = x + y * roomsizex
			local unique_id = tostring(tileid_id) .. "_" .. existing_id

			--MF_alert("Testing " .. word .. ": " .. tostring(donefirstwords[unique_id]) .. ", " .. tostring(dir) .. ", " .. tostring(unitid) .. ", " .. tostring(unique_id))

			limiter = limiter + 1

			if (limiter > 5000) then
				MF_alert("Level destroyed - firstwords run too many times")
				destroylevel("toocomplex")
				return
			end

			--[[
			MF_alert("Current unique id: " .. tostring(unique_id))

			if (donefirstwords[unique_id] ~= nil) and (donefirstwords[unique_id][dir] ~= nil) then
				MF_alert("Already used: " .. tostring(unitid) .. ", " .. tostring(unique_id))
			end
			]]--

			if (donefirstwords[unique_id] == nil) or ((donefirstwords[unique_id] ~= nil) and (donefirstwords[unique_id][dir] == nil)) and (limiter < 5000) then
				local ox,oy = 0,0
				local name = word

				local drs = dirs[dir]
				ox = drs[1]
				oy = drs[2]

				if (donefirstwords[unique_id] == nil) then
					donefirstwords[unique_id] = {}
				end

				donefirstwords[unique_id][dir] = 1

				local sentences = {}
				local finals = {}
				local maxlen = 0
				local variations = 1
				local sent_ids = {}
				local newfirstwords = {}

				if (#existing == 0) then
					sentences,finals,maxlen,variations,sent_ids,newfirstwords = calculatesentences(unitid,x,y,dir)
				else
					sentences[1] = existing
					maxlen = 3
					finals[1] = {}
					sent_ids = {existing_id}
				end

				if (sentences == nil) then
					return
				end

				if (#newfirstwords > 0) then
					for i,v in ipairs(newfirstwords) do
						table.insert(firstwords, v)
					end
				end

				--[[
				-- BIG DEBUG MESS
				if (variations > 0) then
					for i=1,variations do
						local dsent = ""
						local currsent = sentences[i]

						for a,b in ipairs(currsent) do
							dsent = dsent .. b[1] .. " "
						end

						MF_alert(tostring(k) .. ": Variant " .. tostring(i) .. ": " .. dsent)
					end
				end
				]]--

				if (maxlen > 2) then
					for i=1,variations do
						local current = finals[i]
						local letterword = ""
						local stage = 0
						local prevstage = 0
						local tileids = {}

						local notids = {}
						local notwidth = 0
						local notslot = 0

						local stage3reached = false
						local stage2reached = false
						local doingcond = false
						local nocondsafterthis = false
						local condsafeand = false

						local firstrealword = false
						local letterword_prevstage = 0
						local letterword_firstid = 0

						local currtiletype = 0
						local prevtiletype = 0

						local prevsafewordid = 0
						local prevsafewordtype = 0

						local stop = false

						local sent = sentences[i]
						local sent_id = sent_ids[i]

						local thissent = ""

						local j = 0
						for wordid=existing_wordid,#sent do
							j = j + 1

							local s = sent[wordid]
							local nexts = sent[wordid + 1] or {-1, -1, {-1}, 1}

							prevtiletype = currtiletype

							local tilename = s[1]
							local tiletype = s[2]
							local tileid = s[3][1]
							local tilewidth = s[4]

							if (string.sub(tilename, 1, 10) == "text_text_") then
								tilename = string.sub(tilename, 6)
							end
							if (string.sub(tilename, 1, 6) == "event_") then
								stop = true
							end

							local wordtile = false

							currtiletype = tiletype

							thissent = thissent .. tilename .. "," .. tostring(wordid) .. "  "

							for a,b in ipairs(s[3]) do
								table.insert(tileids, b)
							end

							--[[
								0 = objekti
								1 = verbi
								2 = quality
								3 = alkusana (LONELY)
								4 = Not
								5 = letter
								6 = And
								7 = ehtosana
								8 = customobject
							]]--

							if (tiletype ~= 5) then
								if (stage == 0) then
									if (tiletype == 0) then
										prevstage = stage
										stage = 2
									elseif (tiletype == 3) then
										prevstage = stage
										stage = 1
									elseif (tiletype ~= 4) then
										prevstage = stage
										stage = -1
										stop = true
									end
								elseif (stage == 1) then
									if (tiletype == 0) then
										prevstage = stage
										stage = 2
									elseif (tiletype == 6) then
										prevstage = stage
										stage = 6
									elseif (tiletype ~= 4) then
										prevstage = stage
										stage = -1
										stop = true
									end
								elseif (stage == 2) then
									if (wordid ~= #sent) then
										if (tiletype == 1) and (prevtiletype ~= 4) and ((prevstage ~= 4) or doingcond or (stage3reached == false)) then
											stage2reached = true
											doingcond = false
											prevstage = stage
											nocondsafterthis = true
											stage = 3
										elseif (tiletype == 7) and (stage2reached == false) and (nocondsafterthis == false) and ((doingcond == false) or (prevstage ~= 4)) then
											doingcond = true
											prevstage = stage
											stage = 3
										elseif (tiletype == 6) and (prevtiletype ~= 4) then
											prevstage = stage
											stage = 4
										elseif (tiletype ~= 4) then
											prevstage = stage
											stage = -1
											stop = true
										end
									else
										stage = -1
										stop = true
									end
								elseif (stage == 3) then
									stage3reached = true

									if (tiletype == 0) or (tiletype == 2) or (tiletype == 8) then
										prevstage = stage
										stage = 5
									elseif (tiletype ~= 4) then
										stage = -1
										stop = true
									end
								elseif (stage == 4) then
									if (wordid <= #sent) then
										if (tiletype == 0) or ((tiletype == 2) and stage3reached) or ((tiletype == 8) and stage3reached) then
											prevstage = stage
											stage = 2
										elseif ((tiletype == 1) and stage3reached) and (doingcond == false) and (prevtiletype ~= 4) then
											stage2reached = true
											nocondsafterthis = true
											prevstage = stage
											stage = 3
										elseif (tiletype == 7) and (nocondsafterthis == false) and ((prevtiletype ~= 6) or ((prevtiletype == 6) and doingcond)) then
											doingcond = true
											stage2reached = true
											prevstage = stage
											stage = 3
										elseif (tiletype ~= 4) then
											prevstage = stage
											stage = -1
											stop = true
										end
									else
										stage = -1
										stop = true
									end
								elseif (stage == 5) then
									if (wordid ~= #sent) then
										if (tiletype == 1) and doingcond and (prevtiletype ~= 4) then
											stage2reached = true
											doingcond = false
											prevstage = stage
											nocondsafterthis = true
											stage = 3
										elseif (tiletype == 6) and (prevtiletype ~= 4) then
											prevstage = stage
											stage = 4
										elseif (tiletype ~= 4) then
											prevstage = stage
											stage = -1
											stop = true
										end
									else
										stage = -1
										stop = true
									end
								elseif (stage == 6) then
									if (tiletype == 3) then
										prevstage = stage
										stage = 1
									elseif (tiletype ~= 4) then
										prevstage = stage
										stage = -1
										stop = true
									end
								end
							end

							if (stage > 0) then
								firstrealword = true
							end

							if (tiletype == 4) then
								if (#notids == 0) or (prevtiletype == 0) then
									notids = s[3]
									notwidth = tilewidth
									notslot = wordid
								end
							else
								if (stop == false) and (tiletype ~= 0) then
									notids = {}
									notwidth = 0
									notslot = 0
								end
							end

							if (prevtiletype ~= 4) and (wordid > existing_wordid) then
								prevsafewordid = wordid - 1
								prevsafewordtype = prevtiletype
							end

							if (prevtiletype == 4) and (tiletype == 6) then
								stop = true
								stage = -1
							end

							--MF_alert(tilename .. ", " .. tostring(wordid) .. ", " .. tostring(stage) .. ", " .. tostring(#sent) .. ", " .. tostring(tiletype) .. ", " .. tostring(prevtiletype) .. ", " .. tostring(stop) .. ", " .. name .. ", " .. tostring(i))

							--MF_alert(tostring(k) .. "_" .. tostring(i) .. "_" .. tostring(wordid) .. ": " .. tilename .. ", " .. tostring(tiletype) .. ", " .. tostring(stop) .. ", " .. tostring(stage) .. ", " .. tostring(letterword_firstid).. ", " .. tostring(prevtiletype))

							if (stop == false) then
								local subsent_id = string.sub(sent_id, (wordid - existing_wordid)+1)
								current.sent = sent
								table.insert(current, {tilename, tiletype, tileids, tilewidth, wordid, subsent_id})
								tileids = {}

								if (wordid == #sent) and (#current >= 3) and (j > 1) then
									subsent_id = tostring(tileid_id) .. "_" .. string.sub(sent_id, 1, j) .. "_" .. tostring(dir)
									--MF_alert("Checking finals: " .. subsent_id .. ", " .. tostring(existingfinals[subsent_id]))
									if (existingfinals[subsent_id] == nil) then
										existingfinals[subsent_id] = 1
									else
										finals[i] = {}
									end
								end
							else
								for a=1,#s[3] do
									if (#tileids > 0) then
										table.remove(tileids, #tileids)
									end
								end

								if (tiletype == 0) and (prevtiletype == 0) and (#notids > 0) then
									notids = {}
									notwidth = 0
								end

								if (#current >= 3) and (j > 1) then
									local subsent_id = tostring(tileid_id) .. "_" .. string.sub(sent_id, 1, j-1) .. "_" .. tostring(dir)
									--MF_alert("Checking finals: " .. subsent_id .. ", " .. tostring(existingfinals[subsent_id]))
									if (existingfinals[subsent_id] == nil) then
										existingfinals[subsent_id] = 1
									else
										finals[i] = {}
									end
								end

								if (wordid < #sent) then
									if (wordid > existing_wordid) then
										if (#notids > 0) and firstrealword and (notslot > 1) and ((tiletype ~= 7) or ((tiletype == 7) and (prevtiletype == 0))) and ((tiletype ~= 1) or ((tiletype == 1) and (prevtiletype == 0))) then
											-- MF_alert(tostring(notslot) .. ", not -> A, " .. unique_id .. ", " .. sent_id)
											local subsent_id = string.sub(sent_id, (notslot - existing_wordid)+1)
											table.insert(firstwords, {notids, dir, notwidth, "not", 4, sent, notslot, subsent_id})

											if (nexts[2] ~= nil) and ((nexts[2] == 0) or (nexts[2] == 3) or (nexts[2] == 4)) and (tiletype ~= 3) then
												-- MF_alert(tostring(wordid) .. ", " .. tilename .. " -> B, " .. unique_id .. ", " .. sent_id)
												subsent_id = string.sub(sent_id, j)
												table.insert(firstwords, {s[3], dir, tilewidth, tilename, tiletype, sent, wordid, subsent_id})
											end
										else
											if (prevtiletype == 0) and ((tiletype == 1) or (tiletype == 7)) then
												-- MF_alert(tostring(wordid-1) .. ", " .. sent[wordid - 1][1] .. " -> C, " .. unique_id .. ", " .. sent_id)
												local subsent_id = string.sub(sent_id, wordid - existing_wordid)
												table.insert(firstwords, {sent[wordid - 1][3], dir, tilewidth, tilename, tiletype, sent, wordid-1, subsent_id})
											elseif (prevsafewordtype == 0) and (prevsafewordid > 0) and (prevtiletype == 4) and (tiletype ~= 1) and (tiletype ~= 2) then
												-- MF_alert(tostring(prevsafewordid) .. ", " .. sent[prevsafewordid][1] .. " -> D, " .. unique_id .. ", " .. sent_id)
												local subsent_id = string.sub(sent_id, (prevsafewordid - existing_wordid)+1)
												table.insert(firstwords, {sent[prevsafewordid][3], dir, tilewidth, tilename, tiletype, sent, prevsafewordid, subsent_id})
											else
												-- MF_alert(tostring(wordid) .. ", " .. tilename .. " -> E, " .. unique_id .. ", " .. sent_id)
												local subsent_id = string.sub(sent_id, j)
												table.insert(firstwords, {s[3], dir, tilewidth, tilename, tiletype, sent, wordid, subsent_id})
											end
										end

										break
									elseif (wordid == existing_wordid) then
										if (nexts[3][1] ~= -1) then
											-- MF_alert(tostring(wordid+1) .. ", " .. nexts[1] .. " -> F, " .. unique_id .. ", " .. sent_id)
											local subsent_id = string.sub(sent_id, j+1)
											table.insert(firstwords, {nexts[3], dir, nexts[4], nexts[1], nexts[2], sent, wordid+1, subsent_id})
										end

										break
									end
								end
							end
						end

						--MF_alert(thissent)
					end
				end

				if (#finals > 0) then
					for i,sentence in ipairs(finals) do
						local group_objects = {}
						local group_targets = {}
						local group_conds = {}

						local group = group_objects
						local stage = 0

						local prefix = ""

						local allowedwords = {0}
						local allowedwords_extra = {}

						local testing = ""

						local extraids = {}
						local extraids_current = ""
						local extraids_ifvalid = {}

						local valid = true

						if (#sentence >= 3) then
							if (#finals > 1) then
								for a,b in ipairs(finals) do
									if (#b == #sentence) and (a > i) then
										local identical = true

										for c,d in ipairs(b) do
											local currids = d[3]
											local equivids = sentence[c][3] or {}

											for e,f in ipairs(currids) do
												--MF_alert(tostring(a) .. ": " .. tostring(f) .. ", " .. tostring(equivids[e]))
												if (f ~= equivids[e]) then
													identical = false
												end
											end
										end

										if identical then
											--MF_alert(sentence[1][1] .. ", " .. sentence[2][1] .. ", " .. sentence[3][1] .. " (" .. tostring(i) .. ") is identical to " .. b[1][1] .. ", " .. b[2][1] .. ", " .. b[3][1] .. " (" .. tostring(a) .. ")")
											valid = false
										end
									end
								end
							end
						else
							valid = false
						end

						if valid then
							for index,wdata in ipairs(sentence) do
								local wname = wdata[1]
								local wtype = wdata[2]
								local wid = wdata[3]

								testing = testing .. wname .. " "

								local wcategory = -1

								if (wtype == 1) or (wtype == 3) or (wtype == 7) then
									wcategory = 1
								elseif (wtype ~= 4) and (wtype ~= 6) then
									wcategory = 0
								else
									table.insert(extraids_ifvalid, {prefix .. wname, wtype, wid})
									extraids_current = wname
								end

								if (wcategory == 0) then
									local allowed = false

									for a,b in ipairs(allowedwords) do
										if (b == wtype) then
											allowed = true
											break
										end
									end

									if (allowed == false) then
										for a,b in ipairs(allowedwords_extra) do
											if (wname == b) then
												allowed = true
												break
											end
										end
									end

									if allowed then
										table.insert(group, {prefix .. wname, wtype, wid})
									else
										local sent = sentence.sent
										local wordid = wdata[5]
										local subsent_id = wdata[6]
										table.insert(firstwords, {{wid[1]}, dir, 1, wname, wtype, sent, wordid, subsent_id})
										break
									end
								elseif (wcategory == 1) then
									if (index < #sentence) then
										allowedwords = {0}
										allowedwords_extra = {}

										local realname = unitreference["text_" .. wname]
										local cargtype = false
										local cargextra = false

										local argtype = {0}
										local argextra = {}

										if (changes[realname] ~= nil) then
											local wchanges = changes[realname]

											if (wchanges.argtype ~= nil) then
												argtype = wchanges.argtype
												cargtype = true
											end

											if (wchanges.argextra ~= nil) then
												argextra = wchanges.argextra
												cargextra = true
											end
										end

										if (cargtype == false) or (cargextra == false) then
											local wvalues = tileslist[realname] or {}

											if (cargtype == false) then
												argtype = wvalues.argtype or {0}
											end

											if (cargextra == false) then
												argextra = wvalues.argextra or {}
											end
										end

										--MF_alert(wname .. ", " .. tostring(realname) .. ", " .. "text_" .. wname)

										if (realname == nil) then
											MF_alert("No object found for " .. wname .. "!")
											valid = false
											break
										else
											if (wtype == 1) then
												allowedwords = argtype

												stage = 1
												local target = {prefix .. wname, wtype, wid}
												table.insert(group_targets, {target, {}})
												local sid = #group_targets
												group = group_targets[sid][2]

												newcondgroup = 1
											elseif (wtype == 3) then
												allowedwords = {0}
												local cond = {prefix .. wname, wtype, wid}
												table.insert(group_conds, {cond, {}})
											elseif (wtype == 7) then
												allowedwords = argtype
												allowedwords_extra = argextra

												stage = 2
												local cond = {prefix .. wname, wtype, wid}
												table.insert(group_conds, {cond, {}})
												local sid = #group_conds
												group = group_conds[sid][2]
											end
										end
									end
								end

								if (wtype == 4) then
									if (prefix == "not ") then
										prefix = ""
									else
										prefix = "not "
									end
								else
									prefix = ""
								end

								if (wname ~= extraids_current) and (string.len(extraids_current) > 0) and (wtype ~= 4) then
									for a,extraids_valid in ipairs(extraids_ifvalid) do
										table.insert(extraids, {prefix .. extraids_valid[1], extraids_valid[2], extraids_valid[3]})
									end

									extraids_ifvalid = {}
									extraids_current = ""
								end
							end
							--MF_alert("Testing: " .. testing)

							if generaldata.flags[LOGGING] then
								rulelog(sentence, testing)
							end

							local conds = {}
							local condids = {}
							for c,group_cond in ipairs(group_conds) do
								local rule_cond = group_cond[1][1]
								--table.insert(condids, group_cond[1][3])

								condids = copytable(condids, group_cond[1][3])

								table.insert(conds, {rule_cond,{}})
								local condgroup = conds[#conds][2]

								for e,condword in ipairs(group_cond[2]) do
									local rule_condword = condword[1]
									--table.insert(condids, condword[3])

									condids = copytable(condids, condword[3])

									table.insert(condgroup, rule_condword)
								end
							end

							for c,group_object in ipairs(group_objects) do
								local rule_object = group_object[1]

								for d,group_target in ipairs(group_targets) do
									local rule_verb = group_target[1][1]

									for e,target in ipairs(group_target[2]) do
										local rule_target = target[1]

										local finalconds = {}
										for g,finalcond in ipairs(conds) do
											table.insert(finalconds, {finalcond[1], finalcond[2]})
										end

										local rule = {rule_object,rule_verb,rule_target}

										local ids = {}
										ids = copytable(ids, group_object[3])
										ids = copytable(ids, group_target[1][3])
										ids = copytable(ids, target[3])

										for g,h in ipairs(extraids) do
											ids = copytable(ids, h[3])
										end

										for g,h in ipairs(condids) do
											ids = copytable(ids, h)
										end

										addoption(rule,finalconds,ids)
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

function calculatesentences(unitid,x,y,dir)
	local drs = dirs[dir]
	local ox,oy = drs[1],drs[2]
	
	local finals = {}
	local sentences = {}
	local sentence_ids = {}
	local firstwords = {}
	
	local sents = {}
	local done = false
	local verbfound = false
	local objfound = false
	local starting = true
	
	local step = 0
	local rstep = 0
	local combo = {}
	local variantshere = {}
	local totalvariants = 1
	local maxpos = 0
	local prevsharedtype = -1
	local prevmaxw = 1
	local currw = 0
	
	local limiter = 5000
	
	local combospots = {}
	
	local unit = mmf.newObject(unitid)
	
	local done = false
	while (done == false) and (totalvariants < limiter) do
		local words,letters,jletters = codecheck(unitid,ox*rstep,oy*rstep,dir,true)
		
		--MF_alert(tostring(unitid) .. ", " .. unit.strings[UNITNAME] .. ", " .. tostring(#words))
		
		step = step + 1
		rstep = rstep + 1
		
		if (totalvariants >= limiter) then
			MF_alert("Level destroyed - too many variants A")
			destroylevel("toocomplex")
			return nil
		end
		
		if (totalvariants < limiter) then
			local sharedtype = -1
			local maxw = 1
			
			if (#words > 0) then
				sents[step] = {}
				
				for i,v in ipairs(words) do
					--unitids, width, word, wtype, dir
					
					--MF_alert("Step " .. tostring(step) .. ", word " .. v[3] .. " here, " .. tostring(v[2]))
					
					if (sharedtype == -1) then
						sharedtype = v[4]
					elseif (v[4] ~= sharedtype) then
						sharedtype = -2
					end
					
					if (v[4] == 1) then
						verbfound = true
					end
					
					if (v[4] == 0) then
						objfound = true
					end
					
					if starting and ((v[4] == 0) or (v[4] == 3) or (v[4] == 4)) then
						starting = false
					end
					
					maxw = math.max(maxw, v[2])
					table.insert(sents[step], v)
					
					if (v[2] > 1) then
						currw = math.max(currw, v[2] + 1)
					end
				end
				
				if (sharedtype >= 0) and (prevsharedtype >= 0) and (#words > 0) and (maxw == 1) and (prevmaxw == 1) and (currw == 0) then
					if ((sharedtype == 0) and (prevsharedtype == 0)) or ((sharedtype == 1) and (prevsharedtype == 1)) or ((sharedtype == 2) and (prevsharedtype == 2)) or ((sharedtype == 0) and (prevsharedtype == 2)) then
						done = true
						sents[step] = nil
						--MF_alert("added " .. words[1][3])
						table.insert(firstwords, {words[1][1], dir, words[1][2], words[1][3], words[1][4], {}})
					end
				end
				
				currw = math.max(currw - 1, 0)
				
				prevsharedtype = sharedtype
				prevmaxw = maxw
				
				if (done == false) then
					if starting then
						sents[step] = nil
						step = step - 1
					else
						totalvariants = totalvariants * #words
						variantshere[step] = #words
						combo[step] = 1
						
						if (totalvariants >= limiter) then
							MF_alert("Level destroyed - too many variants B")
							destroylevel("toocomplex")
							return nil
						end
						
						if (#words > 1) then
							combospots[#combospots + 1] = step
						end
						
						if (totalvariants > #finals) then
							local limitdiff = totalvariants - #finals
							for i=1,limitdiff do
								table.insert(finals, {})
							end
						end
					end
				end
			else
				--MF_alert("Step " .. tostring(step) .. ", no words here, " .. tostring(letters) .. ", " .. tostring(jletters))
				
				if jletters then
					variantshere[step] = 0
					sents[step] = {}
					combo[step] = 0
					
					if starting then
						sents[step] = nil
						step = step - 1
					end
				else
					done = true
				end
			end
		end
	end
	
	--MF_alert(tostring(step) .. ", " .. tostring(totalvariants))
	
	if (totalvariants >= limiter) then
		MF_alert("Level destroyed - too many variants C")
		destroylevel("toocomplex")
		return nil
	end
	
	if (verbfound == false) or (step < 3) or (objfound == false) then
		return {},{},0,0,{},firstwords
	end
	
	maxpos = step
	
	local combostep = 0
	
	for i=1,totalvariants do
		step = 1
		sentences[i] = {}
		sentence_ids[i] = ""
		
		while (step < maxpos) do
			local c = combo[step]
			
			if (c ~= nil) then
				if (c > 0) then
					local s = sents[step]
					local word = s[c]
					
					local w = word[2]
					
					--MF_alert(tostring(i) .. ", step " .. tostring(step) .. ": " .. word[3] .. ", " .. tostring(#word[1]) .. ", " .. tostring(w))
					
					table.insert(sentences[i], {word[3], word[4], word[1], word[2]})
					sentence_ids[i] = sentence_ids[i] .. tostring(c - 1)
					
					step = step + w
				else
					break
				end
			else
				MF_alert("c is nil, " .. tostring(step))
				break
			end
		end
		
		if (#combospots > 0) then
			combostep = 0
			
			local targetstep = combospots[combostep + 1]
			
			combo[targetstep] = combo[targetstep] + 1
			
			while (combo[targetstep] > variantshere[targetstep]) do
				combo[targetstep] = 1
				
				combostep = (combostep + 1) % #combospots
				
				targetstep = combospots[combostep + 1]
				
				combo[targetstep] = combo[targetstep] + 1
			end
		end
	end
	
	--[[
	MF_alert(tostring(totalvariants) .. ", " .. tostring(#sentences))
	for i,v in ipairs(sentences) do
		local text = ""
		
		for a,b in ipairs(v) do
			text = text .. b[1] .. " "
		end
		
		MF_alert(text)
	end
	]]--
	
	return sentences,finals,maxpos,totalvariants,sentence_ids,firstwords
end
