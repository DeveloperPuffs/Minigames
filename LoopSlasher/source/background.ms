Background = class
  constructor = function()
    this.weights = [100, 10, 10, 10, 10, 1, 1, 1, 1]

    local totalWeight = 0
    for weight in this.weights
      totalWeight += weight
    end
    
    for index = 0 to this.weights.length - 1
      this.weights[index] /= totalWeight
    end

    this.columns = 24
    this.rows = 14

    this.buffer = new Image(this.columns * global.TILE_SIZE, this.rows * global.TILE_SIZE, false)
    for row = 0 to this.rows - 1
      local y = row * global.TILE_SIZE
      for column = 0 to this.columns - 1
        local x = column * global.TILE_SIZE
        
        local counter = 0
        local selectedIndex = 0
        local value = random.next()
        for index = 0 to this.weights.length - 1
          counter += this.weights[index]
          if counter >= value then
            selectedIndex = index
            break
          end
        end

        this.buffer.drawSprite("tile" + selectedIndex, x, y, global.TILE_SIZE, global.TILE_SIZE)
      end
    end
  end

  draw = function()
    screen.drawImage(this.buffer, 0, 0, this.buffer.width, this.buffer.height)
  end
end