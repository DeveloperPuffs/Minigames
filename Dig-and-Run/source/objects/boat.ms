
Boat = class
  constructor = function(island)
    this.island = island
    this.x = island.spawn[0]
    this.y = island.spawn[1] - 4
  
    this.acceleration = 50
    
    this.xWave = 0
    this.yWave = 0
    this.waveTimer = 0
    
    this.vx = 0
    this.vy = 0
    
    this.flip = 1
    
    this.shadowDrawing = new Drawing(
      this, 2, function()
        screen.setDrawScale(1, 1.5)
        screen.drawSprite("shadow", this.parent.x, this.parent.y - 12, 16, 4)
        screen.setDrawScale(1, 1)
      end)
    
    this.radiusAlpha = 0
    this.radiusTween = 0
    this.radiusDrawing = new Drawing(
      this, 5, function()
        screen.setAlpha(this.parent.radiusAlpha)
        screen.fillRound(
          this.parent.x + this.parent.xWave,
          this.parent.y + this.parent.yWave,
          48, 48, "#FFFFFF")
        screen.setAlpha(1)
      end)
    
    this.drawing = new Drawing(
      this, 6, function()
        screen.setDrawScale(this.parent.flip, 1)
        screen.drawSprite(
          "boat",
          this.parent.x + this.parent.xWave,
          this.parent.y + this.parent.yWave,
          16, 24)
        screen.setDrawScale(1, 1)
      end)
  end
  
  update = function()
    if not this.onLand then
      this.waveTimer += system.deltaTime
      this.xWave = 4 * sin(this.waveTimer)
      this.yWave = 2 * cos(this.waveTimer * 2)
    end
    
    local x = floor(this.x / 16)
    local y = floor((this.y - 12) / 16)
    this.onLand = this.island.waterColliderMap[y][x]
  end
  
  calculateFriction = function()
    return if this.onLand then 5 else 1 end
  end
  
  draw = function()
    this.shadowDrawing.enqueue()
    this.radiusDrawing.enqueue()
    this.drawing.enqueue()
  end
end

