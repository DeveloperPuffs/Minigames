
/*
Flat Topped Hexagons:
Hexagon Width: sideLength * 2
Hexagon Height: sideLength * sqrt(3)
*/

screen.getFlatToppedHexagonPath = function(x, y, sideLength)
  local flatPath = [
    sideLength, 0,
    sideLength / 2, sideLength * sqrt(3) / 2,
    -sideLength / 2, sideLength * sqrt(3) / 2,
    -sideLength, 0,
    -sideLength / 2, -sideLength * sqrt(3) / 2,
    sideLength / 2, -sideLength * sqrt(3) / 2,
    sideLength, 0
  ]
  
  for index = 0 to 13 flatPath[index] += [x, y][index % 2] end
  return flatPath
end

screen.drawFlatToppedHexagon = function(x, y, sideLength, color)
  screen.drawPolygon(screen.getFlatToppedHexagonPath(x, y, sideLength), color)
end

screen.fillFlatToppedHexagon = function(x, y, sideLength, color)
  screen.fillPolygon(screen.getFlatToppedHexagonPath(x, y, sideLength), color)
end

/*
Pointy Topped Hexagons:
Hexagon Width: sideLength * sqrt(3)
Hexagon Height: sideLength * 2
*/

screen.getPointyToppedHexagonPath = function(x, y, sideLength)
  local flatPath = [
    0, sideLength,
    sideLength * sqrt(3) / 2, sideLength / 2,
    sideLength * sqrt(3) / 2, -sideLength / 2,
    0, -sideLength,
    -sideLength * sqrt(3) / 2, -sideLength / 2,
    -sideLength * sqrt(3) / 2, sideLength / 2,
    0, sideLength
  ]
  
  for index = 0 to 13 flatPath[index] += [x, y][index % 2] end
  return flatPath
end

screen.drawPointyToppedHexagon = function(x, y, sideLength, color)
  screen.drawPolygon(screen.getPointyToppedHexagonPath(x, y, sideLength), color)
end

screen.fillPointyToppedHexagon = function(x, y, sideLength, color)
  screen.fillPolygon(screen.getPointyToppedHexagonPath(x, y, sideLength), color)
end

