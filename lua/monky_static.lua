require "cairo"

function conky_main()

    if conky_window == nil then
        return; 
    end

    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height);
    cr = cairo_create(cs);
    
    ---------------------------------------------
    --  filesystem 
    ---------------------------------------------
    -- draw filesystem perc
    draw_fs()
    
    cairo_destroy(cr);
    cairo_surface_destroy(cs);
    cr = nil;

end

function draw_fs()
    local rainbow_color = {{1,0,0}, {1,0.50,0}, {1,0.67,0}, {0,0.80,0.30}, {0,0.60,0.45}, {0,0.30,0.80}, {0.40,0,0.80}};

    -- this color and font will be inherit
    local font_slant = CAIRO_FONT_SLANT_NORMAL;
    local font_face = CAIRO_FONT_WEIGHT_NORMAL;
    cairo_set_font_size(cr, 10);
    cairo_select_font_face(cr, "Mono", font_slant, font_face);


    -- start top position
    local topy = 7
    local color_index = 1;
    -- mem_perc
    topy = topy + 10;
    local mem_perc = tonumber(conky_parse("${memperc}"));
    draw_per_filesystem(topy, rainbow_color[color_index], "mem  :", mem_perc);
    
    -- obtain mounted filesystem
    local fs_handle = io.popen("df -l --output=source,target | grep ^/dev | awk '{print $2}'");
    local fs = fs_handle:read("*a");
    fs_handle:close();

    -- iter on filesystem
    for line in fs:gmatch("[^\r\n]+") do
        topy = topy + 10;
        color_index = color_index + 1;
        local cur_fs =  "${fs_used_perc " .. line .. "}";
        local cur_f_perc = string.format("%02d", tonumber(conky_parse(cur_fs)));
        local cur_des = {};
        for word in line:gmatch("([^/]+)") do table.insert(cur_des, word) end
        if line:len() == 1 then
            cur_des = "root :";
        else
            cur_des = cur_des[#cur_des];
            cur_des = cur_des:sub(1,4);
            cur_des = string.format("%-5s", cur_des) .. ":";
            cur_des = cur_des:lower();
        end
        draw_per_filesystem(topy, rainbow_color[(color_index - 1) % #rainbow_color + 1], cur_des, cur_f_perc);
    end

end

function draw_per_filesystem(topy, c, des, perc)
    local c0 = c[1];
    local c1 = c[2];
    local c2 = c[3];
    local max_size = 355;
    -- show text info
    cairo_set_source_rgba(cr, c0, c1, c2, 1);
    cairo_move_to(cr, max_size - 54, topy+7 );
    cairo_show_text(cr, des .. perc .. "%");
    -- background
    cairo_set_source_rgba(cr, c0, c1, c2, 0.2);
    cairo_rectangle(cr, 5, topy, max_size, 10);
    cairo_fill(cr);
    -- foreground
    cairo_set_source_rgba(cr, c0, c1, c2, 1) 
    cairo_rectangle(cr, 5, topy, max_size * perc / 100.0, 10);
    cairo_fill(cr);
end
