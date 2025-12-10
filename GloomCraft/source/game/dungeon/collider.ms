
global.getColliderMap = function(dungeon)
  local spaces = [
    global.Dungeon.ROOM, global.Dungeon.TUNNEL,
    global.Dungeon.START, global.Dungeon.FINISH
  ]
  
  local colliderMap = []
  for row = 0 to dungeon.rows - 1
    colliderMap.push([])
    for column = 0 to dungeon.columns - 1
      local collider = spaces.contains(dungeon.tilemap[row][column])
      colliderMap[row].push(collider)
    end
  end
  
  return colliderMap
end

