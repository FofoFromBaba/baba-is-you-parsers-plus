function updatecolours(edit_)
	local edit = false
	
	if (edit_ ~= nil) then
		edit = edit_
	end
	
	MF_setbackcolour()
	
	for i,unit in ipairs(units) do
		if (unit.strings[UNITNAME] ~= "level") then
			if (unit.strings[UNITTYPE] ~= "text" and unit.strings[UNITTYPE] ~= "node" and unit.strings[UNITTYPE] ~= "logic") then
				setcolour(unit.fixed)
			else
				if edit then
					setcolour(unit.fixed,"active")
				else
					setcolour(unit.fixed)
				end
			end
		else
			MF_updatelevelcolour(unit.fixed)
		end
	end
	
	updatecode = 1
	code()
end