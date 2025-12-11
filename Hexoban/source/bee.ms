
Bee = class
  TURN = "Turn"
  MOVE = "Move"
  
  constructor = function(beehive, column, row)
    this.beehive = beehive
    this.entityType = Beehive.BEE
    
    this._column = column
    this._row = row
    this.column = column
    this.row = row
    
    local position = this.beehive.getPosition(column, row)
    this.x = position.x
    this.y = position.y
    this.tween = 0
    
    this._direction = this.beehive.level.startAngle
    this.direction = this._direction
    
    this.animation = false
    this.lerp = function(a, b, t) return ((1 - t) * a) + (t * b) end
    this.scale = 1
    
    this.wingsAngle = 40
    this.wingsAnimation = false
    
    this.float = object x = 0 y = 0 angular = 0 end
  end
  
  generateDirection = function(orientation)
    local direction = if orientation == Beehive.POINTY then 0 else 30 end
    return round(direction + (60 * random.nextInt(6)))
  end
  
  update = function()
    this.float.x = cos(system.time() / 400)
    this.float.y = sin(system.time() / 400)
    this.float.angular = (this.float.x + this.float.y) / 2
    
    this.scale = this.lerp(this.scale, 1, 0.1)
    
    local rotation = keyboard.press.LEFT - keyboard.press.RIGHT
    if rotation and not this.animation then
      audio.playSound("turn", 0.5)
      global.turnCounter += 1
      this.scale = 1.1
      this.flap(0.5)
      
      local turn = object end
      turn.moveType = Bee.TURN
      turn.start = this.direction
      this.beehive.moves.push(turn)
      
      this.turnTo(round(this.direction + (rotation * 60)))
    end
    
    local unit = keyboard.press.UP - keyboard.press.DOWN
    if unit and not this.animation then
      this.scale = 1.2
      this.flap(1)
      
      local tile = this.beehive.move(this, this.column, this.row, this._direction, unit)
      if tile then
        if not this.beehive.pushed.length then audio.playSound("move", 1) end
        global.moveCounter += 1
        
        this.moveTo(tile.column, tile.row)
        
        local move = object end
        move.moveType = Bee.MOVE
        move.direction = this._direction
        move.undo = -unit
        move.blocks = this.beehive.pushed
        this.beehive.moves.push(move)
      else
        audio.playSound("hit", 1)
        this.beehive.shake(0.5)
      end
    end
    
    if this.tween then
      local start = this.beehive.getPosition(this.column, this.row)
      local target = this.beehive.getPosition(this._column, this._row)
      
      this.x = this.lerp(start.x, target.x, this.tween)
      this.y = this.lerp(start.y, target.y, this.tween)
    end
  end
  
  turnTo = function(direction)
    this._direction = direction
    this.animation = TweenService.createTween(this, "direction", this.direction, this._direction, 0.1, Tween.sineInOut)
    this.animation.completionHandlers.push(function(tween) tween.parent.animation = false end)
  end
  
  moveTo = function(column, row)
    this._column = column
    this._row = row
    
    this.animation = TweenService.createTween(this, "tween", this.tween, 1, 0.2, Tween.quadInOut)
    this.animation.completionHandlers.push(function(tween) tween.parent.snap() end)
    this.animation.completionHandlers.push(function(tween) tween.parent.tween = 0 end)
    this.animation.completionHandlers.push(function(tween) tween.parent.animation = false end)
  end
  
  flap = function(amount)
    this.wingsAnimation = TweenService.createTween(this, "wingsAngle", this.wingsAngle, (amount + 1) * 40, 0.1, Tween.quadIn)
    this.wingsAnimation.completionHandlers.push(function(tween)
      tween.parent.wingsAnimation = TweenService.createTween(tween.parent, "wingsAngle", tween.parent.wingsAngle, 40, 0.1, Tween.quadOut)
      tween.parent.wingsAnimation.completionHandlers.push(function(innerTween) innerTween.parent.wingsAnimation = false end)
    end)
  end
  
  snap = function()
    this.column = this._column
    this.row = this._row
  end
  
  draw = function()
    screen.setTranslation(this.x + this.float.x, this.y + this.float.y)
    screen.setRotation(((this.direction - 90) % 360) + (this.float.angular * 10))
    screen.setScale(0.5 * this.scale, 0.5 * this.scale)
    
    screen.setLineWidth(4)
  
    screen.drawArc(0, 6, 6, 0, 180, true, Palette.darkBrown)
    screen.drawArc(0, -6, 6, 0, 180, false, Palette.darkBrown)
    screen.drawRect(0, 0, 12, 12, Palette.darkBrown)
    
    screen.fillArc(0, 6, 6, 0, 180, true, Palette.yellow)
    
    screen.fillRect(0, 4, 12, 4, Palette.darkBrown)
    screen.fillRect(0, 0, 12, 4, Palette.yellow)
    screen.fillRect(0, -4, 12, 4, Palette.darkBrown)
    
    screen.fillArc(0, -6, 6, 0, 180, false, Palette.yellow)
    
    screen.setLineWidth(2)
    
    local v1 = (this.wingsAngle - 40) / 4
    local v2 = v1 / 2
    
    screen.drawBezierCurve(-4, 12, -6, 18 - v2, -8, 18 - v1, -12, 18 - v1, Palette.darkBrown)
    screen.fillRound(-12, 18 - v1, 3, 3, Palette.darkBrown)
    
    screen.drawBezierCurve(4, 12, 6, 18 - v2, 8, 18 - v1, 12, 18 - v1, Palette.darkBrown)
    screen.fillRound(12, 18 - v1, 3, 3, Palette.darkBrown)
    
    screen.fillPolygon(0, -16, -4, -12, 4, -12, 0, -16, Palette.darkBrown)
    
    screen.setLineWidth(4)
    
    screen.setDrawRotation(-this.wingsAngle)
    screen.setDrawAnchor(0, 1)
    
    screen.drawRound(1, 4, 8, 20, Palette.darkBrown)
    screen.fillRound(1, 4, 8, 20, Palette.lightYellow)
    
    screen.setDrawRotation(this.wingsAngle)
    screen.setDrawAnchor(0, 1)
    
    screen.drawRound(-1, 4, 8, 20, Palette.darkBrown)
    screen.fillRound(-1, 4, 8, 20, Palette.lightYellow)
    
    screen.setDrawAnchor(0, 0)
    screen.setDrawRotation(0)
    
    screen.setLineWidth(1)
    
    screen.setRotation(0)
    screen.setTranslation(0, 0)
    screen.setScale(1, 1)
  end
end

