
/*
https://lospec.com/palette-list/toxic-haze
*/

global.x2t = function(x) return floor((x + 320) / 40) end
global.y2t = function(y) return floor((y + 180) / 40) end
global.c2p = function(c) return (c + 0.5) * 40 - 320 end
global.r2p = function(r) return (r + 0.5) * 40 - 180 end

global.setupLevel = function()
  local spawn = function(column, row)
    global.x = global.c2p(column)
    global.y = global.r2p(row)
    global.float = [0, 0]
    global.flip = 1
    global.vx = 0
    global.vy = 0
  end

  global.points = []
  global.blocks = []
  global.barrels = []
  global.guards = []
  global.labels = []
  global.heys = []
  
  local addBlock = function(column, row)
    local block = new Block(column, row)
    global.blocks.push(block)
  end
  
  local addBarrel = function(column, row)
    local barrel = new Barrel(column, row)
    global.barrels.push(barrel)
  end
  
  local addGuard = function(column, row, sight)
    local guard = new Guard(column, row, sight)
    global.guards.push(guard)
  end
  
  local addLabel = function(text, x, y)
    local label = object end
    label.text = text
    label.x = x
    label.y = y
    
    global.labels.push(label)
  end
  
  if global.level == 0 then
    spawn(3, 4)
    addBlock(7, 1)
    addBlock(7, 2)
    addBlock(7, 3)
    addBlock(7, 4)
    addBlock(7, 5)
    addBlock(7, 6)
    addBlock(7, 7)
    addGuard(12, 4, 260)
    addLabel("Mouse to Aim, Click to Shoot", 0, 80)
  elsif global.level == 1 then
    spawn(3, 4)
    addBarrel(7, 0)
    addBarrel(7, 2)
    addBarrel(7, 3)
    addBarrel(7, 4)
    addBarrel(7, 5)
    addBarrel(7, 6)
    addBarrel(7, 8)
    addGuard(12, 4, 260)
    addLabel("WASD or Arrow Keys to Move", 0, 80)
    addLabel("Do not try to shoot the toxic barrels.", 0, -80)
  elsif global.level == 2 then
    spawn(3, 7)
    addBlock(6, 5)
    addBlock(15, 3)
    addBlock(14, 2)
    addBlock(11, 4)
    addBarrel(4, 3)
    addBarrel(2, 5)
    addBarrel(4, 8)
    addBarrel(9, 7)
    addBarrel(11, 5)
    addBarrel(14, 2)
    addGuard(12, 4, 300)
    addGuard(2, 2, 180)
  elsif global.level == 3 then
    spawn(11, 2)
    addBlock(9, 5)
    addBlock(10, 5)
    addBlock(11, 5)
    addBlock(12, 5)
    addBlock(13, 5)
    addBlock(14, 5)
    addBlock(15, 5)
    addBarrel(5, 8)
    addBarrel(5, 7)
    addBarrel(5, 6)
    addBarrel(5, 5)
    addBarrel(5, 4)
    addBarrel(5, 3)
    addBarrel(5, 2)
    addBarrel(5, 1)
    addGuard(1, 4, 180)
    addGuard(3, 2, 220)
    addGuard(10, 7, 180)
  elsif global.level == 4 then
    spawn(8, 4)
    addBarrel(13, 7)
    addBarrel(13, 1)
    addBarrel(2, 1)
    addBarrel(2, 7)
    addGuard(0, 0, 380)
    addGuard(0, 8, 380)
    addGuard(15, 0, 380)
    addGuard(15, 8, 380)
  end
end

global.init = function()
  audio.playMusic("music", 1, true)
  
  global.clock = new Clock()
  global.level = 0
  global.levels = 5
  global.setupLevel()
  global.shake = 0
  global.booms = []
  
  global.transition = 0
  global.transitionInned = function() end
  global.transitionOuted = function() end
  global.s = 0
end

