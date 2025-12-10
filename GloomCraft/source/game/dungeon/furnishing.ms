
global.furnish = function(game)
  local enemyTypes = [
    global.Enemy.PURPLE_SLIME,
    global.Enemy.ORANGE_SLIME,
    global.Enemy.GREEN_SLIME,
    global.Enemy.BLUE_SLIME
  ]
  
  local getChances = function()
    local chances = object end
    chances.treasureChest = 0.8
    chances.enemies = 0.6
    chances.craftingBench = 0.4
    chances.shopStand = 0.2
    return chances
  end
  
  local getSpots = function(dungeon, room)
    local spots = []
    
    for row = 0 to room.height - 1
      for column = 0 to room.width - 1
        local spotRow = room.row + row
        local spotColumn = room.column + column
        
        local neighbors = [
          dungeon.tilemap[spotRow - 1][spotColumn],
          dungeon.tilemap[spotRow + 1][spotColumn],
          dungeon.tilemap[spotRow][spotColumn - 1],
          dungeon.tilemap[spotRow][spotColumn + 1]
        ]
        
        if not neighbors.contains(global.Dungeon.TUNNEL) then
          if dungeon.tilemap[spotRow][spotColumn] == global.Dungeon.ROOM then
            spots.push([spotColumn, spotRow])
          end
        end
      end
    end
    
    return spots
  end
  
  local getFitSpots = function(spots, width, height)
    local fitSpots = []
    
    for spot in spots
      local valid = true
      
      for row = 0 to height - 1
        for column = 0 to width - 1
          if not (column + row) then continue end
          local newSpot = [spot[0] + column, spot[1] + row]
          
          local subValid = false
          for otherSpot in spots
            if otherSpot[0] == newSpot[0] and otherSpot[1] == newSpot[1] then
              subValid = true
            end
          end
          
          if not subValid then valid = false end
        end
      end
      
      if valid then fitSpots.push(spot) end
    end
    
    return fitSpots
  end
  
  local applyFurniture = function(spots, spot, width, height)
    for row = 0 to height - 1
      for column = 0 to width - 1
        local newColumn = spot[0] + column
        local newRow = spot[1] + row
        game.dungeon.tilemap[newRow][newColumn] = global.Dungeon.FURNITURE
        
        for otherSpot in spots
          if otherSpot[0] == newColumn and otherSpot[1] == newRow then
            spots.removeElement(otherSpot)
          end
        end
      end
    end
  end
  
  local placeFurniture = function(game, furniture, spots, width, height)
    local fitSpots = getFitSpots(spots, width, height)
    local spot = random.choice(fitSpots)
    applyFurniture(spots, spot, width, height)
    
    local instance = new furniture(game, spot)
    instance.x = (spot[0] + (width / 2)) * 16
    instance.y = (spot[1] + (height / 2)) * 16
    instance.interaction.x = instance.x
    instance.interaction.y = instance.y + (height * 8)
    game.furniture.push(instance)
  end
  
  for room in game.dungeon.rooms
    local spots = getSpots(game.dungeon, room)
    
    local chances = getChances()
    if room == game.dungeon.startRoom then chances.enemies = 0 end
    
    if random.next() < chances.shopStand then
      placeFurniture(game, global.ShopStand, spots, 2, 2)
      chances.craftingBench = 0
      chances.treasureChest = 0
    end
    
    if random.next() < chances.craftingBench then
      placeFurniture(game, global.CraftingBench, spots, 2, 1)
      chances.treasureChest = 0
    end
    
    if random.next() < chances.treasureChest then
      placeFurniture(game, global.TreasureChest, spots, 1, 1)
    end
    
    if random.next() < chances.enemies then
      local count = ceil(spots.length / 16)
      for _ = 0 to count - 1
        local spot = random.choice(spots)
        spots.removeElement(spot)
        
        local enemy = new global.Enemy(game, random.choice(enemyTypes))
        enemy.x = (spot[0] + 0.5) * 16
        enemy.y = (spot[1] + 0.5) * 16
        enemy.updateHitbox()
        game.entities.push(enemy)
      end
    end
  end
end

