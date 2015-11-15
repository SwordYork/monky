require "cairo"

max_iostat = {
    sda = {tps=1, kB_reads=1024, kB_wrtns=1024, kB_read=1024, kB_wrtn=1024, c={c1=1.00,c2=0.5,c3=0.00}, c2={c1=1,c2=0.0,c3=0.0}},
    sdb = {tps=1, kB_reads=1024, kB_wrtns=1024, kB_read=1024, kB_wrtn=1024, c={c1=0.00,c2=0.6,c3=0.45}, c2={c1=0,c2=0.8,c3=0.3}},
    sdc = {tps=1, kB_reads=1024, kB_wrtns=1024, kB_read=1024, kB_wrtn=1024, c={c1=0.40,c2=0.0,c3=0.80}, c2={c1=0,c2=0.3,c3=0.8}}
}

last_iostat = {
    sda = {kB_wrtn=0, kB_read=0},
    sdb = {kB_wrtn=0, kB_read=0},
    sdc = {kB_wrtn=0, kB_read=0}
}

update_times = 0

function conky_main()

    if conky_window == nil then
        return; 
    end

    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height);
    cr = cairo_create(cs);
    
    ---------------------------------------------
    --  disk state support sda, sdb, sdc
    ---------------------------------------------
    
    local total_disk = io.popen("lsblk -d -oNAME");
    local total_disk_str = total_disk:read("*a");
    total_disk:close();
    

    --
    -- draw disk state
    -- 
    update_times = update_times + 1

    if string.find(total_disk_str, "sda") then
        local f = io.popen("iostat -d /dev/sda | tail -2 | head -1"); -- store the output in a "file"
        local tmp = f:read("*a");    -- print out the "file"'s content
        local i;
        i = 0;
        local disk_para = {}
        for word in string.gmatch(tmp, '([^ ]+)') do
            disk_para[i] = word
            i = i + 1
        end
        if (update_times < 3) then
            last_iostat["sda"]["kB_read"] = tonumber(disk_para[4]);
            last_iostat["sda"]["kB_wrtn"] = tonumber(disk_para[5]);
        else
            draw_iostat(90, 70, disk_para, - math.pi / 4)
            last_iostat["sda"]["kB_read"] = tonumber(disk_para[4]);
            last_iostat["sda"]["kB_wrtn"] = tonumber(disk_para[5]);
        end
    end

    if string.find(total_disk_str, "sdb") then
        f = io.popen("iostat -d /dev/sdb | tail -2 | head -1") -- store the output in a "file"
        local tmp = f:read("*a")    -- print out the "file"'s content
        local i
        i = 0
        local disk_para = {}
        for word in string.gmatch(tmp, '([^ ]+)') do
            disk_para[i] = word
            i = i + 1
        end
        if (update_times < 4) then
            last_iostat["sdb"]["kB_read"] = tonumber(disk_para[4]);
            last_iostat["sdb"]["kB_wrtn"] = tonumber(disk_para[5]);
        else
            draw_iostat(210, 90, disk_para, - math.pi / 2)
            last_iostat["sdb"]["kB_read"] = tonumber(disk_para[4]);
            last_iostat["sdb"]["kB_wrtn"] = tonumber(disk_para[5]);
        end
    end

    if string.find(total_disk_str, "sdc") then
        f = io.popen("iostat -d /dev/sdc | tail -2 | head -1") -- store the output in a "file"
        local tmp = f:read("*a")    -- print out the "file"'s content
        local i
        i = 0
        local disk_para = {}
        for word in string.gmatch(tmp, '([^ ]+)') do
            disk_para[i] = word
            i = i + 1
        end
        if (update_times < 3) then
            last_iostat["sdc"]["kB_read"] = tonumber(disk_para[4]);
            last_iostat["sdc"]["kB_wrtn"] = tonumber(disk_para[5]);
        else
            draw_iostat(320, 75, disk_para, 5 * math.pi / 4)
            last_iostat["sdc"]["kB_read"] = tonumber(disk_para[4]);
            last_iostat["sdc"]["kB_wrtn"] = tonumber(disk_para[5]);
        end
    end

    f:close()
    cairo_destroy(cr);
    cairo_surface_destroy(cs);
    cr = nil;
end

