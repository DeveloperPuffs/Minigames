global.init = function()
  audio.playMusic("music", 0.05, true)

  /* Levels are defined with series of strings to represent the value of each
  tile. This system has the inconvenience that each tile can only contain one
  single element. However, it should be good enough for this project. */
  // '^' - Spike, '#' - Block, '0' - Spawn, '1' - Exit, '!' - Enemy
  global.levels = [
    [
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "   0           ^^           1   ",
    ],
    [
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "   0         ^^^^^^         1   ",
    ],
    [
      "                  !#            ",
      "                   #            ",
      "                   #            ",
      "                   #            ",
      "   0        ^      #            ",
      "#############      #            ",
      "            #      #            ",
      "            #      #            ",
      "            #      #            ",
      "            #      #            ",
      "            #      #            ",
      "            #      #            ",
      "            #      #############",
      "            #                   ",
      "            #                   ",
      "            #                   ",
      "            #                   ",
      "            #      ^        1   ",
    ],
    [
      "                                ",
      " !                              ",
      "                                ",
      "                                ",
      "     ^           ^          0   ",
      "     ###########################",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "     ^           ^              ",
      "#############################   ",
      "                                ",
      "                                ",
      "                                ",
      "                                ",
      "   1             ^              ",
    ],
    [
      "          #          #          ",
      "          #          #          ",
      "          #          #          ",
      "          #          #          ",
      "          #          #          ",
      "   ^                 #      ^   ",
      "   #                 #      #   ",
      "   #      #          #      #   ",
      "   #      #          #      #   ",
      "   #      #          #      #   ",
      "   #      #          #      #   ",
      "   #      #          #      #   ",
      "   #      #          #      #   ",
      "   #      #                 #   ",
      "   #      #                 #   ",
      "   #      #          #      #   ",
      "   #      #          #      #   ",
      " 0 #      #    ^^    #      # 1 ",
    ],
  ]
  
  global.backgroundColor = "rgb(000, 000, 000)"
  global.foregroundColor = "rgb(255, 255, 255)"
  global.colorCurrent = true
  global.colorTarget = true
  
  global.map = object end
  global.map.columns = 32
  global.map.rows = 18
  global.tileSize = screen.height / global.map.rows
  
  global.gravity = object end
  global.gravity.x = 0
  global.gravity.y = -0.4
  
  global.player = object end
  global.player.position = object end
  global.player.position.x = 0
  global.player.position.y = 0
  global.player.velocity = object end
  global.player.velocity.x = 0
  global.player.velocity.y = 0
  global.player.friction = object end
  global.player.friction.x = 0.2
  global.player.friction.y = 0
  global.player.acceleration = object end
  global.player.acceleration.x = 0.5
  global.player.acceleration.y = 1.5
  global.player.collision = object end
  global.player.collision.x = 0
  global.player.collision.y = 0
  
  // The precision will determine the size of each 'step' taken before checking
  // for collisions
  global.player.precision = 10
  
  // The player can hold for a few frames to jump slightly higher.
  global.player.jumpFrames = 0
  
  // Whether the player is holding on to vertical surface. This determines
  // whether the player can perform a wall jump.
  global.player.wallGrip = false
  
  // Keeping track of the state
  global.player.HUMAN = "HUMAN"
  global.player.GHOST = "GHOST"
  global.player.state = global.player.HUMAN
  global.player.invincibilityFrames = 0
  global.player.invertColor = false
  global.player.corpse = object end
  global.player.corpse.x = -global.tileSize
  global.player.corpse.y = -global.tileSize
  global.player.dying = false
  
  // The ghost instructions will only show when this is equal to '1'.
  // Incrementing this when changing states is perfect for showing the ghost
  // instructions for only the first time the player turns into a ghost.
  global.ghostInstructionsState = -1
  
  global.spawn = object end
  global.spawn.x = 0
  global.spawn.y = 0
  
  global.enemies = []
  
  global.START = "START"
  global.GAME = "GAME"
  global.WIN = "WIN"
  global.state = global.START
  global.startTime = 0
  global.currentTime = 0
  
  global.level = false
  global.levelIndex = 0
  
  global.shake = object end
  global.shake.power = 0
  global.shake.x = 0
  global.shake.y = 0
