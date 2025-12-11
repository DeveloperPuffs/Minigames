
global.calculateIntersection = function(px, py, angle, walls)
  local intersections = []
  
  for wall in walls
    local dx = cosd(angle)
    local dy = sind(angle)
    local ix = 0
    local iy = 0
    local t = 0
    
    if wall.direction == "vertical" then
      t = (wall.x1 - px) / dx
      iy = py + dy * t
      ix = wall.x1
      
      if t > 0 and iy >= min(wall.y1, wall.y2) and iy <= max(wall.y1, wall.y2) then
        intersections.push(object x = ix y = iy t = t data = wall end)
      end
    elsif wall.direction == "horizontal" then
      t = (wall.y1 - py) / dy
      ix = px + dx * t
      iy = wall.y1
      
      if t > 0 and ix >= min(wall.x1, wall.x2) and ix <= max(wall.x1, wall.x2) then
        intersections.push(object x = ix y = iy t = t data = wall end)
      end
    end
  end
  
  intersections.sortList(function(a, b) return a.t - b.t end)
  return intersections[0]
end

global.calculateTrajectory = function()
  global.points = [[x, y]]
  global.gonnaExplode = []
  
  local walls = []
  for block in blocks walls = walls.concat(block.calculateWalls()) end
  for barrel in barrels walls = walls.concat(barrel.calculateWalls()) end
  
  local border = object wall = "border" end
  walls = walls.concat([
    object x1 = -320 y1 = -180 x2 = -320 y2 = 180 direction = "vertical" parent = border end,
    object x1 = 320 y1 = -180 x2 = 320 y2 = 180 direction = "vertical" parent = border end,
    object x1 = -320 y1 = 180 x2 = 320 y2 = 180 direction = "horizontal" parent = border end,
    object x1 = -320 y1 = -180 x2 = 320 y2 = -180 direction = "horizontal" parent = border end
  ])
  
  local scale = screen.height / 360
  local angle = atan2d(mouse.y / scale - y, mouse.x / scale - x)
  
  local t = 800
  local px = x
  local py = y
  local epsilon = 1
  while true
    local intersection = global.calculateIntersection(px, py, angle, walls)
    
    t -= intersection.t
    if t < 0 then
      t += intersection.t
      points.push([px + cosd(angle) * t, py + sind(angle) * t])
      break
    end
    
    px = intersection.x - epsilon * cosd(angle)
    py = intersection.y - epsilon * sind(angle)
    points.push([px, py])
    
    if intersection.data.direction == "horizontal" then
      angle = -angle
    else
      angle = 180 - angle
    end
    
    if intersection.data.parent.wall == "barrel" then
      if not global.gonnaExplode.includes(intersection.data.parent) then
        global.gonnaExplode.push(intersection.data.parent)
      end
    end
  end
end

