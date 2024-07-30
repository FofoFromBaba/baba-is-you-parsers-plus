local objobjlist = {"baba","keke","rock","tile","flag","triangle","key","obj","is","wall", "you", "door", "obj_baba","arrow","text_obj","jiji","bog","water","empty","obj_obj_baba","obj_obj_obj_baba","dot","tree","it","fungus","jelly","cliff","pillar","obj_obj_obj_obj_baba"}
local objobjtiling = {0,3,-1,-1,-1,-1,-1,-1,0,-1,0,-1,0,0,-1,0,1,-1,-1,0,0,-1,-1,-1,-1,-1,0,-1,0,-1,0}
local objobjcolors = {
	bog = {5,0},
	triangle = {4,3},
	["obj_baba"] = {2,1},
	["obj_obj_baba"] = {2,0},
	["obj_obj_obj_baba"] = {1,0},
	["obj_obj_obj_obj_baba"] = {6,4},
	["text_obj"] = {0,0},
	empty = {2,0}
}
--[[
	valid types:
	0 = noun
	1 = noun
	-1 = noun
	0 = noun
	-1 = noun
	i = noun
]]--
local objobjtypes = {
	baba = 0,
	keke = 0,
	rock = 0,
	tile = 0,
	flag = 0,
	triangle = 0,
	key = 0,
	obj = 0,
	is = 1,
	wall = 0,
	you = -1,
	door = 0,
	["obj_baba"] = i,
	["obj_obj_baba"] = i,
	["obj_obj_obj_baba"] = i,
	["obj_obj_obj_obj_baba"] = i,
	["text_obj"] = i,
	jiji = 0,
	bog = 0,
	empty = 0,
	dot = 0,
	tree = 0,
	it = 0,
	fungus = 0,
	jelly = 0,
	cliff = 0,
	pillar = 0,
}

table.insert(nlist.full, "obj")
table.insert(nlist.short, "obj")
table.insert(nlist.objects, "obj")

table.insert(editor_objlist_order, "text_obj")
editor_objlist["text_obj"] = {
	name = "text_obj",
	sprite_in_root = false,
	unittype = "text",
	tags = {"abstract"},
	tiling = -1,
	type = 0,
	layer = 20,
	colour = {0, 1},
	colour_active = {0, 2}
}

table.insert(editor_objlist_order, "text_becobj")
editor_objlist["text_becobj"] = {
	name = "text_becobj",
	sprite_in_root = false,
	unittype = "text",
	tags = {"abstract"},
	tiling = -1,
	type = 1,
	layer = 20,
	colour = {0, 0},
	colour_active = {0, 1},
	argtype = {0}
}

table.insert(editor_objlist_order, "text_object")
editor_objlist["text_object"] = {
	name = "text_object",
	sprite_in_root = false,
	unittype = "text",
	tags = {"abstract"},
	tiling = -1,
	type = 2,
	layer = 20,
	colour = {0, 1},
	colour_active = {0, 2}
}

table.insert(editor_objlist_order, "text_deobj")
editor_objlist["text_deobj"] = {
	name = "text_deobj",
	sprite_in_root = false,
	unittype = "text",
	tags = {"abstract"},
	tiling = -1,
	type = 2,
	layer = 20,
	colour = {0, 2},
	colour_active = {0, 3}
}

table.insert(editor_objlist_order, "text__")
editor_objlist["text__"] = {
	name = "text__",
	sprite_in_root = false,
	unittype = "text",
	tags = {"abstract"},
	tiling = -1,
	type = 2,
	layer = 20,
	colour = {1, 0},
	colour_active = {0, 0}
}

table.insert(editor_objlist_order, "text_ect")
editor_objlist["text_ect"] = {
	name = "text_ect",
	sprite_in_root = false,
	unittype = "text",
	tags = {"abstract"},
	tiling = -1,
	type = 0,
	layer = 20,
	colour = {1, 3},
	colour_active = {1, 4}
}

table.insert(editor_objlist_order, "ect")
editor_objlist["ect"] = 
{
	name = "ect",
	sprite_in_root = false,
	unittype = "object",
	tags = {"abstract"},
	tiling = -1,
	type = 0,
	layer = 8,
	colour = {1, 4},
}

formatobjlist()

for i,objobjname in pairs(objobjlist) do
	local objobjcolor = objobjcolors[objobjname] or editor_objlist[editor_objlist_reference["text_" .. objobjname]].colour or {0,1}
	
	table.insert(editor_objlist_order, "obj_" .. objobjname)
	editor_objlist["obj_" .. objobjname] = {
		name = "obj_" .. objobjname,
		sprite_in_root = false,
		unittype = "obj",
		tags = {"abstract", "obj"},
		tiling = objobjtiling[i] or -1,
		type = 0,
		layer = 20,
		colour = objobjcolor,
		colour_active = objobjcolor
	}
end
editor_objlist["obj_water"].sprite = "obj_bog"

formatobjlist()