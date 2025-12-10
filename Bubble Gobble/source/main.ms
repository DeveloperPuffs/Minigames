
// Time used: 2h 56m 55s

random.choice = function(a) a[random.nextInt(a.length)] end
random.shuffle = function(c)
  c.sortList(function(a, b) random.next() - 0.5 end)
end

reset = function()
  depth = 0
  air = 1
  _air = 1
  
  x = 0
  y = 0
  a = 0
  
  vx = 0
  vy = 0
  can = true
  
  count = 0
  bubbles = []
  fizzes = []
  creatures = []
  
  stretch = 1
  squash = 1
  roll = 0
  
  camera = 0
end

gameOver = function()
  state = "Game Over"
  audio.playSound("hit", 1)
  
  local score = floor(camera / -16)
  if score > highscore then
    highscore = score
    storage.set("highscore", score)
  end
end

init = function()
  audio.playMusic("bubble_gobble", 0.2, true)
  asset_manager.loadFont("font")
  screen.setFont("font")
  highscore = storage.get("highscore")
  tick = 0
  state = "Main Menu"
  reset()
end

update = function()
  tick += 1
  
  if state == "Main Menu" then
    if mouse.press then
      audio.playSound("click", 0.5)
      state = "Game"
    end
    return
  elsif state == "Game Over" then
    if mouse.press then
      audio.playSound("click", 0.5)
      state = "Main Menu"
      reset()
    end
    return
  end
  
  air -= 0.0005
  _air += (air - _air) * 0.1
  
  stretch = 1 - (cos((tick + 30) / 30) / 8)
  squash = 1 - (cos(tick / 30) / 8)
  roll = sin(tick / 48) * 2
  
  if mouse.press and can then
    audio.playSound("whoosh", 0.02)
    can = false
    air -= 0.1
    after 0.2 seconds do can = true end
    
    vx += cosd(a) * 2
    vy += sind(a) * 2
  end
  
  vx *= 0.98
  vy *= 0.98
  
  x += vx
  y += vy
  
  if vx < 0 then
    if x + 8 < screen.width / -2 then
      x = (screen.width / 2) + 8
    end
  end
  
  if vx > 0 then
    if x - 8 > screen.width / 2 then
      x = (screen.width / -2) - 8
    end
  end
  
  y -= 1
  
  a = atan2d(mouse.y - (y - camera), mouse.x - x)
  
  for bubble in bubbles
    if bubble.y - camera > (bubble.radius * 2) + (screen.height / 2) then
      bubbles.removeElement(bubble)
      continue
    end
    
    if bubble.pop then
      bubble.pop += 0.05
      if bubble.pop >= 1 then bubbles.removeElement(bubble) end
      continue
    end
    
    local distance = sqrt(pow(bubble.x - x, 2) + pow(bubble.y - y, 2))
    if distance < bubble.radius + 8 then
      audio.playSound("bubble", 0.5)
      bubble.pop += 0.05
      air = 1
    end
  end
  
  if not (tick % 8) and random.next() < 0.8 then
    fizz = object end
    fizz.x = x + (random.next() * 12) - 6
    fizz.y = y
    fizz.vx = 0
    fizz.vy = 0
    fizz.pop = 0.2
    fizz.radius = 1 + random.next()
    fizzes.push(fizz)
  end
  
  for fizz in fizzes
    fizz.pop += 0.01
    if fizz.pop >= 1 then
      fizzes.removeElement(fizz)
      continue
    end
    
    fizz.vy += 0.02
    
    fizz.vx *= 0.95
    fizz.vy *= 0.95
    
    fizz.x += fizz.vx
    fizz.y += fizz.vy
  end
  
  if y < camera - 20 then
    distance = y - camera
    camera += distance * 0.03
    
    if (camera / -50) > count then
      count += 1
      
      local bubble = object end
      bubble.radius = 20 + (random.next() * 10)
      bubble.pop = 0
      
      position = false
      while not position
        position = [
          (random.next() * screen.width) - (screen.width / 2)
          camera - 200 + random.nextInt(100) - 50
        ]
        
        intersection = false
        for o in bubbles
          if sqrt(
            pow(o.x - position[0], 2) + pow(o.y - position[1], 2)
          ) < bubble.radius + o.radius then
            intersection = true
            break
          end
        end
        
        if intersection then position = false end
      end
      
      bubble.x = position[0]
      bubble.y = position[1]
      bubbles.push(bubble)
      
      local creature = object end
      creature.x = (screen.width / 2) - position[0]
      creature.y = position[1]
      
      local data = random.choice([
        ["lunker", 64, 32, 0.1],
        ["fish", 32, 16, 0.2],
        ["fishling", 16, 8, 0.5],
        ["fishy", 16, 8, 1],
        ["fry", 8, 8, 2]
      ])
      
      creature.name = data[0]
      creature.width = data[1]
      creature.height = data[2]
      creature.beat = 1
      
      local r = random.next()
      local a = r * (1 / 3)
      local b = (r + 1) * (1 / 3)
      local c = (r + 2) * (1 / 3)
      local components = [a, b, c]
      random.shuffle(components)
      creature.color = (
        "rgb(" +
        min(components[0] * 500, 255) + ", " +
        min(components[1] * 500, 255) + ", " +
        min(components[2] * 500, 255) + ")"
      )
      
      creature.flip = ((random.next() > 0.5) * 2) - 1
      creature.speed = creature.flip * data[3]
      creatures.push(creature)
    end
  end
  
  for creature in creatures
    if creature.y - camera > creature.width + (screen.height / 2) then
      creatures.removeElement(creature)
      continue
    end
    
    creature.beat += ((1 - creature.beat) * 0.05)
    creature.x += creature.speed
    local w = creature.width / 2
    
    if creature.speed < 0 then
      if creature.x + w < screen.width / -2 then
        creature.x = (screen.width / 2) + w
      end
    end
    
    if creature.speed > 0 then
      if creature.x - w > screen.width / 2 then
        creature.x = (screen.width / -2) - w
      end
    end
    
    if not (tick % 60) then creature.beat = 1.1 end
    if not (tick % 8) and random.next() < 0.8 then
      local o = (
        (random.next() * creature.width * 0.75) - (creature.width - 0.375)
      )
      
      fizz = object end
      fizz.x = creature.x + o
      fizz.y = creature.y
      fizz.vx = 0
      fizz.vy = random.next() * 4
      fizz.pop = 0.2
      fizz.radius = 1 + random.next()
      fizzes.push(fizz)
    end
    
    if (
      creature.x - (creature.width / 2) < x + 8 and
      creature.x + (creature.width / 2) > x - 8 and
      creature.y - (creature.height / 2) < y + 8 and
      creature.y + (creature.height / 2) > y - 8
    ) then
      gameOver()
      return
    end
  end
  
  air = min(max(air, 0), 1)
  if not air then gameOver() end
