/*
        Debug Tools v0.7
      
      
      
    Quick usage reference:
        
        update = function()
          debug.update()  // call this before everything
          
          debug.print("foo", foo)
        end
        
        draw = function()
          debug.print("bar", bar)
          
          debug.bm("map_drawing", function()
            draw_map()
          end)
          
          debug.draw()  // call this after everything
        end
*/



// This array makes it easier to try out different fonts while the game 
// is running. 
__fonts = [
  "AESystematic"        /* 0 */,  "Alkhemikal"    /* 1 */,  "AlphaBeta"        /* 2 */,
  "Arpegius"            /* 3 */,  "Awesome"       /* 4 */,  "BitCell"          /* 5 */,
  "Blocktopia"          /* 6 */,  "Comicoro"      /* 7 */,  "Commodore64"      /* 8 */,
  "DigitalDisco"        /* 9 */,  "Edunline"      /* 10 */, "EnchantedSword"   /* 11 */,
  "EnterCommand"        /* 12 */, "Euxoi"         /* 13 */, "FixedBold"        /* 14 */,
  "GenericMobileSystem" /* 15 */, "GrapeSoda"     /* 16 */, "JupiterCrash"     /* 17 */,
  "Kapel"               /* 18 */, "KiwiSoda"      /* 19 */, "Litebulb8bit"     /* 20 */,
  "LycheeSoda"          /* 21 */, "MisterPixel"   /* 22 */, "ModernDos"        /* 23 */,
  "NokiaCellPhone"      /* 24 */, "PearSoda"      /* 25 */, "PixAntiqua"       /* 26 */,
  "PixChicago"          /* 27 */, "PixelArial"    /* 28 */, "PixelOperator"    /* 29 */,
  "Pixellari"           /* 30 */, "Pixolde"       /* 31 */, "PlanetaryContact" /* 32 */,
  "PressStart2P"        /* 33 */, "RainyHearts"   /* 34 */, "RetroGaming"      /* 35 */,
  "Revolute"            /* 36 */, "Romulus"       /* 37 */, "Scriptorium"      /* 38 */,
  "Squarewave"          /* 39 */, "Thixel"        /* 40 */, "Unbalanced"       /* 41 */,
  "UpheavalPro"         /* 42 */, "VeniceClassic" /* 43 */, "ZXSpectrum"       /* 44 */,
  "Zepto"               /* 45 */,
  
  /* 
      monospaced fonts 
        AESystematic      Commodore64       ModernDos       
        PressStart2P      ZXSpectrum
    
      monospaced-ish
        Edunline         JupiterCrash
  */
  
]


debug = object
  active = false
  active_drawing = false
  
  // -------------------------------------
  //   user settings
  // -------------------------------------
  key1 = '\\'
  key2 = '~'
  
  text_font = __fonts[12] // [7]
  
  text_font_default    = "BitCell"
  text_font_size       = 12
  text_line_spacing    = 0
  text_outlined        = true
  text_outline_width   = 3
  text_background      = true
  text_col_separation  = 10
  
  panel_margin_left    = 4
  panel_margin_right   = 4
  panel_margin_top     = 0
  panel_margin_bottom  = 2
  panel_use_colors     = true
  
  panel_key_color      = "rgb(223,223,223)"
  panel_string_color   = "rgb(255,255,198)"
  panel_number_color   = "rgb(255,198,255)"
  panel_object_color   = "rgb(198,217,255)"
  panel_back_color     = "rgba(43,33,33,0.66)"
  panel_frame_color    = "rgba(105,93,93,0.66)"
  text_outline_color   = "rgb(0,0,0)"
  shape_outline_color  = "rgb(0,0,0)"
  
  shape_font           = "BitCell"
  shape_dash           = [4, 6]
  shape_line_width     = 1
  shape_outline_width  = 4
  
  display_as_table     = true
  float_precision      = 2
  time_in_secs         = false     // secs or millisecs
  render_target        = screen
  manual_input         = false
  
  bm_smoothing         = 15          // lower = more responsive | higher = less twichy
  bm_con_upd_interval  = 1.0  // console update interval in seconds
  
  
  // -------------------------------------
  //   internal stuff
  // -------------------------------------
  _lines = []
  _longest_line = 0
  _longest_key  = 0
  _longest_val  = 0
  _longest_single_key  = 0
  _bm_cache = object end
  _draw_commands = object
    line   = []
    rline  = []
    rect   = []
    frect  = []
    point  = []
    fpoint = []
    text   = []
  end
  
  _t1 = system.time()
  _dt = 0
  _update_dt = function()
    local t2 = system.time()
    this._dt = (t2-this._t1)/1000
    this._t1 = t2
  end
