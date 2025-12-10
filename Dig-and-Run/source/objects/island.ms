
Island = class
  grass = "grass"
  water = "water"
  empty = "empty"
  
  constructor = function(width, height, smoothness)
    local heightmap = Island.generateHeightmap(width, height, smoothness)
    
    this.tilemap = Island.terrainFromHeightMap(heightmap, width, height, 0.015)
    this.layers = Island.getTileBitmaksedLayers(this.tilemap, width, height)
    
    this.landColliderMap = Island.getColliderMap(this.tilemap, [Island.water], width, height)
    this.grassColliderMap = Island.getColliderMap(this.tilemap, [Island.grass], width, height)
    this.waterColliderMap = Island.getColliderMap(this.tilemap, [Island.grass, Island.empty], width, height)
    
    this.spawn = Island.choosePosition(Island.water, this.tilemap, width, height)
    
    this.treasure = Island.choosePosition(Island.empty, this.tilemap, width, height)
    this.currentTime = 0
    this.wave = 1
    
    this.mapWidth = width
    this.mapHeight = height
    this.width = width * 16
    this.height = height * 16
    
    this.grassDrawing = new Drawing(
      this, 1, function()
        screen.fillRect(
          this.parent.width / 2,
          this.parent.height / 2,
          this.parent.width,
          this.parent.height,
          "#ebb07c")
        screen.drawImage(
          this.parent.layers.grass,
          this.parent.width / 2, this.parent.height / 2,
          this.parent.width, this.parent.height)
      end)
      
    this.waterDrawing = new Drawing(
      this, 4, function()
        screen.setDrawScale(this.parent.wave, this.parent.wave)
        screen.drawImage(
          this.parent.layers.water,
          this.parent.width / 2, this.parent.height / 2,
          this.parent.width, this.parent.height)
        screen.setDrawScale(1, 1)
      end)
  end
  
  update = function()
    this.currentTime += system.deltaTime
    this.wave = 1.02 + (0.02 * sin(this.currentTime * 2))
  end
  
  draw = function()
    this.grassDrawing.enqueue()
    this.waterDrawing.enqueue()
  end
end

/*
Cellular Automata ish algorithm. Thanks microScript for giving 0s
instead of errors with out of range indexes...
*/
Island.generateHeightmap = function(width, height, smoothness)
  local currentHeightmap = []
    
  for row = 0 to height - 1
    currentHeightmap.push([])
    for column = 0 to width - 1
      currentHeightmap[row].push(random.next())
    end
  end
    
  local blockWeight = 9
  for index = 0 to smoothness - 1
    local smoothenedHeightmap = [] + currentHeightmap
      
    for row = 0 to height - 1
      for column = 0 to width - 1
        local weight = 0
          
        for blockRow = -1 to 1
          for blockColumn = -1 to 1
            weight += currentHeightmap[row + blockRow][column + blockColumn]
          end
        end
          
        smoothenedHeightmap[row][column] = weight / blockWeight
      end
    end
      
    currentHeightmap = smoothenedHeightmap
  end
  
  return currentHeightmap
end


Island.terrainFromHeightMap = function(heightmap, width, height, sandHeightGap)
  local tilemap = []
  
  for row = 0 to height - 1
    tilemap.push([])
    for column = 0 to width - 1
      local height = heightmap[row][column]
      if height < 0.5 - sandHeightGap then tilemap[row].push(Island.water)
      elsif height > 0.5 + sandHeightGap then tilemap[row].push(Island.grass)
      else tilemap[row].push(Island.empty)
      end
    end
  end
  
  return tilemap
end

