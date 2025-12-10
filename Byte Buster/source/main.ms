
/*
First Shift ~ 1h 10min
Second Shift ~ 1h 5min
Third Shift ~ 45min

Sprites made using Pixilart
Font made using PixelForge
Music made using BeepBox
Sounds made using Jsfxr
*/

formatNumber = function(number, precision)
  local rawString = "" + number
  local trimmedString = ""
      
  local dotFound = false
  local charactersAfterDot = 0
  for character in rawString
    if character == "." then
      dotFound = true
    elsif dotFound then
      if charactersAfterDot >= precision then
        return "~" + trimmedString
      else
        charactersAfterDot += 1
      end
    end
        
    trimmedString += character
  end
      
  return trimmedString
end

spaceFormat = function(megabytes)
  if megabytes < 1000 then
    return megabytes + "mb"
  elsif megabytes < 1000000 then
    return formatNumber(megabytes / 1000, 1) + "gb"
  else
    return formatNumber(megabytes / 1000000, 1) + "tb"
  end
end

timeFormat = function(time)
  if time > 3600 then return ">1h" end
  
  local seconds = floor(time % 60)
  local minutes = floor(time / 60)
  
  local secondsString = "" + seconds
  if secondsString.length == 1 then secondsString = "0" + secondsString end
  
  local minutesString = "" + minutes
  if minutesString.length == 1 then minutesString = "0" + minutesString end
  
  return minutesString + ":" + secondsString
end

init = function()
  asset_manager.loadFont("enchanted_echoes")
  while not screen.isFontReady("enchanted_echoes") sleep 1 end
  screen.setFont("enchanted_echoes")
  
  audio.playMusic("music", 1, true)
  
  tick = 0
  time = 0
  gameOver()
  gameState = 0
end

gameOver = function()
  gameState = 1
  
  totalSpace = 1000
  takenSpace = 0
  
  balance = 0
  
  player = object
    x = 0
    y = 0
    vx = 0
    vy = 0
    angle = 0
    radius = 8
    
    flip = 1
    life = 500
    action = "idle"
    
    shootCooldown = 30
    currentShootCooldown = 0
    bulletRadius = 2
  end
  
  bullets = []
  enemies = []
  coins = []
end