end


debug._reset = function()
  this._lines = []
	this._longest_line = 0
	this._longest_key  = 0
	this._longest_val  = 0
	this._longest_single_key = 0
end


debug._reset_drawing = function()
  for kind in this._draw_commands
	  this._draw_commands[kind] = []
	end
end


debug.toggle = function()
  this.active = not this.active
end


debug.toggle_drawing = function()
  this.active_drawing = not this.active_drawing
end
debug.toggleDrawing = debug.toggle_drawing


debug.update = function()
  debug._update_dt()
  
  if this.active then
    this._reset()
  end
  
  if this.active_drawing then
    this._reset_drawing()
  end
  
  if not manual_input then 
    if keyboard.press[this.key1] or keyboard.press[this.key2] then 
      if keyboard["CONTROL"] then 
        this.toggle_drawing()
      else
        this.toggle()
      end
    end
  end
end


debug.commit_deferred = function()
  this._process_draw_commands()
end
debug.commitDeferred = debug.commit_deferred


debug.draw = function()
  this._process_print_commands()
end


debug._draw_text = function(text, x, y, color)
  if this.text_outlined then 
    screen.setLineWidth(this.text_outline_width)
    screen.drawTextOutline(text, x, y, this.text_font_size, this.text_outline_color)
  end
  screen.drawText(text, x, y, this.text_font_size, this.panel_use_colors and color or this.panel_key_color)
end


debug._parse_line_part = function(part, precision, is_key=false)
  if this.___fmt___.is_float(part) then
    return debug.__fmt("%" + floor(precision) + "f", [part])
  end
  if is_key and not this.display_as_table then 
    return debug.__fmt("%s:", [part])
  end
  return debug.__fmt("%s", [part])
end


debug._draw_panel = function(fs)
  if not this.text_background then return end
  local rx = -screen.width/2
	local ry = screen.height/2
  local rh = this._lines.length*(fs+this.text_line_spacing)+this.panel_margin_bottom+this.panel_margin_top
	local margins = this.panel_margin_left + this.panel_margin_right
	local rw = 0
  if this._longest_line+margins < this._longest_single_key then 
    rw = this._longest_single_key
    
  else
	  rw = this._longest_line
	 // rw = this._longest_key + this._longest_val
    rw += this.text_col_separation
  end
  // rw = this._longest_val
	
	rw += margins

	screen.setLineWidth(1)
	screen.setLineDash()
	screen.fillRect(rx, ry, rw, rh, this.panel_back_color)
	screen.drawRect(rx, ry, rw, rh, this.panel_frame_color)
end


