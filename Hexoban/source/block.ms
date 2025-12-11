
Block = class
  constructor = function(beehive, column, row)
    this.beehive = beehive
    this.entityType = Beehive.BLOCK
    
    this._column = column
    this._row = row
    this.column = column
    this.row = row
    
    local position = this.beehive.getPosition(column, row)
    this.x = position.x
    this.y = position.y
    this.tween = 0
    
    this.animation = false
    this.lerp = function(a, b, t) return ((1 - t) * a) + (t * b) end
    this.scale = 1
  end
  
  push = function(column, row)
    audio.playSound("push", 1)
    this.beehive.pushed.push(this)
    this.scale = 1.2
    
    this._column = column
    this._row = row
    
    this.animation = TweenService.createTween(this, "tween", this.tween, 1, 0.1, Tween.quadInOut)
    this.animation.completionHandlers.push(function(tween) tween.parent.snap() end)
    this.animation.completionHandlers.push(function(tween) tween.parent.tween = 0 end)
    this.animation.completionHandlers.push(function(tween) tween.parent.animation = false end)
    this.animation.completionHandlers.push(function(tween) tween.parent.beehive.check() end)
  end
  
  snap = function()
    this.column = this._column
    this.row = this._row
    
    local value = this.beehive.grid[this.row][this.column]
    if Grid.slots.contains(value) then audio.playSound("placed", 2) end
  end
  
  update = function()
    this.scale = lerp(this.scale, 1, 0.1)
    
    if this.tween then
      local start = this.beehive.getPosition(this.column, this.row)
      local target = this.beehive.getPosition(this._column, this._row)
      
      this.x = this.lerp(start.x, target.x, this.tween)
      this.y = this.lerp(start.y, target.y, this.tween)
    end
  end
  
  draw = function()
    screen.setScale(this.scale, this.scale)
    screen.setTranslation(this.x, this.y)
    
    if this.beehive.orientation == Beehive.FLAT then
      screen.fillFlatToppedHexagon(0, 0, this.beehive.sideLength / 2, Palette.gold)
      screen.fillFlatToppedHexagon(0, 2, this.beehive.sideLength / 2, Palette.lightYellow)
    elsif this.beehive.orientation == Beehive.POINTY then
      screen.fillPointyToppedHexagon(0, 0, this.beehive.sideLength / 2, Palette.gold)
      screen.fillPointyToppedHexagon(0, 2, this.beehive.sideLength / 2, Palette.lightYellow)
    end
    
    screen.setTranslation(0, 0)
    screen.setScale(1, 1)
  end
end

