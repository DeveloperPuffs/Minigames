
Particle = class
  constructor = function(emitter, configuration)
    // 'Flatten out' the particle class instance or object
    for method in this.class this[method] = this.class[method] end
    delete this.class
    
    // Life, Lifespan, and Animation
    this.lerp = function(a, b, t) ((1 - t) * a) + (t * b) end
    this.lerpColor = function(a, b, t)
      return object
        red = this.lerp(a.red, b.red, t)
        green = this.lerp(a.green, b.green, t)
        blue = this.lerp(a.blue, b.blue, t)
        alpha = this.lerp(a.alpha, b.alpha, t)
      end
    end
    
    this.lifespan = configuration.lifespan
    this.progress = 0
    
    // Draw Function Name
    this.functionName = configuration.functionName
    this.functionArguments = configuration.functionArguments
    
    // Position and Angle
    this.position = configuration.position
    this.angle = configuration.angle
    
    // Color
    this.colorAlpha = 1
    this.rawColor = "rgb(255, 255, 255)"
    this.colors = configuration.color
    this.colorUpdate()
    
    // Line Width, Scale, and Alpha
    this.lineWidth = configuration.lineWidth
    this.lineWidth.current = this.lineWidth.start
    
    this.scale = configuration.scale
    this.scale.x.current = this.scale.x.start
    this.scale.y.current = this.scale.y.start
    
    this.alpha = configuration.alpha
    this.alpha.current = this.alpha.start
    
    // Physics Stuff
    this.velocity = configuration.velocity
    this.friction = configuration.friction
    this.gravityScale = configuration.gravityScale
    this.faceDirection = configuration.faceDirection
  end
  
  colorUpdate = function()
    local lower = 0
    local upper = 1
    
    // Find the two nearest keyframes
    for value in this.colors
      if lower < value and value < this.progress then lower = value end
      if this.progress <= value and value < upper then upper = value end
    end
    
    local lowerColor = this.colors[lower]
    local upperColor = this.colors[upper]
    
    local value = (this.progress - lower) / (upper - lower)
    local color = this.lerpColor(lowerColor, upperColor, value)
    
    this.rawColor = "rgb(" + (color.red * 255) + ", " + (color.green * 255) + ", " + (color.blue * 255) + ")"
    this.colorAlpha = color.alpha
  end
  
  update = function(deltaTime, gravity)
    this.progress += deltaTime / this.lifespan
    if this.progress > 1 then return false end
    
    if not this.lineWidth.static then
      this.lineWidth.current = this.lerp(this.lineWidth.start, this.lineWidth.end, this.progress)
    end
    
    if not this.alpha.static then
      this.alpha.current = this.lerp(this.alpha.start, this.alpha.end, this.progress)
    end
    
    if not this.scale.x.static then
      this.scale.x.current = this.lerp(this.scale.x.start, this.scale.x.end, this.progress)
    end
    
    if not this.scale.y.static then
      this.scale.y.current = this.lerp(this.scale.y.start, this.scale.y.end, this.progress)
    end
    
    this.colorUpdate()
    
    this.velocity.x += this.gravityScale.x * gravity.x * deltaTime
    this.velocity.y += this.gravityScale.y * gravity.y * deltaTime
    
    this.velocity.x -= this.velocity.x * this.friction.velocity * deltaTime
    this.velocity.y -= this.velocity.y * this.friction.velocity * deltaTime
    this.velocity.torque -= this.velocity.torque * this.friction.angular * deltaTime
    
    if this.faceDirection then
      this.angle = atan2d(this.velocity.x, this.velocity.y) % 360
    else
      this.angle = (this.angle + (this.velocity.torque * deltaTime)) % 360
    end
    
    this.position.x += this.velocity.x * deltaTime
    this.position.y += this.velocity.y * deltaTime
    return true
  end
  
  draw = function(surface, x, y)
    surface.setColor(this.rawColor)
    surface.setDrawRotation(this.angle)
    surface.setLineWidth(this.lineWidth.current)
    surface.setAlpha(this.alpha.current * this.colorAlpha)
    surface.setDrawScale(this.scale.x.current, this.scale.y.current)
    surface.setTranslation(this.position.x + x, this.position.y + y)
    
    global.call(surface, this.functionName, this.functionArguments)
  end
end