debug._process_print_commands = function()
  if not this.active then return end
  screen.setDrawAnchor(-1, 1)
  screen.setFont(this.text_font)
  
	local lines = this._lines
	local fs = this.text_font_size
	
	local x = -screen.width/2+this.panel_margin_left

	for line in lines
    line.key_parsed = this._parse_line_part(line.key, line.precision, line.key != "" and line.val.type != 0 )

    local kw = screen.textWidth(line.key_parsed, fs)
    local vw = 0
    local lw = 0
    local lskw = 0
    
    if line.val.type != 0 then
      line.val_parsed = this._parse_line_part(line.val, line.precision)
      vw = screen.textWidth(line.val_parsed, fs) // +this.text_col_separation
        
    else
      lskw = kw
      kw = 0
      
    end
    lw = kw + vw
    
    if lskw > this._longest_single_key then  this._longest_single_key = lskw end
    if kw > this._longest_key then  this._longest_key  = kw end
    if vw > this._longest_val then  this._longest_val  = vw end
    if lw > this._longest_line then this._longest_line = lw end
    
    // local kstr = kw > 0 and fmt("%s (%d)", [line.key_parsed, kw]).align('l', 20) or ' '.align('l', 20)
    // local vstr = vw > 0 and fmt("%s (%d)", [line.val_parsed, vw]).align('l', 20) or ' '.align('l', 20)
    // local lstr = fmt("sum: %d", [lw]).align('l', 20)
    // global.printf("%s| %s| %s", [kstr, vstr, lstr])
  end
  // global.print("------------------")
  
  if this.display_as_table then 
    // if this._longest_key + this._longest_val > this._longest_single_key then
      this._longest_line = this._longest_key + this._longest_val
  end
  
  local val_x = x + this._longest_key + this.text_col_separation
  
  // global.print(this._longest_key)
  // global.print(this._longest_val)
  // global.print(this._longest_line)
  // global.print("------------------")
  
	this._draw_panel(fs)

	for i=0 to lines.length-1 by 1
	  local line = this._lines[i]
    local y = screen.height/2 - i*(fs+this.text_line_spacing) - this.panel_margin_top
    
    if not this.display_as_table then 
      val_x = line.key_parsed == "" and x or (x + screen.textWidth(line.key_parsed, fs)+this.text_col_separation)
    else
      val_x = x + this._longest_key + this.text_col_separation
    end
    
    if line.key_parsed != "" then 
      this._draw_text(line.key_parsed, x, y, this.panel_key_color)
    end
    
    if line.val_parsed.type != 0 then
      local color = this.panel_string_color
      if    line.val.type == "number" then color = this.panel_number_color
      elsif line.val.type == "object" then color = this.panel_object_color
      end
      this._draw_text(line.val_parsed, val_x, y, color)
    end
  end
  
  screen.setFont(this.text_font_default)
	screen.setDrawAnchor()
	screen.setLineWidth()
end


_NOARG_ = object end
debug.print = function(key, val=_NOARG_, precision=_NOARG_)
  if not this.active then return end
  
  local line = object end
  
  if val == _NOARG_ then // 1 arg given
    precision = this.float_precision
  else   // 2 or 3 args given
    if val.type == "number" and this.___fmt___.is_float(key) then 
      precision = val
      val = _NOARG_
    elsif precision == _NOARG_ then
      precision = this.float_precision
    end
  end
  
  if val != _NOARG_ then 
    line.key = key 
    line.val = val
    line.precision = precision
  else
    line.key = key
    line.precision = precision
  end

  this._lines.push(line)
end


debug._check_cache = function(name)
  if not this._bm_cache[name] then 
    this._bm_cache[name] = object
      time_sum = 0
      history = []
      timer = this.bm_con_upd_interval
    end
  end
  return this._bm_cache[name]
end



// benchmarks and prints results on screen 
// optionally also prints to the console periodically

// debug.bmc(string, function)
debug.bmc = function(name, func)
  this.bm(name, func, true)
end


