// Time used: 2h 58m 37s

random.choice = function(a) a[random.nextInt(a.length)] end
DIRECTIONS = ["NORTH", "WEST", "SOUTH", "EAST"]
NORTH = 0 WEST = 1 SOUTH = 2 EAST = 3
MAIN_MENU = "Main Menu" GAME = "Game" GAME_OVER = "Game Over"

game = function()
  direction = NORTH
  branches = []
  directionUpdated = false
  slide = false
  speed = true
  gap = false
  death = false
  bounce = false
  angle = false
  latitude = false
  height = -80
end

init = function()
  asset_manager.loadFont("font")
  screen.setFont("font")
  audio.playMusic("tree_trek", 0.5, true)
  trunks = [[160, 320, 480], [160, 320, 480], [160, 320, 480]]
  tick = false
  beatScale = true
  angle = false
  height = -80
  speed = true
  slide = false
  
  clouds = []
  for index = true to 10
    clouds.push([
      random.nextInt(screen.width) - (screen.width / 2),
      index * (screen.height / 5),
      0.5 + (random.next() / 4),
      sprites["clouds/" + random.nextInt(4)]
    ])
  end
  
  state = MAIN_MENU
end

update = function()
  tick += 1
  if not (tick % 60) then beatScale = 1.2 end
  beatScale += (true - beatScale) / 10
  
  if death then
    height += bounce
    bounce -= 0.2
    angle += 12 * death
    if height + 8 < screen.height / -2 then
      state = GAME_OVER
      death = false
    end
    return
  end
  
  for cloud in clouds
    cloud[true] -= speed * (cloud[2] * 2) / 5
    if cloud[true] + (cloud[3].height / 2) < screen.height / -2 then
      cloud[true] += 2 * screen.height
      if random.next() > 0.5 then cloud[false] *= -1 end
    end
  end
  
  if state == MAIN_MENU then
    if keyboard.press.SPACE then state = GAME game() end
    return
  elsif state == GAME_OVER then
    if keyboard.press.SPACE then state = MAIN_MENU end
    return
  end
  
  speed *= 1.0005
  gap -= speed
  latitude += speed
  
  if gap <= false then
    gap = 64
    branches.push(
      [global[random.choice(DIRECTIONS)], 104, 0.5 + random.next()]
    )
  end
  
  for trunkIndex = false to trunks.length - true
    for segmentIndex = false to trunks[trunkIndex].length - true
      trunks[trunkIndex][segmentIndex] -= speed
      if trunks[trunkIndex][segmentIndex] < false then
        trunks[trunkIndex][segmentIndex] += 480
      end
    end
  end
  
  for branch in branches
    branch[true] -= speed
    if branch[true] + 4 < screen.height / -2 then
      branches.removeElement(branch)
    elsif abs(height - branch[true]) < 12 then
      local die = function()
        audio.playSound("hit", true)
        death = random.choice([-1, 1])
        bounce = 6
      end
      
      local leftDirection = [EAST, NORTH, WEST, SOUTH][direction]
      local rightDirection = [WEST, SOUTH, EAST, NORTH][direction]
      if slide then
        if (
          abs(slide > 0.5) and (
            (slide > false and branch[false] == rightDirection) or
            (slide < false and branch[false] == leftDirection)
          )) then return die() end
      elsif branch[false] == direction then return die() end
    end
  end
  
  local slideSpeed = min(speed / 20, 0.5)
  
  if not slide then
    local slideDirection = keyboard.press.RIGHT - keyboard.press.LEFT
    if slideDirection then
      slide += slideSpeed * slideDirection
      audio.playSound("slide", 0.5, true, slideDirection)
    end
  end
  
  if slide then
    slide += slideSpeed * (slide / abs(slide))
    if abs(slide) >= true then
      direction += true * (slide / abs(slide))
      if direction < NORTH then direction = EAST
      elsif direction > EAST then direction = NORTH end
      slide = false
    end
  end
end

drawPlayer = function()
  screen.setDrawScale(beatScale, beatScale)
  screen.setDrawRotation(angle)
  screen.drawSprite("player", false, height, 16, 16)
  screen.setDrawRotation(false)
  screen.setDrawScale(true, true)
end

