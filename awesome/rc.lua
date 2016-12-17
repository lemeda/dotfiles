-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
-- Vicious
local vicious = require("vicious")


-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("/usr/share/awesome/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "terminator"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

---- Transparency
--client.connect_signal("focus", function(c)
--    c.border_color = beautiful.border_focus
--    c.opacity = 1
--end)
--client.connect_signal("unfocus", function(c)
--    c.border_color = beautiful.border_normal
--    c.opacity = 0.4
--end)


-- {{{ Wallpaper
--if beautiful.wallpaper then
--    for s = 1, screen.count() do
--        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
--    end
--end

wp_index = 1
wp_timeout = 900
wp_path = "/home/lena/lemeda/Pictures/Wallpapers/"
wp_files = { "01.png", "02.png", "03.png", "04.png", "05.png", "06.png", "07.jpg", "08.jpg", "09.jpg",
             "10.jpg", "11.jpg", "12.jpg", "13.jpg", "14.jpg", "15.jpg", "16.jpg", "17.jpg", "18.jpg", "19.jpg",
             "20.jpg", "21.jpg",
             "Archlinux.jpg" }

gears.wallpaper.maximized("/home/lena/lemeda/Pictures/Wallpapers/Archlinux.jpg", s, true)

-- timer
wp_timer = timer {timeout = wp_timeout }
wp_timer:connect_signal("timeout", function()
    -- set wallpaper to current index
    for s = 1, screen.count() do
        gears.wallpaper.maximized( wp_path .. wp_files[wp_index], s, true)
    end
    -- stop timer
    wp_timer:stop()

    -- get next wp index
    wp_old = wp_index
    while wp_old == wp_index do
        wp_index = math.random( 1, #wp_files)
    end

    -- restart timer
    wp_timer.timeout = wp_timeout
    wp_timer:start()

end)

-- Start when rc.lua is first run
wp_timer:start()

-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, "♫", "+", "←" }, s, layouts[1])
end
-- }}}
-- Compute the maximum number of digit we need, limited to 13 (default 9)
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(13, math.max(#tags[s], keynumber));
end
-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}
app_folders = { "/usr/share/applications/", "~/local/share/applications/" }

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock()

separator = wibox.widget.textbox('|')

-- Network widget
netwidget = wibox.widget.textbox()
vicious.register(netwidget, vicious.widgets.net,
    '<span color="#CC9393">${eno1 down_kb}</span> <span color="#7F9F7F">${eno1 up_kb}</span>'
    , 3)

-- Battery Widget
batwidget = wibox.widget.textbox()
vicious.register(batwidget, vicious.widgets.bat,
	function (widget, args)
	  r = ' BAT: '
	  if args[3] == 'N/A' then
	    r = r .. '<span color="#00ff00">↯</span>'
	  elseif args[1] == '+' then
	    r = r .. '<span color="#00ff00">+</span>'
	  else
	    r = r .. '<span color="red">-</span>'
	  end

	  r = r .. ' '

	  if (args[2] < 15) then
	    r = r .. '<span color="red">' .. args[2] .. '</span>'
        if (args[1] ~= '+' and notified == 0) then
            naughty.notify({ preset = naughty.config.presets.critical,
            title = "Battery",
            text = "Battery needs to be charged!",
    --        timeout = 5
            })
            notified = 1
        end
	  elseif args[2] < 25 then
        notified = 0
	    r = r .. '<span color="orange">' .. args[2] .. '</span>'
	  elseif  args[2] < 35 then
	    r = r .. '<span color="yellow">' .. args[2] .. '</span>'
	  else
	    r = r .. '<span color="#00ff00">' .. args[2] .. '</span>'
	  end

	  r = r .. '% '
	  if args[3] ~= 'N/A' then
	    r = r .. '(' .. args[3] .. ') '
	  end

	  -- notification if need to load
	  if args[1] == '-' and args[2] < 15 then
	    naughty.notify({
	      preset = naughty.config.presets.critical,
	      title = 'Battery',
	      text = 'Battery needs to be charged !',
	      timeout = 5 })
	    end

	    return r
	  end, 5, 'BAT0')


-- Volume Widget
volwidget = wibox.widget.textbox()
vicious.register(volwidget, vicious.widgets.volume,
	function (widget, args)
	  r = 'VOL: '

	  if args[2] == '♫' then
	    r =r .. '<span color="#00ff00">' .. args[1] .. '</span>% '
	  else
	    r =r .. '<span color = "red">' .. args[1] .. '</span> (M) '
	  end
	  return r
	end, 10, 'Master')

-- Memory Widget
memwidget = wibox.widget.textbox()
vicious.register(memwidget, vicious.widgets.mem,
    function (widget, args)
        color = '#00ff00'
        if args[1] >= 86 then
            color = "red"
        elseif args[1] >= 71 then
            color = "orange"
        elseif args[1] >= 51 then
            color = "yellow"
        end

        r = 'RAM: '

        if args[1] < 10 then
            r = r .. ' '
        end

        return r .. '<span color="' .. color .. '">' .. args[1] .. '</span>% (<span color="' .. color .. '">' .. args[2] .. '</span>MB/'     .. args[3] .. 'MB) '
    end, 2)

-- CPU Temperature Widget
cputempwidget = wibox.widget.textbox()
vicious.register(cputempwidget, vicious.widgets.thermal,
    function (widget, args)
        r = 'T: '
        if args[1] < 46 then
            r = r .. '<span color="turquoise">' .. args[1] .. '</span    >'
        elseif args[1] < 61 then
            r = r .. '<span color="yellow">' .. args[1] .. '</span>'
        elseif args[1] < 76 then
            r = r .. '<span color="orange">' .. args[1] .. '</span>'
        else
            r = r .. '<span color="red">' .. args[1] .. '</span>'
        end

        r = r .. '°C '
        return r
    end, 2, 'thermal_zone0')


-- CPU Information Widget
cpuinfowidget = wibox.widget.textbox()
vicious.register(cpuinfowidget, vicious.widgets.cpu,
    function (widget, args)
        r = ' CPU: '

        if args[1] < 31 then
            if args[1] < 10 then
                r = r .. ' '
            end
            r = r .. '<span color="#00ff00">' .. args[1] .. '</span>'
        elseif args[1] < 51 then
            r = r .. '<span color="yellow">' .. args[1] .. '</span>'
        elseif args[1] < 70 then
            r = r .. '<span color="orange">' .. args[1] .. '</span>'
        else
            r = r ..'<span color="red">' .. args[1] .. '</span>'
        end

        r = r .. '% '
        return r
    end, 2)

-- LAN Widget
lanwidget = wibox.widget.textbox()
vicious.register(lanwidget, vicious.widgets.net,
    function (widget, args)
        r = ' LAN: '

        if args['{eno1 carrier}'] == 1 then
            r = r .. '<span color="#00ff00">ON</span> '
        else
            r = r .. '<span color="red">OFF</span> '
        end

        return r
    end, 1)

-- WIFI Widget
-- needs wireless_tools to work properly
-- (if not installed, use fallback version below)
wifiwidget = wibox.widget.textbox()
vicious.register(wifiwidget, vicious.widgets.wifi,
    function (widget, args)
        r = 'WLAN: '

        if args['{ssid}'] == 'N/A' then
            r = r .. '<span color="red">OFF</span> '
        else
--              r = r .. '<span color="#00ff00">ON</span> '
            r = r .. '<span color="#00ff00">' .. args['{ssid}'] .. '</span> '
        end

        return r
    end, 10, 'wlp8s0')


--vicious.register(wifiwidget, vicious.widgets.net,
--    function(widget, args)
--        r = ' WLAN: '
--        if args["{wlp8s0 carrier}"] == 1 then
--            r = r .. '<span color="#00ff00">ON</span> '
--        else
--            r = r .. '<span color="red">OFF</span> '
--        end
--        return r
--        end,1)

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({
                                                      theme = { width = 250 }
                                                  })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, fg = beautiful.wibox_fg })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(wifiwidget)
    right_layout:add(separator)
    right_layout:add(lanwidget)
    right_layout:add(separator)
    --right_layout:add(netwidget)
    --right_layout:add(separator)
    right_layout:add(cpuinfowidget)
    right_layout:add(separator)
    right_layout:add(cputempwidget)
    right_layout:add(separator)
    right_layout:add(memwidget)
    right_layout:add(separator)
    right_layout:add(volwidget)
    right_layout:add(separator)
    right_layout:add(batwidget)
    right_layout:add(separator)


    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(mytextclock)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),

    -- Manually change Wallpaper
    awful.key({ modkey, "Shift"   }, "s",
    function()
        wp_timer:emit_signal("timeout")
    end),

    -- Screenshots
    awful.key({ }, "Print",
    function()
        awful.util.spawn_with_shell("scrot -e 'mv $f /home/lena/lemeda/screenshots/'")
    end),

    -- Lock screen without suspending system
    awful.key({ modkey }, "l",
        function()
            awful.util.spawn_with_shell("i3lock -u -i lemeda/Pictures/Wallpapers/Archlinux.png")
        end),

    -- Lock screen and suspend system - Archlinux lockscreen
    awful.key({ modkey, "Shift" }, "l",
        function()
            awful.util.spawn_with_shell("systemctl suspend & i3lock -u -i lemeda/Pictures/Wallpapers/Archlinux.png")
        end),




    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end),

    -- Function keys
        -- Volume Control
    awful.key({ modkey }, "F7",
        function()
            awful.util.spawn("amixer -q sset Master 1%-")
            vicious.force({ volwidget, })
        end),
    awful.key({ modkey }, "F8",
        function()
            awful.util.spawn("amixer -q sset Master 1%+")
            vicious.force({ volwidget, })
        end),
    awful.key({ modkey }, "F6",
        function()
            awful.util.spawn("amixer -q set Master toggle")
            vicious.force({ volwidget, })
        end),

        -- Light
    awful.key({ modkey  }, "F2",
    function() awful.util.spawn("xbacklight -dec 5") end),
    awful.key({ modkey  }, "F3",
    function() awful.util.spawn("xbacklight -inc 5") end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
ntagskey = 13
for i = 1, ntagskey do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
    { rule = { class = "utox" },
      properties = { tag = tags[1][8] } },
    { rule = { class = "qTox" },
      properties = { tag = tags[1][8] } },
    { rule = { class = "Pidgin" },
      properties = { tag = tags[1][9] } },
    { rule = { class = "Thunderbird" },
      properties = { tag = tags[1][10] } },
    { rule = { class = "chromium" },
      properties = { tag = tags[1][11] } },
    { rule = { class = "discord" },
      properties = { tag = tags[1][8] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}