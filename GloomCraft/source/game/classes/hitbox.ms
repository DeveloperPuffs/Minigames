
global.Rectangle = class
  constructor = function()
    this.x = 0
    this.y = 0
    this.width = 0
    this.height = 0
  end
  
  intersection = function(rectangle)
    local w1 = this.width / 2
    local h1 = this.height / 2
    local w2 = rectangle.width / 2
    local h2 = rectangle.height / 2
    return (
      this.x - w1 <= rectangle.x + w2 and
      this.x + w1 >= rectangle.x - w2 and
      this.y - h1 <= rectangle.y + h2 and
      this.y + h1 >= rectangle.y - h2
    )
  end
  
  vertices = function()
    local w = this.width / 2
    local h = this.height / 2
    
    return [
      [this.x - w, this.y - h],
      [this.x - w, this.y + h],
      [this.x + w, this.y - h],
      [this.x + w, this.y + h]
    ]
  end
end

global.Circle = class
  constructor = function()
    this.x = 0
    this.y = 0
    this.radius = 0
  end
  
  intersection = function(circle)
    sqrt(
      pow(this.x - circle.x, 2) + 
      pow(this.y - circle.y, 2)
    ) <= this.radius + circle.radius
  end
end

global.Hitbox = class
  RECTANGLE = 1
  CIRCLE = 2
  
  constructor = function()
    this.rectangle = new global.Rectangle()
    this.circle = new global.Circle()
  end
  
  intersection = function(hitbox, shape)
    if shape == global.Hitbox.RECTANGLE then
      return this.rectangle.intersection(hitbox.rectangle)
    elsif shape == global.Hitbox.CIRCLE then
      return this.circle.intersection(hitbox.circle)
    else return false end
  end
end

