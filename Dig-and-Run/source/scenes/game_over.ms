
GameOver = class
  constructor = function()
    screen.setTranslation(0, 0)
  end
  
  update = function()
    if keyboard.press.SPACE then
      global.setState(global.states.MAIN_MENU)
      audio.playSound("click", 0.5)
    end
  end
  
  draw = function()
    screen.clear("#3098ff")
    
    screen.setFont("plasmapuffs")
    screen.setLineWidth(8)
    screen.drawTextOutline("The day's over!", 0, 20, 16, 0)
    screen.drawText("The day's over!", 0, 20, 16, 999)
    screen.setLineWidth(4)
    screen.drawTextOutline("You ended with $" + global.balance, 0, -20, 8, 0)
    screen.drawText("You ended with $" + global.balance, 0, -20, 8, 999)
    screen.setLineWidth(2)
    screen.drawTextOutline("Press Space to Proceed", 0, (screen.height / -2) + 20, 4, 0)
    screen.drawText("Press Space to Proceed", 0, (screen.height / -2) + 20, 4, 999)
  end
end
 
