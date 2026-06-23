### LÖVEPlötLib
v0.0.2

<img width="320" height="240" alt="loveplotlib-gif-preview" src="https://github.com/user-attachments/assets/75993dd2-3095-4670-bc72-4d31077cebd3" />

I'm a busy girl and I still have an engine to make, so rather than giving you a crappy filler placeholder doc to slog through, I'm gonna give you a really good example script that makes use of a ton of different features, and then let you figure it out from there. If you've used matplotlib you'll understand the syntax in like two seconds, and if not you'll be fine because it's easy to copy. Probably 95% of the properties you can access are initialized right near the top of the script in `CreateGraphFromData`, if you're looking for something not used in the example.

If you'd like to contribute legit wiki-style documentation, feel free to take a stab at it!

Really the main thing I didn't hit in the example is using ClearGraphs() to get rid of all the graphs in memory, that might come in handy.

Example main.lua file (also included as example.lua in this repo). Draws the memory monitor/framerate counter from the gif at the top of this file!
```
local plt = require "graph-snippet"

-- ###This is just code for my example data to show it in action

-- Shared Variables (pulled in by both FrameRate and Garbage Sampler)
local sample_every = 1/7
local sample_timer = 0
local times_run = 0
local sample_points = 120

-- FrameRate Sampler Variables
local fr_collector = {}
local copy_holder = {}

---@param dt number
function SampleFramerate(dt)

	sample_timer = sample_timer - dt
	if sample_timer < 0 then
		local fr = 1/dt
		times_run = times_run + 1
		sample_timer = sample_every
		table.insert(fr_collector, fr)
		table.remove(fr_collector, 1)

		SampleGarbageCollector()
	end
	return fr_collector
end
-- Garbage Collector Sampler Variables
local gb_collector = {}
for i=1, sample_points do
	table.insert(gb_collector, i, 1)
	table.insert(fr_collector, i, 1)
end
local gb_copy = {}
function SampleGarbageCollector()
	local gb = collectgarbage("count")
	table.insert(gb_collector,gb)
	table.remove(gb_collector,1)
	gb_copy = CopyTable(gb_collector)
	
	return gb_collector
end

-- This is the important stuff to base your implementation off

function love.load()
	local test_cat = {"1/7", "2/7", "3/7", "4/7", "5/7", "6/7", "7/7"}
	local test_cat_3 = {}
	for i=1, 21 do
		table.insert(test_cat_3, i, i/7)
	end
	local phosphor = {
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
	local test_data = fr_collector
	local test_cat_2 = gb_collector
	bar_graph = CreateGraphFromData("bar",test_cat, test_data, 0, 0, 400, 300, 150, nil, nil, phosphor)
	bar_graph.accent_color = {0.9922, 0.5881, 0.1639, 1.0000}
	bar_graph.background = {0.0822, 0.0307, 0.0369, 0.0000}
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

	local dot_plot = CreateGraphFromData("dot",test_cat_2, test_data, 400, 300, 400, 300, 200, nil,nil, phosphor)
	dot_plot.background = {0.0822, 0.0307, 0.0369, 0.0000}
	dot_plot.accent_color = {0.9922, 0.5881, 0.1639, 1.0000}
	dot_plot.bar_outline_thickness = 1
	dot_plot.hide_y_labels = false
	dot_plot.box_outline_thickness = 0
	dot_plot.bar_outline_thickness = 0
	dot_plot.hide_x_labels = false
	dot_plot.color_type = "value"
	dot_plot.dynamic_scale = true
	dot_plot.dot_trace = false
	dot_plot.title = "Framerate vs Garbage Cleaned"
	dot_plot.x_axis_label = "Garbage"
	dot_plot.y_axis_label = "FPS"
	dot_plot.y_label_offset_x = -25
	dot_plot.y_label_offset_y = 2
	dot_plot.x_label_offset_y = 1
	dot_plot.x_label_offset_x =-dot_plot.bar_width/2-6
	dot_plot.y_axis_label_o_y = 4
	dot_plot.title_offset_y = -10


	local line_graph = CreateGraphFromData("dot",test_cat_3, test_cat_2, 0, 300, 400, 300, 200, nil,nil, phosphor)
	line_graph.accent_color = {0.9922, 0.5881, 0.1639, 1.0000}
	line_graph.background = {0.0822, 0.0307, 0.0369, 0.0000}
	line_graph.bar_outline_thickness = 1
	line_graph.hide_y_labels = false
	line_graph.box_outline_thickness = 0
	line_graph.bar_outline_thickness = 0
	line_graph.hide_x_labels = false
	line_graph.color_type = "value"
	line_graph.dynamic_scale = true
	line_graph.dot_trace = true
	line_graph.title = "Garbage Collector"
	line_graph.x_axis_label = "Time (in s)"
	line_graph.y_axis_label = "Garbage\n(in KB)"
	line_graph.y_axis_label_o_y = 100
	line_graph.y_label_offset_x = -25
	line_graph.y_label_offset_y = 2
	line_graph.x_label_offset_y = 1
	line_graph.x_label_offset_x =-line_graph.bar_width/2-6
	line_graph.title_offset_y = 0

	local radar_plot = CreateGraphFromData("poly",test_cat, test_data, 400, 0, 400, 300, 150, nil, nil, phosphor)
	radar_plot.accent_color = {0.9922, 0.5881, 0.1639, 1.0000}
	radar_plot.background = {0.0822, 0.0307, 0.0369, 0.0000}
	radar_plot.bar_outline_thickness = 1
	radar_plot.hide_y_labels = false
	radar_plot.box_outline_thickness = 0
	radar_plot.bar_outline_thickness = 0
	radar_plot.hide_x_labels = false
	radar_plot.color_type = "cycle"
	radar_plot.dynamic_scale = false
	radar_plot.title = "Framerate over time"
	radar_plot.x_axis_label = ""
	radar_plot.y_axis_label = ""
	radar_plot.y_axis_label_o_y = -50
	radar_plot.y_label_offset_x = -25
	radar_plot.y_label_offset_y = 2
	radar_plot.x_label_offset_y = 1
	radar_plot.x_label_offset_x =-radar_plot.bar_width/2-6
	radar_plot.y_axis_label_o_y = 4
	radar_plot.title_offset_y = -10
	radar_plot.box_outline = false
end

function love.update(dt)
	SampleFramerate(dt)
	UpdGraphs(dt)
end

function love.draw()
	love.graphics.clear()
	DrawGraphs()
end
```
