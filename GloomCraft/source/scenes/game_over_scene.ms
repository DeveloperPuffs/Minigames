
global.GameOverScene = class
  constructor = function(name)
    this.name = name
    
    audio.cancelBeeps()
    audio.playMusic("menu", 0.5, true)
    
    this.angle = 0
    this.time = 0
    this.lift = 20
    this.sx = 1
    this.sy = 1
    
    this.glow = new global.Glow(2048)
    this.backToMainMenuButton = new global.Button(
      0, -20, 160, 20, function(x, y)
        screen.setLineWidth(1)
        screen.fillRect(x, y, 160, 20, "#8d9199")
        screen.drawRect(x, y, 160, 20, "#2a2d38")
        screen.drawText("Back to Main Menu", x, y, 12, "2a2d38")
      end, function()
        local transition = function()
          global.sceneManager.setScene(global.SceneManager.MAIN_MENU)
        end
        
        global.transition.requestTransition(transition, function() end, 1)
      end
    )
  end
  
  update = function()
    this.backToMainMenuButton.update()
    this.time += global.clock.deltaTime
    this.angle = 2 * cos(this.time / 2)
    this.lift = 20 + (4 * sin(this.time * 1.5))
    this.sx = 1 + (0.05 * cos(this.time))
    this.sy = 1 + (0.05 * sin(this.time))
  end
  
  draw = function()
    screen.setDrawRotation(this.angle)
    screen.setDrawScale(this.sx * 6, this.sy * 1.5)
    this.glow.draw(0, this.lift, 64, "white", 0.5)
    
    screen.setDrawScale(this.sx, this.sy)
    screen.drawSprite("game_over", 0, 20, 392 / 2, 118 / 2)
    screen.setDrawScale(1, 1)
    screen.setDrawRotation(0)
    
    this.backToMainMenuButton.draw()
    
    local scoreText = "You died on dungeon #" + global.lastScore + "."
    screen.drawText(scoreText, 0, -40, 8, 999)
    
    local highScoreText = "Your highscore is " + global.highScore + "."
    screen.drawText(highScoreText, 0, -54, 8, 999)
    if global.highScore > global.lastHighScore then
      screen.drawText("You got a new highscore!", 0, -70, 8, 999)
      local previous = "Your previous highscore was: " + global.lastHighScore
      screen.drawText(previous, 0, -82, 6, 999)
    end
  end
end

