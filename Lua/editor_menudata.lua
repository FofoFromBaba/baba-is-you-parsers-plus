menufuncs.currobjlist =
	{
		button = "CurrentObjectList",
		escbutton = "editor_return",
		enter = 
			function(parent,name,buttonid,extra)
				editor2.values[OBJLISTTYPE] = 1
				editor_objects_build(nil,nil)
				
				local total = #editor_objects
				local total_ = #editor_currobjlist
				
				local ymult = 1.5
				
				local x_ = 1.5 * f_tilesize
				local y_ = 2 * f_tilesize
				
				local dynamic_structure = {}
				
				createbutton("tool_normal",x_,y_,2,2,2,"",name,3,2,buttonid,nil,nil,langtext("tooltip_currobjlist_tool_normal",true),bicons.t_pen,true)
				createbutton("tool_line",x_ + f_tilesize * 2,y_,2,2,2,"",name,3,2,buttonid,nil,nil,langtext("tooltip_currobjlist_tool_line",true),bicons.t_line,true)
				createbutton("tool_rectangle",x_ + f_tilesize * 4,y_,2,2,2,"",name,3,2,buttonid,nil,nil,langtext("tooltip_currobjlist_tool_rectangle",true),bicons.t_rect,true)
				createbutton("tool_fillrectangle",x_ + f_tilesize * 6,y_,2,2,2,"",name,3,2,buttonid,nil,nil,langtext("tooltip_currobjlist_tool_fillrectangle",true),bicons.t_frect,true)
				createbutton("tool_select",x_ + f_tilesize * 8,y_,2,2,2,"",name,3,2,buttonid,nil,nil,langtext("tooltip_currobjlist_tool_select",true),bicons.t_select,true)
				createbutton("tool_fill",x_ + f_tilesize * 10,y_,2,2,2,"",name,3,2,buttonid,nil,nil,langtext("tooltip_currobjlist_tool_fill",true),bicons.t_fill,true)
				createbutton("tool_erase",x_ + f_tilesize * 12,y_,2,2,2,"",name,3,2,buttonid,nil,nil,langtext("tooltip_currobjlist_tool_erase",true),bicons.t_erase,true)
				
				local selected_tool = editor2.values[EDITORTOOL]
				
				makeselection({"tool_normal","tool_line","tool_rectangle","tool_fillrectangle","tool_select","tool_fill","tool_erase"},selected_tool + 1)
				
				local searchdisable = true
				if (total_ > 1) then
					searchdisable = false
				end
				
				local deletesearchdisable = searchdisable
				
				if (string.len(objlistdata.search_currobjlist) == 0) then
					deletesearchdisable = true
				end
				
				createbutton("search_edit",x_ + f_tilesize * 14.5,y_,2,2,2,"",name,3,2,buttonid,searchdisable,nil,langtext("tooltip_currobjlist_search_edit",true),bicons.search)
				createbutton("search_remove",x_ + f_tilesize * 16.5,y_,2,2,2,"",name,3,2,buttonid,deletesearchdisable,nil,langtext("tooltip_currobjlist_search_remove",true),bicons.rsearch)
				createbutton("search_tags",x_ + f_tilesize * 18.5,y_,2,2,2,"",name,3,2,buttonid,searchdisable,nil,langtext("tooltip_currobjlist_search_tags",true),bicons.tags)
				
				ymult = ymult + 1
				
				local atlimit = false
				if (total_ >= 150) then
					atlimit = true
				end
				createbutton("add",x_ + f_tilesize * 21,y_,2,2,2,"",name,3,2,buttonid,atlimit,nil,langtext("tooltip_currobjlist_add",true),bicons.o_add)
				
				local removedisable = true
				if (total_ > 0) then
					removedisable = false
				end
				
				createbutton("remove",x_ + f_tilesize * 23,y_,2,2,2,"",name,3,2,buttonid,removedisable,nil,langtext("tooltip_currobjlist_remove",true),bicons.o_del)
				createbutton("editobject",x_ + f_tilesize * 25,y_,2,2,2,"",name,3,2,buttonid,removedisable,nil,langtext("tooltip_currobjlist_editobject",true),bicons.o_edit)
				
				local pair_option_names = {"l_separate", "l_pairs"}
				local pair_option = editor2.values[DOPAIRS] + 1
				local pair_option_ = pair_option_names[pair_option]
				
				--createbutton("nothing",24.5 * f_tilesize,ymult * f_tilesize - f_tilesize,2,8,1,langtext("editor_objectlist_nothing"),name,3,2,buttonid)
				createbutton("dopairs",x_ + f_tilesize * 27.5,y_,2,2,2,"",name,3,2,buttonid,nil,nil,langtext("tooltip_currobjlist_dopairs",true),bicons[pair_option_])
				
				local this_structure = {{"tool_normal","cursor"},{"tool_line","cursor"},{"tool_rectangle","cursor"},{"tool_fillrectangle","cursor"},{"tool_select","cursor"},{"tool_fill","cursor"},{"tool_erase","cursor"},{"search_edit","cursor"},{"search_remove","cursor"},{"search_tags","cursor"},{"add","cursor"},{"remove","cursor"},{"editobject","cursor"},{"dopairs","cursor"}}
				
				if (pair_option == 2) then
					createbutton("swap",x_ + f_tilesize * 29.5,y_,2,2,2,"",name,3,2,buttonid,nil,nil,langtext("tooltip_currobjlist_swap",true),bicons.swap)
					table.insert(this_structure, {"swap","cursor"})
				end
				
				if (generaldata.strings[BUILD] ~= "n") then
					table.insert(this_structure, {"editor_return","cursor"})
					createbutton("editor_return",x_ + f_tilesize * 32,y_,2,2,2,"",name,3,2,buttonid,nil,nil,langtext("tooltip_currobjlist_return",true),bicons.cross)
				end
				
				table.insert(dynamic_structure, this_structure)
				
				ymult = ymult + 1
				
				local subline = ""
				
				if (editor4.values[EDITOR_TUTORIAL] == 0) then
					if (string.len(objlistdata.search_currobjlist) > 0) then
						subline = langtext("editor_objectlist_result") .. " '" .. objlistdata.search_currobjlist .. "'"
						
						if (#objlistdata.tags_currobjlist > 0) then
							subline = subline .. ", "
						end
					end
					
					if (#objlistdata.tags_currobjlist > 0) then
						if (#objlistdata.tags_currobjlist == 1) then
							subline = subline .. langtext("editor_objectlist_tag") .. " "
						else
							subline = subline .. langtext("editor_objectlist_tags") .. " "
						end
						
						for i,v in ipairs(objlistdata.tags_currobjlist) do
							subline = subline .. v
							
							if (i < #objlistdata.tags_currobjlist) then
								subline = subline .. ", "
							end
						end
					end
					
					if (string.len(subline) == 0) then
						subline = langtext("editor_objectlist_search_none")
					end
				
					writetext(subline,0,1.5 * f_tilesize,ymult * f_tilesize,name,false,2,nil,nil,nil,nil,nil,true)
				end
				
				local xmaxdim = 15
				local ymaxdim = 9
				
				local yoff = ymult * f_tilesize
				local xoff = f_tilesize * 0.5 + 6
				local tsize = 36
				
				for a=1,xmaxdim do
					for b=1,(ymaxdim+1) do
						local backid = MF_currobjlist_back(xoff + a * tsize, yoff + b * tsize, 1)
					end
				end
				
				if (total > 0) then
					local x = 1
					local y = 1
					
					local ydim = math.floor(math.sqrt(total))
					local xdim = math.floor(total / ydim)
					
					ydim = math.min(ymaxdim, ydim)
					local maxtotal = xdim * ydim
					
					while (total > maxtotal) do
						xdim = xdim + 1
						maxtotal = xdim * ydim
					end
					
					local struct = {}
					
					MF_setobjlisttopleft(tsize + xoff,tsize + yoff)
					
					for i=1,total do
						local iddata = editor_objects[i]
						local id = iddata.objlistid
						local oid = iddata.databaseid
						
						local gx = x
						local gy = y
						
						local obj = editor_currobjlist[oid]
						
						if (editor2.values[DOPAIRS] == 1) then
							if (obj.grid_overlap ~= nil) then
								local gridpos = obj.grid_overlap
								gx = gridpos[1] + 1
								gy = gridpos[2] + 1
							end
						elseif (editor2.values[DOPAIRS] == 0) then
							if (obj.grid_full ~= nil) then
								local gridpos = obj.grid_full
								gx = gridpos[1] + 1
								gy = gridpos[2] + 1
							end
						end
						
						local v = editor_objlist[id] or {}
						local name = getactualdata_objlist(obj.object, "name")
						
						local objword = editor2.values[OBJECTWORDSWAP]
						local objwords = {["object"] = 0, ["text"] = 1}
						local ut = objwords[v.unittype] or 0
						local valid = true
						
						if (editor2.values[DOPAIRS] == 1) and ((v.unpaired == nil) or (v.unpaired == false)) and ((obj.pair ~= nil) and (obj.pair ~= 0)) then
							if (v.type == 0) and (ut ~= objword) then
								valid = false
							end
						end
						
						if valid then
							local buttonfunc = tostring(oid) .. "," .. name .. "," .. tostring(i)
							local bid = createbutton_objlist(buttonfunc,gx * tsize + xoff,gy * tsize + yoff,name,3,2,buttonid,2)
							MF_setbuttongrid(bid,gx - 1,gy - 1,obj.object)
							
							local imagefile = getactualdata_objlist(obj.object, "sprite")
							local ut = getactualdata_objlist(obj.object, "unittype")
							local root = getactualdata_objlist(obj.object, "sprite_in_root")
							local c = {}
							
							if (ut == "object") then
								c = getactualdata_objlist(obj.object, "colour")
							elseif (ut == "text") or (ut == "node") or (ut == "logic") or (ut == "obj") then
								c = getactualdata_objlist(obj.object, "active")
							end
							
							if (root == nil) then
								root = true
							end
							
							local c1 = c[1] or 0
							local c2 = c[2] or 3
							
							local folder = "Sprites/"
							
							if (root == false) then
								local world = generaldata.strings[WORLD]
								folder = "Worlds/" .. world .. "/Sprites/"
							end
							
							--MF_alert(name .. ", " .. obj.object .. ", " .. imagefile)
							imagefile = imagefile .. "_0_1"
							MF_thumbnail(folder,imagefile,i-1,0,0,bid,c1,c2,0,0,buttonid,obj.object)
							
							x = x + 1
							
							if (x > xdim) then
								x = 1
								y = y + 1
							end
						end
					end
				end
				
				if (generaldata.strings[BUILD] ~= "n") then
					local dir = editor.values[EDITORDIR]
					
					local dir_x = screenw - f_tilesize * 5
					local dir_y = f_tilesize * 7.6
					
					createbutton("dir_right",dir_x + f_tilesize * 2.5,dir_y,2,2.5,2.5,"",name,3,2,buttonid,nil,nil,langtext("tooltip_currobjlist_dir_right",true),bicons.r_arrow)
					createbutton("dir_up",dir_x,dir_y - f_tilesize * 2.5,2,2.5,2.5,"",name,3,2,buttonid,nil,nil,langtext("tooltip_currobjlist_dir_up",true),bicons.u_arrow)
					createbutton("dir_left",dir_x - f_tilesize * 2.5,dir_y,2,2.5,2.5,"",name,3,2,buttonid,nil,nil,langtext("tooltip_currobjlist_dir_left",true),bicons.l_arrow)
					createbutton("dir_down",dir_x,dir_y + f_tilesize * 2.5,2,2.5,2.5,"",name,3,2,buttonid,nil,nil,langtext("tooltip_currobjlist_dir_down",true),bicons.d_arrow)
					
					makeselection({"dir_right","dir_up","dir_left","dir_down"},dir + 1)
				end
				
				local dir_x = screenw - f_tilesize * 5
				local dir_y = f_tilesize * 4.6
				
				--table.insert(dynamic_structure, {{"currobjlist","custom"}})
				
				local x = screenw - f_tilesize * 7
				local y = f_tilesize * 14.5
				
				if (generaldata.strings[BUILD] ~= "n") then
					controlicon_editor("gamepad_currobjlist","tooltip",x,y,buttonid,langtext("buttons_currobjlist_tooltip",true))
					
					y = y - f_tilesize * 1.25
					
					controlicon_editor("gamepad_currobjlist","swap",x,y,buttonid,langtext("buttons_currobjlist_swap",true))
					
					y = y - f_tilesize * 1.25
					
					controlicon_editor("gamepad_currobjlist","drag",x,y,buttonid,langtext("buttons_currobjlist_drag",true))
					
					y = y - f_tilesize * 1.25
					
					controlicon_editor("gamepad_currobjlist","select",x,y,buttonid,langtext("buttons_currobjlist_select",true))
				else
					x = screenw - f_tilesize * 5
					y = f_tilesize * 13
					
					controlicon_editor("gamepad_currobjlist","x",x,y - f_tilesize,buttonid,"buttons_currobjlist",1,true)
					controlicon_editor("gamepad_currobjlist","y",x - f_tilesize,y,buttonid,"buttons_currobjlist",2,true)
					controlicon_editor("gamepad_currobjlist","b",x,y + f_tilesize,buttonid,"buttons_currobjlist",3,true)
					controlicon_editor("gamepad_currobjlist","a",x + f_tilesize,y,buttonid,"buttons_currobjlist",0,true)
				end
				
				x = screenw - f_tilesize * 6
				y = f_tilesize * 4
				
				controlicon_editor("gamepad_currobjlist","scrollleft",x - f_tilesize,y,buttonid,langtext("buttons_currobjlist_scrollleft",true),2)
				controlicon_editor("gamepad_currobjlist","scrollright",x + f_tilesize,y,buttonid,langtext("buttons_currobjlist_scrollright",true),0)
				
				controlicon_editor("gamepad_currobjlist","autoadd",x - f_tilesize,y + f_tilesize * 2,buttonid,langtext("buttons_currobjlist_autoadd",true),2)
				controlicon_editor("gamepad_editor","scrollright_tool",x + f_tilesize,y + f_tilesize * 2,buttonid,langtext("buttons_currobjlist_removesearch",true),0)
				
				dir_y = f_tilesize * 5 + f_tilesize * 5
				
				if (editor2.values[EXTENDEDMODE] == 1) then
					dir_y = dir_y + f_tilesize * 4 + f_tilesize * 2
					
					local world = generaldata.strings[WORLD]
					local tooldisable = false
					if (world == "levels") then
						tooldisable = true
					end
					
					createbutton("brush_normal",dir_x,dir_y,2,8,1,langtext("editor_brush_normal"),name,3,2,buttonid)
					createbutton("brush_level",dir_x,dir_y + f_tilesize * 1,2,8,1,langtext("editor_brush_level"),name,3,2,buttonid,tooldisable)
					createbutton("brush_path",dir_x - f_tilesize * 0.5,dir_y + f_tilesize * 2,2,7,1,langtext("editor_brush_path"),name,3,2,buttonid)
					createbutton("brush_special",dir_x,dir_y + f_tilesize * 3,2,8,1,langtext("editor_brush_special"),name,3,2,buttonid)
					
					createbutton("brush_pathsetup",dir_x + f_tilesize * 3.5,dir_y + f_tilesize * 2,2,1,1,"",name,3,2,buttonid,nil,nil,nil,bicons.cog)
					
					selected_tool = editor.values[STATE]
					makeselection({"brush_normal","brush_level","_brush_cursor","brush_path","brush_special"},selected_tool + 1)
					
					table.insert(dynamic_structure, {{"brush_normal"}})
					table.insert(dynamic_structure, {{"brush_level"}})
					table.insert(dynamic_structure, {{"brush_path"},{"brush_pathsetup"}})
					table.insert(dynamic_structure, {{"brush_special"}})
				end
				
				if (string.len(editor4.strings[EDITOR_CURROBJTARGET]) > 0) then
					MF_positioncurrobjselector(editor4.strings[EDITOR_CURROBJTARGET])
					editor4.strings[EDITOR_CURROBJTARGET] = ""
				end
				
				buildmenustructure(dynamic_structure)
			end,
		leave = 
			function(parent,name)
				MF_clearthumbnails("CurrentObjectList")
				MF_currobjlist_backdel()
			end,
	}


function hotbar_updatethumbnail(object,thumbid,slotid)
	local thumb = mmf.newObject(thumbid)
	
	if (string.len(object) > 0) then
		local sprite = getactualdata_objlist(object,"sprite")
		local sprite_in_root = getactualdata_objlist(object,"sprite_in_root")
		local colour = getactualdata_objlist(object,"colour")
		local colour_a = getactualdata_objlist(object,"active")
		local tiletype = getactualdata_objlist(object,"unittype")
		
		local path = "Data/Sprites/"
		if (sprite_in_root == false) then
			path = "Data/Worlds/" .. generaldata.strings[WORLD] .. "/Sprites/"
		end
		
		MF_thumbnail_loadimage(thumbid,0,slotid,path .. sprite .. "_0_1.png")
		
		if (tiletype == "object") then
			MF_setcolour(thumbid, colour[1], colour[2])
		else
			MF_setcolour(thumbid, colour_a[1], colour_a[2])
		end
		
		thumb.visible = true
	else
		thumb.visible = false
	end
end

menufuncs.settings =
	{
		button = "SettingsButton",
		enter = 
			function(parent,name,buttonid)
				local x = screenw * 0.5
				local y = 1.5 * f_tilesize
				
				local disable = MF_unfinished()
				local build = generaldata.strings[BUILD]
				
				local extrasize = 0
				local sliderxoffset = 0
				local slideryoffset = 0
				local delaytext = "settings_repeat"
				
				if (build ~= "m") then
					writetext(langtext("settings_colon"),0,x,y,name,true,2,true)
					y = y + f_tilesize * 1
				else
					extrasize = f_tilesize * 1.5
					sliderxoffset = 0 - f_tilesize * 4
					slideryoffset = 0 - f_tilesize * 0.6
					delaytext = "settings_repeat_m"
				end
				
				x = screenw * 0.5 - f_tilesize * 1
				
				writetext(langtext("settings_music"),0,x - f_tilesize * 11.5 + sliderxoffset,y + slideryoffset,name,false,2,true)
				local mvolume = MF_read("settings","settings","music")
				slider("music",x + f_tilesize * 5 + sliderxoffset * 1.5,y + slideryoffset,8,{1,3},{1,4},buttonid,0,100,tonumber(mvolume))
				
				y = y + f_tilesize + extrasize * 0.5
				
				writetext(langtext("settings_sound"),0,x - f_tilesize * 11.5 + sliderxoffset,y + slideryoffset,name,false,2,true)
				local svolume = MF_read("settings","settings","sound")
				slider("sound",x + f_tilesize * 5 + sliderxoffset * 1.5,y + slideryoffset,8,{1,3},{1,4},buttonid,0,100,tonumber(svolume))
				
				y = y + f_tilesize + extrasize * 0.5
				
				writetext(langtext(delaytext),0,x - f_tilesize * 11.5 + sliderxoffset,y + slideryoffset,name,false,2,true)
				local delay = MF_read("settings","settings","delay")
				slider("delay",x + f_tilesize * 5 + sliderxoffset * 1.5,y + slideryoffset,8,{1,3},{1,4},buttonid,7,20,tonumber(delay))
				
				x = screenw * 0.5
				y = y + f_tilesize * 2 + extrasize
				
				local s,c,icon = 0,{0,3},""
				
				if (build ~= "m") then
					createbutton("language",x,y,2,18,1,langtext("settings_language"),name,3,2,buttonid)
				
					y = y + f_tilesize
				end
				
				if (build ~= "n") and (build ~= "m") then
					createbutton("controls",x,y,2,18,1,langtext("controls"),name,3,2,buttonid)
				
					y = y + f_tilesize
				
					local fullscreen = MF_read("settings","settings","fullscreen")
					s,c = gettoggle(fullscreen)
					createbutton("fullscreen",x,y,2,18,1,langtext("settings_fullscreen"),name,3,2,buttonid,nil,s)
					
					y = y + f_tilesize
				end
				
				local grid = MF_read("settings","settings","grid")
				s,c,icon = gettoggle(grid,{"m_settings_grid_no","m_settings_grid"})
				
				if (build ~= "m") then
					createbutton("grid",x,y,2,18,1,langtext("settings_grid"),name,3,2,buttonid,nil,s)
					
					y = y + f_tilesize + extrasize
				else
					y = y - f_tilesize * 0.5
					
					createbutton("grid",x - f_tilesize * 12.5,y,2,4,4,"",name,3,2,buttonid,nil,nil,nil,bicons[icon])
				end
				
				local wobble = MF_read("settings","settings","wobble")
				s,c,icon = gettoggle(wobble,{"m_settings_wobble","m_settings_wobble_no"})
				
				if (build ~= "m") then
					createbutton("wobble",x,y,2,18,1,langtext("settings_wobble"),name,3,2,buttonid,nil,s)
					
					y = y + f_tilesize + extrasize
				else
					createbutton("wobble",x - f_tilesize * 7.5,y,2,4,4,"",name,3,2,buttonid,nil,nil,nil,bicons[icon])
				end
				
				local particles = MF_read("settings","settings","particles")
				s,c,icon = gettoggle(particles,{"m_settings_particles","m_settings_particles_no"})
				
				if (build ~= "m") then
					createbutton("particles",x,y,2,18,1,langtext("settings_particles"),name,3,2,buttonid,nil,s)
				else
					createbutton("particles",x - f_tilesize * 2.5,y,2,4,4,"",name,3,2,buttonid,nil,nil,nil,bicons[icon])
				end
				
				if (build == "m") then
					createbutton("language",x + f_tilesize * 2.5,y,2,4,4,"",name,3,2,buttonid,nil,nil,nil,bicons.m_settings_language)
					
					local hand = MF_read("settings","settings","m_hand")
					s,c,icon = gettoggle(hand,{"m_settings_hand_right","m_settings_hand_left"})
					
					createbutton("hand",x + f_tilesize * 7.5,y,2,4,4,"",name,3,2,buttonid,nil,nil,nil,bicons[icon])
					
					local pointers = MF_read("settings","settings","m_pointers")
					s,c,icon = gettoggle(pointers,{"m_settings_pointers_on","m_settings_pointers_off"})
					
					createbutton("pointers",x + f_tilesize * 12.5,y,2,4,4,"",name,3,2,buttonid,nil,nil,nil,bicons[icon])
				
					y = y + f_tilesize
				end
				
				local shake = MF_read("settings","settings","shake")
				s,c,icon = gettoggle(shake)
				
				y = y + f_tilesize + extrasize
				
				if (build ~= "m") then
					createbutton("shake",x,y,2,18,1,langtext("settings_shake"),name,3,2,buttonid,nil,s)
				else
					createbutton("shake",x,y,2,32,2,langtext("settings_shake"),name,3,2,buttonid,nil,s)
				end
				
				y = y + f_tilesize + extrasize * 0.9
				
				local contrast = MF_read("settings","settings","contrast")
				s,c = gettoggle(contrast)
				
				if (build ~= "m") then
					createbutton("contrast",x,y,2,18,1,langtext("settings_palette"),name,3,2,buttonid,nil,s)
				else
					createbutton("contrast",x,y,2,32,2,langtext("settings_palette"),name,3,2,buttonid,nil,s)
					
					--y = y + f_tilesize * 0.1
				end
				
				y = y + f_tilesize + extrasize * 0.9
				
				local blinking = MF_read("settings","settings","blinking")
				s,c = gettoggle(blinking)
				
				if (build ~= "m") then
					createbutton("blinking",x,y,2,18,1,langtext("settings_blinking"),name,3,2,buttonid,nil,s)
					
					y = y + f_tilesize + extrasize * 0.9
				end
				
				local restartask = MF_read("settings","settings","restartask")
				s,c = gettoggle(restartask)
				
				if (build ~= "m") then
					createbutton("restartask",x,y,2,18,1,langtext("settings_restart"),name,3,2,buttonid,nil,s)
				else
					createbutton("restartask",x,y,2,32,2,langtext("settings_restart"),name,3,2,buttonid,nil,s)
					
					--y = y + f_tilesize * 0.1
				end
				
				y = y + f_tilesize + extrasize * 0.9

				local parsing = MF_read("settings","settings","objparsing")
				s,c = gettoggle(parsing)
				createbutton("objparsing",x,y,2,18,1,"Enable Obj Parsing",name,3,2,buttonid,nil,s)
				
				y = y + f_tilesize + extrasize * 0.9
				
				--[[
				local zoom = MF_read("settings","settings","zoom")
				s,c = gettoggle(zoom)
				createbutton("zoom",x,y,2,16,1,langtext("settings_zoom"),name,3,2,buttonid,nil,s)
				]]--
				
				if (build ~= "m") then
					writetext(langtext("settings_zoom"),0,x - f_tilesize * 15.5,y,name,false,2,true)
					
					local zoom = tonumber(MF_read("settings","settings","zoom")) or 0
					createbutton("zoom1",x - f_tilesize * 4.5,y,2,7,1,langtext("zoom1"),name,3,2,buttonid,nil)
					createbutton("zoom2",x + f_tilesize * 3.5,y,2,7,1,langtext("zoom2"),name,3,2,buttonid,nil)
					createbutton("zoom3",x + f_tilesize * 11.5,y,2,7,1,langtext("zoom3"),name,3,2,buttonid,nil)
					
					makeselection({"zoom2","zoom1","zoom3"},tonumber(zoom) + 1)
					
					y = y + f_tilesize
				end
				
				if (build == "n") and (1 == 0) then
					local disablestick = generaldata5.values[DISABLESTICK] + 1
					createbutton("disable_stick",x,y,2,18,1,langtext("controls_disablestick"),name,3,2,buttonid)
					makeselection({"","disable_stick"},disablestick)
					
					y = y + f_tilesize
				end
				
				if (build ~= "m") then
					createbutton("return",x,y,2,18,1,langtext("return"),name,3,2,buttonid)
				else
					createbutton("return",x,y,2,24,2,langtext("return"),name,3,2,buttonid)
				end
			end,
		structure =
		{
			{
				{{"music",-392},},
				{{"sound",-392},},
				{{"delay",-392},},
				{{"language"},},
				{{"controls"},},
				{{"fullscreen"},},
				{{"grid"},},
				{{"wobble"},},
				{{"particles"},},
				{{"shake"},},
				{{"contrast"},},
				{{"blinking"},},
				{{"restartask"},},
				{{"objparsing"},},
				{{"zoom1"},{"zoom2"},{"zoom3"},},
				{{"return"},},
			},
			n = {
				{{"music",-392},},
				{{"sound",-392},},
				{{"delay",-392},},
				{{"language"},},
				{{"grid"},},
				{{"wobble"},},
				{{"particles"},},
				{{"shake"},},
				{{"contrast"},},
				{{"blinking"},},
				{{"restartask"},},
				{{"objparsing"},},
				{{"zoom1"},{"zoom2"},{"zoom3"},},
				-- {{"disable_stick"},},
				{{"return"},},
			},
			m = {
				{{"music",-340},},
				{{"sound",-340},},
				{{"delay",-340},},
				{{"grid"},{"wobble"},{"particles"},{"language"},{"hand"},{"pointers"},},
				{{"shake"}},
				{{"contrast"}},
				{{"restartask"},},
				{{"objparsing"},},
				{{"return"},},
			},
		}
	}
buttonclick_list["objparsing"] = function(unitid)
	local parsing = MF_read("settings","settings","objparsing")
	if parsing ~= "1" then
		MF_playsound("confirm_short")
		MF_playsound("rule" .. math.random(1,4))
		MF_store("settings","settings","objparsing",1)
	else
		MF_playsound("confirm_short")
		MF_store("settings","settings","objparsing",0)
	end
	parsing = MF_read("settings","settings","objparsing")
	updatebuttoncolour(unitid,tonumber(parsing))
end