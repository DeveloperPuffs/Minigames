
global.getCulledSurfaces = function(surfaces, position)
  local distance = sqrt(pow(screen.width, 2) + pow(screen.height, 2)) / 2
  local culledSurfaces = []
  
  for surface in surfaces
    local distance1 = sqrt(
      pow(position[0] - surface.x1, 2) + pow(position[1] - surface.y1, 2)
    )
    
    local distance2 = sqrt(
      pow(position[0] - surface.x2, 2) + pow(position[1] - surface.y2, 2)
    )
    
    if distance1 < distance or distance2 < distance then
      culledSurfaces.push(surface)
    end
  end
  
  return culledSurfaces
end

global.getLightmap = function(dungeon)
  local lightmap = []
  for row = 0 to dungeon.rows - 1
    lightmap.push([])
    for column = 0 to dungeon.columns - 1
      if dungeon.tilemap[row][column] == global.Dungeon.WALL then
        if row then
          if not (dungeon.tilemap[row - 1][column] == global.Dungeon.WALL) then
            lightmap[row].push(true)
          else lightmap[row].push(false) end
        else lightmap[row].push(false) end
      else lightmap[row].push(true) end
    end
  end
  
  return lightmap
end

global.getSurfaces = function(dungeon)
  local lightmap = global.getLightmap(dungeon)
  local buffer = 1
  
  local surfaces = []
  for row = 0 to dungeon.rows - 1
    for column = 0 to dungeon.columns - 1
      local c = [(column + 0.5) * 16, (row + 0.5) * 16]
      
      if lightmap[row][column] then
        if (
          dungeon.tilemap[row][column] == global.Dungeon.WALL and
          not (dungeon.tilemap[row - 1][column] == global.Dungeon.WALL) and
          not (dungeon.tilemap[row + 1][column] == global.Dungeon.WALL)
        ) then
          local lr = if lightmap[row][column - 1] then 0 else -6 end
          local rr = if lightmap[row][column + 1] then 0 else 6 end
          
          local surface = new global.Surface(
            c[0] + 8 + rr, c[1] + 8, c[0] - 8 + lr, c[1] + 8
          )
          
          surface.direction = "BOTTOM"
          surfaces.push(surface)
        end
        
        continue
      end
      
      if row then
        if lightmap[row - 1][column] then
          local lr = 0
          if not lightmap[row - 1][column - 1] then lr = -6
          elsif (
            lightmap[row][column - 1] and
            not (dungeon.tilemap[row - 1][column - 1] == global.Dungeon.WALL)
          ) then lr = 6 end
          
          local rr = 0
          if not lightmap[row - 1][column + 1] then rr = 6
          elsif (
            lightmap[row][column + 1] and
            not (dungeon.tilemap[row - 1][column + 1] == global.Dungeon.WALL)
          ) then rr = -6 end
          
          local surface = new global.Surface(
            c[0] + 8 + rr + buffer, c[1] - 8, c[0] - 8 + lr - buffer, c[1] - 8
          )
          
          surface.direction = "BOTTOM"
          surfaces.push(surface)
        end
      end
      
      if column then
        if lightmap[row][column - 1] then
          local br = if lightmap[row - 1][column] then 0 else -6 end
          local tr = 0
          if (
            lightmap[row + 1][column] and
            not (dungeon.tilemap[row][column - 1] == global.Dungeon.WALL)
          ) then tr = -6 end
          
          local surface = new global.Surface(
            c[0] - 2, c[1] - 8 + br - buffer, c[0] - 2, c[1] + 8 + tr + buffer
          )
          
          surface.direction = "RIGHT"
          surfaces.push(surface)
        end
      end
      
      if not (row == dungeon.rows - 1) then
        if lightmap[row + 1][column] then
          local lr = 0
          if lightmap[row + 1][column - 1] then
            if lightmap[row][column - 1] then lr = 6 end
          else lr = -6 end
          
          local rr = 0
          if lightmap[row + 1][column + 1] then
            if lightmap[row][column + 1] then rr = -6 end
          else rr = 6 end
          
          local surface = new global.Surface(
            c[0] + 8 + rr + buffer, c[1] + 2, c[0] - 8 + lr - buffer, c[1] + 2
          )
          
          surface.direction = "TOP"
          surfaces.push(surface)
        end
      end
      
      if not (column == dungeon.columns - 1) then
        if lightmap[row][column + 1] then
          local br = if lightmap[row - 1][column] then 0 else -6 end
          local tr = 0
          if (
            lightmap[row + 1][column] and
            not (dungeon.tilemap[row][column + 1] == global.Dungeon.WALL)
          ) then tr = -6 end
          
          local surface = new global.Surface(
            c[0] + 2, c[1] - 8 + br - buffer, c[0] + 2, c[1] + 8 + tr + buffer
          )
          
          surface.direction = "LEFT"
          surfaces.push(surface)
        end
      end
    end
  end
  
  return surfaces
end





