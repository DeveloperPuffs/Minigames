
Beehive = class
  FLAT = "Flat"
  POINTY = "Pointy"
  
  BEE = "Bee"
  BLOCK = "Block"
  
  constructor = function(level)
    this.level = level
    this.grid = this.level.grid
    
    this.x = 0
    this.y = 0
    
    this.columns = this.level.columns
    this.rows = this.level.rows
    
    this.orientation = this.level.orientation
    this.lineColor = Palette.lightYellow
    this.filledColor = Palette.gold
    this.fillColor = Palette.yellow
    this.sideLength = 10
    this.lineWidth = 1.5
    
    if this.orientation == Beehive.FLAT then
      this.tileWidth = this.sideLength * 2
      this.tileHeight = this.sideLength * sqrt(3)
      
      this.width = (this.columns * this.sideLength) + ((this.columns + 1) * (this.sideLength / 2))
      this.height = ((this.rows + 0.5) * this.tileHeight) - if rows == 1 then this.tileHeight / 2 else 0 end
    elsif this.orientation == Beehive.POINTY then
      this.tileWidth = this.sideLength * sqrt(3)
      this.tileHeight = this.sideLength * 2
      
      this.width = ((this.columns + 0.5) * this.tileWidth) - if this.rows == 1 then this.tileWidth / 2 else 0 end
      this.height = (this.rows * this.sideLength) + ((this.rows + 1) * (this.sideLength / 2))
    end
    
    this.entities = []
    
    for row = 0 to rows - 1
      for column = 0 to columns - 1
        local value = this.grid[row][column]
        
        if value == Grid.SPAWN or value == Grid.HOME then
          this.entities.push(new Bee(this, column, row))
        elsif value == Grid.BLOCK or value == Grid.FILLED then
          this.entities.push(new Block(this, column, row))
        end
      end
    end
    
    this.shake = function(amount) this.shakeMagnitude += amount end
    this.shakePosition = object x = 0 y = 0 end
    this.shakeMagnitude = 0
    this.shakeDecay = 0.1
    
    this.pushed = []
    this.moves = []
  end
  
  undo = function()
    if not this.moves.length then return end
    
    local bee = false
    for entity in this.entities
      if entity.entityType == Beehive.BEE then bee = entity end
    end
    
    if bee.animation then return end
    
    local move = this.moves.pop()
    audio.playSound("undo", 0.5)
    
    if move.moveType == Bee.TURN then
      global.turnCounter -= 1
      bee.turnTo(move.start)
      bee.scale = 0.9
    elsif move.moveType == Bee.MOVE then
      global.moveCounter -= 1
      bee.scale = 0.8
      
      local tile = this.move(bee, bee.column, bee.row, move.direction, move.undo, false)
      bee.moveTo(tile.column, tile.row)
      
      for block in move.blocks
        if block.animation then TweenService.removeTween(block.animation) end
        local tile = this.move(block, block.column, block.row, move.direction, move.undo, false)
        block.push(tile.column, tile.row)
        block.scale = 0.8
      end
    end
  end
  
  check = function()
    local blockSpots = []
    
    for entity in this.entities
      if entity.entityType == Beehive.BLOCK then
        blockSpots.push(object column = entity.column row = entity.row end)
      end
    end
    
    for row = 0 to this.rows - 1
      for column = 0 to this.columns - 1
        local value = this.grid[row][column]
        if Grid.slots.contains(value) then
          local foundSpot = false
          for spot in blockSpots
            if spot.column == column and spot.row == row then
              foundSpot = true
            end
          end
          
          if not foundSpot then return end
        end
      end
    end
    
    after 500 do
      audio.playSound("win", 1)
      after 500 do global.nextLevel() end
    end
  end
  
  update = function()
    this.pushed = []
    
    local shakeDirection = random.nextInt(360)
    this.shakePosition.x = cosd(shakeDirection) * this.shakeMagnitude
    this.shakePosition.y = sind(shakeDirection) * this.shakeMagnitude
    this.shakeMagnitude -= this.shakeMagnitude * this.shakeDecay
    
    for entity in this.entities entity.update() end
  end
  
  draw = function()
    screen.setLineWidth(this.lineWidth)
    
    for row = 0 to this.rows - 1
      for column = 0 to this.columns - 1
        local value = this.grid[row][column]
        if value == Grid.EMPTY then continue end
        
        local x = 0
        local y = 0
        
        local tileColor = if Grid.slots.contains(value) then this.filledColor else this.fillColor end
        
        if this.orientation == Beehive.FLAT then
          x = ((column + 0.5) * this.tileWidth) - (column * (this.sideLength / 2)) - (this.width / 2)
          y = ((row + 0.5) * this.tileHeight) - (this.height / 2) + ((column % 2) * (this.tileHeight / 2))
          
          screen.setTranslation(this.shakePosition.x, this.shakePosition.y)
          screen.fillFlatToppedHexagon(x, y - 4, this.sideLength, tileColor)
          screen.setTranslation(-this.shakePosition.x, -this.shakePosition.y)
          screen.fillFlatToppedHexagon(x, y, this.sideLength, tileColor)
          screen.drawFlatToppedHexagon(x, y, this.sideLength, this.lineColor)
        elsif this.orientation == Beehive.POINTY then
          x = ((column + 0.5) * this.tileWidth) - (this.width / 2) + ((row % 2) * (this.tileWidth / 2))
          y = ((row + 0.5) * this.tileHeight) - (row * (this.sideLength / 2)) - (this.height / 2)
          
          screen.setTranslation(this.shakePosition.x, this.shakePosition.y)
          screen.fillPointyToppedHexagon(x, y - 4, this.sideLength, tileColor)
          screen.setTranslation(-this.shakePosition.x, -this.shakePosition.y)
          screen.fillPointyToppedHexagon(x, y, this.sideLength, tileColor)
          screen.drawPointyToppedHexagon(x, y, this.sideLength, this.lineColor)
        end
      end
    end
    
    screen.setTranslation(0, 0)
    screen.setLineWidth(1)
    
    for entity in this.entities entity.draw() end
  end
  
  getPosition = function(column, row)
    local position = object x = 0 y = 0 end
    
    if this.orientation == Beehive.FLAT then
      position.x = ((column + 0.5) * this.sideLength) + ((column + 1) * (this.sideLength / 2))
      position.y = ((row + 0.5) * this.tileHeight) + ((column % 2) * (this.tileHeight / 2))
    elsif this.orientation == Beehive.POINTY then
      position.x = ((column + 0.5) * this.tileWidth) + ((row % 2) * (this.tileWidth / 2))
      position.y = ((row + 0.5) * this.sideLength) + ((row + 1) * (this.sideLength / 2))
    end
    
    position.x -= this.width / 2
    position.y -= this.height / 2
    return position
  end
  
  move = function(entity, column, row, direction, unit, checks = true)
    if checks and not unit then return false end
    
    local newTile = object end
    newTile.column = column
    newTile.row = row
    
    if this.orientation == Beehive.FLAT then
      if not ((direction - 30) % 360) then // Top Right
        newTile.column += unit
        if not (newTile.column % 2) and unit > 0 then newTile.row += unit
        elsif newTile.column % 2 and unit < 0 then newTile.row += unit
        end
      elsif not ((direction - 90) % 360) then newTile.row += unit // Top
      elsif not ((direction - 150) % 360) then // Top Left
        newTile.column -= unit
        if not (newTile.column % 2) and unit > 0 then newTile.row += unit
        elsif newTile.column % 2 and unit < 0 then newTile.row += unit
        end
      elsif not ((direction + 150) % 360) then // Bottom Left
        newTile.column -= unit
        if newTile.column % 2 and unit > 0 then newTile.row -= unit
        elsif not (newTile.column % 2) and unit < 0 then newTile.row -= unit
        end
      elsif not ((direction + 90) % 360) then newTile.row -= unit // Bottom
      elsif not ((direction + 30) % 360) then // Bottom Right
        newTile.column += unit
        if newTile.column % 2 and unit > 0 then newTile.row -= unit
        elsif not (newTile.column % 2) and unit < 0 then newTile.row -= unit
        end
      end
    elsif this.orientation == Beehive.POINTY then
      if not (direction % 360) then newTile.column += unit // Right
      elsif not ((direction - 60) % 360) then // Top Right
        newTile.row += unit
        if not (newTile.row % 2) and unit > 0 then newTile.column += unit
        elsif newTile.row % 2 and unit < 0 then newTile.column += unit
        end
      elsif not ((direction - 120) % 360) then // Top Left
        newTile.row += unit
        if not (newTile.row % 2) and unit < 0 then newTile.column -= unit
        elsif newTile.row % 2 and unit > 0 then newTile.column -= unit
        end
      elsif not ((direction - 180) % 360) then newTile.column -= unit // Left
      elsif not ((direction - 240) % 360) then // Bottom Left
        newTile.row -= unit
        if newTile.row % 2 and unit > 0 then newTile.column -= unit
        elsif not (newTile.row % 2) and unit < 0 then newTile.column -= unit
        end
      elsif not ((direction - 300) % 360) then // Bottom Right
        newTile.row -= unit
        if newTile.row % 2 and unit < 0 then newTile.column += unit
        elsif not (newTile.row % 2) and unit > 0 then newTile.column += unit
        end
      end
    end
    
    if checks and this.grid[newTile.row][newTile.column] == Grid.EMPTY then return false end
    
    local clampedTile = object
      column = min(max(newTile.column, 0), this.columns - 1)
      row = min(max(newTile.row, 0,), this.rows - 1)
    end
    
    if not (clampedTile.column == newTile.column) or not (clampedTile.row == newTile.row) then
      if checks then return false end
    end
    
    if checks then
      for otherEntity in this.entities
        if otherEntity == entity then continue end
        if otherEntity.column == newTile.column and otherEntity.row == newTile.row then
          
          local pushedTile = this.move(otherEntity, newTile.column, newTile.row, direction, unit)
          if not pushedTile then return false end
          
          otherEntity.push(pushedTile.column, pushedTile.row)
        end
      end
    end
    
    return newTile
  end
end