end

draw = function()
  if state == "Main Menu" then
    screen.clear("rgb(127, 219, 255)")
    
    local s = sin(tick / 10)
    local c = cos(tick / 20)
    
    screen.setDrawScale(1 + (sin(tick / 20) / 10), 1 + (cos(tick / 20) / 10))
    screen.setLineWidth(16)
    screen.setDrawRotation(c)
    screen.drawTextOutline("Bubble Gobble", 0, s, 32, "rgb(0, 31, 51)")
    screen.drawText("Bubble Gobble", 0, c, 32, 999)
    screen.setLineWidth(1)
    screen.setDrawScale(1, 1)
    screen.setDrawRotation(0)
    
    local s = "Your highscore is: " + highscore + "m"
    screen.setLineWidth(4)
    screen.drawTextOutline(s, 0, -60, 8, "rgb(0, 31, 51)")
    screen.drawText(s, 0, -60, 8, 999)
    screen.setLineWidth(1)
    
    local help = "Controls and Description in the Project Description."
    screen.setLineWidth(4)
    screen.drawTextOutline(help, 0, -70, 8, "rgb(0, 31, 51)")
    screen.drawText(help, 0, -70, 8, 999)
    screen.setLineWidth(1)
    
    local play = "Click Anywhere on the Screen to Play!"
    screen.setLineWidth(4)
    screen.drawTextOutline(play, 0, -80, 8, "rgb(0, 31, 51)")
    screen.drawText(play, 0, -80, 8, 999)
    screen.setLineWidth(1)
    return
  elsif state == "Game Over" then
    local color = waterColor(camera / -9999)
    screen.clear("rgb(" + color[0] + ", " + color[1] + ", " + color[2] + ")")
    
    local s = sin(tick / 10)
    local c = cos(tick / 20)
    
    screen.setDrawScale(1 + (sin(tick / 20) / 10), 1 + (cos(tick / 20) / 10))
    screen.setLineWidth(16)
    screen.setDrawRotation(c)
    screen.drawTextOutline("Game Over!", 0, s, 32, "rgb(0, 31, 51)")
    screen.drawText("Game Over!", 0, c, 32, 999)
    screen.setLineWidth(1)
    screen.setDrawScale(1, 1)
    screen.setDrawRotation(0)
    
    local s = "Your highscore is: " + highscore + "m"
    screen.setLineWidth(4)
    screen.drawTextOutline(s, 0, -60, 8, "rgb(0, 31, 51)")
    screen.drawText(s, 0, -60, 8, 999)
    screen.setLineWidth(1)
    
    local score = "Your score is: " + floor(camera / -16) + "m!"
    screen.setLineWidth(4)
    screen.drawTextOutline(score, 0, -70, 8, "rgb(0, 31, 51)")
    screen.drawText(score, 0, -70, 8, 999)
    screen.setLineWidth(1)
    
    local proceed = "Click Anywhere on the Screen to Proceed."
    screen.setLineWidth(4)
    screen.drawTextOutline(proceed, 0, -80, 8, "rgb(0, 31, 51)")
    screen.drawText(proceed, 0, -80, 8, 999)
    screen.setLineWidth(1)
    return
  end
  
  local color = waterColor(camera / -9999)
  screen.clear("rgb(" + color[0] + ", " + color[1] + ", " + color[2] + ")")
  
  screen.setTranslation(0, -camera)
  screen.setRotation(roll)
  
  for o in creatures
    screen.setDrawScale(o.flip * o.beat, o.beat)
    local fill = new Image(o.width, o.height, true)
    fill.drawSprite(o.name + "/fill", 0, 0, o.width, o.height)
    fill.setBlending('source-in')
    fill.fillRect(0, 0, o.width, o.height, o.color)
    screen.drawImage(fill, o.x, o.y, o.width, o.height)
    screen.drawSprite(o.name + "/outline", o.x, o.y, o.width, o.height)
    screen.setDrawScale(1, 1)
  end
  
  screen.setDrawRotation(a - 90)
  screen.drawSprite(sprites["player"].frames[can] x, y, 16, 16)
  screen.setDrawRotation(0)
  
  for o in bubbles + fizzes
    local size = o.radius * 2
    screen.setAlpha(1 - o.pop)
    screen.setDrawScale(1 + o.pop, 1 + o.pop)
    screen.setAlpha((1 - o.pop) / 5)
    screen.fillRound(o.x, o.y, size * stretch, size * squash, 999)
    screen.setAlpha(1 - o.pop)
    screen.drawRound(o.x, o.y, size * stretch, size * squash, 999)
    screen.setDrawScale(1, 1)
    screen.setAlpha(1)
  end
  
  screen.setRotation(0)
  screen.setTranslation(0, 0)
  
  screen.setAlpha(0.4)
  screen.setDrawAnchor(-1, 0)
  screen.fillRect(-170, 80, 340 * _air, 20, 999)
  screen.setDrawAnchor(0, 0)
  screen.setAlpha(1)
  
  screen.setLineWidth(2)
  screen.drawRect(0, 80, 340, 20, "rgb(0, 31, 51)")
  screen.setLineWidth(1)
  
  screen.setLineWidth(4)
  local airText = "Air: " + round(air * 100) + "%"
  screen.drawTextOutline(airText, 0, 80, 8, "rgb(0, 31, 51)")
  screen.drawText(airText, 0, 80, 8, 999)
  screen.setLineWidth(4)
  
  screen.setLineWidth(8)
  screen.setDrawAnchor(-1, -1)
  local x = (screen.width / -2) + 8
  local y = (screen.height / -2) + 8
  local depthText = "Depth: " + floor(camera / -16) + "m"
  screen.drawTextOutline(depthText, x, y, 16, "rgb(0, 31, 51)")
  screen.drawText(depthText, x, y, 16, 999)
  screen.setDrawAnchor(0, 0)
  screen.setLineWidth(1)
end

lerp = function(a, b, t) a + ((b - a) * t) end
lerpColor = function(color1, color2, t)
  [
    lerp(color1[0], color2[0], t),
    lerp(color1[1], color2[1], t),
    lerp(color1[2], color2[2], t)
  ]
end

waterColor = function(depth)
  depth = min(max(depth, 0), 1)
  
  local lightAqua = [127, 219, 255]
  local aqua = [0, 116, 217]
  local deepAqua = [0, 31, 63]
  local navyBlue = [0, 31, 51]

  local stage = false
  local t = false

  if depth < (1 / 3) then
    stage = 1
    t = depth * 3
  elsif depth < (2 / 3) then
    stage = 2
    t = (depth - (1 / 3)) * 3
  else
    stage = 3
    t = (depth - (2 / 3)) * 3
  end

  if stage == 1 then return lerpColor(lightAqua, aqua, t)
  elsif stage == 2 then return lerpColor(aqua, deepAqua, t)
  else return lerpColor(deepAqua, navyBlue, t) end
end

