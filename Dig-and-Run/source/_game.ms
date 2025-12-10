
init = function()
  asset_manager.loadFont("plasmapuffs")
  while not screen.isFontReady("plasmapuffs") sleep 1 end
  
  system.startTime = system.time() / 1000
  system.currentTime = system.time() / 1000
  system.totalTime = 0
  system.deltaTime = 0
  
  debug.active = false
  debug.active_drawing = true
  debug.text_font_size = 8
  
  global.states = object
    INTRODUCTION = 1
    MAIN_MENU = 2
    GAME_OVER = 3
  end
  
  global.state = 0
  global.scene = 0
  global.newGame()
  global.setState(global.states.INTRODUCTION)
end

update = function()
  local currentTime = system.time() / 1000
  system.totalTime = currentTime - system.startTime
  system.deltaTime = currentTime - system.currentTime
  system.currentTime = currentTime
  
  debug.update()
  debug.print("FPS", system.fps)
  debug.print("Delta Time", system.deltaTime, 3)
  debug.print("Font", debug.text_font)
  debug.print("mouse.x", mouse.x, 3)
  debug.print("mouse.y", mouse.y, 3)
  
  TweenService.tick()
  
  if global.scene then global.scene.update() else
    if global.reward then global.reward.update() else
      global.timer.update()
      global.camera.update()
      global.island.update()
      global.treasure.update()
      global.player.update()
    end
    
    if global.player.boating and global.gotReward and not global.transitionTween then
      global.transitionTween = TweenService.newTween(global, "transition", 0, 1, 1, Tween.quadIn, function()
        global.newWorld()
        global.transitionTween = TweenService.newTween(global, "transition", 1, 0, 1, Tween.quadOut, function()
          global.transitionTween = 0
          end)
        end)
    end
    
    debug.print("camera.x", global.camera.x, 3)
    debug.print("camera.y", global.camera.y, 3)
    debug.print("player.x", global.player.x, 3)
    debug.print("player.y", global.player.y, 3)
    debug.print("treasure.x", global.treasure.x, 3)
    debug.print("treasure.y", global.treasure.y, 3)
  end
end

draw = function()
  if global.scene then global.scene.draw() else
    screen.clear("#3098ff")
    
    global.camera.draw()
    global.island.draw()
    global.treasure.draw()
    global.player.draw()
    
    for drawing in Drawing.queue drawing.call() end
    Drawing.queue = []
    
    global.timer.draw("$" + global.balance)
    if global.reward then global.reward.draw() end
    
    screen.setTranslation(0, 0)
    screen.setAlpha(global.transition)
    screen.fillRect(0, 0, screen.width, screen.height, 0)
    screen.setAlpha(1)
  end
  
  screen.setTranslation(0, 0)
  debug.draw()
end

global.setState = function(newState)
  if global.state == newState then return end
  global.state = newState
  
  if newState == global.states.INTRODUCTION then
    global.scene = new Introduction()
  elsif newState == global.states.MAIN_MENU then
    global.scene = new MainMenu()
  elsif newState == global.states.GAME_OVER then
    global.scene = new GameOver()
  else
    global.newGame()
    global.scene = 0 
  end
end

global.newWorld = function()
  global.camera = new Camera()
  global.island = new Island(45, 45, 10)
  global.camera.y = global.island.height / 2
  global.treasure = new Treasure(global.island)
  global.boat = new Boat(global.island)
  global.player = new Player(global.island, global.boat, global.treasure, global.camera)
  global.camera.x = global.player.x
  global.camera.y = global.player.y
  global.reward = 0
  global.gotReward = 0
  global.transitionTween = 0
  global.transition = 0
  global.timer.timeSpeed += 2
end

global.newGame = function()
  global.balance = 0
  global.timer = new Timer()
  global.rewards = []
  global.newWorld()
end

/*
DRAWING ORDER
1 - grass
2 - shadows
3 - treasure
4 - water
5 - radii?
6 - boat
7 - entity
8 - hands and tools
*/