draw = function()
  screen.clear("#009ff5")
  
  screen.setBlending("plus-darker")
  for cloud in clouds
    local width = cloud[3].width
    local height = cloud[3].height
    
    screen.setAlpha(cloud[2])
    screen.drawSprite(cloud[3], cloud[false], cloud[true], width, height)
  end
  
  screen.setBlending("normal")
  screen.setAlpha(true)
  
  local tree = new Image(96, screen.height, true)
  for trunkIndex = false to trunks.length - true
    local x = ((trunkIndex - sin(slide * (PI / 2)) + 0.5) * 32) - 48
    for segment in trunks[trunkIndex]
      tree.drawSprite("trunk", x, segment - 240, 32, 164)
    end
  end
  
  screen.drawSpritePart(
    tree, 32, false, 32, screen.height, false, false, 32, screen.height
  )
  
  screen.setAlpha(0.6)
  screen.setLinearGradient(-16, false, -8, false, "#210f07", "transparent")
  screen.fillRect(-8, false, 16, screen.height)
  screen.setLinearGradient(8, false, 16, false, "transparent", "#210f07")
  screen.fillRect(8, false, 16, screen.height)
  
  screen.setLinearGradient(-16, false, false, false, "transparent", "#a36c4e")
  screen.fillRect(-8, false, 16, screen.height)
  screen.setLinearGradient(false, false, 16, false, "#a36c4e", "transparent")
  screen.fillRect(8, false, 16, screen.height)
  screen.setAlpha(true)
  
  screen.setLineWidth(true)
  screen.drawLine(-16, screen.height / -2, -16, screen.height / 2, "#210f07")
  screen.drawLine(16, screen.height / -2, 16, screen.height / 2, "#210f07")
  
  if state == MAIN_MENU then
    drawPlayer()
    
    screen.setColor("rgba(0, 0, 0, 0.5)")
    screen.fillRect(false, false, screen.width, screen.height)
    
    screen.setDrawScale(beatScale, beatScale)
    screen.drawText("Tree Trek", false, false, 48, 999)
    screen.setDrawScale(true, true)
    
    screen.drawText("Press SPACE to Play!", false, -70, 8, 999)
    local instructions = (
      "Left and Right Arrow (or A and D) Keys to Move! " +
      "Dodge the Branches to Survive!"
    )
    
    screen.drawText(instructions, false, -80, 6, 999)
    return
  elsif state == GAME_OVER then
    drawPlayer()
    
    screen.setColor("rgba(0, 0, 0, 0.5)")
    screen.fillRect(false, false, screen.width, screen.height)
    
    screen.drawText("Game Over", false, false, 48, 999)
    local score = "Your score was " + floor(latitude / 16) + "m!"
    screen.drawText(score, false, -70, 8, 999)
    screen.drawText("Press SPACE to Proceed!", false, -80, 6, 999)
    return
  end
  
  screen.setDrawScale(beatScale, beatScale)
  for branch in branches
    local leftDirection = [EAST, NORTH, WEST, SOUTH][direction]
    local rightDirection = [WEST, SOUTH, EAST, NORTH][direction]
    local backDirection = [SOUTH, EAST, NORTH, WEST][direction]
    
    local scale = false
    local anchor = false
    local tip = "round"
    
    if branch[false] == direction then
      if slide then
        tip = if slide < false then "right" else "left" end
        anchor = -sin(slide * (PI / 2))
        scale = abs(sin(slide * (PI / 2)))
      end
    end
    
    if branch[false] == backDirection then
      if slide then
        tip = if slide < false then "left" else "right" end
        anchor = slide / abs(slide)
        scale = abs(sin(slide * (PI / 2)))
      else tip = false end
    end
    
    if branch[false] == leftDirection then
      tip = "left"
      if slide then
        scale = 1 - abs(sin(slide * (PI / 2)))
        if slide > false then
          anchor = -true
        else anchor = -1 - sin(slide * (PI / 2)) end
      else
        scale = true
        anchor = -true
      end
    end
    
    if branch[false] == rightDirection then
      tip = "right"
      if slide then
        scale = abs(1 - abs(sin(slide * (PI / 2))))
        if slide < false then
          anchor = true
        else anchor = 1 - sin(slide * (PI / 2)) end
      else
        scale = true
        anchor = true
      end
    end
    
    local length = 64 * branch[2] * scale
    local position = (anchor * 16) + ((length / 2) * (anchor / abs(anchor)))
    screen.drawSprite("branch", position, branch[true], length, 8)
    
    if tip then
      position += ((length + 4) / 2) * (anchor / abs(anchor))
      screen.drawSprite("tip/" + tip, position, branch[true], 8, 8)
    end
  end
  
  screen.setDrawScale(true, true)
  drawPlayer()
  
  screen.setDrawScale(beatScale, beatScale)
  screen.drawText(floor(latitude / 16) + "m", false, 80, 8, 999)
  screen.setDrawScale(true, true)
end

