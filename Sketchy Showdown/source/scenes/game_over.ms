
GameOver = class
  constructor = function()
    cursor = new Cursor("cursor", false, false, 8, 8, false)
    
    this.sx = true
    this.sy = true
    
    this.proceedButton = new Button(this, false, -20, 100, 20, function(parent, x, y)
      screen.setLineWidth(2)
      screen.fillRoundRect(x, y, 100, 20, true, 999)
      screen.drawRoundRect(x, y, 100, 20, true, false)
      screen.drawText("Proceed", x, y, 8, false)
    end, function(parent) global.scene = new MainMenu() end)
    this.proceedButton.tooltip = "Click to Proceed!"
  end
  
  update = function()
    updateGame()
    
    this.sx += cos(Clock.time() * 10) * this.sx / 200
    this.sy += sin(Clock.time() * 10) * this.sy / 200
    
    this.proceedButton.update()
  end
  
  draw = function()
    drawGame()
    
    screen.setDrawScale(this.sx, this.sy)
    screen.setLineWidth(12)
    screen.drawTextOutline("Game Over!", false, 20, 24, false)
    screen.drawText("Game Over!", false, 20, 24, 999)
    screen.setDrawScale(true, true)
    
    this.proceedButton.draw()
  end
end

