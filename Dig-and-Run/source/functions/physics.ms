
global.accelerate = function(entity, x, y)
  local diagonalMovementFactor = if x and y then 1 / sqrt(2) else 1 end
  local deltaTime = min(system.deltaTime, 1 / entity.calculateFriction())
  
  entity.vx += x * entity.acceleration * diagonalMovementFactor * deltaTime
  entity.vy += y * entity.acceleration * diagonalMovementFactor * deltaTime
end

global.applyPhysics = function(entity, precision, colliderMap)
  local friction = entity.calculateFriction()
  local deltaTime = min(system.deltaTime, 1 / friction)
  
  entity.vx -= entity.vx * friction * deltaTime
  entity.vy -= entity.vy * friction * deltaTime
  
  global.move(entity, "x", round(entity.vx * precision * deltaTime), precision, colliderMap)
  global.move(entity, "y", round(entity.vy * precision * deltaTime), precision, colliderMap)
end

global.move = function(entity, axis, units, precision, colliderMap)
  if not units then return end
  
  local steps = abs(units)
  local step = units / steps
  for _ = 1 to steps
    entity[axis] += step / precision
    
    if colliderMap then
      if global.tilemapCollision(entity.x, entity.y, colliderMap) then
        entity[axis] -= step / precision
        entity["v" + axis] = 0
        return
      end
    end
  end
end

global.tilemapCollision = function(x, y, colliderMap)
  local xTile = floor(x / 16)
  local yTile = floor((y - 8) / 16)
  
  return colliderMap[yTile][xTile]
  
  return (
    colliderMap[yTile][xTile] or
    colliderMap[yTile + 1][xTile] or
    colliderMap[yTile][xTile + 1] or
    colliderMap[yTile + 1][xTile + 1]
  )
end