/*
Probably needs some optimization but it should be fine ...
*/
Island.getTileBitmaksedLayers = function(tilemap, width, height)
  local tileBitmaskingRules = Island.getTileBitmaskingRules()
  local getTileBitmaskRules = function(key, row, column, tilemap, rules)
    local block = []
    for blockRow = -1 to 1
      block.push([])
      for blockColumn = -1 to 1
        local tileKey = tilemap[row + blockRow][column + blockColumn]
        if tileKey then block[blockRow + 1].push(tileKey)
        else block[blockRow + 1].push(Island.water) end
      end
    end
    
    local validRules = []
    
    for rule in rules
      local adjacency = rule.adjacency
      local validRule = true
      
      for blockRow = 0 to 2
        for blockColumn = 0 to 2
          local condition = adjacency[blockRow][blockColumn]
          if condition == " " then continue
          elsif condition == "0" then
            if block[blockRow][blockColumn] == key then validRule = false end
          elsif condition == "1" then
            if block[blockRow][blockColumn] != key then validRule = false end
          end
        end
      end
      
      if validRule then validRules.push(rule) end
    end
    
    return validRules
  end
  
  local imageWidth = width * 16
  local imageHeight = height * 16
  local layers = object
    water = new Image(imageWidth, imageHeight, true)
    grass = new Image(imageWidth, imageHeight, true)
  end
  
  for key in [Island.grass, Island.water]
    for row = 0 to height - 1
      for column = 0 to width - 1
        local x = ((column + 0.5) * 16) - (imageWidth / 2)
        local y = ((row + 0.5) * 16) - (imageHeight / 2)
        
        if tilemap[row][column] == key then 
          layers[key].drawSprite(sprites[key].frames[0], x, y, 16, 16)
        end

        for rule in getTileBitmaskRules(key, row, column, tilemap, tileBitmaskingRules)
          layers[key].setDrawRotation(90 * rule.rotationIndex)
          layers[key].drawSprite(sprites[key].frames[rule.spriteIndex], x, y, 16, 16)
          layers[key].setDrawRotation(0)
        end
      end
    end
  end
  
  return layers
end

Island.getTileBitmaskingRules = function()
  [
    object
      adjacency = [
        " 1 ",
        "101",
        " 1 "]
      spriteIndex = 1
      rotationIndex = 0
    end,
    
    object
      adjacency = [
        " 1 ",
        "101",
        " 0 "]
      spriteIndex = 2
      rotationIndex = 0
    end,
    object
      adjacency = [
        " 1 ",
        "001",
        " 1 "]
      spriteIndex = 2
      rotationIndex = 1
    end,
    object
      adjacency = [
        " 0 ",
        "101",
        " 1 "]
      spriteIndex = 2
      rotationIndex = 2
    end,
    object
      adjacency = [
        " 1 ",
        "100",
        " 1 "]
      spriteIndex = 2
      rotationIndex = 3
    end,
    
    object
      adjacency = [
        " 1 ",
        "100",
        " 0 "]
      spriteIndex = 3
      rotationIndex = 0
    end,
    object
      adjacency = [
        " 1 ",
        "001",
        " 0 "]
      spriteIndex = 3
      rotationIndex = 1
    end,
    object
      adjacency = [
        " 0 ",
        "001",
        " 1 "]
      spriteIndex = 3
      rotationIndex = 2
    end,
    object
      adjacency = [
        " 0 ",
        "100",
        " 1 "]
      spriteIndex = 3
      rotationIndex = 3
    end,
    
    object
      adjacency = [
        " 1 ",
        "000",
        "   "]
      spriteIndex = 4
      rotationIndex = 0
    end,
    object
      adjacency = [
        " 0 ",
        " 01",
        " 0 "]
      spriteIndex = 4
      rotationIndex = 1
    end,
    object
      adjacency = [
        "   ",
        "000",
        " 1 "]
      spriteIndex = 4
      rotationIndex = 2
    end,
    object
      adjacency = [
        " 0 ",
        "10 ",
        " 0 "]
      spriteIndex = 4
      rotationIndex = 3
    end,
    
    object
      adjacency = [
        "10 ",
        "00 ",
        "   "]
      spriteIndex = 5
      rotationIndex = 0
    end,
    object
      adjacency = [
        " 01",
        " 00",
        "   "]
      spriteIndex = 5
      rotationIndex = 1
    end,
    object
      adjacency = [
        "   ",
        " 00",
        " 01"]
      spriteIndex = 5
      rotationIndex = 2
    end,
    object
      adjacency = [
        "   ",
        "00 ",
        "10 "]
      spriteIndex = 5
      rotationIndex = 3
    end
  ]
end

Island.getColliderMap = function(tilemap, colliders, width, height)
  local colliderMap = []
  
  for row = 0 to height - 1
    colliderMap.push([])
    for column = 0 to width - 1
      local value = tilemap[row][column]
      colliderMap[row].push(colliders.contains(value))
    end
  end
  
  return colliderMap
end

Island.choosePosition = function(key, tilemap, width, height)
  local spots = []
  local reversed = tilemap.reverse()
  for row = 0 to height - 1
    for column = 0 to width - 1
      if key == reversed[row][column] then spots.push([column, row]) end
    end
  end
  
  local spot = spots[random.nextInt(spots.length)]
  return [(spot[0] + 0.5) * 16, (spot[1] + 0.5) * 16]
end