update = function()
  tick += 1
  
  if gameState == 0 then
    if keyboard.press.SPACE then
      audio.playSound("coin")
      gameState = 2
    end
    return
  elsif gameState == 1 then
    if keyboard.press.SPACE then
      audio.playSound("coin")
      time = 0
      tick = 0
      gameState = 0
    end
    return
  end
  
  time += 1 / system.fps
  
  if keyboard.press.DIGIT_1 then
    if balance < 20 then
      audio.playSound("nope")
      return
    end
    
    audio.playSound("coin")
    
    balance -= 20
    totalSpace += 500
  end
  
  if keyboard.press.DIGIT_2 then
    local price = if player.bulletRadius == 2 then 10 else 50 end
    if balance < price then
      audio.playSound("nope")
      return
    end
    
    audio.playSound("coin")
    
    balance -= price
    player.bulletRadius *= 2
  end
  
  local collisionCheck = function(a, b)
    local distance = sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2))
    return (distance <= a.radius + b.radius)
  end
  
  local screenClip = function(thing)
    if thing.vx < 0 and thing.x + thing.radius < (screen.width / -2) then
      thing.x = (screen.width / 2) + thing.radius
    end
    
    if thing.vx > 0 and thing.x - thing.radius > (screen.width / 2) then
      thing.x = (screen.width / -2) - thing.radius
    end
    
    if thing.vy < 0 and thing.y + thing.radius < (screen.height / -2) then
      thing.y = (screen.height / 2) + thing.radius
    end
    
    if thing.vy > 0 and thing.y - thing.radius > (screen.height / 2) then
      thing.y = (screen.height / -2) - thing.radius
    end
  end
  
  local xInput = (keyboard.RIGHT - keyboard.LEFT)
  local yInput = (keyboard.UP - keyboard.DOWN)
  
  player.flip = if xInput then xInput else player.flip end
  
  if xInput and yInput then
    xInput /= sqrt(2)
    yInput /= sqrt(2)
  end
  
  player.vx += xInput * 0.2
  player.vy += yInput * 0.2
  
  player.vx *= 0.9
  player.vy *= 0.9
  
  player.x += player.vx
  player.y += player.vy
  
  local speed = sqrt(pow(player.vx, 2) + pow(player.vy, 2))
  player.action = if round(speed) then "running" else "idle" end
  
  screenClip(player)
  
  local mx = player.x - mouse.x
  local my = player.y - mouse.y
  local angle = atan2d(mx, my)
  
  player.angle = angle
  player.currentShootCooldown = max(player.currentShootCooldown - 1, 0)
  
  if mouse.press and not player.currentShootCooldown then
    player.currentShootCooldown = player.shootCooldown
    
    local magnitude = sqrt(pow(mx, 2) + pow(my, 2))
    mx /= -magnitude
    my /= -magnitude
    
    bullets.push(object
      x = player.x
      y = player.y
      vx = mx * 3
      vy = my * 3
      punch = player.bulletRadius * 2
      damage = player.bulletRadius * (random.nextInt(5) + 5)
      radius = player.bulletRadius
      mask = 1
      sprite = "bullets/player/" + player.bulletRadius
      angle = player.angle
      torque = random.next() * 10
      life = ([2, 4, 8].indexOf(player.bulletRadius) + 1) * 60
      alpha = 1
    end)
  end
  
  if not (tick % 180) then
    local enemy = object
      x = 0
      y = 0
      vx = 0
      vy = 0
      radius = 8
      flip = 1
      life = random.nextInt(10) + round(10 * tick / 360)
      action = "idle"
    end
    
    local validPosition = false
    while not validPosition
      enemy.x = random.nextInt(screen.width) - (screen.width / 2)
      enemy.y = random.nextInt(screen.height) - (screen.height / 2)
      
      validPosition = sqrt(
        pow(enemy.x - player.x, 2) +
        pow(enemy.y - player.y, 2)
      ) > 32
    end
    
    enemies.push(enemy)
  end
  
  for enemy in enemies
    local targetPoints = []
    
    for row = -1 to 1
      targetPoints.push([])
      for column = -1 to 1
        local currentTargetPoint = object
          x = player.x + (column * screen.width)
          y = player.y + (row * screen.height)
        end
        
        currentTargetPoint.distance = sqrt(
          pow(currentTargetPoint.x - enemy.x, 2) +
          pow(currentTargetPoint.y - enemy.y, 2)
        )
        
        targetPoints[row + 1].push(currentTargetPoint)
      end
    end
    
    local targetPoint = 0
    for points in targetPoints
      for point in points
        if targetPoint then
          if point.distance < targetPoint.distance then
            targetPoint = point
          end
        else
          targetPoint = point
        end
      end
    end
    
    local dx = enemy.x - targetPoint.x
    local dy = enemy.y - targetPoint.y
    local magnitude = sqrt(pow(dx, 2) + pow(dy, 2))
    
    dx /= -magnitude
    dy /= -magnitude
    
    enemy.vx += dx * 0.2
    enemy.vy += dy * 0.2
    
    enemy.vx *= 0.8
    enemy.vy *= 0.8
    
    enemy.x += enemy.vx
    enemy.y += enemy.vy
    
    if enemy.x - targetPoint.x < 0 then enemy.flip = 1 end
    if enemy.x - targetPoint.x > 0 then enemy.flip = -1 end
    
    local speed = sqrt(pow(enemy.vx, 2) + pow(enemy.vy, 2))
    enemy.action = if round(speed) then "running" else "idle" end
    
    if collisionCheck(enemy, player) then
      audio.playSound("ouch")
      player.life -= 50
      
      if player.life <= 0 then
        gameOver()
      else
        player.vx = dx * 5
        player.vy = dy * 5
      end
    end
    
    screenClip(enemy)
  end
  
  for bullet in bullets
    bullet.x += bullet.vx
    bullet.y += bullet.vy
    
    bullet.angle += bullet.torque
    
    bullet.life -= 1
    if bullet.life <= 0 then
      bullets.removeElement(bullet)
      continue
    else
      bullet.alpha = min(bullet.life / 12, 1)
    end
    
    screenClip(bullet)
    
    local objects = if bullet.mask then enemies else [player] end
    
    for obj in objects
      if collisionCheck(obj, bullet) then
        audio.playSound("hit")
        obj.life -= bullet.damage
        
        if obj.life <= 0 then
          for _ = 0 to random.nextInt(6)
            local angle = random.nextInt(360)
            coins.push(object
              x = obj.x
              y = obj.y
              vx = cosd(angle)
              vy = sind(angle)
              radius = 4
            end)
          end
          
          objects.removeElement(obj)
          bullets.removeElement(bullet)
          break
        end
        
        local dx = obj.x - bullet.x
        local dy = obj.y - bullet.y
      
        local magnitude = sqrt(pow(dx, 2) + pow(dy, 2))
        obj.vx += (dx / magnitude) * bullet.punch
        obj.vy += (dy / magnitude) * bullet.punch
        
        bullets.removeElement(bullet)
        break
      end
    end
  end
  
  for coin in coins
    coin.vx *= 0.8
    coin.vy *= 0.8
    coin.x += coin.vx
    coin.y += coin.vy
    
    if collisionCheck(coin, player) then
      audio.playSound("coin")
      balance += 1
      coins.removeElement(coin)
    end
  end
  
  takenSpace = 0
  local hoggers = [player] + enemies
  for hogger in hoggers takenSpace += hogger.life end
  if takenSpace > totalSpace then gameOver() end
