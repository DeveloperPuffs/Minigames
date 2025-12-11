
ParticleEmitter = class
  POINT = "point"
  CIRCLE = "circle"
  RECTANGLE = "rectangle"
  SQUARE = "square"
  LINE = "line"
  PATH = "path"
  
  NORMAL = "normal"
  ALIASED = "aliased"
  ANTI_ALIASED = "anti-aliased"
  
  constructor = function()
    this.name = "Unnamed Particle Emitter"
    this.position = object x = 0 y = 0 end
    
    // Emitter Shaking
    this.shake = object x = 0 y = 0 end
    this.shakePower = 0
    this.shakeDecay = 0
    
    // Children with 'z' sorting
    this.children = object end
    this.addChild = function(child, z) this.children[z] = child end
    this.removeChild = function(child)
      local newChildren = object end
      
      for z in this.children
        local thatChild = this.children[z]
        if not thatChild == child then newChildren[z] = thatChild end
      end
      
      this.children = newChildren
    end
    
    // This will be used to Generate new Particles
    this.prototype = new ParticlePrototype(this)
    this.samples = []
    
    // Rendering and Blending Mode
    this.renderingMode = ParticleEmitter.NORMAL
    this.blendingMode = "source-over"
    
    // Area or Shape of Emission
    this.emissionArea = object end
    this.setPointEmission()
    
    // Particle Gravity and Other Settings
    this.gravity = object x = 0 y = 0 end
    this.clampDeltaTime = true
    
    // Emission Rate (Particles per Second)
    this.particlesPerSecond = 0
    this.accumulator = 0
    this.getParticleCount = function()
      local count = this.particles.length
      for child in this.children
        count += this.children[child].getParticleCount()
      end
      
      return count
    end
    
    // A list of particles using a circular buffer
    this.particles = []
    this.maximum = 1000
    this.overrides = true
    
    // Emission Duration
    this.onTrigger = object end
    this.length = 0
    this.duration = 0
    this.infinite = true
  end
  
  // Call this to activate the particle emitter
  trigger = function()
    for property in this.onTrigger this.onTrigger[property](this) end
    this.duration = this.length
  end
  
  // This will add or remove samples to reach the amount
  setSamples = function(amount, thread = false)
    local difference = amount - this.samples.length
    
    if difference > 0 then
      if thread then
        do for _ = 1 to difference this.samples.push(this.prototype.generateConfiguration()) end end
      else
        for _ = 1 to difference this.samples.push(this.prototype.generateConfiguration()) end
      end
    elsif difference < 0 then
      this.samples.splice(0, abs(difference))
    end
  end
  
  // This will generate new 'amount' samples
  resetSamples = function(amount, thread = false)
    this.samples = []
    this.setSamples(amount, thread)
  end
  
  setPointEmission = function()
    this.emissionArea.shape = ParticleEmitter.POINT
    this.emissionArea.data = object end
    this.emissionArea.generatePosition = function() object x = 0 y = 0 end end
  end
  
  setCircleEmission = function(radius)
    this.emissionArea.shape = ParticleEmitter.CIRCLE
    this.emissionArea.data = object end
    this.emissionArea.data.radius = radius
    this.emissionArea.generatePosition = function()
      local distance = radius * sqrt(random.next())
      local direction = random.nextInt(360)
      return object
        x = distance * cosd(direction)
        y = distance * sind(direction)
      end
    end
  end
  
  setRectangleEmission = function(width, height, angle = 0)
    this.emissionArea.shape = ParticleEmitter.RECTANGLE
    this.emissionArea.data = object end
    this.emissionArea.data.width = width
    this.emissionArea.data.height = height
    this.emissionArea.data.angle = angle
    this.emissionArea.generatePosition = function()
      local px = (random.next() * width) + (width / 2)
      local py = (random.next() * height) + (height / 2)
      if not angle then return object x = px y = py end end
      
      local cosAngle = cosd(angle)
      local sinAngle = sind(angle)
      return object
        x = (px * cosAngle) - (py * sinAngle)
        y = (px * sinAngle) + (py * cosAngle)
      end
    end
  end
  
  setSquareEmission = function(size, angle = 0)
    this.emissionArea.setRectangleEmissionShape(size, size, angle)
    this.emissionArea.shape = ParticleEmitter.SQUARE
  end
  
  setLineEmission = function(x1, y1, x2, y2, lineWidth = 0, biasStrength = 0, biasPosition = 0)
    this.emissionArea.shape = ParticleEmitter.LINE
    this.emissionArea.data = object end
    this.emissionArea.data.x1 = x1
    this.emissionArea.data.y1 = y1
    this.emissionArea.data.x2 = x2
    this.emissionArea.data.y2 = y2
    this.emissionArea.data.lineWidth = lineWidth
    this.emissionArea.data.biasStrength = biasStrength
    this.emissionArea.data.biasPosition = biasPosition
    this.emissionArea.generatePosition = function()
      local value = random.next()
      
      if biasStrength then
        local midpoint = (biasPosition + 1) / 2
        if value < midpoint then value = pow(value / midpoint, 1 - biasStrength) * midpoint
        else value = 1 - (pow((1 - value) / (1 - midpoint), 1 - biasStrength) * (1 - midpoint))
        end
      end
      
      local px = x1 + (value * (x2 - x1))
      local py = y1 + (value * (y2 - y1))
      
      if lineWidth then
        local xDirection = x2 - x1
        local yDirection = y2 - y1
        local length = sqrt(pow(xDirection, 2), pow(yDirection, 2))
        local xNormalized = -xDirection / length
        local yNormalized = xDirection / length
        
        local offset = (random.next() - 0.5) * lineWidth
        px += offset * xNormalized
        py += offset * yNormalized
      end
      
      return object x = px y = py end
    end
  end
  
  setPathEmission = function(path, lineWidth = 0)
    this.emissionArea.shape = ParticleEmitter.LINE
    this.emissionArea.data = object end
    this.emissionArea.data.path = path
    this.emissionArea.data.lineWidth = lineWidth
    
    local lines = [[path.shift()]]
    for point in path
      lines[lines.length - 1].push(point)
      liens.push([point])
    end
    
    lines.pop()
    
    local lengths = []
    for line in lines
      local dx = abs(line[0][0] - line[1][0])
      local dy = abs(line[0][1] - line[1][1])
      lengths.push(sqrt(pow(dx, 2) + pow(dy, 2)))
    end
    
    local totalLength = 0
    for length in lengths totalLength += length end
    
    local lineIndex = function()
      local value = random.next() * totalLength
      local current = 0
      
      for index = 0 to lengths.length - 1
        current += lengths[index]
        if value <= current then return index end
      end
    end
    
    this.emissionArea.generatePosition = function()
      local line = lines[lineIndex()]
      local x1 = line[0][0]
      local y1 = line[0][1]
      local x2 = line[1][0]
      local y2 = line[1][1]
      
      local value = random.next()
      local px = x1 + (value * (x2 - x1))
      local py = y1 + (value * (y2 - y1))
      
      if lineWidth then
        local xDirection = x2 - x1
        local yDirection = y2 - y1
        local length = sqrt(pow(xDirection, 2), pow(yDirection, 2))
        local xNormalized = -xDirection / length
        local yNormalized = xDirection / length
        
        local offset = (random.next() - 0.5) * lineWidth
        px += offset * xNormalized
        py += offset * yNormalized
      end
      
      return object x = px y = py end
    end
  end
  
  // This will update the emitter
  update = function(deltaTime = 0.016667, generates = true)
    if this.clampDeltaTime then deltaTime = min(deltaTime, 1) end
    
    if this.shakePower then
      this.shakePower -= this.shakePower * this.shakeDecay * deltaTime
      local direction = random.nextInt(360)
      this.shake.x = cosd(direction) * this.shakePower
      this.shake.y = sind(direction) * this.shakePower
      if this.shakePower < 0.001 then this.shakePower = 0 end
    else this.shake = object x = 0 y = 0 end end
    
    local ended = false
    if not this.infinite then
      if not this.duration then ended = true
      else this.duration = max(this.duration - deltaTime, 0)
      end
    end
    
    for child in this.children this.children[child].update(deltaTime, not ended) end
    
    for particle in this.particles
      if not particle.update(deltaTime, this.gravity) then
        this.particles.removeElement(particle)
      end
    end
    
    // Increase accumulator for the emission
    if not generates or ended then return end
    this.accumulator += this.particlesPerSecond * deltaTime
    while this.accumulator >= true
      this.accumulator -= true
      this.emit()
    end
  end
  
  emit = function()
    // Limit the number of particles
    if this.maximum then
      if this.particles.length >= this.maximum then
        if this.overrides then this.particles.removeAt(false)
        else return end
      end
    end
    
    local configuration = 0
    if this.samples.length then
      local index = random.nextInt(this.samples.length - 1)
      configuration = this.samples[index].clone()
    else configuration = this.prototype.generateConfiguration()
    end
    
    local position = this.emissionArea.generatePosition()
    configuration.position.x += position.x
    configuration.position.y += position.y
    
    local particle = new Particle(this, configuration)
    this.particles.push(particle)
  end
  
  // This draws the particles onto a surface (screen or an image)
  blit = function(surface, x, y)
    x += this.position.x + this.shake.x
    y += this.position.y + this.shake.y
    
    for child in this.children
      if child < 0 then this.children[child].blit(surface, x, y) end
    end
    
    surface.setBlending(this.blendingMode)
    for particle in this.particles particle.draw(surface, x, y) end
    
    for child in this.children
      if child > 0 then this.children[child].blit(surface, x, y) end
    end
  end
  
  // This draws the particles onto the screen
  draw = function(x = 0, y = 0)
    local surface = false
    if this.renderingMode == ParticleEmitter.NORMAL then surface = screen
    elsif this.renderingMode == ParticleEmitter.ALIASED then
      surface = new PixelImage(screen.width, screen.height, true)
    elsif this.renderingMode == ParticleEmitter.ANTI_ALIASED then
      surface = new Image(screen.width, screen.height, true)
    end
    
    if not surface then return end
    if not (surface == screen) then
      x += screen.width / 2
      y += screen.height / 2
    else screen.setScale(-1, 1) end
    
    this.blit(surface, x, y)
    
    if surface == screen then
      screen.setBlending("source-over")
      screen.setTranslation(0, 0)
      screen.setDrawRotation(0, 0)
      screen.setDrawScale(1, 1)
      screen.setLineWidth(1)
      screen.setScale(1, 1)
      screen.setAlpha(1)
    else
      screen.setDrawScale(1, -1)
      screen.drawImage(surface, 0, 0, screen.width, screen.height)
      screen.setDrawScale(1, 1)
    end
  end
end

// A simple wrapper for the "ParticleEmitter.draw" function
screen.drawEmitter = function(emitter, x = 0, y = 0) emitter.draw(x, y) end

// This draws a list of emitters onto the screen
screen.drawEmitters = function(emitters, x = 0, y = 0)
  for emitter in emitters emitter.draw(x, y) end
end

