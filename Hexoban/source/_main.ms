
global.millisecondsFormat = function(milliseconds)
  local totalSeconds = floor(milliseconds / 1000)
  local hours = floor(totalSeconds / 3600)
  local minutes = floor((totalSeconds % 3600) / 60)
  local seconds = totalSeconds % 60
  
  local paddedMinutes = (if minutes < 10 then "0" else "" end) + minutes
  local paddedSeconds = (if seconds < 10 then "0" else "" end) + seconds
  
  return (if hours > 0 then hours + ":" else "" end) + paddedMinutes + ":" + paddedSeconds
end

GameState = object end
GameState.INTRODUCTION = "Introduction"
GameState.MAIN_MENU = "Main Menu"
GameState.PLAYING = "Playing"
GameState.VICTORY = "Victory"

global.restart = function(restarting = function() end)
  global.transition.go(function()
    restarting()
    global.turnCounter = 0
    global.moveCounter = 0
    global.tick = random.nextInt(60 * 360)
    global.beehive = new Beehive(global.levels[levelNumber - 1])
    global.gameState = GameState.PLAYING
  end)
end

global.nextLevel = function()
  if global.levelNumber == global.levels.length then
    global.transition.go(function() global.gameState = GameState.VICTORY end)
  else global.restart(function() global.levelNumber += 1 end) end
end

global.startGame = function()
  global.levels = global.loadLevels()
  global.startTime = system.time()
  global.currentTime = system.time()
  global.nextLevel()
end

global.init = function()
  asset_manager.loadFont("dangrek")
  screen.setFont("dangrek")
  audio.playMusic("hexoban", 0.25, true)
  
  global.tick = random.nextInt(60 * 360)
  
  global.gameState = GameState.INTRODUCTION
  global.transition = new Transition()
  global.introduction = new Introduction()
  global.levelNumber = 0
  
  after 500 do global.introduction.start() end
end

global.update = function()
  TweenService.update()
  
  if global.gameState == GameState.PLAYING then
    global.beehive.update()
    global.currentTime = system.time()
    
    if keyboard.press.Z then global.beehive.undo() end
    if keyboard.press.R then global.restart() end
  elsif global.gameState == GameState.MAIN_MENU then
    if keyboard.press.SPACE or mouse.press then
      audio.playSound("click", 1)
      global.startGame()
    end
  end
  
  global.tick += if global.levelNumber % 2 then 1 else -1 end
end

global.draw = function()
  screen.clear(Palette.brown)
  
  global.drawBackground(tick / 60)
  
  if global.gameState == GameState.PLAYING then global.beehive.draw() end
  
  if not (global.gameState == GameState.INTRODUCTION) and not (global.gameState == GameState.VICTORY) then
    screen.setDrawAnchor(0, 1)
    screen.drawText("Arrow Keys or WASD to Turn and Move - Z to Undo - R to Restart", 0, (screen.height / 2) - 4, 4, Palette.yellow)
    screen.setDrawAnchor(0, 0)
  end
  
  if global.gameState == GameState.PLAYING then
    screen.setDrawAnchor(-1, -1)
    screen.drawText("Moves: " + global.moveCounter, 4 - (screen.width / 2), 2 - (screen.height / 2), 8, Palette.yellow)
    screen.drawText("Turns: " + global.turnCounter, 4 - (screen.width / 2), 12 - (screen.height / 2), 6, Palette.yellow)
    screen.setDrawAnchor(0, 0)
    
    screen.drawText(global.levelNumber + " ⋅ " + global.beehive.level.name, 0, 72, 16, Palette.yellow)
    
    local time = global.millisecondsFormat(global.currentTime - global.startTime)
    
    screen.setDrawAnchor(1, -1)
    screen.drawText("Hexoban", (screen.width / 2) - 4, 2 - (screen.height / 2), 8, Palette.yellow)
    screen.drawText(time, (screen.width / 2) - 4, 12 - (screen.height / 2), 6, Palette.yellow)
    screen.setDrawAnchor(0, 0)
  elsif global.gameState == GameState.INTRODUCTION then global.introduction.draw()
  elsif global.gameState == GameState.MAIN_MENU then
    screen.setDrawScale(1 + (sind(global.tick / 2) / 8), 1 + (cosd(global.tick / 2) / 8))
    screen.drawText("Hexoban", 0, 0, 32, Palette.yellow)
    screen.setDrawScale(1, 1)
    
    screen.drawText("Created in Under 48 Hours for the Ludum Dare 56!", 0, -20, 6, Palette.yellow)
    screen.drawText("Press SPACE or Click Anywhere ont the Screen to Play!", 0, -84, 6, Palette.yellow)
    
    local fontCreditText = "Font: " + '"' + "Dangrek" + '"' + " by Danh Hong (Open Source)"
    local musicCreditText = "Music Made With UltraBox (BeepBox Mod)"
    local soundsCreditText = "Sound Effects Generated Using JSFXR"
    
    screen.setDrawAnchor(0, 1)
    screen.drawText(fontCreditText, 0, (screen.height / 2) - 12, 4, Palette.yellow)
    screen.drawText(musicCreditText, 0, (screen.height / 2) - 20, 4, Palette.yellow)
    screen.drawText(soundsCreditText, 0, (screen.height / 2) - 28, 4, Palette.yellow)
    screen.setDrawAnchor(0, 0)
  elsif global.gameState == GameState.VICTORY then
    screen.setDrawScale(1 + (sind(global.tick / 2) / 8), 1 + (cosd(global.tick / 2) / 8))
    screen.drawText("You Win", 0, 0, 32, Palette.yellow)
    screen.setDrawScale(1, 1)
    
    local time = global.millisecondsFormat(global.currentTime - global.startTime)
    
    screen.drawText("Thank you for playing!", 0, -24, 8, Palette.yellow)
    screen.drawText("Your time was: " + time, 0, -36, 6, Palette.yellow)
  end
  
  global.transition.draw()
end

