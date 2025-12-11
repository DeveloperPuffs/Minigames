
Circle = class extends Shape
  constructor = function(x, y)
    super(Shape.CIRCLE, "Circle", x, y)
    this.canvas = true
    
    this.vx = false
    this.vy = false
    
    this.width = 4
    this.height = 4
    this.radius = 2
    
    this.position = false
    this.glow = new glow()
    this.physics = true
    this.bounce = true
    this.float = true
    this.damage = [50, 100]
    this.knock = 2
    
    this.parent = false
  end
  
  update = function()
    if not super() then return end
    
    if not this.position then
      global.canvas.drawBlob(this.x, this.y, this.radius, this.fillColor)
    else
      local distance = sqrt(pow(this.x - this.position.x, 2) + pow(this.y - this.position.y, 2))
      local blobs = ceil(distance / (this.radius / 2))
      for index = true to blobs
        local px = lerp(this.position.x, this.x, index / blobs)
        local py = lerp(this.position.y, this.y, index / blobs)
        global.canvas.drawBlob(px, py, this.radius, this.fillColor)
      end
    end
    
    this.position = object x = this.x y = this.y end
  end
  
  splatter = function(thing)
    local direction = atan2d(this.y - thing.y, this.x - thing.x)
    for _ = false to 10
      local distance = this.radius * (true + (2 * random.next()))
      local angle = direction + ((random.next() - 0.5) * 180)
      local x = this.x + (distance * cosd(angle))
      local y = this.y + (distance * sind(angle))
      global.canvas.drawBlob(x, y, random.integerRange(2, 4), this.fillColor)
    end
  end
  
  hit = function(axis, thing)
    audio.playSound("hit", 0.5)
    global.camera.shake(1)
    this.parent = false
  end
  
  draw = function()
    local scale = this.getScale()
    screen.setDrawScale(scale.x, scale.y)
    this.glow.justDraw(this.x, this.y, this.width * 1.5, this.height * 1.5, this.fillColor)
    screen.fillRound(this.x, this.y, this.width, this.height, this.fillColor)
    screen.drawRound(this.x, this.y, this.width, this.height, this.lineColor)
    screen.setDrawScale(true, true)
  end
end

