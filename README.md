# LOVEPlotLib
MatPlotLib-style graphing in LÖVE 2D
v0.1 (just bar graphs for now!)
Katherina Jesek 2026 - MIT License

<img width="591" height="577" alt="Screenshot 2026-06-19 at 2 58 38 PM" src="https://github.com/user-attachments/assets/7816f44b-dffd-40e5-91ad-3778260027a4" />


##### Why did I make this?
Because I used matplotlib in a research project recently, while also working on a strategy RPG on the train ride, and visualizing stat matchups is cool.

### *Graphing Functions:*
    CreateBarGraphFromData()
- Makes a bar graph
    `ClearGraphs()`
- Clears graphs from memory

### Additional Utility Functions included:

    - TableMax(input_table) -> any (returns the largest value in an indexed table)
    
    - ReverseInPlace(input_table) -> table (flips the current table's order without creating a copy. returns the table anyway for good measure)
    
    - CopyTable(input_table) -> table (makes a shallow copy of an indexed table)
    
    - RoundToDecimalPlaces(x, places) -> number (returns value x, rounded to n places after the decimal point)

    
### **Constructor Parameters**

These are the arguments you pass directly when calling `CreateBarGraphFromData`. Some are optional, others are required.

- **`categories` (table):** A list of strings used for the X-axis labels (e.g., model names).
- **`datapoints` (table):** A list of numerical values to be plotted.
- **`x`, `y` (integer):** The screen coordinates for the top-left corner of the graph.
- **`w`, `h` (integer):** The total width and height of the graph canvas.
- **`max_val` (number, optional):** The maximum value for the Y-axis scale. If not provided, it defaults to the highest value in `datapoints`.
- **`margin_hor` (integer, optional):** Horizontal padding inside the canvas. Defaults to `w/10`.
- **`margin_ver` (integer, optional):** Vertical padding inside the canvas. Defaults to `h/8`.
- **`colors` (table, optional):** A table of RGBA color tables. Defaults to `default_graph_palette`.

---

### **Styling and Visual Properties**

Once the object is created, you can modify these properties to change the look of the graph.

- **`background` (table):** The RGBA color for the graph background. Default is a dark purple `{0.0332, 0.0260, 0.0463, 1.0000}`.
- **`accent_color` (table):** The color used for the axis lines and ticks. Default is white `{1, 1, 1, 1}`.
- **`color_type` (string):**
    - `"value"`: Bars are colored based on their data value relative to the palette (ie. default is green-yellow-red, with high stats being green and low ones being red).
    - `"cycle"`: Bars cycle through the palette colors sequentially. (so each bar is a different color)
- **`bar_spacing` (integer):** The pixel gap between bars. Default is `2`.
- **`bar_outline_thickness` (integer):** Thickness of the border around individual bars. Default is `4`.
- **`bar_outline_color` (table):** RGBA color for the bar borders. Default is white.
- **`box_outline_thickness` (integer):** Thickness of the main graph frame. Default is `4`.
- **`box_outline_color` (table):** RGBA color for the main graph frame. Default is white.
- **`blendMode` (string):** The LÖVE blend mode used when drawing the canvas. Default is `"alpha"`.

---

### **Label and Text Properties**

These properties control the text rendering and positioning.

- **`hide_x_labels` (bool)**: Turns off category labels.
- **`hide_y_labels` (bool)**: Turns off tick labels.
- **`title` (string):** The main title of the graph.
- **`x_axis_label` (string):** Label for the horizontal axis.
- **`y_axis_label` (string):** Label for the vertical axis.
- **`round` (integer):** The number of decimal places to round Y-axis tick values. Default is `3`.

**Offset Parameters (for fine-tuning text placement):**

- **`title_offset_x`, `title_offset_y`**
- **`x_axis_label_o_x`, `x_axis_label_o_y`**
- **`y_axis_label_o_x`, `y_axis_label_o_y`**
- **`x_label_offset_x`, `x_label_offset_y`** (for the individual bar labels)
- **`y_label_offset_x`, `y_label_offset_y`** (for the Y-axis tick values)

---

### **Internal Data and Scaling Properties**

These are calculated automatically during instantiation but are useful for debugging or advanced logic.

- **`max` (number):** The ceiling value used for scaling the bars.
- **`ticks` (integer):** The number of divisions on the Y-axis. Default is `5`.
- **`tick_val` (number):** The numerical increment between each tick.
- **`bar_width` (number):** The calculated width of each bar based on the available horizontal space.
- **`ratios` (table):** A list of values representing the height of each bar as a percentage of the graph height.
- **`mapped_data` (table):** The actual pixel heights of the bars after scaling.
- **`tick_pos` (table):** The Y-coordinates for the tick marks.
- **`ticks_rev` (table):** A reversed version of the tick positions used for rendering labels from bottom to top.
- **`colors_per_bar` (table):** The specific color assigned to each bar if `color_type` is set to `"value"`.
- **`canvas`:** The `love.graphics.newCanvas` object where the graph is pre-rendered.

Example Usage: 
```
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
```

