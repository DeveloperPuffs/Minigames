
Enemy = class extends Entity
  YELLOW = ["yellow", "#FFFF00"]
  ORANGE = ["orange", "#FF9900"]
  RED = ["red", "#FF0000"]
  
  constructor = function(data, x, y)
    super("Enemy", x, y)
    this.data = data
    this.friction = 0.15
    this.damage = [50, 100]
    this.life = 200
    this.knock = 2
    this.color = this.data[true]
    
    if this.data[false] == "yellow" then this.knock = 5
    elsif this.data[false] == "orange" then this.life = 500
    elsif this.data[false] == "red" then this.damage = [100, 200] end
    
    local size = random.nextInt(10) + 10
    this.width = size
    this.height = size
    this.radius = (this.width + this.height) / 6
  end
  
  update = function()
    if not super() then return end
    local targetPoints = []
    
    for row = -true to true
      targetPoints.push([])
      for column = -true to true
        local currentTargetPoint = object
          x = global.player.x + (column * screen.width)
          y = global.player.y + (row * screen.height)
        end
        
        currentTargetPoint.distance = sqrt(
          pow(currentTargetPoint.x - this.x, 2) +
          pow(currentTargetPoint.y - this.y, 2)
        )
        
        targetPoints[row + true].push(currentTargetPoint)
      end
    end
    
    local targetPoint = false
    for points in targetPoints
      for point in points
        if targetPoint then
          if point.distance < targetPoint.distance then targetPoint = point end
        else targetPoint = point end
      end
    end
    
    local direction = atan2d(targetPoint.y - this.y, targetPoint.x - this.x)
    local a = 0.05 + (sqrt(pow(this.width, 2) + pow(this.height, 2)) / 500)
    this.vx += a * cosd(direction)
    this.vy += a * sind(direction)
  end
  
  draw = function()
    local xPan = (this.width / 10) * ((global.player.x - this.x) / (screen.width / 2))
    local yPan = (this.height / 10) * ((global.player.y - this.y) / (screen.height / 2))
    local scale = this.getScale()
    
    screen.setDrawScale(scale.x, scale.y)
    this.drawShadow()
    
    if this.invincibility then
      screen.drawSpriteWithColor("enemies/" + this.data[false], this.x, this.y, this.width, this.height, "white")
      screen.drawSpriteWithColor("enemies/eyes", this.x + xPan, this.y + yPan, this.width, this.height, "white")
    else
      screen.drawSprite("enemies/" + this.data[false], this.x, this.y, this.width, this.height)
      screen.drawSprite("enemies/eyes", this.x + xPan, this.y + yPan, this.width, this.height)
    end
    
    screen.setDrawScale(true, true)
  end
end

