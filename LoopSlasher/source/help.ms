HelpScene = class
  constructor = function()
    global.requestMusic("menu", 0.5)

    this.background = new Background()
    this.transitioning = false
    this.animation = 0
  end

  update = function(deltaTime)
    this.animation = sin(system.time() / 250) * 2
    
    if keyboard.press.ENTER then
      if this.transitioning then
        return
      end

      local transitionAction = function()
        global.currentScene = new MainMenuScene()
      end
      
      if global.transition.requestTransition(transitionAction, false, 1) then
        this.transitioning = true
        audio.playSound("click", 2)
      end
    end
  end
  
  draw = function()
    this.background.draw()
    screen.setAlpha(0.5)
    CRT(1000, 0, 0)
    screen.setAlpha(1)

    screen.drawTextOutlined("How to play", 0, 60, 24, "white", "black")
    
    screen.setTranslation(screen.width / -4)

    screen.setAlpha(0.5)
    screen.drawSprite("shadow", -55, 10, 20, 5)
    screen.drawSprite("shadow", -10, 10, 20, 5)
    screen.drawSprite("shadow", 35, 10, 20, 5)
    screen.resetAlpha()

    screen.drawSprite("player_idle", -55, 20, 20, 20)
    screen.drawSprite("player_running", -10, 20, 20, 20)
    
    screen.drawTextOutlined("<", -10 - 20 - this.animation / 2, 20, 16, "white", "black")
    screen.drawTextOutlined(">", -10 + 20 + this.animation / 2, 20, 16, "white", "black")
    screen.setDrawRotation(90)
    screen.drawTextOutlined("<", -10, -this.animation / 2, 16, "white", "black")
    screen.drawTextOutlined(">", -10, 40 + this.animation / 2, 16, "white", "black")
    screen.resetDrawRotation()

    screen.drawSprite("player_rolling", 35, 20, 20, 20)

    screen.drawTextOutlined(">", 55 + this.animation / 2, 20, 16, "white", "black")
    screen.drawTextOutlined(">", 65 + this.animation / 2, 20, 16, "white", "black")

    screen.drawTextOutlined("- Use WASD or arrow keys to move.", 0, -20, 8, "white", "black")
    screen.drawTextOutlined("- Press space while moving to roll. ", 0, -30, 8, "white", "black")
    screen.drawTextOutlined("Tip: you are invincible while rolling.", 0, -40, 8, "white", "black")
    
    screen.setTranslation(screen.width / 4)
    
    screen.drawTextOutlined("The slimes are your enemies. You need", 0, 35, 8, "white", "black")
    screen.drawTextOutlined("to avoid them. Slimes with different", 0, 25, 8, "white", "black")
    screen.drawTextOutlined("colors have different properties.", 0, 15, 8, "white", "black")

    screen.setAlpha(0.5)
    screen.drawSprite("shadow", -45, -10, 20, 5)
    screen.drawSprite("shadow", -15, -10, 20, 5)
    screen.drawSprite("shadow", 15, -10, 20, 5)
    screen.drawSprite("shadow", 45, -10, 20, 5)
    screen.resetAlpha()
  
    screen.drawSprite("green_slime", -45, 0, 20, 20)
    screen.drawSprite("blue_slime", -15, 0, 20, 20)
    screen.drawSprite("purple_slime", 15, 0, 20, 20)
    screen.drawSprite("orange_slime", 45, 0, 20, 20)
    
    screen.drawTextOutlined("Click and drag with your mouse to draw a", 0, -20, 8, "white", "black")
    screen.drawTextOutlined("magical trail. When the trail LOOPS around", 0, -30, 8, "white", "black")
    screen.drawTextOutlined("itself, all enemies enclosed are killed.", 0, -40, 8, "white", "black")

    screen.resetTranslation()
    
    local y = this.animation + 20 - screen.height / 2
    screen.drawTextOutlined("Press enter to go back", 0, y, 16, "white", "black")
  end
end