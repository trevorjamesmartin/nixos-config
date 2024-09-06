-- Conky, a system monitor https://github.com/brndnmtthws/conky
--
-- This configuration file is Lua code. You can write code in here, and it will
-- execute when Conky loads. You can use it to generate your own advanced
-- configurations.
--
-- Try this (remove the `--`):
--
--   print("Loading Conky config")
--
-- For more on Lua, see:
-- https://www.lua.org/pil/contents.html

conky.config = {
    out_to_x = true,
    out_to_wayland = true,
    alignment = 'top_right',
    background = true,
    border_width = 1,
    border_margins = 5,
    cpu_avg_samples = 2,
    default_color = 'white',
    default_outline_color = 'white',
    default_shade_color = 'white',
    double_buffer = true,
    draw_borders = false,
    draw_graph_borders = true,
    draw_outline = false,
    draw_shades = false,
    extra_newline = false,
    font = 'DejaVu Sans Mono:size=14',
    gap_x = 25,
    gap_y = 30,
    minimum_height = 5,
    minimum_width = 5,
    net_avg_samples = 2,
    no_buffers = true,
    out_to_console = false,
    out_to_ncurses = false,
    out_to_stderr = false,
    own_window = true,
    -- own_window_class = 'Conky',
    own_window_type = 'normal',
    own_window_transparent = false,
    own_window_hints = 'undecorated,below,skip_taskbar,skip_pager',
    own_window_argb_visual = true,
    
    own_window_argb_value = 120,
    --own_window_argb_value = 0,
    show_graph_range = false,
    show_graph_scale = false,
    stippled_borders = 10,
    update_interval = 1.0,
    uppercase = false,
    use_spacer = 'none',
    use_xft = true,
    border_inner_margin = 15,
    border_outer_margin = 6,
    lua_load = '~/.config/conky/conky-draw_bg.lua',
    lua_draw_hook_pre = 'draw_bg',
}

conky.text = [[
${voffset 8}$color2${font Iosevka Nerd Font:size=18}${time %A}$font\
${voffset 0}$alignr$color${font Iosevka Nerd Font:size=30}${time %e}$font
$color${voffset -30}$color${font Iosevka Nerd Font:size=18}${time %b}$font\
${voffset -1} $color${font Iosevka Nerd Font:size=18}${time %Y}$font$color2 $hr
${voffset 0}$alignr${color2}${font Iosevka Nerd Font:size=16}${color}$alignr${execi 86400 env | grep '^DESKTOP_SESSION' | cut -d'=' -f2-} / ${alignr}$nodename${font}

${color grey}Info:${color2} NixOS $sysname $kernel $machine
$hr
${color grey}Uptime:$color $uptime
${color grey}Frequency (in MHz):$color $freq
${color grey}Frequency (in GHz):$color $freq_g
${color grey}RAM Usage:$color $mem/$memmax - $memperc% ${membar 4}
${color grey}Swap Usage:$color $swap/$swapmax - $swapperc% ${swapbar 4}
${color grey}CPU Usage:$color $cpu% ${cpubar 4}
${color grey}Processes:$color $processes  ${color grey}Running:$color $running_processes
$hr
${color grey}File systems:
 / $color${fs_used /}/${fs_size /} ${fs_bar 6 /}
#${color grey}Networking:
#Up:$color ${upspeed} ${color grey} - Down:$color ${downspeed}
$hr
${color grey}Name              PID     CPU%   MEM%
${color lightgrey} ${top name 1} ${top pid 1} ${top cpu 1} ${top mem 1}
${color lightgrey} ${top name 2} ${top pid 2} ${top cpu 2} ${top mem 2}
${color lightgrey} ${top name 3} ${top pid 3} ${top cpu 3} ${top mem 3}
${color lightgrey} ${top name 4} ${top pid 4} ${top cpu 4} ${top mem 4}
#${color lightgrey} ${top name 5} ${top pid 5} ${top cpu 5} ${top mem 5}
#${color lightgrey} ${top name 6} ${top pid 6} ${top cpu 6} ${top mem 6}
#${color lightgrey} ${top name 7} ${top pid 7} ${top cpu 7} ${top mem 7}
#${color lightgrey} ${top name 8} ${top pid 8} ${top cpu 8} ${top mem 8}
$hr
]]
