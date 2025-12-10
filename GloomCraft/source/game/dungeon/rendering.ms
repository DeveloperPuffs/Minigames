
global.getLayers = function(dungeon)
  local layers = object end
  layers.ground = global.getGround(dungeon)
  layers.walls = global.getWalls(dungeon)
  return layers
end

global.getGround = function(dungeon)
  local groundImage = new Image(dungeon.columns * 16, dungeon.rows * 16, true)
  groundImage.setDrawScale(17 / 16, 17 / -16)
  
  local w = groundImage.width / 2
  local h = groundImage.height / 2
  
  local floorSprite = global.sprites["dungeon/tileset"].frames[0]
  for row = 0 to dungeon.rows - 1
    for column = 0 to dungeon.columns - 1
      if not (dungeon.tilemap[row][column] == global.Dungeon.WALL) then
        groundImage.drawSprite(
          floorSprite,
          ((column + 0.5) * 16) - w,
          ((row + 0.5) * 16) - h,
          16, 16
        )
      end
    end
  end
  
  groundImage.setDrawScale(1, 1)
  return groundImage
end

global.dungeonWallBitmasks = function(dungeon, column, row)
  local indexes = []
  
  local space = function(columnShift, rowShift)
    local newColumn = column + columnShift
    local newRow = row + rowShift
    
    if (
      newRow < 0 or newColumn < 0 or
      newRow >= dungeon.tilemap.length or
      newColumn >= dungeon.tilemap[0].length
    ) then return false end
    
    return not (dungeon.tilemap[newRow][newColumn] == global.Dungeon.WALL)
  end
  
  if space(0, -1) then
    if space(-1, 0) and space(1, 0) then
      indexes.push(4)
    elsif space(-1, 0) then
      indexes.push(1)
    elsif space(1, 0) then
      indexes.push(3)
    else
      indexes.push(2)
    end
    
    return indexes
  end
  
  if space(-1, 0) then
    indexes.push(8)
  end
  
  if space(1, 0) then
    indexes.push(7)
  end
  
  if not space(-1, 0) and space(-1, -1) then
    indexes.push(6)
  end
  
  if not space(1, 0) and space(1, -1) then
    indexes.push(5)
  end
  
  if space(0, 1) then
    if space(-1, 0) and space(1, 0) then
      indexes.push(10)
    elsif space(-1, 0) then
      indexes.push(9)
    elsif space(1, 0) then
      indexes.push(11)
    else
      indexes.push(13)
    end
  end
  
  if space(-1, 1) and not space(-1, 0) and not space(0, 1) then
    indexes.push(14)
  end
  
  if space(1, 1) and not space(1, 0) and not space(0, 1) then
    indexes.push(12)
  end
  
  return indexes
end

global.getWalls = function(dungeon)
  local wallsImage = new Image(dungeon.columns * 16, dungeon.rows * 16, true)
  wallsImage.setDrawScale(17 / 16, 17 / -16)
  
  local w = wallsImage.width / 2
  local h = wallsImage.height / 2
  
  local frames = global.sprites["dungeon/tileset"].frames
  for row = 0 to dungeon.rows - 1
    for column = 0 to dungeon.columns - 1
      if dungeon.tilemap[row][column] == global.Dungeon.WALL then
        for index in global.dungeonWallBitmasks(dungeon, column, row)
          local sprite = frames[index]
          wallsImage.drawSprite(
            sprite,
            ((column + 0.5) * 16) - w,
            ((row + 0.5) * 16) - h,
            16, 16
          )
        end
      end
    end
  end
  
  wallsImage.setDrawScale(1, 1)
  return wallsImage
end



