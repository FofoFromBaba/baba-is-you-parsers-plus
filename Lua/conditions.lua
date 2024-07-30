function testcond(conds,unitid,x_,y_,autofail_,limit_,checkedconds_,ignorebroken_,subgroup_)
	local result = true

	local orhandling = false
	local orresult = false

	local x,y,name,dir,broken = 0,0,"",4,0
	local surrounds = {}
	local autofail = autofail_ or {}
	local limit = limit_ or 0

	limit = limit + 1
	if (limit > 80) then
		HACK_INFINITY = 200
		destroylevel("infinity")
		return
	end

	local checkedconds = {}
	local ignorebroken = ignorebroken_ or false
	local subgroup = subgroup_ or {}

	if (checkedconds_ ~= nil) then
		for i,v in pairs(checkedconds_) do
			checkedconds[i] = v
		end
	end

	if (#features == 0) then
		return false
	end

	-- 0 = bug, 1 = level, 2 = empty

	if (unitid ~= 0) and (unitid ~= 1) and (unitid ~= 2) and (unitid ~= nil) then
		local unit = mmf.newObject(unitid)
		x = unit.values[XPOS]
		y = unit.values[YPOS]
		name = unit.strings[UNITNAME]
		dir = unit.values[DIR]
		broken = unit.broken or 0

		if (unit.strings[UNITTYPE] == "text") then
			name = "text"
		elseif (unit.strings[UNITTYPE] == "logic") then
			name = "logic"
		end
	elseif (unitid == 2) then
		x = x_
		y = y_
		name = "empty"
		broken = 0

		if (featureindex["broken"] ~= nil) and (ignorebroken == false) and (checkedconds[tostring(conds)] == nil) then
			checkedconds[tostring(conds)] = 1
			broken = isitbroken("empty",2,x,y,checkedconds)
		end
	elseif (unitid == 1) then
		name = "level"
		surrounds = parsesurrounds()
		dir = tonumber(surrounds.dir) or 4
		broken = 0

		if (featureindex["broken"] ~= nil) and (ignorebroken == false) and (checkedconds[tostring(conds)] == nil) then
			checkedconds[tostring(conds)] = 1
			broken = isitbroken("level",1,x,y,checkedconds)
		end
	end

	checkedconds[tostring(conds)] = 1
	checkedconds[tostring(conds) .. "_s_"] = 1

	if (unitid == 0) or (unitid == nil) then
		print("WARNING!! Unitid is " .. tostring(unitid))
	end

	if ignorebroken then
		broken = 0
	end

	if (broken == 1) then
		result = false
	end

	if (conds ~= nil) and ((broken == nil) or (broken == 0)) then
		if (#conds > 0) then
			local valid = false

			for i,cond in ipairs(conds) do
				local condtype = cond[1]
				local params_ = cond[2]
				local params = {}

				local extras = {}

				if (string.sub(condtype, 1, 1) == "(") then
					condtype = string.sub(condtype, 2)
					orhandling = true
					orresult = false
				end

				if (string.sub(condtype, -1) == ")") then
					condtype = string.sub(condtype, 1, string.len(condtype) - 1)
				end

				local basecondtype = string.sub(condtype, 1, 4)
				local notcond = false

				if (basecondtype == "not ") then
					basecondtype = string.sub(condtype, 5)
					notcond = true
				else
					basecondtype = condtype
				end

				if (condtype ~= "never") then
					local condname = unitreference["text_" .. basecondtype]

					local conddata = conditions[condname] or {}
					if (conddata.argextra ~= nil) then
						extras = conddata.argextra
					end
				end

				for a,b in ipairs(autofail) do
					if (condtype == b) then
						result = false
						valid = true
					end
				end

				if (result == false) and valid then
					break
				end

				if (params_ ~= nil) then
					local handlegroup = false

					for a,b in ipairs(params_) do
						if (string.sub(b, 1, 4) == "not ") then
							table.insert(params, b)
						else
							table.insert(params, 1, b)
						end

						if ((string.sub(b, 1, 5) == "group") or (string.sub(b, 1, 9) == "not group")) and condtype ~= "refers" then
							handlegroup = true
						end
					end

					local removegroup = {}
					local removegroupoffset = 0

					if handlegroup then
						local plimit = #params

						for a=1,plimit do
							local b = params[a]
							local mem = subgroup_
							local notnoun = false

							if (string.sub(b, 1, 5) == "group") then
								if (mem == nil) then
									mem = findgroup(b,false,limit,checkedconds)
								end
								table.insert(removegroup, a)
							elseif (string.sub(b, 1, 9) == "not group") then
								notnoun = true

								if (mem == nil) then
									mem = findgroup(string.sub(b, 5),true,limit,checkedconds)
								else
									local memfound = {}

									for c,d in ipairs(mem) do
										memfound[d] = 1
									end

									mem = {}

									for c,mat in pairs(objectlist) do
										if (memfound[c] == nil) and (findnoun(c,nlist.short) == false) then
											table.insert(mem, c)
										end
									end
								end
								table.insert(removegroup, a)
							end

							if (mem ~= nil) then
								for c,d in ipairs(mem) do
									if notnoun then
										table.insert(params, d)
									else
										table.insert(params, 1, d)
										removegroupoffset = removegroupoffset - 1
									end
								end
							end

							if (mem == nil) or (#mem == 0) then
								table.insert(params, "_NONE_")
								break
							end
						end

						for a,b in ipairs(removegroup) do
							table.remove(params, b - removegroupoffset)
							removegroupoffset = removegroupoffset + 1
						end
					end
				end

				local condsubtype = ""

				if (string.sub(basecondtype, 1, 7) == "powered") then
					for a,b in pairs(condlist) do
						if (#basecondtype > #a) and (string.sub(basecondtype, 1, #a) == a) then
							condsubtype = string.sub(basecondtype, #a + 1)
							basecondtype = string.sub(basecondtype, 1, #a)
							break
						end
					end
				end

				if (condlist[basecondtype] ~= nil) then
					valid = true

					local cfunc = condlist[basecondtype]
					local subresult = true
					local ccc = false
					local cdata = {name = name, x = x, y = y, unitid = unitid, dir = dir, extras = extras, limit = limit, conds = conds, subtype = condsubtype, i = i, surrounds = surrounds, notcond = notcond, debugname = cond[1]}
					subresult,checkedconds,ccc = cfunc(params,checkedconds,checkedconds_,cdata)
					local clearcconds = ccc or false

					if notcond then
						subresult = not subresult
					end

					if subresult and clearcconds then
						checkedconds = {}

						if (checkedconds_ ~= nil) then
							for i,v in pairs(checkedconds_) do
								checkedconds[i] = v
							end
						end

						checkedconds[tostring(conds)] = 1
						checkedconds[tostring(conds) .. "_s_"] = 1
					end

					if (subresult == false) then
						if (orhandling == false) then
							result = false
							break
						end
					elseif orhandling then
						orresult = true
					end
				else
					MF_alert("condtype " .. tostring(condtype) .. " doesn't exist?")
					result = false
					break
				end

				if (string.sub(cond[1], -1) == ")") then
					orhandling = false

					if (orresult == false) then
						result = false
						break
					else
						result = true
					end
				end
			end

			if (valid == false) then
				MF_alert("invalid condition!")
				result = true

				for a,b in ipairs(conds) do
					MF_alert(tostring(b[1]))
				end
			end
		end
	end

	return result
end

condlist['near'] = function(params,checkedconds,checkedconds_,cdata)
	local allfound = 0
	local alreadyfound = {}

	local unitid,x,y,surrounds = cdata.unitid,cdata.x,cdata.y,cdata.surrounds

	if (#params > 0) then
		for a,b in ipairs(params) do
			local pname = b
			local metaparam = false
			if (string.sub(pname, 1, 6) == "glyph_") or (string.sub(pname, 1, 6) == "event_") or (string.sub(pname, 1, 5) == "text_") then
				metaparam = true
			end
			local pnot = false
			if (string.sub(b, 1, 4) == "not ") then
				pnot = true
				pname = string.sub(b, 5)
			end

			local bcode = b .. "_" .. tostring(a)

			if (string.sub(pname, 1, 5) == "group") then
				return false,checkedconds
			end

			if (unitid ~= 1) then
				if (b ~= "level") or ((b == "level") and (alreadyfound[1] ~= nil)) then
					for g=-1,1 do
						for h=-1,1 do
							if (pname ~= "empty") then
								local tileid = (x + g) + (y + h) * roomsizex
								if (unitmap[tileid] ~= nil) then
									for c,d in ipairs(unitmap[tileid]) do
										if (d ~= unitid) and (alreadyfound[d] == nil) then
											local unit = mmf.newObject(d)
											local name_ = getname(unit)
											if metaparam then
												name_ = unit.strings[UNITNAME]
											end

											if (pnot == false) then
												if (name_ == pname) and (alreadyfound[bcode] == nil) then
													alreadyfound[bcode] = 1
													alreadyfound[d] = 1
													allfound = allfound + 1
												end
											else
												if (name_ ~= pname) and (alreadyfound[bcode] == nil) and (name_ ~= "text") then
													alreadyfound[bcode] = 1
													alreadyfound[d] = 1
													allfound = allfound + 1
												end
											end
										end
									end
								end
							else
								local nearempty = false

								local tileid = (x + g) + (y + h) * roomsizex
								local l = map[0]
								local tile = l:get_x(x + g,y + h)

								local tcode = tostring(tileid) .. "e"

								if ((unitmap[tileid] == nil) or (#unitmap[tileid] == 0)) and (tile == 255) and (alreadyfound[tcode] == nil) then
									nearempty = true
								end

								if (g == 0) and (h == 0) then
									if (unitid == 2) then
										if (pnot == false) then
											nearempty = false
										end
									elseif (unitid ~= 1) and pnot then
										if (unitmap[tileid] == nil) or (#unitmap[tileid] <= 1) then
											nearempty = true
										end
									end
								end

								if (pnot == false) then
									if nearempty and (alreadyfound[bcode] == nil) then
										alreadyfound[bcode] = 1
										alreadyfound[tcode] = 1
										allfound = allfound + 1
									end
								else
									if (nearempty == false) and (alreadyfound[bcode] == nil) then
										alreadyfound[bcode] = 1
										alreadyfound[tcode] = 1
										allfound = allfound + 1
									end
								end
							end
						end
					end
				elseif (b == "level") and (alreadyfound[bcode] == nil) and (alreadyfound[1] == nil) then
					alreadyfound[bcode] = 1
					alreadyfound[1] = 1
					allfound = allfound + 1
				end
			else
				local ulist = false

				if (b ~= "empty") and (b ~= "level") then
					if (pnot == false) then
						if (unitlists[pname] ~= nil) and (#unitlists[pname] > 0) then
							for c,d in ipairs(unitlists[pname]) do
								if (alreadyfound[d] == nil) and (alreadyfound[bcode] == nil) then
									alreadyfound[bcode] = 1
									alreadyfound[d] = 1
									ulist = true
									break
								end
							end
						end
					else
						for c,d in pairs(unitlists) do
							local tested = false

							if (c ~= pname) and (#d > 0) then
								for e,f in ipairs(d) do
									if (alreadyfound[f] == nil) and (alreadyfound[bcode] == nil) then
										alreadyfound[bcode] = 1
										alreadyfound[f] = 1
										ulist = true
										tested = true
										break
									end
								end
							end

							if tested then
								break
							end
						end
					end
				elseif (b == "empty") then
					local empties = findempty()

					if (#empties > 0) then
						for c,d in ipairs(empties) do
							if (alreadyfound[d] == nil) and (alreadyfound[bcode] == nil) then
								alreadyfound[bcode] = 1
								alreadyfound[d] = 1
								ulist = true
								break
							end
						end
					end
				end

				if (b ~= "text") and (ulist == false) then
					for e,f in pairs(surrounds) do
						if (e ~= "dir") then
							for c,d in ipairs(f) do
								if (pnot == false) then
									if (ulist == false) and (d == pname) and (alreadyfound[bcode] == nil) then
										alreadyfound[bcode] = 1
										ulist = true
									end
								else
									if (ulist == false) and (d ~= pname) and (alreadyfound[bcode] == nil) then
										alreadyfound[bcode] = 1
										ulist = true
									end
								end
							end
						end
					end
				end

				if ulist or (b == "text") then
					alreadyfound[bcode] = 1
					allfound = allfound + 1
				end
			end
		end
	else
		print("no parameters given!")
		return false,checkedconds
	end

	return (allfound == #params),checkedconds
end

condlist['on'] = function(params,checkedconds,checkedconds_,cdata)
	local allfound = 0
	local alreadyfound = {}

	local unitid,x,y,surrounds = cdata.unitid,cdata.x,cdata.y,cdata.surrounds

	local tileid = x + y * roomsizex

	if (unitid ~= 2) then
		if (#params > 0) then
			for a,b in ipairs(params) do
				local pname = b
				local metaparam = false
				if (string.sub(pname, 1, 6) == "glyph_") or (string.sub(pname, 1, 6) == "event_") or (string.sub(pname, 1, 5) == "text_") then
					metaparam = true
				end
				local pnot = false
				if (string.sub(b, 1, 4) == "not ") then
					pnot = true
					pname = string.sub(b, 5)
				end

				local bcode = b .. "_" .. tostring(a)

				if (string.sub(pname, 1, 5) == "group") then
					return false,checkedconds
				end

				if (unitid ~= 1) then
					if ((pname ~= "empty") and (b ~= "level")) or ((b == "level") and (alreadyfound[1] ~= nil)) then
						if (unitmap[tileid] ~= nil) then
							for c,d in ipairs(unitmap[tileid]) do
								if (d ~= unitid) and (alreadyfound[d] == nil) then
									local unit = mmf.newObject(d)
									local name_ = getname(unit)
									if metaparam then
										name_ = unit.strings[UNITNAME]
									end

									if (pnot == false) then
										if (name_ == pname) and (alreadyfound[bcode] == nil) then
											alreadyfound[bcode] = 1
											alreadyfound[d] = 1
											allfound = allfound + 1
										end
									else
										if (name_ ~= pname) and (alreadyfound[bcode] == nil) and (name_ ~= "text") then
											alreadyfound[bcode] = 1
											alreadyfound[d] = 1
											allfound = allfound + 1
										end
									end
								end
							end
						else
							print("unitmap is nil at " .. tostring(x) .. ", " .. tostring(y) .. " for object " .. tostring(name) .. " (" .. tostring(unitid) .. ")!")
						end
					elseif (pname == "empty") then
						if (pnot == false) then
							return false,checkedconds
						else
							if (unitmap[tileid] ~= nil) then
								for c,d in ipairs(unitmap[tileid]) do
									if (d ~= unitid) and (alreadyfound[d] == nil) then
										alreadyfound[bcode] = 1
										alreadyfound[d] = 1
										allfound = allfound + 1
									end
								end
							end
						end
					elseif (b == "level") and (alreadyfound[bcode] == nil) and (alreadyfound[1] == nil) then
						alreadyfound[bcode] = 1
						alreadyfound[1] = 1
						allfound = allfound + 1
					end
				else
					local ulist = false

					if (b ~= "empty") and (b ~= "level") then
						if (pnot == false) then
							if (unitlists[b] ~= nil) and (#unitlists[b] > 0) and (alreadyfound[bcode] == nil) then
								for c,d in ipairs(unitlists[b]) do
									if (alreadyfound[d] == nil) then
										alreadyfound[bcode] = 1
										alreadyfound[d] = 1
										ulist = true
										break
									end
								end
							end
						else
							for c,d in pairs(unitlists) do
								local tested = false

								if (c ~= pname) and (#d > 0) then
									for e,f in ipairs(d) do
										if (alreadyfound[f] == nil) and (alreadyfound[bcode] == nil) then
											alreadyfound[bcode] = 1
											alreadyfound[f] = 1
											ulist = true
											tested = true
											break
										end
									end
								end

								if tested then
									break
								end
							end
						end
					elseif (b == "empty") then
						local empties = findempty()

						if (#empties > 0) then
							for c,d in ipairs(empties) do
								if (alreadyfound[d] == nil) and (alreadyfound[bcode] == nil) then
									alreadyfound[bcode] = 1
									alreadyfound[d] = 1
									ulist = true
									break
								end
							end
						end
					elseif (b == "level") then
						for c,unit in ipairs(units) do
							if (unit.className == "level") and (alreadyfound[unit.fixed] == nil) and (alreadyfound[bcode] == nil) then
								alreadyfound[bcode] = 1
								alreadyfound[unit.fixed] = 1
								ulist = true
								break
							end
						end
					end

					if (b ~= "text") and (ulist == false) then
						if (surrounds["o"] ~= nil) then
							for c,d in ipairs(surrounds["o"]) do
								if (pnot == false) then
									if (d == pname) and (alreadyfound[bcode] == nil) then
										alreadyfound[bcode] = 1
										ulist = true
									end
								else
									if (d ~= pname) and (alreadyfound[bcode] == nil) then
										alreadyfound[bcode] = 1
										ulist = true
									end
								end
							end
						end
					end

					if ulist or (b == "text") then
						alreadyfound[bcode] = 1
						allfound = allfound + 1
					end
				end
			end
		else
			print("no parameters given!")
			return false,checkedconds
		end
	else
		for a,b in ipairs(params) do
			local bcode = b .. "_" .. tostring(a)

			if (b == "level") and (alreadyfound[bcode] == nil) then
				alreadyfound[bcode] = 1
				allfound = allfound + 1
			else
				return false,checkedconds
			end
		end
	end

	return (allfound == #params),checkedconds
end


condlist['nextto'] = function(params,checkedconds,checkedconds_,cdata)
	local allfound = 0
	local alreadyfound = {}

	local unitid,x,y,surrounds = cdata.unitid,cdata.x,cdata.y,cdata.surrounds

	if (#params > 0) then
		for a,b in ipairs(params) do
			local pname = b
			local metaparam = false
			if (string.sub(pname, 1, 6) == "glyph_") or (string.sub(pname, 1, 6) == "event_") or (string.sub(pname, 1, 5) == "text_") then
				metaparam = true
			end
			local pnot = false
			if (string.sub(b, 1, 4) == "not ") then
				pnot = true
				pname = string.sub(b, 5)
			end

			local bcode = b .. "_" .. tostring(a)

			if (string.sub(pname, 1, 5) == "group") then
				return false,checkedconds
			end

			if (unitid ~= 1) then
				if (b ~= "level") or ((b == "level") and (alreadyfound[1] ~= nil)) then
					for g=-1,1 do
						for h=-1,1 do
							if ((h ~= 0) and (g == 0)) or ((h == 0) and (g ~= 0)) then
								if (pname ~= "empty") then
									local tileid = (x + g) + (y + h) * roomsizex
									if (unitmap[tileid] ~= nil) then
										for c,d in ipairs(unitmap[tileid]) do
											if (d ~= unitid) and (alreadyfound[d] == nil) then
												local unit = mmf.newObject(d)
												local name_ = getname(unit)
												if metaparam then
													name_ = unit.strings[UNITNAME]
												end

												if (pnot == false) then
													if (name_ == pname) and (alreadyfound[bcode] == nil) then
														alreadyfound[bcode] = 1
														alreadyfound[d] = 1
														allfound = allfound + 1
													end
												else
													if (name_ ~= pname) and (alreadyfound[bcode] == nil) and (name_ ~= "text") then
														alreadyfound[bcode] = 1
														alreadyfound[d] = 1
														allfound = allfound + 1
													end
												end
											end
										end
									end
								else
									local nearempty = false

									local tileid = (x + g) + (y + h) * roomsizex
									local l = map[0]
									local tile = l:get_x(x + g,y + h)

									local tcode = tostring(tileid) .. "e"

									if ((unitmap[tileid] == nil) or (#unitmap[tileid] == 0)) and (tile == 255) and (alreadyfound[tcode] == nil) then
										nearempty = true
									end

									if (g == 0) and (h == 0) then
										if (unitid == 2) then
											if (pnot == false) then
												nearempty = false
											end
										elseif (unitid ~= 1) and pnot then
											if (unitmap[tileid] == nil) or (#unitmap[tileid] <= 1) then
												nearempty = true
											end
										end
									end

									if (pnot == false) then
										if nearempty and (alreadyfound[bcode] == nil) then
											alreadyfound[bcode] = 1
											alreadyfound[tcode] = 1
											allfound = allfound + 1
										end
									else
										if (nearempty == false) and (alreadyfound[bcode] == nil) then
											alreadyfound[bcode] = 1
											alreadyfound[tcode] = 1
											allfound = allfound + 1
										end
									end
								end
							end
						end
					end
				elseif (b == "level") and (alreadyfound[bcode] == nil) and (alreadyfound[1] == nil) then
					alreadyfound[bcode] = 1
					alreadyfound[1] = 1
					allfound = allfound + 1
				end
			else
				local ulist = false

				if (b ~= "empty") and (b ~= "level") then
					if (pnot == false) then
						if (unitlists[pname] ~= nil) and (#unitlists[pname] > 0) then
							for c,d in ipairs(unitlists[pname]) do
								if (alreadyfound[d] == nil) and (alreadyfound[bcode] == nil) then
									alreadyfound[bcode] = 1
									alreadyfound[d] = 1
									ulist = true
									break
								end
							end
						end
					else
						for c,d in pairs(unitlists) do
							local tested = false

							if (c ~= pname) and (#d > 0) then
								for e,f in ipairs(d) do
									if (alreadyfound[f] == nil) and (alreadyfound[bcode] == nil) then
										alreadyfound[bcode] = 1
										alreadyfound[f] = 1
										ulist = true
										tested = true
										break
									end
								end
							end

							if tested then
								break
							end
						end
					end
				elseif (b == "empty") then
					local empties = findempty()

					if (#empties > 0) then
						for c,d in ipairs(empties) do
							if (alreadyfound[d] == nil) and (alreadyfound[bcode] == nil) then
								alreadyfound[bcode] = 1
								alreadyfound[d] = 1
								ulist = true
								break
							end
						end
					end
				end

				if (b ~= "text") and (ulist == false) then
					for e,f in pairs(surrounds) do
						if (e ~= "dir") and (e ~= "o") then
							for c,d in ipairs(f) do
								if (pnot == false) then
									if (ulist == false) and (d == pname) and (alreadyfound[bcode] == nil) then
										alreadyfound[bcode] = 1
										ulist = true
									end
								else
									if (ulist == false) and (d ~= pname) and (alreadyfound[bcode] == nil) then
										alreadyfound[bcode] = 1
										ulist = true
									end
								end
							end
						end
					end
				end

				if ulist or (b == "text") then
					alreadyfound[bcode] = 1
					allfound = allfound + 1
				end
			end
		end
	else
		print("no parameters given!")
		return false,checkedconds
	end

	return (allfound == #params),checkedconds
end

condlist['feeling']  = function(params,checkedconds,checkedconds_,cdata)
	local allfound = 0
	local alreadyfound = {}
	local name,unitid,x,y,limit = cdata.name,cdata.unitid,cdata.x,cdata.y,cdata.limit

	if string.sub(name,1,6) == "glyph_" then
		name = "glyph"
	end
	if string.sub(name,1,6) == "event_" then
		name = "event"
	end

	if (#params > 0) then
		for a,b in ipairs(params) do
			local pname = b
			local pnot = false
			if (string.sub(b, 1, 4) == "not ") then
				pnot = true
				pname = string.sub(b, 5)
			end

			local bcode = b .. "_" .. tostring(a)

			if (featureindex[name] ~= nil) then
				for c,d in ipairs(featureindex[name]) do
					local drule = d[1]
					local dconds = d[2]

					if (checkedconds[tostring(dconds)] == nil) then
						if (pnot == false) then
							if (drule[1] == name) and (drule[2] == "is") and (drule[3] == b) then
								checkedconds[tostring(dconds)] = 1

								if (alreadyfound[bcode] == nil) and testcond(dconds,unitid,x,y,nil,limit,checkedconds) then
									alreadyfound[bcode] = 1
									allfound = allfound + 1
									break
								end
							end
						else
							if (string.sub(drule[3], 1, 4) ~= "not ") then
								local obj = unitreference["text_" .. drule[3]]

								if (obj ~= nil) then
									local objtype = getactualdata_objlist(obj,"type")

									if (objtype == 2) then
										if (drule[1] == name) and (drule[2] == "is") and (drule[3] ~= pname) then
											checkedconds[tostring(dconds)] = 1

											if (alreadyfound[bcode] == nil) and testcond(dconds,unitid,x,y,nil,limit,checkedconds) then
												alreadyfound[bcode] = 1
												allfound = allfound + 1
												break
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
	else
		return false,checkedconds,true
	end

	--MF_alert(tostring(cdata.debugname) .. ", " .. tostring(allfound) .. ", " .. tostring(#params))

	return (allfound == #params),checkedconds,true
end

condlist['refers'] = function(params,checkedconds,checkedconds_,cdata)
for i, j in pairs(params) do
    local _params = " "..j

	local unitname = mmf.newObject(cdata.unitid).strings[UNITNAME]
	_params = string.sub(_params, 2)
	if (string.sub(unitname, 1, 5) == "text_") or (string.sub(unitname, 1, 5) == "node_") then
		if (string.sub(unitname, 6) == _params) then
			return true, checkedconds
		end
	elseif (string.sub(unitname, 1, 6) == "glyph_") or (string.sub(unitname, 1, 6) == "event_") or (string.sub(unitname, 1, 6) == "logic_") then
		if (string.sub(unitname, 7) == _params) then
			return true, checkedconds
		end
	end

    if hasfeature(unitname,"is","word",cdata.unitid) and (unitname == _params) then
        return true, checkedconds
    elseif hasfeature(unitname,"is","symbol",cdata.unitid) and (unitname == _params) then
        return true, checkedconds
    end
end
	return false, checkedconds
end