end

global.setLevel = function(level)
  if global.level == level then
    global.player.velocity.x = 0
    global.player.velocity.y = 0
    global.player.invincibilityFrames = 0
    global.player.state = global.player.HUMAN
    global.player.position.x = global.spawn.x
    global.player.position.y = global.spawn.y
    global.player.corpse.x = -global.tileSize
    global.player.corpse.y = -global.tileSize
    global.colorTarget = true
    
    if not global.ghostInstructionsState then
      global.ghostInstructionsState += 1
    end
    
    return
  end
  
  if not level then
    global.state = global.WIN
    global.player.position.x = global.spawn.x
    global.player.position.y = global.spawn.y
    global.player.invincibilityFrames = 0
    global.player.velocity.x = 0
    global.player.velocity.y = 0
    return
  end
  
  global.level = level
  global.enemies = []
  
  // Iterate over all tiles and spawn dynamic objects
  for row = 0 to global.map.rows - 1
    for column = 0 to global.map.columns - 1
      local tile = global.level[row][column]
      local x = (column + 0.5) * global.tileSize
      local y = (global.map.rows - row - 0.5) * global.tileSize
      
      if tile == "0" then
        global.spawn.x = x
        global.spawn.y = y
      elsif tile == "!" then
        local enemy = object end
        enemy.targetting = false
        enemy.anchor = object end
        enemy.anchor.x = x
        enemy.anchor.y = y
        enemy.position = object end
        enemy.position.x = x
        enemy.position.y = y
        enemy.velocity = object end
        enemy.velocity.x = 0
        enemy.velocity.y = 0
        enemy.friction = object end
        enemy.friction.x = 0.1
        enemy.friction.y = 0.1
        enemy.acceleration = object end
        enemy.acceleration.x = 0
        enemy.acceleration.y = 0
        global.enemies.push(enemy)
      end
    end
  end
  
  global.player.invincibilityFrames = 0
  global.player.position.x = global.spawn.x
  global.player.position.y = global.spawn.y
  global.player.invincibilityFrames = 0
  global.player.velocity.x = 0
  global.player.velocity.y = 0
end

global.aabb = function(x1, y1, s1, x2, y2, s2)
  x1 < x2 + s2 and
  x1 + s1 > x2 and
  y1 < y2 + s2 and
  y1 + s1 > y2 end

global.collision = function()
  if global.player.state == global.player.GHOST then
    if global.aabb(
      global.player.position.x, global.player.position.y, global.tileSize,
      global.player.corpse.x, global.player.corpse.y, global.tileSize
    ) then
      global.ghostInstructionsState += 1
      global.player.state = global.player.HUMAN
      global.player.invincibilityFrames = 60
      global.player.corpse.x = -global.tileSize
      global.player.corpse.y = -global.tileSize
      global.colorTarget = true
      global.shake.power += 0.5
    end
  end
  
  // For this game, it should be fine if I just check for collision with each
  // of the four vertices of the player.
  local vertices = [
    // Bottom Left Vertex
    global.player.position.x,
    global.player.position.y,
  
    // Bottom Right Vertex
    global.player.position.x + global.tileSize,
    global.player.position.y,
  
    // Top Left Vertex
    global.player.position.x,
    global.player.position.y + global.tileSize,
    
    // Top Right Vertex
    global.player.position.x + global.tileSize,
    global.player.position.y + global.tileSize,
  ]
  
  for index = 0 to 3
    local column = floor(vertices[index * 2] / global.tileSize)
    local row = floor(vertices[index * 2 + 1] / global.tileSize)
    local tile = global.level[global.map.rows - row - 1][column]
    if not tile then return true end
    
    if tile == "^" and not global.player.invincibilityFrames then
      if global.player.state == global.player.HUMAN then
        global.player.state = global.player.GHOST
        global.player.dying = true
        global.colorTarget = false
        global.shake.power += 1
        audio.playSound("hit", 0.1)
      elsif not global.player.dying then
        global.player.position.x = global.spawn.x
        global.player.position.y = global.spawn.y
        global.player.velocity.x = 0
        global.player.velocity.y = 0
        global.shake.power += 0.5
        audio.playSound("hit", 0.1)
      end
    elsif tile == "1" and global.player.state == global.player.HUMAN then
      global.levelIndex += 1
      global.setLevel(global.levels[global.levelIndex])
      audio.playSound("win", 0.05)
    end
    
    if tile == "#" then
      return true
    end
  end
  
  return false