// debug.bm(string, function)
debug.bm = function(name, func, __con_prt=false)
  if not this.active and not __con_prt then 
    func()
    return 0
  end
  
	local t1 = system.time()
	func()
	local t2 = (system.time() - t1)
	if time_in_secs then
	  t2 /= 1000
	end
  
  local cache = this._check_cache(name)
  
  if this.bm_smoothing > 1 then 
    cache.time_sum += t2
    if cache.history.length > this.bm_smoothing then 
      cache.time_sum -= cache.history.removeAt(0)
    end
    cache.history.push(t2)
    t2 = cache.time_sum/cache.history.length
  end
  
  local times_str = this.__fmt((time_in_secs and "%4f s" or "%d ms"), [t2])

	if this.active and not __con_prt then 
	  this.print(name, times_str)
	end
	
	if __con_prt then
    local str = this.__fmt("%s: " + times_str, [name])
    
    cache.timer -= this._dt
    if cache.timer <= 0 then 
      global.print(str)
      cache.timer = this.bm_con_upd_interval
    end  
  end
  return t2
end



/*******************************************************************************

      Internal Drawing API

*******************************************************************************/
debug._process_draw_commands = function()
  if not this.active_drawing then return end
  
  // lines
  for c in this._draw_commands.line
    this.line(c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7])
  end
  
  for c in this._draw_commands.rline
    this.line(c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7])
  end
  
  for c in this._draw_commands.rect
    this.rect(c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8])
  end

  for c in this._draw_commands.frect
    this.frect(c[0], c[1], c[2], c[3], c[4], c[5], c[6])
  end
  
  for c in this._draw_commands.point
    this.point(c[0], c[1], c[2], c[3], c[4], c[5], c[6])
  end
  
  for c in this._draw_commands.fpoint
    this.fpoint(c[0], c[1], c[2], c[3], c[4])
  end
  
  for c in this._draw_commands.text
    this.text(c[0], c[1], c[2], c[3], c[4], c[5], c[6])
  end
end


debug._add_draw_command = function(kind, params)
  if not this.active_drawing then return end
  this._draw_commands[kind].push(params)    
end

  



/*******************************************************************************


      Public Drawing API


*******************************************************************************

/*******************************************************************************
      Deferred Drawing API
*******************************************************************************/
debug.dline = function(x1, y1, x2, y2, color, thickness=0, outline=false, dash=false)
  this._add_draw_command("line", [x1, y1, x2, y2, color, thickness, outline, dash])    
end

debug.drline = function(x, y, rx, ry, color, thickness=0, outline=false, dash=false)
  this._add_draw_command("rline", [x, y, x+rx, y+ry, color, thickness, outline, dash])    
end

debug.drect = function(x, y, w, h, color, thickness=0, radius=0, outline=false, dash=false)
  this._add_draw_command("rect", [x, y, w, h, color, thickness, radius, outline, dash])
end

debug.dfrect = function(x, y, w, h, color, radius=0, outline=false)
  this._add_draw_command("frect", [x, y, w, h, color, radius, outline])
end

debug.dpoint = function(x, y, radius, color, thickness=0, outline=false, dash=false)
  this._add_draw_command("point", [x, y, radius, color, thickness, outline, dash])
end

debug.dfpoint = function(x, y, radius, color, outline=false)
  this._add_draw_command("fpoint", [x, y, radius, color, outline])
end

debug.dtext = function(text, x, y, size, color, outline=false, font=0)
  this._add_draw_command("text", [text, x, y, size, color, outline, font])
end



/*******************************************************************************      
      Immediate Drawing API
*******************************************************************************/
debug.line = function(x1, y1, x2, y2, color, thickness=0, outline=false, dash=false)
  if not this.active_drawing then return end
  
  thickness = thickness or this.shape_line_width
  if dash then this.render_target.setLineDash(dash.type == "number" and this.shape_dash or dash) end
  
  if outline then 
    this.render_target.setLineWidth(thickness+this.shape_outline_width)  
    this.render_target.drawLine(x1, y1, x2, y2, this.shape_outline_color)
  end  
  
  this.render_target.setLineWidth(thickness)
  this.render_target.drawLine(x1, y1, x2, y2, color)
  
  this.render_target.setLineWidth()
  if dash then this.render_target.setLineDash() end
end


