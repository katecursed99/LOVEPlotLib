-- LÖVEPlotLib
	-- Katherina Jesek, 2026
	-- inspired by some matplotlib functions and 
	-- syntax, but running in-engine in LÖVE2D
	-- why? because graphs are satisfying to nerds like me

local graph_template = {
	x=0, y=0, w=0, h=0,
	data={}, labels={},
	draw= function() end,
	upd= function() end
}

local default_graph_palette =
	-- amber phosphor 16
	-- sampled from my 'abstract composition in amber phosphor' series
	-- of art photos of an '82 amber CRT monitor
	{
		{0.0820, 0.0317, 0.0368, 1.0000},
		{0.1430, 0.0523, 0.0650, 1.0000},
		{0.1978, 0.0701, 0.0889, 1.0000},
		{0.2349, 0.0844, 0.1064, 1.0000},
		{0.2772, 0.1014, 0.1201, 1.0000},
		{0.3507, 0.1283, 0.1561, 1.0000},
		{0.4160, 0.1480, 0.1933, 1.0000},
		{0.4770, 0.1756, 0.2070, 1.0000},
		{0.6123, 0.2321, 0.2423, 1.0000},
		{0.8416, 0.3398, 0.2630, 1.0000},
		{0.9478, 0.4145, 0.1749, 1.0000},
		{0.9561, 0.5607, 0.1622, 1.0000},
		{0.9682, 0.7291, 0.1975, 1.0000},
		{0.9751, 0.8055, 0.3419, 1.0000},
		{0.9807, 0.8603, 0.4622, 1.0000}}

local graph_manager = {}



