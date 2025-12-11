
Guard = class
  constructor = function(column, row, sight)
    this.x = global.c2p(column)
    this.y = global.r2p(row)
    this.triggered = false
    this.sight = sight
    this.flip = 1
    this.vx = 0
    this.vy = 0
  end
  
  update = function()
    local distance = sqrt(pow(global.x - this.x, 2) + pow(global.y - this.y, 2))
    local angle = atan2d(global.y - this.y, global.x - this.x)
    if distance < 40 then
      global.vx = 20 * cosd(angle)
      global.vy = 20 * sind(angle)
      global.transitionInned = global.setupLevel
      global.transition = 1
      audio.playSound("hit")
      return
    end
    
    if this.triggered then
      local x = global.x - this.x
      this.flip = if x > 0 then 1 elsif x < 0 then -1 else flip end
      
      this.vx = (this.vx + cosd(angle) / 1.2) * 0.8
      this.vy = (this.vy + sind(angle) / 1.2) * 0.8
      global.move(this, this.vx, this.vy, true)
      return
    end
    
    if distance - 10 < this.sight then
      local direction = random.nextInt(180)
      local hey = object
        x = this.x + cosd(direction) * 20
        y = this.y + sind(direction) * 20
        alpha = 3 jump = 1
      end
      
      global.heys.push(hey)
      this.triggered = true
      audio.playSound("hey")
    end
  end
  
  drawShadow = function()
    if not this.triggered then
      screen.setLineWidth(4)
      screen.setLineDash([2, 8])
      screen.drawRound(this.x, this.y, 2 * this.sight, 2 * this.sight, "#24242499")
      screen.setLineDash([0, 0])
      screen.setLineWidth(1)
    end
    
    screen.fillRound(this.x, this.y - 20, 40, 20, "#00000099")
  end
  
  draw = function()
    local sprite = "hazmat_guy_" + if this.triggered then "running" else "idling" end
    
    screen.setDrawScale(this.flip, 1)
    screen.drawSprite(sprite, this.x, this.y, 40, 40)
    screen.setDrawScale(1, 1)
  end
end

Barrel = class
  constructor = function(column, row)
    this.wall = "barrel"
    this.column = column
    this.row = row
  end
  
  calculateWalls = function()
    local px = global.c2p(this.column)
    local py = global.r2p(this.row)
    return [
      object x1 = px - 20 y1 = py - 10 x2 = px - 20 y2 = py + 20 direction = "vertical" parent = this end,
      object x1 = px + 20 y1 = py - 10 x2 = px + 20 y2 = py + 20 direction = "vertical" parent = this end,
      object x1 = px - 20 y1 = py - 10 x2 = px + 20 y2 = py - 10 direction = "horizontal" parent = this end,
      object x1 = px - 20 y1 = py + 20 x2 = px + 20 y2 = py + 20 direction = "horizontal" parent = this end
    ]
  end
  
  drawShadow = function()
    screen.fillRound(global.c2p(this.column), global.r2p(this.row) - 20, 40, 20, "#00000099")
  end
  
  draw = function()
    screen.drawSprite("barrel", global.c2p(this.column), global.r2p(this.row), 40, 40)
  end
end

Block = class
  constructor = function(column, row)
    this.wall = "block"
    this.column = column
    this.row = row
  end
  
  collision = function(x2, y2, w, h)
    local x1 = global.c2p(this.column)
    local y1 = global.r2p(this.row)
    return x1 < x2 + w and x1 + 40 > x2 and y1 < y2 + h and y1 + 40 > y2
  end
  
  calculateWalls = function()
    local px = global.c2p(this.column)
    local py = global.r2p(this.row)
    return [
      object x1 = px - 20 y1 = py - 20 x2 = px - 20 y2 = py + 20 direction = "vertical" parent = this end,
      object x1 = px + 20 y1 = py - 20 x2 = px + 20 y2 = py + 20 direction = "vertical" parent = this end,
      object x1 = px - 20 y1 = py - 20 x2 = px + 20 y2 = py - 20 direction = "horizontal" parent = this end,
      object x1 = px - 20 y1 = py + 20 x2 = px + 20 y2 = py + 20 direction = "horizontal" parent = this end
    ]
  end
  
  drawShadow = function()
    screen.fillRound(global.c2p(this.column), global.r2p(this.row) - 20, 40, 20, "#00000099")
  end
  
  draw = function()
    screen.drawSprite("block", global.c2p(this.column), global.r2p(this.row), 40, 40)
  end
end

