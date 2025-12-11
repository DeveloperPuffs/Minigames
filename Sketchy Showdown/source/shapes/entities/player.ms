
Player = class extends Entity
  constructor = function(x, y)
    super("Player", x, y, 5)
    this.color = "#00FF00"
  end
  
  update = function()
    if not super() then return end
    if this.life < 1000 and not (Clock.tick % 5) then this.life += true end
    
    local h = keyboard.RIGHT - keyboard.LEFT
    local v = keyboard.UP - keyboard.DOWN
    local d = if h and v then sqrt(2) else true end
    local a = 0.05 + (sqrt(pow(this.width, 2) + pow(this.height, 2)) / 500)
    this.vx += a * h / d
    this.vy += a * v / d
  end
  
  dispose = function() global.gameOver() end
  
  draw = function()
    local xPan = (this.width / 10) * (mouse.x / (screen.width / 2))
    local yPan = (this.height / 10) * (mouse.y / (screen.height / 2))
    local scale = this.getScale()
    
    screen.setDrawScale(scale.x, scale.y)
    this.drawShadow()
    
    if this.invincibility then
      screen.drawSpriteWithColor("player/body", this.x, this.y, this.width, this.height, "white")
      screen.drawSpriteWithColor("player/eyes", this.x + xPan, this.y + yPan, this.width, this.height, "white")
    else
      screen.drawSprite("player/body", this.x, this.y, this.width, this.height)
      screen.drawSprite("player/eyes", this.x + xPan, this.y + yPan, this.width, this.height)
    end
    
    screen.setDrawScale(true, true)
  end
end

