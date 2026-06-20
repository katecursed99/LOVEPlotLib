local plt = require "graph-snippet"

local sample_every = 1/7
local sample_timer = 0
local sample_number = 7
local fr_collector = {1,1,1,1,1,1,1}
local times_run = 0
local copy_holder = {}

---@param dt number
function SampleFramerate(dt)
	local fr = 1/dt
	sample_timer = sample_timer - dt
	if sample_timer < 0 then
		times_run = times_run + 1
		sample_timer = sample_every
		table.insert(fr_collector, fr)
		copy_holder = CopyTable(fr_collector)
		for i, sample in ipairs(copy_holder) do
			if i > 1 then
				fr_collector[i-1] = sample
			end
		end
	end
	return fr_collector
end


function love.load()
	local test_cat = {"1/7", "2/7", "3/7", "4/7", "5/7", "6/7", "7/7"}
	local test_data = fr_collector
	bar_graph = CreateBarGraphFromData(test_cat, test_data, 0, 0, 320, 240, 150)
	bar_graph.background = {0,0,0,1}
	bar_graph.color_type = "value"
	bar_graph.y_label_offset_x = -30
	bar_graph.y_label_offset_y = 2
	bar_graph.x_label_offset_y = 1
	bar_graph.x_label_offset_x = bar_graph.bar_width/2-6
	bar_graph.y_axis_label_o_y = 4
	bar_graph.x_axis_label = "Time"
	bar_graph.y_axis_label = "Frames"
	bar_graph.y_axis_label_o_y = -bar_graph.w/3
	bar_graph.title = "Framerate Over the Last Second"
	bar_graph.dynamic_scale = false
	bar_graph.round = 0

	local bar_graph_2 = CreateBarGraphFromData(test_cat, test_data, 320, 240, 240, 320, 200, 10,10, {{0.7278, 0.0000, 0.6342, 1.0000},{0.3041, 0.0000, 0.9886, 1.0000},{0.0401, 0.0000, 0.8557, 1.0000},{0.0814, 0.5698, 0.9198, 1.0000}})
	bar_graph_2.accent_color = {0.1244, 0.8719, 0.8493, 1.0000}
	bar_graph_2.background = {0.3030, 0.0488, 0.0693, 1.0000}
	bar_graph_2.bar_outline_thickness = 1
	bar_graph_2.hide_y_labels = true
	bar_graph_2.box_outline_thickness = 0
	bar_graph_2.bar_outline_thickness = 0
	bar_graph_2.hide_x_labels = true
	bar_graph_2.color_type = "cycle"
	bar_graph_2.dynamic_scale = false
end

function love.update(dt)
	SampleFramerate(dt)
	UpdGraphs(dt)
end

function love.draw()
	love.graphics.clear()
	DrawGraphs()
end