debug.rline = function(x, y, rx, ry, color, thickness=0, outline=false, dash=false)
  if not this.active_drawing then return end
  
  thickness = thickness or this.shape_line_width
  if dash then this.render_target.setLineDash(dash.type == "number" and this.shape_dash or dash) end
  
  local x2 = x+rx
  local y2 = y+ry
  
  if outline then 
    this.render_target.setLineWidth(thickness+this.shape_outline_width)  
    this.render_target.drawLine(x, y, x2, y2, this.shape_outline_color)
  end  
  
  this.render_target.setLineWidth(thickness)
  this.render_target.drawLine(x, y, x2, y2, color)
  
  this.render_target.setLineWidth()
  if dash then this.render_target.setLineDash() end
end


debug.vec = function(px, py, dx, dy, color, thickness=0, outline=false, dash=false)
  // this is an ongoing experiment, disregard
  
  local x2 = px+dx 
  local y2 = py+dy
  
  this.line(px, py, x2, y2, color, thickness, outline, dash)
  this.fpoint(px, py, thickness*2, color, outline)
  
end


debug.rect = function(x, y, w, h, color, thickness=0, radius=0, outline=false, dash=false)
  if not this.active_drawing then return end
  
  thickness = thickness or this.shape_line_width

  if dash then this.render_target.setLineDash(dash.type == "number" and this.shape_dash or dash) end
  if outline then 
    this.render_target.setLineWidth(thickness+this.shape_outline_width)  
    this.render_target.drawRoundRect(x, y, w, h, radius, this.shape_outline_color)
  end
  this.render_target.setLineWidth(thickness)
  this.render_target.drawRoundRect(x, y, w, h, radius, color)
  
  this.render_target.setLineWidth()
  if dash then this.render_target.setLineDash() end
end


debug.frect = function(x, y, w, h, color, radius=0, outline=false)
  if not this.active_drawing then return end
  if outline then 
    this.render_target.setLineWidth(this.shape_outline_width/2)  
    this.render_target.drawRoundRect(x, y, w+this.shape_outline_width/2, h+this.shape_outline_width/2, radius, this.shape_outline_color)
    this.render_target.setLineWidth()
  end
  this.render_target.fillRoundRect(x, y, w, h, radius, color)
end


debug.point = function(x, y, radius, color, thickness=0, outline=false, dash=false)
  if not this.active_drawing then return end

  if dash then this.render_target.setLineDash(dash.type == "number" and this.shape_dash or dash) end
  if outline then 
    this.render_target.setLineWidth(thickness+this.shape_outline_width)  
    this.render_target.drawRound(x, y, radius*2, radius*2, this.shape_outline_color)  
  end
  this.render_target.setLineWidth(thickness or this.shape_line_width)
  this.render_target.drawRound(x, y, radius*2, radius*2, color)

  this.render_target.setLineWidth()
  if dash then this.render_target.setLineDash() end
end


debug.fpoint = function(x, y, radius, color, outline=false)
  if not this.active_drawing then return end
  
  if outline then 
    this.render_target.setLineWidth(this.shape_outline_width/2)
    this.render_target.drawRound(x, y, radius*2+this.shape_outline_width/2, radius*2+this.shape_outline_width/2, this.shape_outline_color)  
    this.render_target.setLineWidth()
  end
  this.render_target.fillRound(x, y, radius*2, radius*2, color)
end



debug.text = function(text, x, y, size, color, outline=false, font=0)
  if not this.active_drawing then return end
  
  local rtarget = this.render_target
  
  rtarget.setFont(font or this.shape_font)
  
  if outline then 
    rtarget.setLineWidth(this.shape_outline_width)
    rtarget.drawTextOutline(text, x, y, size, this.shape_outline_color)
    rtarget.setLineWidth()
  end
  
  rtarget.drawText(text, x, y, size, color)

  if font then rtarget.setFont(this.text_font_default) end
end
















/*
    
    
    Disregard everything below. It's a partial copy of my String format 
    library (version 0.9). The debugger just uses it for (my) convenience. 
    
    
*/

