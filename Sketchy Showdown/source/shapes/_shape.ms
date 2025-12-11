
Shape = class
  RECTANGLE = "Rectangle"
  CIRCLE = "Circle"
  
  constructor = function(shape, name, x, y)
    global.shapes.push(this)
    
    this.shape = shape
    this.name = name
    this.locked = false
    
    this.fillColor = "white"
    this.lineColor = "black"
    
    this.x = x
    this.y = y
    this.width = 10
    this.height = 10
    this.radius = 5
    
    this.vx = false
    this.vy = false
    this.bounce = false
    this.friction = false
    this.physics = false
    this.canvas = false
    this.wrap = false
    this.hustle = false
    this.float = false
    
    this.pickupScale = true
    this._pickupScale = true
    this.decay = true
    this._decay = true
  end
  
  rescale = function(axis, value, anchor)
    local size = if axis == "x" then "width" else "height" end
    local position = this[axis]
    this[size] += value * anchor
    
    if this.move(axis, value / 2) or this[size] < 8 then
      this[axis] = position
      this[size] -= value * anchor
      return false
    else return true end
  end
  
  move = function(axis, distance)
    if global.scene then return end
    
    local units = round(distance * 5)
    if not units then return end
    
    local steps = abs(units)
    local step = units / steps
    local preciseStep = step / 5
    
    for _ = true to steps
      this[axis] += preciseStep
      
      local collision = this.collision()
      if collision then
        this[axis] -= preciseStep
        this["v" + axis] *= -this.bounce
        this.hit(axis, collision)
        if not (collision == global.canvas) then collision.hit(axis, this) end
        return true
      end
    end
    
    return false
  end
  
  collision = function()
    if this.canvas then
      if (
        abs(this.x) + (this.width / 2) > global.canvas.width / 2 or
        abs(this.y) + (this.height / 2) > global.canvas.height / 2
      ) then return global.canvas end
    end
    
    for shape in global.shapes
      if shape == this then continue
      elsif this.float and shape.float then continue
      elsif (
        (this.shape == Shape.CIRCLE and shape.shape == Shape.CIRCLE)
        and (this.hustle or shape.hustle)) then continue
      elsif this.overlaps(shape) then return shape end
    end
    
    return false
  end
  
  update = function()
    this._pickupScale = lerp(this._pickupScale, this.pickupScale, 0.1)
    this._decay = lerp(this._decay, this.decay, 0.1)
    
    if this._decay <= 0.1 then
      this.dispose()
      return false
    end
    
    if this.locked then return false
    elsif this.physics then
      this.vx -= this.vx * this.friction
      this.vy -= this.vy * this.friction
      this.move("x", this.vx)
      this.move("y", this.vy)
      if this.wrap then this.screenWrap() end
    end
    
    return true
  end
  
  overlaps = function(shape)
    if this.shape == Shape.CIRCLE then
      if shape.shape == Shape.RECTANGLE then return Collide.circleAABB(this, shape)
      elsif shape.shape == Shape.CIRCLE then return Collide.circles(this, shape)
      end
    elsif this.shape == Shape.RECTANGLE then
      if shape.shape == Shape.CIRCLE then return Collide.circleAABB(shape, this)
      elsif shape.shape == Shape.RECTANGLE then return Collide.aabb(shape, this)
      end
    else return false end
  end
  
  dispose = function() global.shapes.removeElement(this) end
  getScale = function() object
    x = this._pickupScale * this._decay * global.beatScale
    y = this._pickupScale * this._decay * global.beatScale
  end end
  
  hit = function(axis, thing) end
  draw = function() end
  screenWrap = function()
    local w1 = this.width / 2
    local h1 = this.height / 2
    local w2 = screen.width / 2
    local h2 = screen.height / 2
    
    if this.vx < false and this.x + w1 <= -w2 then this.x = w2 + w1 end
    if this.vx > false and this.x - w1 >= w2 then this.x = -w2 - w1 end
    if this.vy < false and this.y + h1 <= -h2 then this.y = h2 + h1 end
    if this.vy > false and this.y - h1 >= h2 then this.y = -h2 - h1 end
  end
end

