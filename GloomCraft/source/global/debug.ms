
global.setupDebug = function(active)
  global.debug.active = active
  global.debug.active_drawing = active
  global.debug.text_font_size = 4
end

global.updateDebug = function()
  if not global.debug.active then return end
  global.debug.update()
  
  global.debug.print("")
  global.debug.print("global.clock.fps", global.clock.fps)
  global.debug.print("global.clock.deltaTime", global.clock.deltaTime, 3)
  global.debug.print("")
  global.debug.print("mouse.x", mouse.x, 3)
  global.debug.print("mouse.y", mouse.y, 3)
  global.debug.print("")
  
  local scene = global.sceneManager.scene.name
  global.debug.print("global.sceneManager.scene.name", scene)
  
  if scene == global.sceneManager.GAME then
    local dungeon = global.sceneManager.scene.dungeon
    local player = global.sceneManager.scene.player
    
    global.debug.print("")
    global.debug.print("...dungeon.columns", dungeon.columns)
    global.debug.print("...dungeon.rows", dungeon.rows)
    global.debug.print("")
    global.debug.print("...player.x", player.x)
    global.debug.print("...player.y", player.y)
    global.debug.print("...player.vx", player.vx)
    global.debug.print("...player.vy", player.vy)
    global.debug.print("...player.column", floor(player.x / 16))
    global.debug.print("...player.row", floor(player.y / 16))
    global.debug.print('...player.balance', player.balance)
    global.debug.print("")
  end
end

global.drawDebug = function()
  if not global.debug.active then return end
  global.debug.draw()
  screen.setFont("font")
end

