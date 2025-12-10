
global.tilemapCollision = function(entity)
  local points = entity.hitbox.rectangle.vertices()
  local colliderMap = entity.game.dungeon.colliderMap
  
  for point in points
    local column = floor(point[0] / 16)
    local row = floor(point[1] / 16)
    if not colliderMap[row][column] then return true end
  end
  
  return false
end

global.move = function(entity, axis, distance)
  local units = round(distance * entity.precision)
  if not units then return end
  
  local steps = abs(units)
  local step = units / steps
  
  for _ = 1 to steps
    entity[axis] += step / entity.precision
    entity.updateHitbox()
    
    if global.tilemapCollision(entity) then
      entity[axis] -= step / entity.precision
      entity["v" + axis] = 0
      return true
    end
  end
  
  return false
end

global.applyPhysics = function(entity)
  local deltaTime = min(global.clock.deltaTime, 1 / entity.friction)
  
  entity.vx -= entity.vx * entity.friction * deltaTime
  entity.vy -= entity.vy * entity.friction * deltaTime
  
  local horizontalCollision = global.move(entity, "x", entity.vx)
  local verticalCollision = global.move(entity, "y", entity.vy)
  
  return horizontalCollision or verticalCollision
end

global.resetForces = function(entity)
  entity.vx = 0
  entity.vy = 0
end

global.applyImpulse = function(entity, x, y)
  entity.vx += x
  entity.vy += y
end

global.updatePhysics = function(entities)
  for entity in entities
    for otherEntity in entities
      if entity == otherEntity then continue end
      
      if entity.hitbox.intersection(
        otherEntity.hitbox, global.Hitbox.CIRCLE
      ) then
        local horizontalDistance = entity.x - otherEntity.x
        local verticalDistance = entity.y - otherEntity.y
        local distance = sqrt(
          pow(horizontalDistance, 2) + pow(verticalDistance, 2)
        )
        
        local overshot = (
          entity.hitbox.circle.radius +
          otherEntity.hitbox.circle.radius
        ) - distance
        
        local horizontalPush = overshot * horizontalDistance / distance
        local verticalPush = overshot * verticalDistance / distance
        
        global.move(entity, "x", horizontalPush)
        global.move(entity, "y", verticalPush)
        
        global.applyImpulse(entity, horizontalPush, verticalPush)
        global.applyImpulse(otherEntity, -horizontalPush, -verticalPush)
        
        if entity.identifier == "player" then
          local damage = otherEntity.damage
          entity.takeDamage(random.integerRange(damage[0], damage[1]))
          global.applyImpulse(
            entity,
            otherEntity.knockback * horizontalDistance / distance,
            otherEntity.knockback * verticalDistance / distance
          )
        elsif otherEntity.identifier == "player" then
          local damage = entity.damage
          otherEntity.takeDamage(random.integerRange(damage[0], damage[1]))
          global.applyImpulse(
            otherEntity,
            entity.knockback * -horizontalDistance / distance,
            entity.knockback * -verticalDistance / distance
          )
        end
      end
    end
  end
end


