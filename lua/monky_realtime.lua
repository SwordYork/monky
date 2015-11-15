require "cairo"

function conky_main()

    if conky_window == nil then
        return; 
    end

    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height);
    cr = cairo_create(cs);

    
    ---------------------------------------------
    -- cpu0 average load ${cpu cpu0} or ${cpu}
    -- cpu1-4 each core ${cpu cpu1}
    ---------------------------------------------
    -- draw cpu arc
    draw_cpu();

    ---------------------------------------------
    -- mem and swap perc
    ---------------------------------------------
    draw_mem();

    ---------------------------------------------
    -- cpu freq 4 core
    ---------------------------------------------
    draw_freq();

    ---------------------------------------------
    -- time
    ---------------------------------------------
    draw_clock();
    
    cairo_destroy(cr);
    cairo_surface_destroy(cs);
    cr = nil;

end

function draw_clock()
    local cur_hour = tonumber(conky_parse('${time %k}'));
    local cur_minute = tonumber(conky_parse('${time %M}'));
    local cur_second = tonumber(conky_parse('${time %S}'));


    -- time circle center
    local circle_x = 100;
    local circle_y = 100;

    -- hour
    cairo_set_line_width(cr, 6.0);
    cairo_set_source_rgba(cr, 0.0, 0.612, 0.775, 0.55);
    cairo_arc(cr, circle_x, circle_y, 65, -math.pi / 2, -math.pi / 2 + (cur_hour + cur_minute / 60.0) / 24 * math.pi * 2);
    cairo_stroke(cr);
    
    -- minute
    cairo_set_line_width(cr, 5.0);
    cairo_set_source_rgba(cr, 0, 0.91, 0.412, 0.6);
    cairo_arc(cr, circle_x, circle_y, 70, -math.pi / 2, -math.pi / 2 + (cur_minute + cur_second / 60.0) / 60 * math.pi * 2);
    cairo_stroke(cr);

    -- second
    cairo_set_line_width (cr, 2.0);
    cairo_set_source_rgba(cr, 0.682, 0.896, 0.839,  0.7);
    cairo_arc(cr, circle_x, circle_y, 72, -math.pi / 2, -math.pi / 2 + cur_second / 60 * math.pi * 2);
    cairo_stroke(cr);

end

function draw_freq()
    local freq1 = tonumber(conky_parse('${freq 1}'));
    local freq2 = tonumber(conky_parse('${freq 2}'));
    local freq3 = tonumber(conky_parse('${freq 3}'));
    local freq4 = tonumber(conky_parse('${freq 4}'));
    local max_freq = 3600.0;
    
    cairo_set_source_rgba(cr,  0.7 * freq1 / max_freq, 0.6 * (1 - freq1 / max_freq), 0.3 * (1 - freq1 / max_freq), 0.8);
    cairo_rectangle (cr, 10, 217, freq1 / max_freq * 256 , 5);
    cairo_fill (cr);

    cairo_set_source_rgba(cr,  0.7 * freq2 / max_freq, 0.6 * (1 - freq2 / max_freq), 0.3 * (1 - freq2 / max_freq), 0.8);
    cairo_rectangle (cr, 10, 225, freq2 / max_freq * 256, 5);
    cairo_fill (cr);

    cairo_set_source_rgba(cr,  0.7 * freq3 / max_freq, 0.6 * (1 - freq3 / max_freq), 0.3 * (1 - freq3 / max_freq), 0.8);
    cairo_rectangle (cr, 10, 233, freq3 / max_freq * 256, 5);
    cairo_fill (cr);


    cairo_set_source_rgba(cr,  0.7 * freq4 / max_freq, 0.6 * (1 - freq4 / max_freq), 0.3 * (1 - freq4 / max_freq), 0.8);
    cairo_rectangle (cr, 10, 241, freq4 / max_freq * 256, 5);
    cairo_fill (cr);

end

function draw_mem()
    local mem_arc_x = 100;
    local mem_arc_y = 100;
    local mem_arc_radius = 90;
    local mem_arc_start = 106.0 / 180 * math.pi;
    local mem_arc_end = -22.0 / 180 * math.pi;

    local mem_perc = tonumber(conky_parse("${memperc}"));
    local mem_perc_s = mem_perc / 100.0;
    local mem_arc_end_usage = mem_arc_start - (mem_arc_start - mem_arc_end) * mem_perc / 100;
    
    cairo_set_source_rgba(cr,  0.52 * mem_perc_s, 0.55 * (1 - mem_perc_s), 0.20 * (1 - mem_perc_s), 0.3);
    cairo_set_line_width (cr, 8.0);
    cairo_arc_negative (cr, mem_arc_x, mem_arc_y, mem_arc_radius, mem_arc_start, mem_arc_end);
    cairo_stroke (cr);
    cairo_set_source_rgba(cr,  0.52 * mem_perc_s, 0.55 * (1 - mem_perc_s ), 0.20 * (1 - mem_perc_s), 1);
    cairo_set_line_width (cr, 8.0);
    cairo_arc_negative (cr, mem_arc_x, mem_arc_y, mem_arc_radius, mem_arc_start, mem_arc_end_usage);
    cairo_stroke (cr);


    local swap_arc_x = 100;
    local swap_arc_y = 100;
    local swap_arc_radius = 80;
    local swap_arc_start = 107.0 / 180 * math.pi;
    local swap_arc_end = -36.0 / 180 * math.pi;
    local swap_perc = tonumber(conky_parse("${swapperc}"))
    local swap_arc_end_usage = swap_arc_start - (swap_arc_start - swap_arc_end) * swap_perc / 100
    cairo_set_source_rgba(cr, 0.52294, 0.8239, 0.72686, 0.3);
    cairo_set_line_width (cr, 8.0);
    cairo_arc_negative (cr, swap_arc_x, swap_arc_y, swap_arc_radius, swap_arc_start, swap_arc_end);
    cairo_stroke (cr);
    cairo_set_source_rgba(cr, 0.52294, 0.8239, 0.72686, 1);
    cairo_set_line_width (cr, 8.0);
    cairo_arc_negative (cr, swap_arc_x, swap_arc_y, swap_arc_radius, swap_arc_start, swap_arc_end_usage);
    cairo_stroke (cr);