---@param x_value table
---@param y_value table
---@param x integer
---@param y integer
---@param w integer
---@param h integer
---@param max_val number
---@param margin_hor integer
---@param margin_ver integer
---@param colors table
function CreateGraphFromData(type, x_value, y_value, x, y, w, h, max_val, margin_hor, margin_ver, colors)
	-- instantiate a graph "object"
	local new_graph = CopyTable(graph_template)
	if type == "line" then -- a line graph is just a dot plot
		type = "dot" --       with a few extra steps
		new_graph.dot_trace = true
	else
		new_graph.type = type
		new_graph.dot_trace = false
	end
	new_graph.x = x
	new_graph.y = y
	new_graph.w = w
	new_graph.h = h
	new_graph.poly_inner_lines = true
	new_graph.tick_size = 5
	new_graph.box_outline = true
	new_graph.bar_outline = false
	new_graph.animate_intro = true
	new_graph.intro_length = 0.8
	new_graph.intro_timer = new_graph.intro_length
	new_graph.intro_timer_mapped = 0
	new_graph.title = ""
	new_graph.title_offset_x = 0
	new_graph.title_offset_y = 0
	new_graph.x_label_top = false
	new_graph.x_axis_label = ""
	new_graph.x_axis_label_o_x = 0
	new_graph.x_axis_label_o_y = 0
	new_graph.y_axis_label = ""
	new_graph.y_axis_label_o_x = 0
	new_graph.y_axis_label_o_y = 0
	new_graph.y_label_offset_x = 0
	new_graph.y_label_offset_y = 0
	new_graph.x_label_offset_x = 0
	new_graph.x_label_offset_y = 0
	new_graph.round = 1
	new_graph.dots_x = {}
	new_graph.radial_offset_multiplier = 1.14
	new_graph.bar_outline_thickness = 4
	new_graph.bar_outline_color = {1,1,1,1}
	new_graph.box_outline_thickness = 4
	new_graph.box_outline_color = {1,1,1,1}
	new_graph.hide_y_labels = false
	new_graph.hide_x_labels = false
	new_graph.color_type = "value"
	new_graph.max_x = 0
	new_graph.main_line_width = 6
	new_graph.main_color = colors[math.floor(#colors/2)]
	if new_graph.type == "dot" then
		new_graph.max_x = TableMax(x_value)
	end
	if max_val == nil then
		new_graph.dynamic_scale = true

	else
		new_graph.dynamic_scale = false
	end
	new_graph.max = max_val or TableMax(y_value)



	if type == "poly" then
		new_graph.canvas_2 = love.graphics.newCanvas(new_graph.h, new_graph.w)
		new_graph.poly_label_pos = {}
	end

	if colors then
		new_graph["colors"] = colors
	else
		new_graph["colors"] = default_graph_palette
	end
	new_graph["colors_per_bar"] = {}
	new_graph["blendMode"] = "alpha"
	new_graph.accent_color = {1,1,1,1}
	new_graph["background"] = {0.0332, 0.0260, 0.0463, 1.0000}
	new_graph["bar_spacing"] = 2
	new_graph.labels = x_value
	new_graph.data = y_value

	if margin_hor == nil then
		new_graph["margin_hor"] = w/10
	else
		new_graph["margin_hor"] = margin_hor
	end
	if margin_ver == nil then
		new_graph["margin_ver"] = h/8
	else
		new_graph["margin_ver"] = margin_ver
	end
	-- handle ticks
	new_graph["ticks"] = 5
	new_graph["tick_val"] = new_graph.max / new_graph.ticks
	new_graph["tick_pos"] = {}
	if new_graph.type == "dot" then -- we only need ticks on x for some kinds of graphs
		new_graph["ticks_x"] = 5
		new_graph["tick_val_x"] = new_graph.max_x / new_graph.ticks_x
		new_graph["tick_pos_x"] = {}
		local i = 0
		while i < new_graph.ticks_x do
			local tick_x = (new_graph.margin_hor+(w-new_graph.margin_hor*2) / new_graph.ticks_x * i) + ((w-new_graph.margin_hor*2) / new_graph.ticks_x) - new_graph.tick_size
			table.insert(new_graph.tick_pos_x, tick_x)
			i = i+1
		end
	end

	-- we always need the y label I think
	local i = 0
	while i < new_graph.ticks do
		local tick_y = new_graph.margin_ver+(h-new_graph.margin_ver*2) / new_graph.ticks * i
		table.insert(new_graph.tick_pos, tick_y)
		i = i+1
	end

	
	new_graph["ratios"] = {}
	new_graph["bar_width"] = (w-new_graph.margin_hor*2)/#x_value
	new_graph["mapped_data"] = {}
	-- map bar height to graph size
	for index, data in ipairs(new_graph.data) do
		-- find highest data point
		local max = new_graph.max
		local ratio = data/max
		table.insert(new_graph.ratios, ratio)
		local color_index_precise = (data*#new_graph.colors-1)/max
		local color_index = math.floor(color_index_precise)+1
		--if color_index == 0 then color_index = 1 end
		-- insert the color for the bar
		table.insert(new_graph.colors_per_bar, new_graph.colors[color_index])
		local bar_h = ratio*(h-new_graph.margin_ver*2-new_graph.margin_ver/5)
		new_graph.mapped_data[index] = bar_h
	end


		-- circle stuff for polygon graph
	if new_graph.type == 'poly' then
		local circ = math.pi*2
		new_graph.point_dist = circ/#new_graph.labels
		new_graph.radius = w/4
		new_graph.points_on_circle = {outer={},inner={}}
		new_graph.offset_poly_x = new_graph.w/2
		new_graph.offset_poly_y = new_graph.h/2
		for i = 1, #new_graph.labels do
			-- outer points (the maximums)
			local y = new_graph.radius*math.sin(new_graph.point_dist*i)
			local x = new_graph.radius*math.cos(new_graph.point_dist*i)
			local p = {x=x+new_graph.offset_poly_x, y=y+new_graph.offset_poly_y}
			table.insert(new_graph.points_on_circle.outer, p)
			-- inner points (the data)
			local y2 = y*new_graph.ratios[i]
			local x2 = x*new_graph.ratios[i]
			local p2 = {x=x2+new_graph.offset_poly_x, y=y2+new_graph.offset_poly_y}
			table.insert(new_graph.points_on_circle.inner, p2)
		end
	end


	new_graph["ticks_rev"] = ReverseInPlace(new_graph.tick_pos)
	-- create a canvas for this new graph
	-- so we can draw it as one whole unit
	new_graph["canvas"] = love.graphics.newCanvas(new_graph.w, new_graph.h)
	new_graph["rot_buffer"] = love.graphics.newCanvas(new_graph.h, new_graph.h)
	-- do a drawing function based on type
	if new_graph.type == "bar" then
		new_graph["draw"] = BarGraphDraw
		new_graph["upd"] = BarGraphUpd
	elseif new_graph.type == "dot" then
		new_graph["draw"] = DotGraphDraw
		new_graph["upd"] = DotGraphUpd
	elseif new_graph.type == "poly" then
		new_graph["draw"] = PolyPlotDraw
		new_graph["upd"] = PolyPlotUpd
	end
	-- add to the handling list
	table.insert(graph_manager, new_graph)
	return graph_manager[#graph_manager]
end

function ClearGraphs()
	graph_manager = {}
end

-----##### DOT PLOT #####-----

---@param self self
---@param dt number
function DotGraphUpd(self, dt)
	-- handle animations
	self.ratios = {}
	self.colors_per_bar = {}
	self.dots_x = {}
	if self.animate_intro == true then
		if self.intro_timer >= 0 then
			self.intro_timer = self.intro_timer - dt
			self.intro_timer_mapped = self.intro_timer*self.h/self.intro_length
		end
	end
	-- update the datas in case they have ch-ch-ch-cha-CHAAANGES
	if self.dynamic_scale == true then
		self.max = TableMax(self.data)
		self.max_x = TableMax(self.labels)
	end
	if self.ticks_x == nil then
		self.ticks_x = 5
	end

	self.tick_val = self.max / self.ticks
	self.tick_val_x = self.max_x / self.ticks_x
	for index, data in ipairs(self.data) do
		--if index > #self.labels then
		--	self.data[index] = nil
		---end
		-- find highest data point
		local max = self.max
		local ratio = data/max
		table.insert(self.ratios, ratio)
		local color_index_precise = (data*#self.colors-1)/max
		local color_index = math.floor(color_index_precise)+1
		if color_index > #self.colors then
			color_index = #self.colors
		end
		-- for the dot plot
		self.plot_width = self.w - self.margin_hor*2
		if self.labels[index] == nil then
			goto skip
		end
		self.dots_x[index] = (self.margin_hor+self.labels[index]*self.plot_width/self.max_x)
		--if color_index == 0 then color_index = 1 end
		-- insert the color for the bar
		::skip::
		table.insert(self.colors_per_bar, self.colors[color_index])
		local bar_h = ratio*(self.h-self.margin_ver*2-self.margin_ver/5)
		self.mapped_data[index] = bar_h
	end
end

---@param self self
function DotGraphDraw(self)
	local prev_canv = love.graphics.getCanvas()
	love.graphics.push()
	-- Draw the graph
	love.graphics.setCanvas(self.canvas)
	love.graphics.setBlendMode(self.blendMode)
	love.graphics.clear(self.background)
	love.graphics.setColor(self.accent_color)
	love.graphics.setLineWidth(self.box_outline_thickness)
	if self.box_outline == true then
		love.graphics.rectangle("line",self.margin_hor,self.margin_ver,self.w-self.margin_hor*2,self.h-self.margin_ver*2)
	end
	-- run through categories
	for i, label in ipairs(self.labels) do
		local bar_color_cycle = self.colors[i % #self.colors+1]
		local bar_color_by_val = self.colors_per_bar[i]
		if bar_color_by_val == nil then
			bar_color_by_val = self.colors_per_bar[1]
		end
		if self.color_type == "cycle" then
			love.graphics.setColor(bar_color_cycle)
		elseif self.color_type == "value" then
			love.graphics.setColor(bar_color_by_val)
		end
		love.graphics.setLineWidth(self.box_outline_thickness)
		local bar_height = (self.mapped_data[i])
		if bar_height == nil then
			bar_height = 0
		end
		if self.animate_intro == true then
			bar_height = bar_height - self.intro_timer_mapped
			if bar_height < 0 then
				bar_height = 0
			end
		end
		local dot_height = 0
		if i > 1 then
			dot_height = (self.mapped_data[i-1])
		else
			dot_height = (self.mapped_data[i])
		end
		if dot_height == nil then
			goto continue
		end
		if self.animate_intro == true then
			dot_height = dot_height - self.intro_timer_mapped
			if dot_height < 0 then
				goto continue
			end
		end
		local disconnect = false
		if self.dots_x[i] == nil or self.mapped_data[i] == nil then
			disconnect = true
			goto continue
		end
		love.graphics.rectangle("fill",self.dots_x[i],self.h-self.margin_ver-bar_height,2,2)
		
		if self.dot_trace == true then
			if i > 1 and disconnect == false then
				love.graphics.line(self.dots_x[i],self.h-self.margin_ver-bar_height,self.dots_x[i-1],self.h-self.margin_ver-dot_height)
			end
		end
		::continue::
	end
	love.graphics.setColor(self.accent_color)
	for i, y_pos in ipairs(self.tick_pos) do
		love.graphics.rectangle("fill", self.margin_hor-self.margin_hor/8, y_pos, self.margin_hor/4, self.tick_size)
	end
	if self.hide_x_labels == false then
		--love.graphics.print(label, self.margin_hor+self.bar_width*(i-1)+self.x_label_offset_x, self.h-self.margin_ver+self.x_label_offset_y)
		for i, x_pos in ipairs(self.tick_pos_x) do
			if self.x_label_top == true then
				local string_build = tostring(RoundToDecimalPlaces(self.tick_val_x*i,self.round))
				love.graphics.print(string_build, x_pos+self.x_label_offset_x, self.margin_ver+self.x_label_offset_y)
				love.graphics.rectangle("fill", x_pos, self.margin_ver-self.margin_ver/8, self.tick_size, self.margin_ver/4)
			else
				local string_build = tostring(RoundToDecimalPlaces(self.tick_val_x*i,self.round))
				love.graphics.print(string_build, x_pos+self.x_label_offset_x, self.h-self.margin_ver+self.x_label_offset_y)
				love.graphics.rectangle("fill", x_pos, self.h-self.margin_ver-self.margin_ver/8, self.tick_size, self.margin_ver/4)
			end
		end
	end
	for i, y_pos in ipairs(self.ticks_rev) do
		if self.hide_y_labels == false then
			local string_build = tostring(RoundToDecimalPlaces(self.tick_val*i,self.round))
			love.graphics.print(string_build, self.margin_hor+self.y_label_offset_x, y_pos+self.y_label_offset_y)
		end
	end
	local x_width = love.graphics.getFont():getWidth(self.x_axis_label)
	love.graphics.print(self.x_axis_label,self.w/2+self.x_axis_label_o_x-x_width/2,self.h/13*12+self.x_axis_label_o_y)
	love.graphics.print(self.y_axis_label, self.y_axis_label_o_x, self.h/2+self.y_axis_label_o_y)
	local t_width = love.graphics.getFont():getWidth(self.title)
	love.graphics.print(self.title, self.w/2+self.title_offset_x-t_width/2, self.margin_ver/3+self.title_offset_y)
	-- Draw the graph to the screen
	love.graphics.setColor(1,1,1,1)
	love.graphics.setCanvas(prev_canv)
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.draw(self.canvas, self.x, self.y)
	love.graphics.setBlendMode("alpha")
	love.graphics.pop()
end


-----##### POLY PLOT #####-----

---@param self self
---@param dt number
function PolyPlotUpd(self, dt)
	self.ratios = {}
	self.colors_per_bar = {}
	if self.animate_intro == true then
		if self.intro_timer >= 0 then
			self.intro_timer = self.intro_timer - dt
			self.intro_timer_mapped = self.intro_timer*self.h/self.intro_length
		end
	end
	-- update the datas in case they have ch-ch-ch-cha-CHAAANGES
	if self.dynamic_scale == true then
		self.max = TableMax(self.data)
	end

	self.tick_val = self.max / self.ticks
	for index, data in ipairs(self.data) do
		if index > #self.labels then
			break
		end
		-- find highest data point
		local max = self.max
		local ratio = data/max
		table.insert(self.ratios, ratio)
		local color_index_precise = (data*#self.colors-1)/max
		local color_index = math.floor(color_index_precise)+1
		if color_index > #self.colors then
			color_index = #self.colors
		end
		table.insert(self.colors_per_bar, self.colors[color_index])
		local bar_h = ratio*(self.h-self.margin_ver*2-self.margin_ver/5)
		self.mapped_data[index] = bar_h
	end

	local circ = math.pi*2
	self.point_dist = circ/#self.labels
	self.radius = self.w/4
	self.points_on_circle = {outer={},inner={}}
	self.poly_label_pos = {}
	for i = 1, #self.labels do
		-- outer points (the maximums)
		local y = self.radius*math.sin(self.point_dist*i)
		local x = self.radius*math.cos(self.point_dist*i)
		local p = {x=x+self.offset_poly_y, y=y+self.offset_poly_x}
		table.insert(self.points_on_circle.outer, p)
		-- label positions (outer just further)
		local yl = self.radius*self.radial_offset_multiplier*math.sin(self.point_dist*i)
		local xl = self.radius*self.radial_offset_multiplier*math.cos(self.point_dist*i)
		local pl = {x=xl+self.offset_poly_y, y=yl+self.offset_poly_x}
		table.insert(self.poly_label_pos, pl)
		-- inner points (the data)
		local y2 = yl*self.ratios[i]
		local x2 = xl*self.ratios[i]
		local p2 = {x=x2+self.offset_poly_y, y=y2+self.offset_poly_x}
		table.insert(self.points_on_circle.inner, p2)
	end
	local poly_table_outer = {}
	local poly_table_inner = {}
	for i, point in ipairs(self.points_on_circle.outer) do
		table.insert(poly_table_outer, point.x)
		table.insert(poly_table_outer, point.y)
		table.insert(poly_table_inner, self.points_on_circle.inner[i].x)
		table.insert(poly_table_inner, self.points_on_circle.inner[i].y)
	end
	self.poly_table_outer = poly_table_outer
	self.poly_table_inner = poly_table_inner
end

---@param self self
function PolyPlotDraw(self)
	local prev_canv = love.graphics.getCanvas()
	love.graphics.push()
	-- Draw the graph
	love.graphics.setCanvas(self.canvas)
	love.graphics.setBlendMode(self.blendMode)
	love.graphics.clear(self.background)
	love.graphics.setColor(self.accent_color)
	love.graphics.setLineWidth(self.box_outline_thickness)
	if self.box_outline == true then
		love.graphics.rectangle("line",self.margin_hor,self.margin_ver,self.w-self.margin_hor*2,self.h-self.margin_ver*2)
	end
	love.graphics.setCanvas(self.canvas_2)
	love.graphics.clear()
	love.graphics.setBlendMode("alpha")
	love.graphics.setColor(self.main_color)
	love.graphics.polygon("fill", self.poly_table_inner)
	for i, point in ipairs(self.points_on_circle.outer) do
		local bar_color_cycle = self.colors[i % #self.colors+1]
		local bar_color_by_val = self.colors_per_bar[i]
		

		if i > 1 then
			love.graphics.setLineWidth(self.box_outline_thickness)
			love.graphics.setColor(self.accent_color)
			love.graphics.line(self.points_on_circle.outer[i-1].x,
							   self.points_on_circle.outer[i-1].y,
							   point.x,
							   point.y)
			if self.poly_inner_lines == true then
				love.graphics.line(point.x,point.y,self.offset_poly_y,self.offset_poly_x)
			end
			if bar_color_by_val == nil then
				bar_color_by_val = self.colors_per_bar[1]
			end
			if self.color_type == "cycle" then
				love.graphics.setColor(bar_color_cycle)
			elseif self.color_type == "value" then
				love.graphics.setColor(bar_color_by_val)
			end

			love.graphics.setLineWidth(self.main_line_width)
			love.graphics.line(self.points_on_circle.inner[i-1].x,
							   self.points_on_circle.inner[i-1].y,
							   self.points_on_circle.inner[i].x,
							   self.points_on_circle.inner[i].y)
			love.graphics.setColor(self.accent_color)
		else
			love.graphics.setLineWidth(self.box_outline_thickness)
			love.graphics.setColor(self.accent_color)
			love.graphics.line(self.points_on_circle.outer[#self.points_on_circle.outer].x,
							   self.points_on_circle.outer[#self.points_on_circle.outer].y,
							   point.x,
							   point.y)
			if self.poly_inner_lines == true then
				love.graphics.line(point.x,point.y,self.offset_poly_y,self.offset_poly_x)
			end
			if bar_color_by_val == nil then
				bar_color_by_val = self.colors_per_bar[1]
			end
			if self.color_type == "cycle" then
				love.graphics.setColor(bar_color_cycle)
			elseif self.color_type == "value" then
				love.graphics.setColor(bar_color_by_val)
			end
			love.graphics.setLineWidth(self.main_line_width)
			love.graphics.line(self.points_on_circle.inner[#self.points_on_circle.inner].x,
							   self.points_on_circle.inner[#self.points_on_circle.inner].y,
							   self.points_on_circle.inner[i].x,
							   self.points_on_circle.inner[i].y)
			love.graphics.setColor(self.accent_color)
		end
		local label_txt = self.labels[i]
		local label_x_pos = self.poly_label_pos[i].x
		local label_y_pos = self.poly_label_pos[i].y
		local label_width = love.graphics.getFont():getWidth(label_txt)
		local label_height = love.graphics.getFont():getHeight(label_txt)
		love.graphics.print(label_txt, label_x_pos, label_y_pos, -math.pi/2, 1, 1, label_width/2, label_height/2)
	end
	love.graphics.setCanvas(self.canvas)
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.setColor(1,1,1,1)
	love.graphics.draw(self.canvas_2,self.w,0,math.pi/2,1,1)
	love.graphics.setBlendMode("alpha")
	love.graphics.setColor(self.accent_color)
	local x_width = love.graphics.getFont():getWidth(self.x_axis_label)
	love.graphics.print(self.x_axis_label,self.w/2+self.x_axis_label_o_x-x_width/2,self.h/13*12+self.x_axis_label_o_y)
	love.graphics.print(self.y_axis_label, self.y_axis_label_o_x, self.h/2+self.y_axis_label_o_y)
	love.graphics.print("Max: "..tostring(RoundToDecimalPlaces(self.max,1)), self.margin_hor, self.h-self.margin_ver)
	local t_width = love.graphics.getFont():getWidth(self.title)
	love.graphics.print(self.title, self.w/2+self.title_offset_x-t_width/2, self.margin_ver/3+self.title_offset_y)
	-- Draw the graph to the screen
	love.graphics.setColor(1,1,1,1)
	love.graphics.setCanvas(prev_canv)
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.draw(self.canvas, self.x, self.y)
	love.graphics.setBlendMode("alpha")

	love.graphics.pop()
end

-----##### BAR GRAPH #####-----

---@param self self
---@param dt number
function BarGraphUpd(self, dt)
	-- handle animations
	self.ratios = {}
	self.colors_per_bar = {}
	if self.animate_intro == true then
		if self.intro_timer >= 0 then
			self.intro_timer = self.intro_timer - dt
			self.intro_timer_mapped = self.intro_timer*self.h/self.intro_length
		end
	end
	-- update the datas in case they have ch-ch-ch-cha-CHAAANGES
	if self.dynamic_scale == true then
		self.max = TableMax(self.data)
	end

	self.tick_val = self.max / self.ticks
	for index, data in ipairs(self.data) do
		if index > #self.labels then
			break
		end

		-- find highest data point
		local max = self.max
		local ratio = data/max
		table.insert(self.ratios, ratio)
		local color_index_precise = (data*#self.colors-1)/max
		local color_index = math.floor(color_index_precise)+1
		if color_index > #self.colors then
			color_index = #self.colors
		end
		table.insert(self.colors_per_bar, self.colors[color_index])
		local bar_h = ratio*(self.h-self.margin_ver*2-self.margin_ver/5)
		self.mapped_data[index] = bar_h
	end
end

---@param self self
function BarGraphDraw(self)
	local prev_canv = love.graphics.getCanvas()
	love.graphics.push()
	-- Draw the graph
	love.graphics.setCanvas(self.canvas)
	love.graphics.setBlendMode(self.blendMode)
	love.graphics.clear(self.background)
	love.graphics.setColor(self.accent_color)
	love.graphics.setLineWidth(self.box_outline_thickness)
	if self.box_outline == true then
		love.graphics.rectangle("line",self.margin_hor,self.margin_ver,self.w-self.margin_hor*2,self.h-self.margin_ver*2)
	end
	-- run through categories
	for i, label in ipairs(self.labels) do
		local bar_color_cycle = self.colors[i % #self.colors+1]
		local bar_color_by_val = self.colors_per_bar[i]
		if bar_color_by_val == nil then
			bar_color_by_val = self.colors_per_bar[1]
		end
		if self.color_type == "cycle" then
			love.graphics.setColor(bar_color_cycle)
		elseif self.color_type == "value" then
			love.graphics.setColor(bar_color_by_val)
		end
		love.graphics.setLineWidth(self.box_outline_thickness)
		local bar_height = (self.mapped_data[i])
		if self.animate_intro == true then
			bar_height = bar_height - self.intro_timer_mapped
			if bar_height < 0 then
				bar_height = 0
			end
		end
		love.graphics.rectangle("fill",self.bar_spacing+self.margin_hor+self.bar_width*(i-1),self.h-self.margin_ver,self.bar_width-self.bar_spacing*2,-bar_height)
		if self.hide_x_labels == false then
			love.graphics.print(label, self.margin_hor+self.bar_width*(i-1)+self.x_label_offset_x, self.h-self.margin_ver+self.x_label_offset_y)
		end
		if self.bar_outline == true then
			love.graphics.setColor(self.box_outline_color)
			love.graphics.rectangle("line",self.bar_spacing+self.margin_hor+self.bar_width*(i-1),self.h-self.margin_ver,self.bar_width-self.bar_spacing*2,-bar_height)
		end
	end
	love.graphics.setColor(self.accent_color)
	for i, y_pos in ipairs(self.tick_pos) do
		love.graphics.rectangle("fill", self.margin_hor-self.margin_hor/8, y_pos, self.margin_hor/4, 5)
	end

	for i, y_pos in ipairs(self.ticks_rev) do
		if self.hide_y_labels == false then
			local string_build = tostring(RoundToDecimalPlaces(self.tick_val*i,self.round))
			love.graphics.print(string_build, self.margin_hor+self.y_label_offset_x, y_pos+self.y_label_offset_y)
		end
	end
	local x_width = love.graphics.getFont():getWidth(self.x_axis_label)
	love.graphics.print(self.x_axis_label,self.w/2+self.x_axis_label_o_x-x_width/2,self.h/13*12+self.x_axis_label_o_y)
	love.graphics.print(self.y_axis_label, self.y_axis_label_o_x, self.h/2+self.y_axis_label_o_y)
	local t_width = love.graphics.getFont():getWidth(self.title)
	love.graphics.print(self.title, self.w/2+self.title_offset_x-t_width/2, self.margin_ver/3+self.title_offset_y)
	-- Draw the graph to the screen
	love.graphics.setColor(1,1,1,1)
	love.graphics.setCanvas(prev_canv)
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.draw(self.canvas, self.x, self.y)
	love.graphics.setBlendMode("alpha")

	love.graphics.pop()
end

function DrawGraphs()
	for i, obj in ipairs(graph_manager) do
		if obj.draw ~= nil then
			obj:draw()
		end
	end
end

function UpdGraphs(dt)
	for i, obj in ipairs(graph_manager) do
		if obj.upd ~= nil then
			obj:upd(dt)
		end
	end
end


-- Utility Functions --

---@param input_table table[int]
function TableMax(input_table)
    local current_max = 0
    for i, integer in ipairs(input_table) do
        if integer > current_max then
            current_max = integer
        end
    end
    return current_max
end

function ReverseInPlace(self)
    local table_length = #self
    for index = 1, math.floor(table_length) * 0.5 do
        self[index], self[table_length - index + 1] = self[table_length - index + 1], self[index]
    end
    return self
end

function CopyTable(i_table)
    local new_table = {} -- establish separate table
    for i, obj in ipairs(i_table) do -- run through list of children
        new_table[i] = obj-- for each child object, add it to the new table
    end
    return new_table
end

---@param x number
---@param places integer
function RoundToDecimalPlaces(x, places)
    local mult_collector = 1
    -- for each decimal place, multiply by 10
    if places > 0 then -- if we have a decimal to round to
    	for i = 1, places do
  	    	mult_collector = mult_collector * 10
    	end
    --elseif places == 0 then -- for rounding to a whole number
    --	mult_collector = 1
    end
    -- multiply that into the input
    local big_buffer = x*mult_collector
    -- round it to an integer
    big_buffer = math.floor(big_buffer+0.5)
    -- step it back down
    local y = big_buffer / mult_collector
    return y
end