global.update = function()
  global.shake *= 0.9
  global.direction = random.nextInt(360)
  global.position = [
    global.shake * cos(global.direction),
    global.shake * sin(global.direction)
  ]
  
  for boom in global.booms
    boom.update()
    
    if boom.particles.length == 0 then
      global.booms.removeElement(boom)
    end
  end
  
  global.float = [cosd(global.clock.currentTime * 200), sind(global.clock.currentTime * 500)]
  if not (global.level == global.levels) then global.clock.tick() end
  
  if global.transition then
    global.s += global.transition * 2
    if global.s == 100 then
      global.transition = -1
      global.transitionInned()
      global.transitionInned = function() end
    elsif global.s == 0 then
      global.transition = 0
      global.transitionOuted()
      global.transitionOuted = function() end
    end
    
    return
  end
  
  for hey in global.heys
    hey.y += hey.jump
    hey.jump -= 0.1
    
    hey.alpha -= 0.1
    if hey.alpha <= 0 then
      global.heys.removeElement(hey)
    end
  end
  
  local horizontal = keyboard.RIGHT - keyboard.LEFT
  local vertical = keyboard.UP - keyboard.DOWN
  
  if global.level == global.levels then
    horizontal = 0
    vertical = 0
  end
  
  global.flip = if horizontal then horizontal else flip end
  
  local diagonal = if horizontal and vertical then sqrt(2) else 1 end
  global.vx += horizontal * 1.2 / diagonal
  global.vy += vertical * 1.2 / diagonal
  global.vx *= 0.7
  global.vy *= 0.7
  
  local movementDelegate = object end
  movementDelegate.x = global.x
  movementDelegate.y = global.y
  global.move(movementDelegate, global.vx, global.vy, false)
  global.x = movementDelegate.x
  global.y = movementDelegate.y
  
  if global.level == global.levels then return end
  
  global.calculateTrajectory()
  for guard in global.guards guard.update() end
  
  if mouse.press then
    audio.playSound("laser")
    global.shake = max(shake, 8)
    
    for guard in global.guards
      if global.laserCollision(guard.x, guard.y, true) then
        global.createExplosion(guard.x, guard.y, 10)
        global.guards.removeElement(guard)
        audio.playSound("hit")
      end
    end
    
    local survived = true
    
    if global.laserCollision(global.x, global.y, false) then
      global.createExplosion(global.x, global.y, 10)
      global.transitionInned = global.setupLevel
      global.transition = 1
      survived = false
    end
    
    if not (global.gonnaExplode.length == 0) then
      audio.playSound("boom")
      
      global.transitionInned = global.setupLevel
      global.transition = 1
      survived = false
      
      for gonna in global.gonnaExplode
        global.createExplosion(global.c2p(gonna.column), global.r2p(gonna.row), 20)
      end
    end
    
    if survived and global.guards.length == 0 then
      global.transition = 1
      global.transitionInned = function()
        global.level += 1
        global.setupLevel()
      end
    end
  end
end

global.draw = function()
  local scale = screen.height / 360
  
  screen.clear(333)
  screen.setScale(scale, scale)
  screen.setTranslation(global.position[0], global.position[1])
  
  // 640 by 360 Units
  
  for column = -1 to 16
    for row = -1 to 9
      screen.drawSprite("floor_tile", global.c2p(column), global.r2p(row), 40, 40)
    end
  end
  
  if global.level == global.levels then
    local text = global.millisecondsFormat(global.clock.elapsedTime * 1000)
  
    screen.setLineWidth(8)
    screen.drawTextOutline(text, 0, 140, 20, "#242424")
    screen.drawText(text, 0, 140, 20, "#b8d14a")
    screen.setLineWidth(1)
  
    screen.setLineWidth(20)
    screen.drawTextOutline("Thank you for playing!", 0, 0, 60, "#242424")
    screen.drawText("Thank you for playing!", 0, 0, 60, "#b8d14a")
    screen.setLineWidth(1)
    return
  end
  
  for barrel in global.barrels barrel.drawShadow() end
  for guard in global.guards guard.drawShadow() end
  screen.fillRound(x, y - 20, 40, 20, "#00000099")
  
  for block in global.blocks block.draw() end
  for barrel in global.barrels barrel.draw() end
  for guard in global.guards guard.draw() end
  
  screen.setLineWidth(4)
  screen.setLineDash([2, 8])
  screen.drawPolyline(points.flat(), "#e5ff0099")
  screen.setLineDash([0, 0])
  screen.setLineWidth(1)
  
  local state = if abs(global.vx) + abs(global.vy) < 1 then "idling" else "running" end
    
  screen.setDrawScale(global.flip, 1)
  screen.drawSprite("hazmat_guy_" + state, global.x, global.y, 40, 40)
  screen.drawSprite("indicator", global.x + global.float[0], global.y + global.float[1] + 40, 20, 20)
  screen.setDrawScale(1, 1)
  
  for hey in global.heys
    screen.setAlpha(hey.alpha)
    screen.drawSprite("hey", hey.x, hey.y, 16, 32)
    screen.setAlpha(1)
  end
  
  for label in global.labels
    screen.setLineWidth(8)
    screen.drawTextOutline(label.text, label.x, label.y, 20, "#242424")
    screen.drawText(label.text, label.x, label.y, 20, "#b8d14a")
    screen.setLineWidth(1)
  end
  
  local text = global.millisecondsFormat(global.clock.elapsedTime * 1000)
  
  screen.setLineWidth(8)
  screen.drawTextOutline(text, 0, 140, 20, "#242424")
  screen.drawText(text, 0, 140, 20, "#b8d14a")
  screen.setLineWidth(1)
  
  screen.setTranslation(0, 0)
  screen.setScale(1, 1)
  
  for boom in global.booms boom.draw() end
  
  screen.setScale(4, 4)
  local w1 = screen.width / -8
  local w2 = screen.width / 8
  local h1 = screen.height / -8
  local h2 = screen.height / 8
  screen.fillPixelRect(w1, h1, global.s, global.s, 45, "#242424")
  screen.fillPixelRect(w1, h2, global.s, global.s, 45, "#242424")
  screen.fillPixelRect(w2, h1, global.s, global.s, 45, "#242424")
  screen.fillPixelRect(w2, h2, global.s, global.s, 45, "#242424")
  screen.setScale(1, 1)
end