debug.___fmt___ = object
  // helper lookup tables
  // TODO: test if using table is faster than using strings for LUTs
  VALID = ['s', 'd', 'f', 'o', 't', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
  DIGITS = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
  
  // used to replace escaped or invalid '%'s, to mark where they are
  // because 'indexOf' always finds the first occurrence
  TEMP = "__(@^€!$~@]__"  // (just an unlikely pattern to exist in any other string)
  
  // truncate floats
  ftrunc = function(val, num_decimals)
    return round(val*10^num_decimals)/10^num_decimals
  end
  
  is_float = function(num)
    return num.type == "number" and num % 1 != 0
  end
  // parse objects, recursively, and expand their properties
  // 'obj.__str' should be an instance function that returns 
  // a string representing the object
  parse_obj = function(obj, level=0)
    // if obj.__str then return obj.__str() end
    // and obj.__str.type == "function" then return obj.__str() end
  
    local indent = ""
    local fields_str = ""
    
    for k in obj
      local v = obj[k]
      
      indent = "  "
      for i=0 to level-1 by 1 
        indent += "  " 
      end
      
      if v.type == "object" and k != "class" then 
        v = this.parse_obj(v, level+1) 
      end
      
      fields_str += indent + k + " = " + v + "\n"
    end
    
    indent = ""
    for i=0 to level-1 by 1 
      indent += "  " 
    end
    
    local out_str = "object\n" + fields_str + indent + "end"
    
    return level == 0
       and indent + out_str
        or out_str
  end
end

debug.__fmt = function(str, args)
  if args.type != "list" or args.length == 0 then return str end
  local index = str.indexOf('%')
  local i = 0

  // local j = 0  // temp safety
  while index != -1 //and j < 100
    // j += 1
    local ch = str.substring(index+1, min(index+2, str.length))
    
    // if '%' is escaped, mark it and continue
    if str.substring(index-1, index, str.length) == '\\' then
      str = str.substring(0, index-1) + str.substring(index, str.length)
      str = str.replace('%', debug.___fmt___.TEMP)
      index = str.indexOf('%')
      continue
    end
    
    if debug.___fmt___.VALID.contains(ch) then
      local arg = args[i]
      
      // not a float or no precision specified
      if not debug.___fmt___.DIGITS.contains(ch) then
        if    ch == 'd' then
          arg = if arg.type == "number" then floor(arg) else "NAN" end
        
        elsif ch == 'f' then
          arg = if arg.type == "number" then arg else "NAN" end
        
        elsif ch == 'o'and arg.type == "object" then
          arg = debug.___fmt___.parse_obj(arg)
        
        elsif ch == 't' then
          arg = arg.__type or arg.type
        else
          if arg.__str then arg = arg.__str() end
        end
        
        str = str.replace("%" + ch, arg)
      
      // it's a float with precision
      else
        if arg.type != "number" then
          str = str.replace("%" + ch, "NAN")
        else
          local tmp = str.substring(index+1, str.length)
          local ending = tmp.indexOf('f')
          
          if ending < 0 then
            str = str.replace('%', debug.___fmt___.TEMP)
            index = str.indexOf('%')
            continue
          end
          tmp = tmp.substring(0, ending+1)
          
          local prec = Number.parse(tmp.substring(0, ending))
          str = str.replace('%'+tmp, debug.___fmt___.ftrunc(arg, prec))
        end
      end
      
      index = str.indexOf('%')
      i += 1
    else
      str = str.replace('%', debug.___fmt___.TEMP)
      index = str.indexOf('%')
    end
    // print(j + " | " + str)
  end
  
  
  // j = 0  // temp safety
  while true// and j < 100
    // j += 1
    local idx = str.indexOf(debug.___fmt___.TEMP)
    if idx < 0 then break end
    str = str.replace(debug.___fmt___.TEMP, '%')
  end
  
  return str
end