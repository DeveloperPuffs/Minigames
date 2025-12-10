
Player = class
  constructor = function(island, boat, treasure, camera)
    this.island = island
    this.boat = boat
    this.treasure = treasure
    this.camera = camera
    this.x = boat.x
    this.y = boat.y
    
    this.acceleration = 800
    this.friction = 10
    
    this.boating = true
      
    this.vx = 0
    this.vy = 0
      
    this.flip = 1
    this.canBoat = true
    
    this.steppingFrames = 0
    this.nextStep = random.nextInt(5) + 15
    
    this.xHand = 0
    this.yHand = 0
    this.handAngle = 0
    this.handOffset = 8
    this.digging = false
    
    this.shadowDrawing = new Drawing(
      this, 2, function()
        screen.drawSprite("shadow", this.parent.x, this.parent.y - 8, 16, 4)
      end)
    
    this.drawing = new Drawing(
      this, 7, function()
        if this.parent.boating then
          screen.setDrawScale(boat.flip, 1)
          screen.drawSprite(
            "idle",
            this.parent.boat.x + this.parent.boat.xWave,
            this.parent.boat.y + this.parent.boat.yWave,
            16, 16)
          screen.setDrawScale(1, 1)
        else
          local spriteName = if round(sqrt(pow(this.parent.vx, 2) + pow(this.parent.vy, 2))) then "running" else "idle" end
          screen.setDrawScale(this.parent.flip, 1)
          screen.drawSprite(spriteName, this.parent.x, this.parent.y, 16, 16)
          screen.setDrawScale(1, 1)
        end
      end)
      
    this.handDrawing = new Drawing(
      this, 8, function()
        screen.setDrawRotation(this.parent.handAngle)
        screen.drawSprite("hand", this.parent.xHand, this.parent.yHand, 4, 4)
        screen.setDrawRotation(0)
      end)
  end
  
  update = function()
    if keyboard.press.SPACE then
      if this.boating then this.boatOff()
      else this.boatOn() end
    end
    
    if mouse.press then
      if not this.digging then
        audio.playSound("dig", 0.2)
        this.dig()
      end
    end

    local leftInput = keyboard.LEFT or gamepad.LEFT
    local rightInput = keyboard.RIGHT or gamepad.RIGHT
      
    local upInput = keyboard.UP or gamepad.UP
    local downInput = keyboard.DOWN or gamepad.DOWN
      
    local horizontalInput = rightInput - leftInput
    local verticalInput = upInput - downInput
    
    this.boat.update()
    
    local entity = if this.boating then this.boat else this end
    local colliderMap = if this.boating then 0 else this.island.landColliderMap end
    global.accelerate(entity, horizontalInput, verticalInput)
    global.applyPhysics(entity, 10, colliderMap)
    
    if this.boating then
      this.x = this.boat.x
      this.y = this.boat.y
      
      this.xHand = this.x + this.boat.xWave
      this.yHand = this.y + this.boat.yWave
      
      this.camera.ox = this.boat.x + this.boat.xWave
      this.camera.oy = this.boat.y + this.boat.yWave
      this.boat.flip = if horizontalInput then horizontalInput else this.boat.flip end
        
      if this.steppingFrames then
        this.steppingFrames = 0
      end
    else
      local boatDistance = sqrt(pow(this.boat.x - this.x, 2) + pow(this.boat.y - this.y, 2))
      local canBoat = boatDistance <= 32
      
      if this.canBoat then
        if not canBoat then
          this.canBoat = false
          
          if this.boat.radiusTween.tween then TweenService.removeTween(this.boat.radiusTween) end
          this.boat.radiusTween = TweenService.newTween(this.boat, "radiusAlpha", this.boat.radiusAlpha, 0, 0.2, Tween.sineInOut)
        end
      else
        if canBoat then
          this.canBoat = true
          
          if this.boat.radiusTween.tween then TweenService.removeTween(this.boat.radiusTween) end
          this.boat.radiusTween = TweenService.newTween(this.boat, "radiusAlpha", this.boat.radiusAlpha, 0.2, 0.2, Tween.sineInOut)
        end
      end
      
      if round(sqrt(pow(this.vx, 2) + pow(this.vy, 2))) then
        this.steppingFrames += 1
        
        if this.steppingFrames > this.nextStep then
          this.nextStep = random.nextInt(5) + 15
          this.steppingFrames = 0
          audio.playSound("step", 0.1)
        end
      else this.steppingFrames = 0 end
      
      this.xHand = this.x
      this.yHand = this.y
      
      this.camera.ox = this.x
      this.camera.oy = this.y
      this.flip = if horizontalInput then horizontalInput else this.flip end
    end
    
    this.handAngle = atan2d(
      mouse.y - (this.yHand - this.camera.y),
      mouse.x - (this.xHand - this.camera.x))
    this.xHand += cosd(this.handAngle) * this.handOffset
    this.yHand += sind(this.handAngle) * this.handOffset
  end
  
  boatOn = function()
    if this.boating then return end
    if this.canBoat then
      this.boating = true
      
      if this.boat.radiusTween.tween then TweenService.removeTween(this.boat.radiusTween) end
      this.boat.radiusTween = TweenService.newTween(this.boat, "radiusAlpha", this.boat.radiusAlpha, 0, 0.2, Tween.sineInOut)
    else screen.shake(5, 50, 5) end
  end
  
  boatOff = function()
    if not this.boating then return end
    if this.boat.onLand then
      this.boating = false
    
      if this.boat.radiusTween.tween then TweenService.removeTween(this.boat.radiusTween) end
      this.boat.radiusTween = TweenService.newTween(this.boat, "radiusAlpha", this.boat.radiusAlpha, 0.2, 0.2, Tween.sineInOut)
    else screen.shake(5, 50, 5) end
  end
  
  calculateFriction = function()
    local x = floor(this.x / 16)
    local y = floor((this.y - 8) / 16)
    return if this.island.grassColliderMap[y][x] then 8 else 12 end
  end
  
  dig = function()
    this.digging = true
    TweenService.newTween(this, "handOffset", this.handOffset, 16, 0.1, Tween.cubeOut, function()
      this.parent.treasure.dig(this.parent.xHand, this.parent.yHand)
      TweenService.newTween(this.parent, "handOffset", this.parent.handOffset, 8, 0.2, Tween.cubeOut, function()
        this.parent.digging = false
        end)
    end)
  end
  
  draw = function()
    if not this.boating then this.shadowDrawing.enqueue() end
    this.drawing.enqueue()
    this.handDrawing.enqueue()
    this.boat.draw()
  end
end




