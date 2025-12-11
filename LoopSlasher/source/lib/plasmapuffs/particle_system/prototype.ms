
ParticlePrototype = class
  constructor = function()
    this.functionName = "fillRound"
    this.functionArguments = [0, 0, 1, 1]
    
    // Position and Angle
    this.position = object end
    this.position.x = new Generator(0, 0)
    this.position.y = new Generator(0, 0)
    this.angle = new Generator(0, 0)
    
    // Color
    this.color = object end
    this.color[0] = object red = 1 green = 1 blue = 1 alpha = 1 end
    this.color[1] = object red = 1 green = 1 blue = 1 alpha = 1 end
    
    // This will determine the velocity of the particle
    // 'direction' is in degrees, not radians
    this.direction = new Generator(0, 0)
    this.speed = new Generator(0, 0)
    this.faceDirection = false
    
    this.gravityScale = object end
    this.gravityScale.x = new Generator(1, 1)
    this.gravityScale.y = new Generator(1, 1)
    
    this.friction = object end
    this.friction.velocity = new Generator(0, 0)
    this.friction.angular = new Generator(0, 0)
    
    this.torque = new Generator(0, 0)
    
    // Transformation Values
    this.lineWidth = object static = false end
    this.lineWidth.start = new Generator(1, 1)
    this.lineWidth.end = new Generator(1, 1)
    
    this.scale = object square = false end
    this.scale.x = object static = false end
    this.scale.x.start = new Generator(1, 1)
    this.scale.x.end = new Generator(1, 1)
    this.scale.y = object static = false end
    this.scale.y.start = new Generator(1, 1)
    this.scale.y.end = new Generator(1, 1)
    
    this.alpha = object static = false end
    this.alpha.start = new Generator(1, 1)
    this.alpha.end = new Generator(1, 1)
    
    // Lifespan
    this.lifespan = new Generator(1, 1)
  end
  
  generateConfiguration = function()
    local configuration = object end
    
    configuration.functionName = this.functionName
    configuration.functionArguments = this.functionArguments
    configuration.color = if this.color.type == "function" then this.color() else this.color.clone() end
    
    configuration.position = object end
    configuration.position.x = this.position.x.generate()
    configuration.position.y = this.position.y.generate()
    configuration.angle = this.angle.generate()
    
    local angle = this.direction.generate()
    local speed = this.speed.generate()
    configuration.velocity = object end
    configuration.velocity.x = speed * cosd(angle)
    configuration.velocity.y = speed * sind(angle)
    configuration.velocity.torque = this.torque.generate() * (if random.next() > 0.5 then 1 else -1 end)
    configuration.faceDirection = this.faceDirection
    
    configuration.friction = object end
    configuration.friction.velocity = this.friction.velocity.generate()
    configuration.friction.angular = this.friction.angular.generate()
    
    configuration.gravityScale = object end
    configuration.gravityScale.x = this.gravityScale.x.generate()
    configuration.gravityScale.y = this.gravityScale.y.generate()
    
    configuration.lineWidth = object static = this.lineWidth.static end
    configuration.lineWidth.start = this.lineWidth.start.generate()
    configuration.lineWidth.end = this.lineWidth.end.generate()
    
    configuration.scale = object end
    configuration.scale.x = object static = this.scale.x.static end
    configuration.scale.y = object static = this.scale.y.static end
    
    local axis = this.scale.square
    if axis then
      local startScale = this.scale[axis].start.generate()
      local endScale = this.scale[axis].end.generate()
      
      configuration.scale.x.start = startScale
      configuration.scale.x.end = endScale
      
      configuration.scale.y.start = startScale
      configuration.scale.y.end = endScale
    else
      configuration.scale.x.start = this.scale.x.start.generate()
      configuration.scale.y.start = this.scale.y.start.generate()
      configuration.scale.x.end = this.scale.x.end.generate()
      configuration.scale.y.end = this.scale.y.end.generate()
    end
    
    configuration.alpha = object static = this.alpha.static end
    configuration.alpha.start = this.alpha.start.generate()
    configuration.alpha.end = this.alpha.end.generate()
    
    configuration.lifespan = this.lifespan.generate()
    
    return configuration
  end
end