end

global.move = function(axis)
  local distance = global.player.velocity[axis]
  local units = round(distance * global.player.precision)
  if not units then return end
  
  local steps = abs(units)
  local step = units / steps
  
  for _ = 1 to steps
    global.player.position[axis] += step / global.player.precision
    
    // If there is a collision, take a step back and reset the velocity for the
    // current axis.
    if global.collision() then
      global.player.position[axis] -= step / global.player.precision
      global.player.velocity[axis] = 0
      
      if axis == "y" and step == -1 and global.player.dying then
        global.ghostInstructionsState += 1
        
        global.player.corpse.x = global.player.position.x
        global.player.corpse.y = global.player.position.y
        global.player.dying = false
        
        global.player.position.x = global.spawn.x
        global.player.position.y = global.spawn.y
        global.player.velocity.x = 0
        global.player.velocity.y = 0
        global.shake.power += 0.5
      end
      
      return
    end
  end
end

global.update = function()
  if global.state == global.START then
    if keyboard.press.SPACE then
      audio.playSound("click", 0.2)
      
      global.startTime = system.time()
      global.currentTime = system.time()
      
      global.state = global.GAME
      global.setLevel(global.levels[global.levelIndex])
    end
    
    return
  elsif global.state == global.WIN then
    if keyboard.press.R then
      audio.playSound("click", 0.2)
      global.state = global.START
      global.levelIndex = 0
    end
    
    return
  end
  
  if keyboard.press.R then
    audio.playSound("click", 0.2)
    global.setLevel(global.levels[global.levelIndex])
  end
  
  global.shake.power *= 0.8
  local direction = random.next() * (2 * PI)
  global.shake.x = cos(direction * global.shake.power)
  global.shake.y = sin(direction * global.shake.power)
  global.currentTime = system.time()
  
  for enemy in global.enemies
    local dx = global.player.position.x - enemy.position.x
    local dy = global.player.position.y - enemy.position.y
      
    if enemy.targetting then
      if global.player.state == global.player.GHOST then
        enemy.targetting = false
        continue
      end
      
      local angle = atan2(dy, dx)
      enemy.acceleration.x = cos(angle) / 3
      enemy.acceleration.y = sin(angle) / 3
    else
      if global.player.state == global.player.HUMAN then
        local distance = sqrt(pow(dx, 2) + pow(dy, 2))
        if distance <= 100 then
          enemy.targetting = true
          global.shake.power += 0.5
          audio.playSound("hey", 0.1)
          continue
        end
      end
      
      dx = enemy.anchor.x - enemy.position.x
      dy = enemy.anchor.y - enemy.position.y
      local distance = sqrt(pow(dx, 2) + pow(dy, 2))
      
      if distance >= 1 then
        local angle = atan2(dy, dx)
        enemy.acceleration.x = cos(angle) / 6
        enemy.acceleration.y = sin(angle) / 6
      else
        enemy.acceleration.x = 0
        enemy.acceleration.y = 0
        enemy.velocity.x = 0
        enemy.velocity.y = 0
        enemy.position.x = enemy.anchor.x
        enemy.position.y = enemy.anchor.y
      end
    end
    
    enemy.velocity.x += enemy.acceleration.x
    enemy.velocity.y += enemy.acceleration.y
    
    enemy.velocity.x *= 1 - enemy.friction.x
    enemy.velocity.y *= 1 - enemy.friction.y
    
    enemy.position.x += enemy.velocity.x
    enemy.position.y += enemy.velocity.y
    
    if global.player.state == global.player.HUMAN and global.aabb(
      global.player.position.x, global.player.position.y, global.tileSize,
      enemy.position.x, enemy.position.y, global.tileSize
    ) then
      audio.playSound("hit", 0.1)
      global.player.state = global.player.GHOST
      global.player.dying = true
      global.colorTarget = false
      global.shake.power += 1
    end
  end
  
  if global.player.invincibilityFrames > 0 then
    global.player.invincibilityFrames -= 1
    
    local value = global.player.invincibilityFrames / 6
    global.player.invertColor = floor(value) % 2
  else
    global.player.invertColor = false
  end
  
  if not global.player.dying then
    local direction = keyboard.RIGHT - keyboard.LEFT
    global.player.velocity.x += global.player.acceleration.x * direction
  end
  
  if not global.player.dying and (keyboard.UP or keyboard.SPACE) then
    if global.player.jumpFrames or global.player.collision.y == -1 then
      if not global.player.jumpFrames then
        audio.playSound("jump", 0.01)
      end
  
      // Create a new jump or continue jumping
      global.player.velocity.y += global.player.acceleration.y
      global.player.jumpFrames += 1
      if global.player.jumpFrames >= 5 then
        global.player.jumpFrames = 0
      end
    elsif global.player.wallGrip then
      if not global.player.jumpFrames then
        audio.playSound("jump", 0.01)
      end
  
      // Perform a wall jump
      local direction = -global.player.collision.x
      global.player.velocity.x = 10 * global.player.acceleration.x * direction
      global.player.velocity.y += 5 * global.player.acceleration.y
      global.player.jumpFrames += 1
    end
  elsif global.player.jumpFrames then
    // Stop the current jump
    global.player.jumpFrames = 0
  end
  
  global.player.velocity.x += global.gravity.x
  global.player.velocity.y += global.gravity.y
  
  global.player.velocity.x *= 1 - global.player.friction.x
  global.player.velocity.y *= 1 - global.player.friction.y
  
  // Override the vertical velocity if needed
  if global.player.wallGrip then
    global.player.velocity.y = -0.1
  end
  
  // Prioritize moving in the axis with the greatest velocity first as the
  // order might be affected by collisions encountered this frame.
  if global.player.velocity.y > global.player.velocity.x then
    global.move("y")
    global.move("x")
  else
    global.move("x")
    global.move("y")
  end
  
  // Update the player's collision state on each axis
  local unit = 1 / global.player.precision
  local x = global.player.position.x
  local y = global.player.position.y
  global.player.collision.x = 0
  global.player.collision.y = 0
  
  global.player.position.x = x - unit
  global.player.position.y = y
  if global.collision() then
    global.player.collision.x = -1
  end
  
  global.player.position.x = x + unit
  global.player.position.y = y
  if global.collision() then
    global.player.collision.x = 1
  end
  
  global.player.position.x = x
  global.player.position.y = y - unit
  if global.collision() then
    global.player.collision.y = -1
  end
  
  global.player.position.x = x
  global.player.position.y = y + unit
  if global.collision() then
    global.player.collision.y = 1
  end
  
  global.player.position.x = x
  global.player.position.y = y
  
  local contact = not not global.player.collision.x
  local falling = global.player.velocity.y <= -0.5
  global.player.wallGrip = contact and falling