end

function draw_cpu_arc(radius, c0, c1, c2, alpha, start_arg, end_arg)
    -- cpu usage circle
    local cpu_circle_x = 100;
    local cpu_circle_y = 100;

    cairo_set_source_rgba(cr, c0, c1, c2,alpha);
    cairo_move_to (cr, cpu_circle_x, cpu_circle_y); 
    cairo_arc (cr, cpu_circle_x, cpu_circle_y, radius, start_arg, end_arg);
    cairo_close_path(cr);
    cairo_fill(cr);
end


function draw_cpu()
    local cpu_circle_x = 100;
    local cpu_circle_y = 100;
    local cpu_circle_r = 70.0;

    local cpu_perc = conky_parse("${cpu}");
    local cpu_perc1 = conky_parse("${cpu cpu1}");
    local cpu_perc2 = conky_parse("${cpu cpu2}");
    local cpu_perc3 = conky_parse("${cpu cpu3}");
    local cpu_perc4 = conky_parse("${cpu cpu4}");

    local cpu_circle_arg1 = 315.0 / 180 * math.pi;
    local cpu_circle_arg2 = 45.0 / 180 * math.pi;
    local cpu_circle_arg3 = 135.0 / 180 * math.pi;
    local cpu_circle_arg4 = 225.0 / 180 * math.pi;



    local alpha1 = 0.3
    local alpha2 = 0.8
    local alpha = 0.9
    draw_cpu_arc(cpu_circle_r + 1, 0.55294, 0.8039, 0.75686, alpha1, cpu_circle_arg1, cpu_circle_arg2);
    draw_cpu_arc(cpu_circle_r + 1, 0.82745, 0.89019, 0.59215, alpha1 + 0.1, cpu_circle_arg2, cpu_circle_arg3);
    draw_cpu_arc(cpu_circle_r + 1, 1.0, 0.9607, 0.7647, alpha1 + 0.1, cpu_circle_arg3, cpu_circle_arg4);
    draw_cpu_arc(cpu_circle_r + 1, 0.3, 0.6, 0, alpha1, cpu_circle_arg4, cpu_circle_arg1);
    
    --[[
    local font_size = 18;

    cairo_set_font_size(cr, font_size);
    cairo_set_source_rgba(cr,  0.32, 0.62, 0.10, alpha);
    cairo_move_to(cr,cpu_circle_x + 30, cpu_circle_y + 5);
    cairo_show_text(cr,cpu_perc1 .. "%");

    cairo_set_source_rgba(cr, 0.52294, 0.8239, 0.72686, alpha);
    cairo_move_to(cr,cpu_circle_x - 10, cpu_circle_y + 40);
    cairo_show_text(cr,cpu_perc2 .. "%");

    cairo_set_source_rgba(cr, 0.84745, 0.91019, 0.61215, alpha);
    cairo_move_to(cr,cpu_circle_x - 50, cpu_circle_y + 5 );
    cairo_show_text(cr,cpu_perc3 .. "%");

    cairo_set_source_rgba(cr, 1.0, 0.9807, 0.7847, alpha);
    cairo_move_to(cr,cpu_circle_x - 10, cpu_circle_y - 35 );
    cairo_show_text(cr,cpu_perc4 .. "%");
    --]]

    cairo_set_source_rgba(cr, 0.9215, 0.4313, 0.2666, 0.4);
    cairo_arc (cr, cpu_circle_x, cpu_circle_y, cpu_circle_r * math.sqrt(tonumber(cpu_perc) / 100), 0, 2 * math.pi);
    cairo_fill (cr);

    draw_cpu_arc(cpu_circle_r * math.sqrt(tonumber(cpu_perc1)/100), 0.52294, 0.8239, 0.72686, alpha2, cpu_circle_arg1, cpu_circle_arg2);
    draw_cpu_arc(cpu_circle_r * math.sqrt(tonumber(cpu_perc2)/100), 0.84745, 0.91019, 0.61215, alpha2, cpu_circle_arg2, cpu_circle_arg3);
    draw_cpu_arc(cpu_circle_r * math.sqrt(tonumber(cpu_perc3)/100), 1.0, 0.9807, 0.7847, alpha2, cpu_circle_arg3, cpu_circle_arg4);
    draw_cpu_arc(cpu_circle_r * math.sqrt(tonumber(cpu_perc4)/100), 0.32, 0.62, 0.1, alpha2, cpu_circle_arg4, cpu_circle_arg1);

end
