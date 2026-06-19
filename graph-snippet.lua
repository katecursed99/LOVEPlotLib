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
	{{0.7688, 0.1137, 0.0646, 1.0000},
	{0.9420, 0.7634, 0.0755, 1.0000},
	{0.1113, 0.6198, 0.0814, 1.0000}}

local graph_manager = {}



---@param categories table
---@param datapoints table
---@param x integer
---@param y integer
---@param w integer
---@param h integer
---@param max_val number
---@param margin_hor integer
---@param margin_ver integer
---@param colors table
function CreateBarGraphFromData(categories, datapoints, x, y, w, h, max_val, margin_hor, margin_ver, colors)
	-- instantiate a graph "object"
	local new_graph = CopyTable(graph_template)
	new_graph.x = x
	new_graph.y = y
	new_graph.w = w
	new_graph.h = h
	new_graph.title = ""
	new_graph.title_offset_x = 0
	new_graph.title_offset_y = 0
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
	new_graph.round = 3
	new_graph.bar_outline_thickness = 4
	new_graph.bar_outline_color = {1,1,1,1}
	new_graph.box_outline_thickness = 4
	new_graph.box_outline_color = {1,1,1,1}
	new_graph.hide_y_labels = false
	new_graph.hide_x_labels = false
	new_graph.color_type = "value"
	new_graph.max = max_val or TableMax(datapoints)
	new_graph["ticks"] = 5
	new_graph["tick_val"] = new_graph.max / new_graph.ticks

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
	new_graph.labels = categories
	new_graph.data = datapoints

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
	new_graph["tick_pos"] = {}
	local i = 0
	while i < new_graph.ticks do
		local tick_y = new_graph.margin_ver+(h-new_graph.margin_ver*2) / new_graph.ticks * i
		table.insert(new_graph.tick_pos, tick_y)
		i = i+1

	end
	new_graph["ratios"] = {}
	new_graph["bar_width"] = (w-new_graph.margin_hor*2)/#categories
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
		local bar_h = ratio*(h-new_graph.margin_ver*2)
		new_graph.mapped_data[index] = bar_h
	end
	new_graph["ticks_rev"] = ReverseInPlace(new_graph.tick_pos)
	-- create a canvas for this new graph
	-- so we can draw it as one whole unit
	new_graph["canvas"] = love.graphics.newCanvas(new_graph.w, new_graph.h)
	new_graph["rot_buffer"] = love.graphics.newCanvas(new_graph.h, new_graph.h)
	-- do a drawing function based on type
	new_graph["draw"] = BarGraphDraw
	-- add to the handling list
	table.insert(graph_manager, new_graph)
	return graph_manager[#graph_manager]
end

function ClearGraphs()
	graph_manager = {}
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
	love.graphics.rectangle("line",self.margin_hor,self.margin_ver,self.w-self.margin_hor*2,self.h-self.margin_ver*2)
	-- run through categories
	for i, label in ipairs(self.labels) do
		local bar_color_cycle = self.colors[i % #self.colors+1]
		local bar_color_by_val = self.colors_per_bar[i]
		if self.color_type == "cycle" then
			love.graphics.setColor(bar_color_cycle)
		elseif self.color_type == "value" then
			love.graphics.setColor(bar_color_by_val)
		end
		love.graphics.setLineWidth(self.box_outline_thickness)
		love.graphics.rectangle("fill",self.bar_spacing+self.margin_hor+self.bar_width*(i-1),self.h-self.margin_ver,self.bar_width-self.bar_spacing*2,-(self.mapped_data[i]))
		if self.hide_x_labels == false then
			love.graphics.print(label, self.margin_hor+self.bar_width*(i-1)+self.x_label_offset_x, self.h-self.margin_ver+self.x_label_offset_y)
		end
		love.graphics.setColor(self.box_outline_color)
		love.graphics.rectangle("line",self.bar_spacing+self.margin_hor+self.bar_width*(i-1),self.h-self.margin_ver,self.bar_width-self.bar_spacing*2,-(self.mapped_data[i]))
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

function UpdGraphs()
	for i, obj in ipairs(graph_manager) do
		if obj.upd ~= nil then
			obj:upd()
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
    local mult_collector = 10
    -- for each decimal place, multiply by 10
    for i = 1, places do
        mult_collector = mult_collector * 10
    end
    -- multiply that into the input
    local big_buffer = x*mult_collector
    -- round it to an integer
    big_buffer = math.floor(big_buffer+0.5)
    -- step it back down
    local y = big_buffer / mult_collector
    return y
end