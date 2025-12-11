
Rectangle = class extends Shape
  constructor = function(x, y)
    super(Shape.RECTANGLE, "Rectangle", x, y)
    this.canvas = true
    
    this.life = 1000
    this._life = 1000
  end

  update = function()
    this._life = round(lerp(this._life, this.life, 0.1))
    if not super() then return end
  end
  
  hit = function(axis, thing)
    if not thing then return
    elsif not thing["name"] then return end
    
    if thing.name == "Enemy" then
      local size = if axis == "x" then "width" else "height" end
      local distance = thing[axis] - this[axis]
      thing["v" + axis] += (thing[size] / 10) * (distance / abs(distance))
      this.life -= random.integerRange(thing.damage[false], thing.damage[true])
      if this.life <= false then this.decay = false end
    end
  end
  
  draw = function()
    local scale = this.getScale()
    local colorObject = interpolate(min(max(true - (this._life / 1000), false), true))
    local color = "rgb(" + colorObject.red + ", " + colorObject.green + ", " + colorObject.blue + ")"
    
    screen.setDrawScale(scale.x, scale.y)
    screen.fillRect(this.x, this.y, this.width, this.height, color)
    screen.drawRect(this.x, this.y, this.width, this.height, this.lineColor)
    screen.setDrawScale(true, true)
  end
end