function draw_iostat(posx, posy, disk_para, start_arg)
    
    local font_slant = CAIRO_FONT_SLANT_NORMAL;
    local font_face = CAIRO_FONT_WEIGHT_NORMAL;
    cairo_set_font_size(cr, 10);
    cairo_select_font_face(cr, "Mono", font_slant, font_face);


    local disk = disk_para[0];
    local max_sdx_iostat = max_iostat[disk];
    local tps = tonumber(disk_para[1]);
    local kB_reads = (tonumber(disk_para[4]) - last_iostat[disk]["kB_read"]) / 2.0;
    local kB_wrtns = (tonumber(disk_para[5]) - last_iostat[disk]["kB_wrtn"]) / 2.0;
    local kB_read = tonumber(disk_para[4]);
    local kB_wrtn = tonumber(disk_para[5]);

    --[[
    -- updates max io stat
    --]]
    if update_times % 128 == 0 then
        max_sdx_iostat["kB_reads"] = 1024;
        max_sdx_iostat["kB_wrtns"] = 1024;
    end
    while tps >= max_sdx_iostat["tps"] do
        max_sdx_iostat["tps"] = max_sdx_iostat["tps"] * 2;
    end
    while kB_reads >= max_sdx_iostat["kB_reads"] do
        max_sdx_iostat["kB_reads"] = max_sdx_iostat["kB_reads"] * 2;
    end
    while kB_wrtns >= max_sdx_iostat["kB_wrtns"] do
        max_sdx_iostat["kB_wrtns"] = max_sdx_iostat["kB_wrtns"] * 2;
    end
    while kB_read >= max_sdx_iostat["kB_read"] do
        max_sdx_iostat["kB_read"] = max_sdx_iostat["kB_read"] * 2;
    end
    while kB_wrtn >= max_sdx_iostat["kB_wrtn"] do
        max_sdx_iostat["kB_wrtn"] = max_sdx_iostat["kB_wrtn"] * 2;
    end

    local radius = 50

    -- write amount and write speed
    -- write amout arc
    local c = max_sdx_iostat["c"]
    cairo_set_source_rgba(cr, c["c1"], c["c2"], c["c3"], 0.6);
    cairo_move_to (cr, posx, posy); 
    -- right write
    cairo_arc (cr, posx, posy, radius, start_arg, start_arg + 1.0 * kB_wrtn / max_sdx_iostat["kB_wrtn"] * math.pi);
    cairo_close_path(cr);
    cairo_fill(cr);

   
    -- write speed
    cairo_set_source_rgba(cr, c["c1"], c["c2"], c["c3"], 0.9);
    cairo_move_to (cr, posx, posy); 
    cairo_arc (cr, posx, posy, radius * math.sqrt(1.0 * kB_wrtns / max_sdx_iostat["kB_wrtns"]) , start_arg, start_arg + 1.0 * kB_wrtn / max_sdx_iostat["kB_wrtn"] * math.pi);
    cairo_close_path(cr);
    cairo_fill(cr);

     -- put write amout text
    cairo_move_to (cr, posx - 60, posy + 40); 
    if kB_wrtn > 1024 then
        cairo_show_text(cr, "MB_wrtn:" .. math.ceil(kB_wrtn / 1024) .. "m");
    else
        cairo_show_text(cr, "kB_wrtn:" .. kB_wrtn .. "k");
    end

    -- put write speed text
    cairo_move_to (cr, posx - 60, posy + 50); 
    if kB_wrtns > 1024 then
        cairo_show_text(cr, "MB_wrtns:" .. math.ceil(kB_wrtns / 1024) .. "m");
    else
        cairo_show_text(cr, "kB_wrtns:" .. kB_wrtns .. "k");
    end

    -- read amount and read speed
    -- read amout arc
    local c2 = max_sdx_iostat["c2"]
    cairo_set_source_rgba(cr, c2["c1"], c2["c2"], c2["c3"], 0.6);
    cairo_move_to (cr, posx, posy); 
    cairo_arc_negative (cr, posx, posy, radius, start_arg, start_arg - 1.0 * kB_read / max_sdx_iostat["kB_read"] * math.pi);
    cairo_close_path(cr);
    cairo_fill(cr);

    -- read speed
    cairo_set_source_rgba(cr, c2["c1"],  c2["c2"], c2["c3"], 0.9);
    cairo_move_to (cr, posx, posy); 
    cairo_arc_negative(cr, posx, posy, radius * math.sqrt(1.0 * kB_reads / max_sdx_iostat["kB_reads"]) , start_arg, start_arg - 1.0 * kB_read / max_sdx_iostat["kB_read"] * math.pi);
    cairo_close_path(cr);
    cairo_fill(cr);

    -- put read amount text
    cairo_move_to (cr, posx - 60, posy + 60); 
    if kB_read > 1024 then
        cairo_show_text(cr, "MB_read:" .. math.ceil(kB_read / 1024) .. "m");
    else
        cairo_show_text(cr, "kB_read:" .. kB_read .. "k");
    end

    -- put read speed text
    cairo_move_to (cr, posx - 60, posy + 70); 
    if kB_reads > 1024 then
        cairo_show_text(cr, "MB_reads:" .. math.ceil(kB_reads / 1024) .. "m");
    else
        cairo_show_text(cr, "kB_reads:" .. kB_reads .. "k");
    end

    cairo_set_source_rgba(cr, (c["c1"] + c2["c1"]) / 2.0,  (c["c2"]+c2["c2"]) / 2.0, (c["c3"] + c2["c3"])/2, 0.2);
    cairo_move_to (cr, posx, posy); 
    cairo_arc(cr, posx, posy, radius * math.sqrt(1.0 * tps / max_sdx_iostat["tps"]) , 0, 2 * math.pi);
    cairo_close_path(cr);
    cairo_fill(cr);

    -- tps
    cairo_set_source_rgba(cr, (c["c1"] + c2["c1"]) / 2.0,  (c["c2"]+c2["c2"]) / 2.0, (c["c3"] + c2["c3"])/2, 0.8);
    cairo_move_to (cr, posx - 60, posy + 80); 
    cairo_show_text(cr, "tps:" .. tps);

end