end

global.draw = function()
  global.colorCurrent += (global.colorTarget - global.colorCurrent) / 10
  global.backgroundColor
    = "rgb("
    + 255 * global.colorCurrent + ", "
    + 255 * global.colorCurrent + ", "
    + 255 * global.colorCurrent + ")"
  global.foregroundColor
    = "rgb("
    + 255 * (1 - global.colorCurrent) + ", "
    + 255 * (1 - global.colorCurrent) + ", "
    + 255 * (1  -global.colorCurrent) + ")"
  
  screen.setFont("monospace")
  screen.clear(global.backgroundColor)
  
  if global.state == global.START then
    screen.drawText(
      "Where I Fell 💀",
      0, 0, 24, global.foregroundColor
    )
    
    screen.drawText(
      "Press 'Space' to Play",
      0, screen.height / -2 + 12, 6, global.foregroundColor
    )
    
    return
  end
  
  local elapsedTime = global.currentTime - global.startTime
  local totalSeconds = floor(elapsedTime / 1000)
  local hours = floor(totalSeconds / 3600)
  local minutes = floor((totalSeconds % 3600) / 60)
  local seconds = totalSeconds % 60
  
  local paddedMinutes = (if minutes < 10 then "0" else "" end) + minutes
  local paddedSeconds = (if seconds < 10 then "0" else "" end) + seconds
  
  local time
    = (if hours > 0 then hours + ":" else "" end)
    + paddedMinutes + ":" + paddedSeconds
  
  local text = time + " - 'R' to Restart"
  screen.drawText(text, 0, screen.height / 2 - 12, 6, global.foregroundColor)
  
  if global.state == global.WIN then
    screen.drawText(
      "You win 🏆",
      0, 12, 18, global.foregroundColor
    )
    
    screen.drawText(
      "Thank you for playing!",
      0, -6, 6, global.foregroundColor
    )
    
    return
  end
  
  screen.setTranslation(
    global.shake.x + screen.width / -2,
    global.shake.y + screen.height / -2
  )
  
  screen.setDrawScale(1.02, 1.02)
  
  // An 'ok' but quick way to simulate stretch and squash effect
  local scale = 1
  if global.player.velocity.y > 0 then
    scale = 1 + global.player.velocity.y / 20
  elsif global.player.velocity.y < 0 then
    scale = 1 - abs(global.player.velocity.y) / 20
  end
  
  screen.setDrawRotation(-global.player.velocity.x)
  
  local invert = global.player.invertColor
  screen.fillRect(
    global.player.position.x + global.tileSize / 2,
    global.player.position.y + global.tileSize / 2,
    global.tileSize, global.tileSize * max(0.5, min(1.5, scale)),
    if invert then global.backgroundColor else global.foregroundColor end
  )
  
  screen.setDrawRotation(0)
  
  local ghost = global.player.state == global.player.GHOST
  if ghost and not global.player.dying then
    screen.fillRect(
      global.player.corpse.x + global.tileSize / 2,
      global.player.corpse.y + global.tileSize / 2,
      global.tileSize, global.tileSize,
      "rgb(0, 255, 0)"
    )
  end
  
  for row = 0 to global.map.rows - 1
    for column = 0 to global.map.columns - 1
      local tile = global.level[global.map.rows - row - 1][column]
      local x = (column + 0.5) * global.tileSize
      local y = (row + 0.5) * global.tileSize
      
      if tile == "#" then
        screen.fillRect(
          x, y, global.tileSize, global.tileSize,
          global.foregroundColor
        )
      elsif tile == "^" then
        screen.fillPolygon(
          x - global.tileSize / 2, y - global.tileSize / 2,
          x + global.tileSize / 2, y - global.tileSize / 2,
          x, y + global.tileSize / 2,
          global.foregroundColor
        )
      elsif tile == "1" then
        local human = global.player.state == global.player.HUMAN
        screen.fillRect(
          x, y, global.tileSize, global.tileSize,
          if human then "rgb(0, 255, 0)" else global.foregroundColor end
        )
      end
    end
  end
  
  screen.setLineDash([2, 4])
  
  for enemy in global.enemies
    screen.setDrawRotation(-enemy.velocity.x)
    screen.fillRect(
      enemy.position.x + global.tileSize / 2,
      enemy.position.y + global.tileSize / 2,
      global.tileSize, global.tileSize, "rgb(255, 0, 0)"
    )
    
    if not enemy.targetting then
      screen.drawRound(
        enemy.position.x + global.tileSize / 2,
        enemy.position.y + global.tileSize / 2,
        200, 200, "rgb(255, 0, 0)"
      )
    end
  end
  
  screen.setDrawRotation(0)
  screen.setDrawScale(1, 1)
  screen.setTranslation(0, 0)
  
  if global.player.state == global.player.HUMAN and global.levelIndex == 0 then
    screen.drawText(
      "Use 'A'/'D' or Left/Right Keys to Move",
      0, 6, 6, global.foregroundColor
    )
    
    screen.drawText(
      "Use 'W', Up, or 'Space' Key to Jump",
      0, -6, 6, global.foregroundColor
    )
  end
  
  if not global.ghostInstructionsState then
    screen.drawText(
      "👻 You are now a ghost. Get back to your dead body to revive!",
      0, 6, 6, global.foregroundColor
    )
    
    screen.drawText(
      "(Don't learn from mistakes - repeat!)",
      0, -6, 4, global.foregroundColor
    )
  end
end