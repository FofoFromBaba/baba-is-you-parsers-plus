table.insert(objlistdata.alltags, "logics")

table.insert(editor_objlist_order, "text_logic")

editor_objlist["text_logic"] = 
{
	name = "text_logic",
	sprite_in_root = false,
	unittype = "text",
	tags = {""},
	tiling = -1,
	type = 0,
	layer = 20,
	colour = {3, 0},
	colour_active = {3, 1},
}

table.insert(editor_objlist_order, "text_log")

editor_objlist["text_log"] = 
{
	name = "text_log",
	sprite_in_root = false,
	unittype = "text",
	tags = {""},
	tiling = -1,
	type = 1,
	layer = 20,
	colour = {0, 1},
	colour_active = {0, 3},
	argtype = {0, 2}
}

table.insert(nlist.full, "logic")
table.insert(nlist.short, "logic")
table.insert(nlist.objects, "logic")

logic_types = {}
logic_argtypes = {}

function addlogic(name,type,col,acol,argtype,tiling)
	local logicname = "logic_"..name

   	logic_types[logicname] = type
   	logic_argtypes[logicname] = argtype

	table.insert(editor_objlist_order, logicname)

	editor_objlist[logicname] = 
	{
		name = logicname,
		sprite_in_root = false,
		unittype = "logic",
		tags = {"logics"},
		tiling = tiling,
		type = 0,
		layer = 20,
		colour = col,
		colour_active = acol,
	}
end

--start
addlogic("start",4,{3,3},{4,4},{},0)
addlogic("omnistart",10,{3,0},{4,2},{},-1)

--connecters
addlogic("connect",-1,{0,1},{0,3},{},0)
addlogic("omniconnect",9,{0,1},{0,3},{},-1)
addlogic("longconnect",-4,{0,1},{0,3},{},0)
addlogic("omnilongconnect",13,{0,1},{0,3},{},-1)

--wireless connecters
addlogic("send",-3,{3,2},{3,3},{},-1)
addlogic("recieve",-2,{3,2},{3,3},{},-1)
addlogic("send2",-3,{2,1},{2,2},{},-1)
addlogic("recieve2",-2,{2,1},{2,2},{},-1)
addlogic("send3",-3,{5,2},{5,3},{},-1)
addlogic("recieve3",-2,{5,2},{5,3},{},-1)

--verbs
addlogic("is",1,{0,1},{0,3},{0,2},-1)
addlogic("has",1,{0,1},{0,3},{0},-1)
addlogic("eat",1,{2,1},{2,2},{0},-1)
addlogic("fear",1,{2,1},{2,2},{0},-1)
addlogic("follow",1,{5,1},{5,3},{0},-1)
addlogic("make",1,{0,1},{0,3},{0},-1)
addlogic("mimic",1,{2,1},{2,2},{0},-1)
addlogic("write",1,{0,1},{0,3},{0,2},-1)
addlogic("log",1,{0,1},{0,3},{0,2},-1)

--prefixes
addlogic("idle",6,{2,2},{2,3},{},-1)
addlogic("lonely",6,{2,1},{2,2},{},-1)
addlogic("often",6,{5,2},{5,3},{},-1)
addlogic("seldom",6,{3,2},{3,3},{},-1)
addlogic("powered",6,{6,1},{2,4},{},-1)
addlogic("powered2",6,{5,2},{5,3},{},-1)
addlogic("powered3",6,{3,2},{4,4},{},-1)

--infixes
addlogic("on",3,{0,1},{0,3},{0},-1)
addlogic("near",3,{0,1},{0,3},{0},-1)
addlogic("nextto",3,{0,1},{0,3},{0},-1)
addlogic("facing",3,{0,1},{0,3},{0},-1)
addlogic("seeing",3,{0,1},{0,3},{0},-1)
addlogic("without",3,{0,1},{0,3},{0},-1)
addlogic("feeling",3,{0,1},{0,3},{2},-1)
addlogic("above",3,{1,2},{1,4},{0},-1)
addlogic("below",3,{1,2},{1,4},{0},-1)
addlogic("besideleft",3,{1,2},{1,4},{0},-1)
addlogic("besideright",3,{1,2},{1,4},{0},-1)

--boolean
addlogic("true",5,{5,1},{5,3},{},0)
addlogic("omnitrue",8,{1,2},{1,4},{},-1)
addlogic("false",5,{2,1},{2,2},{},0)
addlogic("omnifalse",8,{2,2},{2,3},{},-1)

--not
addlogic("not",7,{2,1},{2,2},{},-1)

--halt
addlogic("halt",11,{2,0},{2,1},{},0)
addlogic("omnihalt",12,{2,1},{2,2},{},-1)

--special nouns
addlogic("logic",0,{3,0},{3,1},{},-1)
addlogic("text",0,{4,0},{4,1},{},-1)
addlogic("all",0,{0,1},{0,3},{},-1)
addlogic("level",0,{4,0},{4,1},{},-1)
addlogic("group",0,{3,2},{3,3},{},-1)
addlogic("group2",0,{2,1},{2,2},{},-1)
addlogic("group3",0,{5,2},{5,3},{},-1)
addlogic("empty",0,{0,1},{0,3},{},-1)
addlogic("cursor",0,{2,3},{2,4},{},-1)