end

drawText = function(text, x, y, size)
  screen.setLineWidth(size / 2)
  screen.drawTextOutline(text, x, y, size, 0)
  screen.drawText(text, x, y, size, 999)
end

draw = function()
  screen.clear(666)
  
  if gameState == 0 then
    drawMainMenu()
    return
  elsif gameState == 1 then
    drawGameOver()
    return
  end
  
  for enemy in enemies
    screen.setDrawScale(enemy.flip, 1)
    screen.drawSprite("shadow", enemy.x, enemy.y - 8, 16, 4)
    screen.drawSprite("enemy/" + enemy.action, enemy.x, enemy.y, 16, 16)
    screen.setDrawScale(1, 1)
  end
  
  for coin in coins
    screen.drawSprite("coin", coin.x, coin.y, 8, 8)
  end
  
  screen.setDrawScale(player.flip, 1)
  screen.drawSprite("shadow", player.x, player.y - 8, 16, 4)
  screen.drawSprite("player/" + player.action, player.x, player.y, 16, 16)
  screen.setDrawScale(1, 1)
  
  for bullet in bullets
    local size = bullet.radius * 2
    
    screen.setAlpha(bullet.alpha)
    screen.setDrawRotation(bullet.angle)
    screen.drawSprite(bullet.sprite, bullet.x, bullet.y, size, size)
    screen.setDrawRotation(0)
    screen.setAlpha(1)
  end
  
  local hoggers = [player] + enemies
  for hogger in hoggers
    drawText(
      spaceFormat(hogger.life),
      hogger.x, hogger.y + 4 + hogger.radius,
      4, 999
    )
  end
  
  local text = (
    "Drive Space: " + spaceFormat(takenSpace) +
    "/" + spaceFormat(totalSpace)
  )
  
  local offset = screen.textWidth(text, 6) / 2
  drawText(
    text, (screen.width / -2) + 8 + offset,
    (screen.height / 2) - 20, 6
  )
  
  local text = "Balance: $" + balance
  local offset = screen.textWidth(text, 6) / 2
  drawText(
    text, (screen.width / 2) - 8 - offset,
    (screen.height / 2) - 20, 6
  )
  
  drawText(timeFormat(time), 0, (screen.height / 2) - 20, 8)
  
  local y = (screen.height / -2) + 12
  drawText("Press '1' to buy Drive Space: $20 for 500mb", 0, y, 6)
  
  if player.bulletRadius < 8 then
    local price = if player.bulletRadius == 2 then 10 else 50 end
      
    local y = (screen.height / -2) + 20
    drawText("Press '2' to Upgrade Bullets: $" + price, 0, y, 6)
  end
end

drawMainMenu = function()
  drawText("Byte Buster", 0, 20, 32 + sin(tick / 20))
  drawText("Press Space to Play", 0, (screen.height / -2) + 32, 8)
  drawText("Controls in Project Description", 0, (screen.height / -2) + 20, 6)
end

drawGameOver = function()
  local timeText = "You survived for: " + timeFormat(time)
  
  drawText("Game Over", 0, 20 + sin(tick / 20), 32)
  drawText(timeText, 0, (screen.height / -2) + 32, 6)
  drawText("Press Space to Proceed", 0, (screen.height / -2) + 20, 8)
end


