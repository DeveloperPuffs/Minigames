
global.drawBackground = function(angle)
  local columns = 10
  local rows = 10
  
  local sideLength = round(sqrt(pow(screen.width, 2) + pow(screen.height, 2)) / sqrt(pow(columns, 2) + pow(rows, 2)))
  
  local tileWidth = sideLength * 2
  local tileHeight = sideLength * sqrt(3)
  
  local width = (columns * sideLength) + ((columns + 1) * (sideLength / 2))
  local height = (rows + 0.5) * tileHeight
  
  screen.setRotation(angle)
  screen.setLineWidth(4)
  
  for row = 0 to rows - 1
    for column = 0 to columns - 1
      local x = ((column + 0.5) * tileWidth) - (column * (sideLength / 2)) - (width / 2)
      local y = ((row + 0.5) * tileHeight) - (height / 2) + ((column % 2) * (tileHeight / 2))
      
      screen.drawFlatToppedHexagon(x, y, sideLength * 0.8, Palette.darkBrown)
    end
  end
  
  screen.setLineWidth(1)
  screen.setRotation(0)
end