--normal nouns
addlogic("baba",0,{4,0},{4,1},{},-1)
addlogic("flag",0,{6,1},{2,4},{},-1)
addlogic("wall",0,{1,1},{0,1},{},-1)
addlogic("rock",0,{6,0},{6,1},{},-1)
addlogic("brick",0,{6,0},{6,1},{},-1)
addlogic("tile",0,{1,1},{0,1},{},-1)
addlogic("grass",0,{5,1},{5,3},{},-1)
addlogic("hedge",0,{5,0},{5,1},{},-1)
addlogic("water",0,{1,2},{1,3},{},-1)
addlogic("lava",0,{2,2},{2,3},{},-1)
addlogic("bog",0,{5,1},{5,3},{},-1)
addlogic("belt",0,{1,2},{1,3},{},-1)
addlogic("cog",0,{0,1},{0,2},{},-1)
addlogic("fire",0,{2,0},{2,2},{},-1)
addlogic("ice",0,{1,2},{1,3},{},-1)
addlogic("skull",0,{2,0},{2,1},{},-1)
addlogic("pipe",0,{1,1},{0,1},{},-1)
addlogic("keke",0,{2,1},{2,2},{},-1)
addlogic("me",0,{3,0},{3,1},{},-1)
addlogic("fofo",0,{5,1},{5,2},{},-1)
addlogic("it",0,{1,2},{1,4},{},-1)
addlogic("box",0,{6,0},{6,1},{},-1)
addlogic("door",0,{2,1},{2,2},{},-1)
addlogic("key",0,{6,1},{2,4},{},-1)
addlogic("square",0,{4,0},{4,1},{},-1)
addlogic("circle",0,{5,2},{5,3},{},-1)
addlogic("fruit",0,{2,1},{2,2},{},-1)
addlogic("tree",0,{5,1},{5,2},{},-1)
addlogic("trees",0,{5,1},{5,2},{},-1)
addlogic("husk",0,{6,0},{6,1},{},-1)
addlogic("husks",0,{6,1},{6,2},{},-1)
addlogic("crab",0,{2,1},{2,2},{},-1)
addlogic("bubble",0,{1,3},{1,4},{},-1)
addlogic("algae",0,{5,1},{5,2},{},-1)
addlogic("jelly",0,{1,3},{1,4},{},-1)
addlogic("cliff",0,{6,1},{6,2},{},-1)
addlogic("star",0,{6,1},{2,4},{},-1)
addlogic("moon",0,{6,1},{2,4},{},-1)
addlogic("dust",0,{6,1},{2,4},{},-1)

--props
addlogic("you",2,{4,0},{4,1},{},-1)
addlogic("you2",2,{4,0},{4,1},{},-1)
addlogic("win",2,{6,1},{2,4},{},-1)
addlogic("stop",2,{5,0},{5,1},{},-1)
addlogic("push",2,{6,0},{6,1},{},-1)
addlogic("sink",2,{1,2},{1,3},{},-1)
addlogic("defeat",2,{2,0},{2,1},{},-1)
addlogic("hot",2,{2,2},{2,3},{},-1)
addlogic("melt",2,{1,2},{1,3},{},-1)
addlogic("open",2,{6,1},{2,4},{},-1)
addlogic("shut",2,{2,1},{2,2},{},-1)
addlogic("move",2,{5,1},{5,3},{},-1)
addlogic("shift",2,{1,2},{1,3},{},-1)
addlogic("float",2,{1,2},{1,4},{},-1)
addlogic("tele",2,{1,2},{1,4},{},-1)
addlogic("pull",2,{6,1},{6,2},{},-1)
addlogic("weak",2,{1,1},{1,2},{},-1)
addlogic("boom",2,{2,1},{2,2},{},-1)
addlogic("safe",2,{0,1},{0,3},{},-1)
addlogic("phantom",2,{1,1},{0,1},{},-1)
addlogic("swap",2,{3,0},{3,1},{},-1)
addlogic("right",2,{1,2},{1,4},{},-1)
addlogic("up",2,{1,2},{1,4},{},-1)
addlogic("left",2,{1,2},{1,4},{},-1)
addlogic("down",2,{1,2},{1,4},{},-1)
addlogic("bonus",2,{4,0},{4,1},{},-1)
addlogic("red",2,{2,1},{2,2},{},-1)
addlogic("blue",2,{3,2},{3,3},{},-1)
addlogic("fall",2,{5,1},{5,3},{},-1)
addlogic("fallright",2,{5,1},{5,3},{},-1)
addlogic("fallup",2,{5,1},{5,3},{},-1)
addlogic("fallleft",2,{5,1},{5,3},{},-1)
addlogic("nudgedown",2,{5,1},{5,3},{},-1)
addlogic("nudgeright",2,{5,1},{5,3},{},-1)
addlogic("nudgeup",2,{5,1},{5,3},{},-1)
addlogic("nudgeleft",2,{5,1},{5,3},{},-1)
addlogic("lockeddown",2,{4,1},{4,2},{},-1)
addlogic("lockedright",2,{4,1},{4,2},{},-1)
addlogic("lockedup",2,{4,1},{4,2},{},-1)
addlogic("lockedleft",2,{4,1},{4,2},{},-1)
addlogic("turn",2,{1,2},{1,4},{},-1)
addlogic("deturn",2,{1,2},{1,4},{},-1)
addlogic("power",2,{6,1},{2,4},{},-1)
addlogic("power2",2,{5,2},{5,3},{},-1)
addlogic("power3",2,{3,2},{4,4},{},-1)

