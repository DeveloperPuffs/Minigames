
global.init = function()
  asset_manager.loadFont("font")
  screen.setFont("font")
  global.lastHighScore = storage.get("highscore")
  global.highScore = global.lastHighScore
  global.lastScore = false
  global.setupDebug(false)
  global.clock = new global.Clock()
  global.tweenService = new global.TweenService()
  global.cursor = new global.Cursor()
  global.sceneManager = new global.SceneManager()
  global.transition = new global.Transition()
  global.sceneManager.setScene()
end

global.update = function()
  global.tweenService.tick()
  global.clock.tick()
  global.cursor.update()
  global.transition.update()
  global.sceneManager.update()
  global.updateDebug()
end

global.draw = function()
  screen.clear(1)
  global.sceneManager.draw()
  global.transition.draw()
  global.drawDebug()
  global.cursor.draw()
end

