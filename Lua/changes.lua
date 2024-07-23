
function dochanges(unitid)
	local unit = mmf.newObject(unitid)
	
	local realname = unit.className
	local name = unit.strings[UNITNAME]
	local name_ = ""
	
	if (changes[realname] ~= nil) then
		local c = changes[realname]
		
		if (c.name ~= nil) then
			name = c.name
			unit.strings[UNITNAME] = c.name
			
			if (string.sub(c.name, 1, 5) == "text_") or (string.sub(c.name, 1, 5) == "node_") then
				name_ = string.sub(c.name, 6)
			else
				name_ = c.name
			end
			
			unit.strings[NAME] = name_
			
			unitreference[name] = realname
		end
		
		if (c.colour ~= nil) then
			local cutoff = 0
			
			for a=1,string.len(c.colour) do
				if (string.sub(c.colour, a, a) == ",") then
					cutoff = a
				end
			end
			
			if (cutoff > 0) then
				local c1 = string.sub(c.colour, 1, cutoff-1)
				local c2 = string.sub(c.colour, cutoff+1)
				
				--MF_alert("Adding objcolour for " .. realname .. ": colour, " .. tostring(c1) .. ", " .. tostring(c2))
				
				addobjectcolour(realname,"colour",c1,c2)
			else
				print("New object colour formatted wrong!")
			end
		end
		
		if (c.activecolour ~= nil) then
			local cutoff = 0
			for a=1,string.len(c.activecolour) do
				if (string.sub(c.activecolour, a, a) == ",") then
					cutoff = a
				end
			end
			
			if (cutoff > 0) then
				local c1 = string.sub(c.activecolour, 1, cutoff-1)
				local c2 = string.sub(c.activecolour, cutoff+1)
				
				--MF_alert("Adding objcolour for " .. realname .. ": active, " .. tostring(c1) .. ", " .. tostring(c2))
				
				addobjectcolour(realname,"active",c1,c2)
			else
				print("New object active colour formatted wrong!")
			end
		end
		
		if (c.tiling ~= nil) then
			unit.values[TILING] = tonumber(c.tiling)
		end
		
		if (c.type ~= nil) then
			unit.values[TYPE] = tonumber(c.type)
		end
		
		if (c.unittype ~= nil) then
			unit.strings[UNITTYPE] = c.unittype
		end
		
		if (c.layer ~= nil) then
			unit.values[ZLAYER] = tonumber(c.layer)
		end
	end
end