formatobjlist()

function logicbaserule()
   	addbaserule("logic", "is", "push")
end

function logfix()
	for a,b in ipairs(units) do
		if b.strings[UNITTYPE] == "object" then
   			objectlist["logic_" .. b.strings[UNITNAME]] = 1
		end
		if b.strings[UNITTYPE] == "text" then
			local textrefer = string.sub(b.strings[UNITNAME],6)
   			objectlist["logic_"..textrefer] = 1
		end
		if b.strings[UNITTYPE] == "logic" then
			if logic_types[b.strings[UNITNAME]] == 0 then
				local logicrefer = string.sub(b.strings[UNITNAME],7)
   				objectlist[logicrefer] = 1
			end
		end
	end
end

table.insert(mod_hook_functions.rule_baserules, logicbaserule)
table.insert(mod_hook_functions.level_start, logfix)

function findflowunits()
	local result = {}
	local alreadydone = {}
	local checkrecursion = {}
	local related = {}
	
	local identifier = ""
	local fullid = {}
	
	if (featureindex["flow"] ~= nil) then
		for i,v in ipairs(featureindex["flow"]) do
			local rule = v[1]
			local conds = v[2]
			local ids = v[3]
			
			local name = rule[1]
			local subid = ""
			
			if (rule[2] == "is") then
				if ((objectlist[name] ~= nil) or (name == "text")) and (name ~= "logic") and (alreadydone[name] == nil) then
					local these = findall({name,{}})
					alreadydone[name] = 1
					
					if (#these > 0) then
						for a,b in ipairs(these) do
							local bunit = mmf.newObject(b)
							local unitname = ""
							if (name == "logic") then
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
						
						if (firstunit.strings[UNITNAME] ~= "text_" .. name) and (firstunit.strings[UNITNAME] ~= "text_" .. notname) and (firstunit.strings[UNITNAME] ~= "logic_" .. name) and (firstunit.strings[UNITNAME] ~= "logic_" .. notname) then
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
			
			for i,v in ipairs(featureindex["flow"]) do
				local rule = v[1]
				local ids = v[3]
				local tags = v[4]
				
				if (rule[1] == b) or ((rule[1] == "logic") and (string.sub(b, 1, 6) == "logic_")) or (rule[1] == "all") or ((rule[1] ~= b) and (string.sub(rule[1], 1, 3) == "not")) and (rule[3] == "flow") then
					for c,g in ipairs(ids) do
						for a,d in ipairs(g) do
							local idunit = mmf.newObject(d)
							
							-- Tässä pitäisi testata myös Group!
							if ((idunit.strings[UNITNAME] == "text_" .. rule[1]) and (tags[1] ~= "logic")) or (idunit.strings[UNITNAME] == "logic_" .. rule[1]) or ((idunit.strings[UNITNAME] == rule[1]) and (tags[1] ~= "logic")) or ((rule[1] == "all") and (rule[1] ~= "text")) then
								--MF_alert("Matching objects - found")
								found = true
							elseif (string.sub(rule[1], 1, 5) == "group") then
								--MF_alert("Group - found")
								found = true
							elseif (rule[1] ~= checkname) and (((string.sub(rule[1], 1, 3) == "not") and (rule[1] ~= "text")) or ((rule[1] == "not all") and (rule[1] == "text"))) then
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
				identifier = "null"
				flowunits = {}
				
				for i,v in pairs(featureindex["flow"]) do
					local rule = v[1]
					local ids = v[3]
					
					--MF_alert("Checking to disable: " .. rule[1] .. " " .. ", not " .. b)
					
					if (rule[1] == b) or (rule[1] == "not " .. b) then
						v[2] = {{"never",{}}}
					end
				end
				
				if (string.sub(checkname, 1, 4) == "not ") then
					local notrules_flow = notfeatures["flow"]
					local notrules_id = checkname_[2]
					local disablethese = notrules_flow[notrules_id]
					
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

function checkflowchanges(unitid,unitname)
	if (#flowunits > 0) then
		for i,v in ipairs(flowunits) do
			if (v[1] == unitid) then
				updatecode = 1
				return
			end
		end
	end
	
	if (#flowrelatedunits > 0) then
		for i,v in ipairs(flowrelatedunits) do
			if (v[1] == unitid) then
				updatecode = 1
				return
			end
		end
	end
end
