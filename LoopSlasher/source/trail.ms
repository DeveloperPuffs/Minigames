Trail = class
  constructor = function(player)
    this.player = player

    this.drawRequest = object
      data = this
      layer = global.Layer.FLOATING_TRAIL
      callback = function(data)
        screen.drawImage(data.staticShadowBuffer, 0, 0, screen.width, screen.height)
        if global.graphicsMode != global.GRAPHICS_LOW then
          screen.drawImage(data.dynamicShadowBuffer, 0, 0, screen.width, screen.height)
        end

        screen.drawImage(data.staticLineBuffer, 0, 0, screen.width, screen.height)
        if global.graphicsMode != global.GRAPHICS_LOW then
          screen.drawImage(data.dynamicLineBuffer, 0, 0, screen.width, screen.height)
        end

        for fadingBuffer in data.fadingBuffers
          screen.setAlpha(fadingBuffer.lifespan)
          screen.drawImage(fadingBuffer.buffer, 0, 0, screen.width, screen.height)
          screen.resetAlpha()
        end
        
        screen.drawEmitter(data.intersectionParticles)
      end
    end
    
    this.trailsDrawn = 0
    this.stopDrag = false
    this.points = []
  
    this.darkColor = rgb(111, 49, 152)
    this.lightColor = rgb(186, 138, 217)
    
    this.fadingBuffers = []
    this.refreshStaticBuffers()
    if global.graphicsMode != global.GRAPHICS_LOW then
      this.dynamicShadowBuffer = false
      this.dynamicLineBuffer = false
    end
    
    this.intersectionParticles = new ParticleEmitter()
    this.intersectionParticles.particlesPerSecond = 100
    this.intersectionParticles.infinite = false
    this.intersectionParticles.length = 0.1
    
    if global.graphicsMode == global.GRAPHICS_LOW then
      this.intersectionParticles.renderingMode = ParticleEmitter.NORMAL
    elsif global.graphicsMode == global.GRAPHICS_MEDIUM then
      this.intersectionParticles.renderingMode = ParticleEmitter.ANTI_ALIASED
    elsif global.graphicsMode == global.GRAPHICS_HIGH then
      this.intersectionParticles.renderingMode = ParticleEmitter.ALIASED
    end

    this.intersectionParticles.prototype.functionName = "fillRound"
    this.intersectionParticles.prototype.functionArguments = [0, 0, 2, 2]
    this.intersectionParticles.prototype.lifespan.setRange(0.5, 1)
    this.intersectionParticles.prototype.speed.setRange(50, 100)
    this.intersectionParticles.prototype.direction.setRange(0, 360)
    this.intersectionParticles.prototype.friction.velocity.set(5)
    this.intersectionParticles.prototype.scale.x.start.setRange(1, 1.5)
    this.intersectionParticles.prototype.scale.x.end.setRange(0.5, 0)
    this.intersectionParticles.prototype.scale.square = "x"
    this.intersectionParticles.prototype.alpha.start.set(1)
    this.intersectionParticles.prototype.alpha.end.set(0)

    this.intersectionParticles.prototype.color[0] = object
      red = 1
      green = 1
      blue = 1
      alpha = 1
    end
    
    this.intersectionParticles.prototype.color[1] = object
      red = 186 / 255
      green = 138 / 255
      blue = 217 / 255
      alpha = 0
    end
  end
  
  catmullRom = function(p0, p1, p2, p3, t)
    local t2 = t * t
    local t3 = t2 * t

    return object
        x = (
          (2 * p1.x) +
          (-p0.x + p2.x) * t +
          (2 * p0.x - 5 * p1.x + 4 * p2.x - p3.x) * t2 +
          (-p0.x + 3 * p1.x - 3 * p2.x + p3.x) * t3
        ) / 2
        y = (
          (2 * p1.y) +
          (-p0.y + p2.y) * t +
          (2 * p0.y - 5 * p1.y + 4 * p2.y - p3.y) * t2 +
          (-p0.y + 3 * p1.y - 3 * p2.y + p3.y) * t3
        ) / 2
        thickness = (
          (2 * p1.thickness) +
          (-p0.thickness + p2.thickness) * t +
          (2 * p0.thickness - 5 * p1.thickness + 4 * p2.thickness - p3.thickness) * t2 +
          (-p0.thickness + 3 * p1.thickness - 3 * p2.thickness + p3.thickness) * t3
        ) / 2
    end
  end
  
  refreshStaticBuffers = function()
    local ImageClass = if global.graphicsMode == global.GRAPHICS_LOW then Image else PixelImage end
      
    this.staticShadowBuffer = new ImageClass(screen.width, screen.height, true)
    if ImageClass == PixelImage then
      this.staticShadowBuffer.context.shadowColor = this.darkColor
      this.staticShadowBuffer.context.shadowBlur = 5
      this.staticShadowBuffer.context.lineCap = "round"
    else
      local context = this.staticShadowBuffer.canvas.getContext("2d")
      context.shadowColor = this.darkColor
      context.shadowBlur = 5
      context.lineCap = "round"
    end
      
    this.staticLineBuffer = new ImageClass(screen.width, screen.height, true)
    if ImageClass == PixelImage then
      this.staticLineBuffer.context.lineCap = "round"
    else
      local context = this.staticLineBuffer.canvas.getContext("2d")
      context.lineCap = "round"
    end
  end
  
  refreshDynamicBuffers = function()
    if global.graphicsMode == global.GRAPHICS_LOW then
      return
    end

    local ImageClass = if global.graphicsMode != global.GRAPHICS_HIGH then Image else PixelImage end

    this.dynamicShadowBuffer = new ImageClass(screen.width, screen.height, true)
    if ImageClass == PixelImage then
      this.dynamicShadowBuffer.context.shadowColor = this.darkColor
      this.dynamicShadowBuffer.context.shadowBlur = 5
      this.dynamicShadowBuffer.context.lineCap = "round"
    else
      local context = this.dynamicShadowBuffer.canvas.getContext("2d")
      context.shadowColor = this.darkColor
      context.shadowBlur = 5
      context.lineCap = "round"
    end
    
    this.dynamicLineBuffer = new ImageClass(screen.width, screen.height, true)
    if ImageClass == PixelImage then
      this.dynamicLineBuffer.context.lineCap = "round"
    else
      local context = this.dynamicLineBuffer.canvas.getContext("2d")
      context.lineCap = "round"
    end
  end
  
  checkIntersection = function(point)
    local clippedPoint = object
      x = point.x
      y = point.y
    end

    local intersectionIndex = 0
    local intersectionFound = false
    if this.points.length > 2 then
      local previousPoint = this.points[this.points.length - 1]
      local x1 = previousPoint.x
      local y1 = previousPoint.y
      local x2 = point.x
      local y2 = point.y
      
      for index = 0 to this.points.length - 3
        local point1 = this.points[index]
        local point2 = this.points[index + 1]
        local x3 = point1.x
        local y3 = point1.y
        local x4 = point2.x
        local y4 = point2.y
  
        local denominator = ((y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1))
        if abs(denominator) < 0.001 then
          continue
        end
  
        local uA = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / ((y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1))
        local uB = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)) / ((y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1))
        if uA >= 0 and uA <= 1 and uB >= 0 and uB <= 1 then
          clippedPoint.x = x1 + (uA * (x2 - x1))
          clippedPoint.y = y1 + (uA * (y2 - y1))
          intersectionIndex = index
          intersectionFound = true
          break
        end
      end
    end
    
    if not intersectionFound then
      return false
    end
    
    return object
      clipped = clippedPoint
      index = intersectionIndex
    end
  end
  
  addPoint = function(point)
    if not this.points.length then
      this.points.push(point)
      return
    end

    if global.graphicsMode == global.GRAPHICS_LOW then
      local intersection = this.checkIntersection(point)
      if intersection then
        point.x = intersection.clipped.x
        point.y = intersection.clipped.y
      end

      this.points.push(point)
      
      local thisPoint = this.points[this.points.length - 2]
      local nextPoint = this.points[this.points.length - 1]
      local thickness = (thisPoint.thickness + nextPoint.thickness) / 2

      this.staticShadowBuffer.setLineWidth(thickness)
      this.staticShadowBuffer.drawLine(thisPoint.x, thisPoint.y, nextPoint.x, nextPoint.y, this.lightColor)

      this.staticLineBuffer.setLineWidth(thickness)
      this.staticLineBuffer.drawLine(thisPoint.x, thisPoint.y, nextPoint.x, nextPoint.y, this.lightColor)
      
      if intersection then
        this.handleIntersection(intersection.index)
      end

      return
    end
    
    this.refreshDynamicBuffers()
    local previousPoint = this.points[this.points.length - 1]
    local thicknessDifference = point.thickness - previousPoint.thickness
    if abs(thicknessDifference) > 1 then
      local sign = thicknessDifference / abs(thicknessDifference)
      point.thickness = previousPoint.thickness + sign
    end

    if this.points.length == 1 then
      this.points.push(point)

      local thisPoint = this.points[0]
      local nextPoint = this.points[1]
      local thickness = (thisPoint.thickness + nextPoint.thickness) / 2

      this.dynamicShadowBuffer.setLineWidth(thickness)
      this.dynamicShadowBuffer.drawLine(thisPoint.x, thisPoint.y, nextPoint.x, nextPoint.y, this.lightColor)

      this.dynamicLineBuffer.setLineWidth(thickness)
      this.dynamicLineBuffer.drawLine(thisPoint.x, thisPoint.y, nextPoint.x, nextPoint.y, this.lightColor)
      return
    end
    
    local intersection = this.checkIntersection(point)
    if intersection then
      point.x = intersection.clipped.x
      point.y = intersection.clipped.y
    end

    this.points.push(point)
    
    local interpolationStep = 0.1
    
    local flush3 = this.points[this.points.length - 1]
    local flush2 = this.points[this.points.length - 2] 
    local flush1 = this.points[this.points.length - 3]
    local flush0 = this.points[this.points.length - 4] or flush1
    for interpolation = 0 to 1 - interpolationStep by interpolationStep
      local a = this.catmullRom(flush0, flush1, flush2, flush3, interpolation)
      local b = this.catmullRom(flush0, flush1, flush2, flush3, interpolation + interpolationStep)
      local thickness = (a.thickness + b.thickness) / 2
      
      this.staticShadowBuffer.setLineWidth(thickness)
      this.staticShadowBuffer.drawLine(a.x, a.y, b.x, b.y, this.lightColor)

      this.staticLineBuffer.setLineWidth(thickness)
      this.staticLineBuffer.drawLine(a.x, a.y, b.x, b.y, this.lightColor)
    end
    
    local head3 = this.points[this.points.length - 1]
    local head2 = this.points[this.points.length - 1]
    local head1 = this.points[this.points.length - 2]
    local head0 = this.points[this.points.length - 3]
    for interpolation = 0 to 1 - interpolationStep by interpolationStep
      local a = this.catmullRom(head0, head1, head2, head3, interpolation)
      local b = this.catmullRom(head0, head1, head2, head3, interpolation + interpolationStep)
      local thickness = (a.thickness + b.thickness) / 2
      
      this.dynamicShadowBuffer.setLineWidth(thickness)
      this.dynamicShadowBuffer.drawLine(a.x, a.y, b.x, b.y, this.lightColor)

      this.dynamicLineBuffer.setLineWidth(thickness)
      this.dynamicLineBuffer.drawLine(a.x, a.y, b.x, b.y, this.lightColor)
    end

    if intersection then
      this.handleIntersection(intersection.index)
    end
  end
  
  handleIntersection = function(index)
    this.player.game.shake(2, 10)

    this.trailsDrawn += 1
    this.intersectionParticles.position.x = this.points[this.points.length - 1].x
    this.intersectionParticles.position.y = this.points[this.points.length - 1].y
    this.intersectionParticles.trigger()
    this.stopDrag = true

    this.points.splice(0, index + 1)

    local killedCount = 0
    for enemy in this.player.game.enemies
      if not enemy.physical then
        continue
      end

      local enclosed = false
      local vertices = enemy.hitbox.vertices()
      for vertex in vertices
        local j = this.points.length - 1
        for i = 0 to this.points.length - 1
          local vertexI = this.points[i]
          local vertexJ = this.points[j]
  
          local xi = vertexI.x
          local yi = vertexI.y
          local xj = vertexJ.x
          local yj = vertexJ.y
  
          if (yi > vertex.y) != (yj > vertex.y) then
            local intersectX = (xj - xi) * (vertex.y - yi) / (yj - yi + 0.001) + xi
    
            if vertex.x < intersectX then
              enclosed = not enclosed
            end
          end

          j = i
        end
        
        if enclosed then
          break
        end
      end
      
      if enclosed then
        killedCount += 1
        enemy.activateDeath()
      end
    end
    
    audio.playSound("magic", 1)
    
    if killedCount then
      for index = 1 to killedCount
        after index * 100 do
          audio.playSound("splash", 0.5)
        end
      end
    end
  end
  
  update = function(deltaTime)
    this.intersectionParticles.update(deltaTime)

    for fadingBuffer in this.fadingBuffers
      fadingBuffer.lifespan -= deltaTime * 2
      if fadingBuffer.lifespan <= 0 then
        this.fadingBuffers.removeElement(fadingBuffer)
      end
    end

    if not mouse.pressed or this.stopDrag then
      if not mouse.pressed and this.stopDrag then
        this.stopDrag = false
      end

      if this.points.length < 2 then
        return
      end
      
      this.points = []

      local copiedBuffer = new Image(screen.width, screen.height, true)
      copiedBuffer.drawImage(this.staticShadowBuffer, 0, 0, screen.width, screen.height)
      if global.graphicsMode != global.GRAPHICS_LOW then
        copiedBuffer.drawImage(this.dynamicShadowBuffer, 0, 0, screen.width, screen.height)
      end
  
      copiedBuffer.drawImage(this.staticLineBuffer, 0, 0, screen.width, screen.height)
      if global.graphicsMode != global.GRAPHICS_LOW then
        copiedBuffer.drawImage(this.dynamicLineBuffer, 0, 0, screen.width, screen.height)
      end
      
      this.fadingBuffers.push(object
        buffer = copiedBuffer
        lifespan = 1
      end)
      
      this.refreshStaticBuffers()
      this.refreshDynamicBuffers()
      return
    end
    
    if not this.points.length then
      this.addPoint(object
        thickness = 0
        x = mouse.x
        y = mouse.y
      end)
      
      return
    end

    local previousPoint = this.points[this.points.length - 1]
    local distance = sqrt(pow(mouse.x - previousPoint.x, 2) + pow(mouse.y - previousPoint.y, 2))
    if distance > 5 then
      this.addPoint(object
        thickness = min(max(distance / 5, 3), 10)
        x = mouse.x
        y = mouse.y
      end)
    end
  end
  
  draw = function()
    this.player.game.drawPool.push(this.drawRequest)
  end
end