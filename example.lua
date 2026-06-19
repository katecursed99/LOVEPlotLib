local plt = require "graph-snippet"

function love.load()
	local test_cat = {"A", "B", "C", "D", "E", "F", "G"}
	local test_data = {1,   3,   7,   2,   13,  22,  11}
	local bar_graph = CreateBarGraphFromData(test_cat, test_data, 0, 0, 320, 240, 30)
	bar_graph.background = {0,0,0,1}
	bar_graph.color_type = "value"
	bar_graph.y_label_offset_x = -30
	bar_graph.y_label_offset_y = 2
	bar_graph.x_label_offset_y = 1
	bar_graph.x_label_offset_x = bar_graph.bar_width/2-6
	bar_graph.y_axis_label_o_y = 4
	bar_graph.x_axis_label = "categories"
	bar_graph.y_axis_label = "numbers"
	bar_graph.y_axis_label_o_y = -bar_graph.w/3
	bar_graph.title = "Bar Graph Snippet"

	local bar_graph_2 = CreateBarGraphFromData(test_cat, test_data, 320, 240, 240, 320, 30, 10,10, {{0.7278, 0.0000, 0.6342, 1.0000},{0.3041, 0.0000, 0.9886, 1.0000},{0.0401, 0.0000, 0.8557, 1.0000},{0.0814, 0.5698, 0.9198, 1.0000}})
	bar_graph_2.accent_color = {0.1244, 0.8719, 0.8493, 1.0000}
	bar_graph_2.background = {0.3030, 0.0488, 0.0693, 1.0000}
	bar_graph_2.bar_outline_thickness = 1
	bar_graph_2.hide_y_labels = true
	bar_graph_2.box_outline_thickness = 0
	bar_graph_2.bar_outline_thickness = 0
	bar_graph_2.hide_x_labels = true
	bar_graph_2.color_type = "cycle"
end

function love.update(dt)

end

function love.draw()
	love.graphics.clear()
	DrawGraphs()
end