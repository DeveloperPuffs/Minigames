
global.laserCollision = function(x, y, tail)
  local collision = function(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    local lengthSquared = dx * dx + dy * dy
    local t = ((x - x1) * dx + (y - y1) * dy) / lengthSquared
    t = max(0, min(1, t))
    
    local closestX = x1 + t * dx
    local closestY = y1 + t * dy
    local distanceSquared = pow(x - closestX, 2) + pow(y - closestY, 2)
    return distanceSquared <= 400
  end
  
  local lines = [[]]
  for point in global.points
    lines[lines.length - 1].push(point)
    lines.push([point])
  end
  
  lines.pop()
  lines.removeAt(0)
  if not tail then lines.removeAt(0) end
  
  for line in lines
    if collision(line[0][0], line[0][1], line[1][0], line[1][1]) then
      return true
    end
  end
  
  return false
end

global.move = function(thing, mx, my, brute)
  local collision = function()
    for block in global.blocks
      if block.collision(thing.x, thing.y, 30, 30) then return true end
    end
    return false
  end
  
  local horizontally = function(units)
    local steps = abs(units)
    local step = units / steps
    
    for _ = 1 to steps
      thing.x += step
      
      if collision() then
        thing.x -= step
        return
      end
    end
  end
  
  local vertically = function(units)
    local steps = abs(units)
    local step = units / steps
    
    for _ = 1 to steps
      thing.y += step
      
      if collision() then
        thing.y -= step
        return
      end
    end
  end
  
  if mx >= my then
    horizontally(round(mx))
    vertically(round(my))
  else
    vertically(round(my))
    horizontally(round(mx))
  end
  
  for barrel in global.barrels
    local x2 = global.c2p(barrel.column)
    local y2 = global.r2p(barrel.row) + 10
    local dist = sqrt(pow(thing.x - x2, 2) + pow(thing.y - y2, 2))
    if dist < 30 then
      local overshot = 30 - dist
      local angle = atan2d(thing.y - y2, thing.x - x2)
      thing.x += cosd(angle) * overshot
      thing.y += sind(angle) * overshot
    end
  end
  
  if brute then
    for guard in global.guards
      if thing == guard then continue end
      local x2 = guard.x
      local y2 = guard.y
      local dist = sqrt(pow(thing.x - x2, 2) + pow(thing.y - y2, 2))
      if dist < 20 then
        local overshot = 20 - dist
        local angle = atan2d(thing.y - y2, thing.x - x2)
        thing.x += cosd(angle) * overshot
        thing.y += sind(angle) * overshot
      end
    end
  end
  
  if abs(thing.x) > 300 then thing.x = 300 * (thing.x / abs(thing.x)) end
  if abs(thing.y) > 160 then thing.y = 160 * (thing.y / abs(thing.y)) end
end

