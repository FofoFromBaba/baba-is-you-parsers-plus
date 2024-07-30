function hasfeature(rule1,rule2,rule3,unitid,x,y,checkedconds,ignorebroken_)
	local ignorebroken = false
	if (ignorebroken_ ~= nil) then
		ignorebroken = ignorebroken_
	end

	if (rule1 ~= nil) and (rule2 ~= nil) and (rule3 ~= nil) then
		if (featureindex[rule1] ~= nil) then
			for i,rules in ipairs(featureindex[rule1]) do
				local rule = rules[1]
				local conds = rules[2]

				if (conds[1] ~= "never") then
					if (rule[1] == rule1) and (rule[2] == rule2) and (rule[3] == rule3) then
						if testcond(conds,unitid,x,y,nil,nil,checkedconds,ignorebroken) then
							return true
						end
					end
				end
			end
		end

		if (string.sub(rule1,1,5) == "text_") and (featureindex["text"] ~= nil) then
			for i,rules in ipairs(featureindex["text"]) do
				local rule = rules[1]
				local conds = rules[2]

				if (conds[1] ~= "never") then
					if (rule[1] == "text") and (rule[2] == rule2) and (rule[3] == rule3) then
						if testcond(conds,unitid,x,y,nil,nil,checkedconds,ignorebroken) then
							return true
						end
					end
				end
			end
		end

		if (string.sub(rule1,1,6) == "glyph_") and (featureindex["glyph"] ~= nil) then
			for i,rules in ipairs(featureindex["glyph"]) do
				local rule = rules[1]
				local conds = rules[2]

				if (conds[1] ~= "never") then
					if (rule[1] == "glyph") and (rule[2] == rule2) and (rule[3] == rule3) then
						if testcond(conds,unitid,x,y,nil,nil,checkedconds,ignorebroken) then
							return true
						end
					end
				end
			end
		end

		if (string.sub(rule1,1,6) == "event_") and (featureindex["event"] ~= nil) then
			for i,rules in ipairs(featureindex["event"]) do
				local rule = rules[1]
				local conds = rules[2]

				if (conds[1] ~= "never") then
					if (rule[1] == "event") and (rule[2] == rule2) and (rule[3] == rule3) then
						if testcond(conds,unitid,x,y,nil,nil,checkedconds,ignorebroken) then
							return true
						end
					end
				end
			end
		end

		if (string.sub(rule1,1,5) == "node_") and (featureindex["node"] ~= nil) then
			for i,rules in ipairs(featureindex["node"]) do
				local rule = rules[1]
				local conds = rules[2]
				
				if (conds[1] ~= "never") then
					if (rule[1] == "node") and (rule[2] == rule2) and (rule[3] == rule3) then
						if testcond(conds,unitid,x,y,nil,nil,checkedconds,ignorebroken) then
							return true
						end
					end
				end
			end
		end
		if (string.sub(rule1, 1, 6) == "logic_") and (featureindex["logic"] ~= nil) then
			for i,rules in ipairs(featureindex["logic"]) do
				local rule = rules[1]
				local conds = rules[2]
				
				if (conds[1] ~= "never") then
					if (rule[1] == "logic") and (rule[2] == rule2) and (rule[3] == rule3) then
						if testcond(conds,unitid,x,y,nil,nil,checkedconds,ignorebroken) then
							return true
						end
					end
				end
			end
		end
          
		if (string.sub(rule1,1,4) == "obj_") and (featureindex["obj"] ~= nil) then
			for i,rules in ipairs(featureindex["obj"]) do
				local rule = rules[1]
				local conds = rules[2]
				
				if (conds[1] ~= "never") then
					if (rule[1] == "obj") and (rule[2] == rule2) and (rule[3] == rule3) then
						if testcond(conds,unitid,x,y,nil,nil,checkedconds,ignorebroken) then
							return true
						end
					end
				end
			end
		end
	end

	if (rule3 ~= nil) and (rule2 ~= nil) and (rule1 ~= nil) then
		if (featureindex[rule3] ~= nil) then
			for i,rules in ipairs(featureindex[rule3]) do
				local rule = rules[1]
				local conds = rules[2]

				if (conds[1] ~= "never") then
					if (rule[1] == rule1) and (rule[2] == rule2) and (rule[3] == rule3) then
						if testcond(conds,unitid,x,y,nil,nil,checkedconds,ignorebroken) then
							return true
						end
					end
				end
			end
		end
		
		if (string.sub(rule3,1,4) == "obj_") and (featureindex["obj"] ~= nil) then
			for i,rules in ipairs(featureindex["obj"]) do
				local rule = rules[1]
				local conds = rules[2]
				
				if (conds[1] ~= "never") then
					if (rule[1] == rule1) and (rule[2] == rule2) and (rule[3] == "obj") then
						if testcond(conds,unitid,x,y,nil,nil,checkedconds,ignorebroken) then
							return true
						end
					end
				end
			end
		end

		if (string.sub(rule3,1,5) == "text_") and (featureindex["text"] ~= nil) then
			for i,rules in ipairs(featureindex["text"]) do
				local rule = rules[1]
				local conds = rules[2]

				if (conds[1] ~= "never") then
					if (rule[1] == rule1) and (rule[2] == rule2) and (rule[3] == "text") then
						if testcond(conds,unitid,x,y,nil,nil,checkedconds,ignorebroken) then
							return true
						end
					end
				end
			end
		end

		if (string.sub(rule3,1,6) == "glyph_") and (featureindex["glyph"] ~= nil) then
			for i,rules in ipairs(featureindex["glyph"]) do
				local rule = rules[1]
				local conds = rules[2]

				if (conds[1] ~= "never") then
					if (rule[1] == rule1) and (rule[2] == rule2) and (rule[3] == "glyph") then
						if testcond(conds,unitid,x,y,nil,nil,checkedconds,ignorebroken) then
							return true
						end
					end
				end
			end
		end

		if (string.sub(rule3,1,6) == "event_") and (featureindex["event"] ~= nil) then
			for i,rules in ipairs(featureindex["event"]) do
				local rule = rules[1]
				local conds = rules[2]

				if (conds[1] ~= "never") then
					if (rule[1] == rule1) and (rule[2] == rule2) and (rule[3] == "event") then
						if testcond(conds,unitid,x,y,nil,nil,checkedconds,ignorebroken) then
							return true
						end
					end
				end
			end
		end

		if (string.sub(rule3,1,5) == "node_") and (featureindex["node"] ~= nil) then
			for i,rules in ipairs(featureindex["node"]) do
				local rule = rules[1]
				local conds = rules[2]
				
				if (conds[1] ~= "never") then
					if (rule[1] == rule1) and (rule[2] == rule2) and (rule[3] == "node") then
						if testcond(conds,unitid,x,y,nil,nil,checkedconds,ignorebroken) then
							return true
						end
					end
				end
			end
		end

		if (string.sub(rule3, 1,6) == "logic_") and (featureindex["logic"] ~= nil) then
			for i,rules in ipairs(featureindex["logic"]) do
				local rule = rules[1]
				local conds = rules[2]
				
				if (conds[1] ~= "never") then
					if (rule[1] == rule1) and (rule[2] == rule2) and (rule[3] == "logic") then
						if testcond(conds,unitid,x,y,nil,nil,checkedconds,ignorebroken) then
							return true
						end
					end
				end
			end
		end
	end

	if (featureindex[rule2] ~= nil) and (rule1 ~= nil) and (rule3 == nil) then
		local usable = false

		if (featureindex[rule1] ~= nil) then
			for i,rules in ipairs(featureindex[rule1]) do
				local rule = rules[1]
				local conds = rules[2]

				if (conds[1] ~= "never") then
					for a,mat in pairs(objectlist) do
						if (a == rule[1]) then
							usable = true
							break
						end
					end

					if (rule[1] == rule1) and (rule[2] == rule2) and usable then
						if testcond(conds,unitid,x,y,nil,nil,checkedconds,ignorebroken) then
							return true
						end
					end
				end
			end
		end
	end

	return nil
end