function editor_autopick(text)
	local result = ""
	local addthese = {}
	local globalprefix = "text_"
	local dir

	prefixes = {
		["!"] = true,
		["%"] = true
	}
	
	dirnames = {
		right = 0,
		r = 0,
		up = 1,
		u = 1,
		left = 2,
		l = 2,
		down = 3,
		d = 3,
	}

	prefixchars = {
		["="] = "",
		["$"] = "text_",
		["#"] = "glyph_",
		[";"] = "event_",
		["^"] = "node_",
		["￼"] = "obj_"
	}

	if string.sub(text, 1, 1) == "!" then
		local firstspace = string.find(text, " ")
		globalprefix = string.sub(text, 2, firstspace-1) .. "_"
		text = string.sub(text, firstspace+1, -1)
	end

	for word_ in string.gmatch(text, "%S+") do
		local word = string.lower(word_)
		local obj = ""
		local editprefix = false
		local myprefix = ""
		repeat
			local changed = false
			for i, v in pairs(prefixchars) do
				if string.sub(word, 1, 1) == i then
					myprefix = myprefix .. v
					changed = true
					editprefix = true
					word = string.sub(word, 2, -1)
				end
			end
		until not changed

		local colon = string.find(word, ":")
		local dir
		if colon then
			dir = dirnames[string.sub(word, colon + 1, -1)]
			word = string.sub(word, 1, colon - 1)
		end

		-- error(dir)

		local prefix
		if editprefix then
			prefix = myprefix
		else
			prefix = globalprefix
		end

		if (string.sub(word, 1, #prefix) == prefix) then
			word = string.sub(word, #prefix)
		end
		
		word = string.gsub(word, "_", " ")

		for i,v in ipairs(editor_currobjlist) do
			if (v.name == prefix .. word) then
				obj = v.object
				break
			end
		end
		
		if (string.len(obj) == 0) and (#editor_currobjlist < 150) then
			for i,v in pairs(editor_objlist) do
				if (v.name == prefix .. word) and ((v.redacted == nil) or (v.redacted == false)) then
					local id_,obj_ = addobjtolist(v.name)
					editor3.values[UNSAVED] = 1
					setundo_editor()
					obj = obj_ or ""
					break
				end
			end
		end
		
		result = result .. obj .. ","
		table.insert(addthese, {obj, dir})
	end
	
	editor_resetselectionrect()
	local database = {}
	
	for i,addthis in ipairs(addthese) do
		v, dir = addthis[1], addthis[2]
		if (string.len(v) > 0) then
			local unitid = placetile(v,i - 1,0,0,dir or editor.values[EDITORDIR],nil,nil,nil,nil,true)
			local unit = mmf.newObject(unitid)
			unit.values[ONLINE] = 2
			table.insert(database, unit)
		end
	end
	
	if (#database > 0) and (#addthese > 0) then
		editor_setselectionrect(0,0,#addthese,1,database,false)
		editor4.values[SELECTIONX] = #addthese - 1
		editor4.values[SELECTIONY] = 0
	end
	
	if (#addthese > 0) then
		editor4.values[SELECTIONWIDTH] = #addthese
		editor4.values[SELECTIONHEIGHT] = 1
		editor_placer.values[SELECTION_XOFFSET] = 0
		editor_placer.values[SELECTION_YOFFSET] = 0
		
		MF_loop("createselectionrect_x", #addthese)
	else
		editor4.values[SELECTION_ON] = 0
		editor4.values[SELECTIONWIDTH] = 0
		editor4.values[SELECTIONHEIGHT] = 0
		editor_placer.values[SELECTION_XOFFSET] = 0
		editor_placer.values[SELECTION_YOFFSET] = 0
	end
	
	return result,#addthese
end