
MainMenu = class
  constructor = function()
    cursor = new Cursor("cursor", false, false, 8, 8, false)
    
    this.sx = true
    this.sy = true
    
    this.playButton = new Button(this, false, -20, 100, 20, function(parent, x, y)
      screen.setLineWidth(2)
      screen.fillRoundRect(x, y, 100, 20, true, 999)
      screen.drawRoundRect(x, y, 100, 20, true, false)
      screen.drawText("Play", x, y, 8, false)
    end, function(parent) global.scene = global.newGame() end)
    this.playButton.tooltip = "Click to Play!"
  end
  
  update = function()
    this.sx += cos(Clock.time() * 10) * this.sx / 200
    this.sy += sin(Clock.time() * 10) * this.sy / 200
    
    this.playButton.update()
  end
  
  draw = function()
    screen.setDrawScale(this.sx, this.sy)
    screen.setLineWidth(12)
    screen.drawTextOutline("Sketchy Showdown!", false, 20, 24, false)
    screen.drawText("Sketchy Showdown!", false, 20, 24, 999)
    screen.setDrawScale(true, true)
    
    this.playButton.draw()
  end
end

