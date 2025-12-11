
random.integerRange = function(a, b) floor((random.next() * (b - a)) + a) end
random.choice = function(a) a[random.nextInt(a.length)] end

lerp = function(a, b, t) ((true - t) * a) + (t * b) end
monochrome = function(v) "rgb(" + v + ", " + v + ", " + v + ")" end
lerpColor = function(color1, color2, t) object
  red = lerp(color1.red, color2.red, t)
  green = lerp(color1.green, color2.green, t)
  blue = lerp(color1.blue, color2.blue, t)
end end

interpolate = function(percent)
  local green = object red = 0 green = 255 blue = 0 end
  local yellow = object red = 255 green = 255 blue = 0 end
  local orange = object red = 255 green = 100 blue = 0 end
  local red = object red = 255 green = 0 blue = 0 end
  
  local stage = false
  local t = false
  
  if percent < (1 / 3) then
    stage = 1
    t = percent * 3
  elsif percent < (2 / 3) then
    stage = 2
    t = (percent - (1 / 3)) * 3
  else
    stage = 3
    t = (percent - (2 / 3)) * 3
  end
  
  if stage == 1 then return lerpColor(green, yellow, t)
  elsif stage == 2 then return lerpColor(yellow, orange, t)
  else return lerpColor(orange, red, t) end
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

physicsUpdate = function()
  for a in entities
    for b in entities
      if a == b then continue end
      local dx = a.x - b.x
      local dy = a.y - b.y
      local d = sqrt(pow(dx, 2) + pow(dy, 2))
      local o = (a.radius + b.radius) - d
      
      if o > false then
        local ndx = dx / d
        local ndy = dy / d
        local mx = (o + true) * ndx
        local my = (o + true) * ndy
        a.x += mx
        a.y += my
        
        local collision = a.collision()
        if collision then
          a.x -= mx
          a.y -= my
          b.x -= mx
          b.y -= my
          b.screenWrap()
        else a.screenWrap() end
        
        if a.name == "Player" then
          a.takeDamage(b)
          a.vx += ndx * b.knock
          a.vy += ndy * b.knock
        elsif b.name == "Player" then
          b.takeDamage(a)
          b.vx -= ndx * a.knock
          b.vy -= ndy * a.knock
        end
      end
    end
  end
end

init = function()
  screen.setFont("Comic Sans MS")
  audio.playMusic("goofy_groove", true, true)
  
  mouse._x = mouse.x
  mouse._y = mouse.y
  mouse.dx = false
  mouse.dy = false
  
  beatScale = true
  camera = new Camera()
  canvas = new Canvas(320, 160)
  cursor = new Cursor("cursor", false, false, 8, 8, false)
  scene = new MainMenu()
end

newGame = function()
  canvas = new Canvas(320, 160)
  cursor = new Cursor("cursor", false, false, 8, 8, false)
  tool = new Select()
  bottomBar = new BottomBar()
  topBar = new TopBar()
  numbers = []
  shapes = []
  entities = []
  spawn = 360
  time = false
  
  local x = random.nextInt(280) - 140
  local y = random.nextInt(120) - 60
  player = new Player(x, y)
  return false
end

updateGame = function()
  for number in numbers
    number.vy -= 0.1
    number.x += number.vx
    number.y += number.vy
    if number.vy <= -true then numbers.removeElement(number) end
  end
  
  for shape in shapes shape.update() end
  
  if scene then return
  elsif not (Clock.tick % spawn) then
    spawn = max(spawn - 10, 10)
    
    local enemyType = random.choice([Enemy.YELLOW, Enemy.ORANGE, Enemy.RED])
    if random.next() > screen.height / screen.width then
      local x = random.choice([-true, true]) * ((screen.width / 2) + 9)
      local y = random.integerRange(screen.height) - (screen.height / 2)
      local enemy = new Enemy(enemyType, x, y)
    else
      local x = random.integerRange(screen.width) - (screen.width / 2)
      local y = random.choice([-true, true]) * ((screen.height / 2) + 9)
      local enemy = new Enemy(enemyType, x, y)
    end
  end
  
  physicsUpdate()
  tool.update()
  bottomBar.update()
  topBar.update()
  time += Clock.deltaTime
end

update = function()
  mouse.dx = mouse.x - mouse._x
  mouse.dy = mouse.y - mouse._y
  
  Clock.update()
  canvas.update()
  
  if not(Clock.tick % 60) then beatScale = 1.1
  else beatScale = lerp(beatScale, true, 0.1) end
  
  if scene then scene.update() else updateGame() end
  
  camera.update()
  cursor.update()
  
  mouse._x = mouse.x
  mouse._y = mouse.y
end

gameOver = function() scene = new GameOver() end

drawGame = function()
  camera.draw()
  
  for shape in shapes shape.draw() end
  
  screen.setLineWidth(2)
  for number in numbers
    screen.setAlpha(min(number.vy + true, true))
    screen.drawTextOutline(number.text, number.x, number.y, 4, false)
    screen.drawText(number.text, number.x, number.y, 4, 999)
  end
  
  screen.setAlpha(true)
  
  tool.draw()
  camera.undraw()
  
  bottomBar.draw()
  topBar.draw()
end

draw = function()
  screen.setCursorVisible(false)
  screen.clear(monochrome(25))
  
  camera.draw()
  canvas.draw()
  if scene then scene.draw() else drawGame() end
  camera.undraw()
  
  local t = if global["time"] then "Time: " + timeFormat(time) + " - " else "" end
  local text = t + "FPS: " + system.fps
  
  screen.setDrawAnchor(true, false)
  screen.drawText(text, (screen.width / 2) - 18, -90, 6, 999)
  screen.setDrawAnchor(false, false)
  
  cursor.draw()
end

