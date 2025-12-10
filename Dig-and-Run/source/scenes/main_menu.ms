
MainMenu = class
  constructor = function()
    screen.setTranslation(0, 0)
    this.scale = 1
  end
  
  update = function()
    this.scale = 1 + (0.05 * cos(system.currentTime * 2))
    if keyboard.press.SPACE then
      global.setState(0)
      audio.playSound("click", 0.5)
    end
  end
  
  draw = function()
    screen.clear("#3098ff")
    
    screen.setFont("plasmapuffs")
    
    screen.setDrawScale(this.scale, this.scale)
    screen.setLineWidth(8)
    screen.drawTextOutline("Dig-and-Run", 0, 20, 16, 0)
    screen.drawText("Dig-and-Run", 0, 20, 16, 999)
    screen.setDrawScale(1, 1)
    screen.setLineWidth(4)
    screen.drawTextOutline("Press Space to Play!", 0, -20, 8, 0)
    screen.drawText("Press Space to Play!", 0, -20, 8, 999)
    
    screen.setLineWidth(2)
    screen.drawTextOutline("Controls in the project description.", 0, (screen.height / -2) + 20, 4, 0)
    screen.drawText("Controls in the project description.", 0, (screen.height / -2) + 20, 4, 999)
  end
end

