
global.Damage = class
  constructor = function(game, number)
    this.game = game
    
    this.x = 0
    this.y = 0
    
    this.number = number
    this.size = 4 + (abs(number) / 8)
    this.lift = number
    this.speed = 100
    
    this.line = 0
    this.text = 999
    this.alpha = 1
  end
  
  update = function()
    if not (this.alpha == 1) then return end
    
    this.lift -= this.game.timer.deltaTime * this.speed
    this.y += this.game.timer.deltaTime * this.speed
    
    if this.lift <= 0 then
      this.alpha -= this.game.timer.deltaTime
      after 0.5 seconds do
        local destroy = function() this.game.effects.removeElement(this) end
        global.tweenService.createTween(
          this, "alpha", 1, 0, 0.5, global.Easing.quadInOut, destroy
        )
      end
    end
  end
  
  draw = function()
    screen.setAlpha(this.alpha)
    screen.setLineWidth(this.size / 2)
    screen.drawTextOutline(this.number, this.x, this.y, this.size, this.line)
    screen.drawText(this.number, this.x, this.y, this.size, this.text)
    screen.setAlpha(1)
  end
end

