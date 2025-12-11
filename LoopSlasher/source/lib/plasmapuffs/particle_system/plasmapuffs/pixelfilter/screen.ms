
rotatedPoint = function(point, origin, angle)
  local c = cosd(angle)
  local s = sind(angle)
  local dx = point[0] - origin[0]
  local dy = point[1] - origin[1]
  return [(c * dx) - (s * dy) + origin[0], (s * dx) + (c * dy) + origin[1]]
end

calculatePointsBoundingBox = function(points)
  if not points.length then return false end
  
  local point = points.pop()
  local minimum = [] + point
  local maximum = [] + point
  delete point
  
  for point in points
    if point[0] < minimum[0] then minimum[0] = point[0] end
    if point[0] > maximum[0] then maximum[0] = point[0] end
    if point[1] < minimum[1] then minimum[1] = point[1] end
    if point[1] > maximum[1] then maximum[1] = point[1] end
  end
  
  return [
    (minimum[0] + maximum[0]) / 2,
    (minimum[1] + maximum[1]) / 2,
    maximum[0] - minimum[0],
    maximum[1] - minimum[1]
  ]
end

calculatePathRawBoundingBox = function(flatPath)
  if flatPath.length < 4 or flatPath.length % 2 then return false end
  
  local path = []
  for index = 0 to flatPath.length - 1
    local position = flatPath[index]
    if index % 2 then path[path.length - 1].push(position)
    else path.push([position])
    end
  end
  
  return calculatePointsBoundingBox(path)
end

rotatedRectangle = function(x, y, width, height, angle)
  local w = width / 2
  local h = height / 2
  local points = [
    [x - w, y - h],
    [x + w, y - h],
    [x - w, y + h],
    [x + w, y + h]
  ]
  
  delete w
  delete h
  
  local origin = [x, y]
  local rotatedPoints = []
  for point in points rotatedPoints.push(rotatedPoint(point, origin, angle)) end
  delete origin
  
  return calculatePointsBoundingBox(rotatedPoints)
end

calculateBoundingBox = function(width, height, angle, lineWidth)
  if angle then
    local rectangle = rotatedRectangle(0, 0, width, height, angle)
    width = rectangle[2]
    height = rectangle[3]
    delete rectangle
  end
  
  local buffer = 2 + if lineWidth then min(round(lineWidth), 2) else 0 end
  return [width + buffer, height + buffer]
end

// microStudio -> Documentation -> Quick Reference -> API Cheatsheet -> Images -> Draw on Image

screen.drawPixelRect = function(x, y, width, height, angle, lineWidth, color)
  local boundingBox = calculateBoundingBox(width, height, angle, lineWidth)
  local image = new PixelImage(boundingBox[0], boundingBox[1], true)
  
  image.setDrawRotation(angle)
  image.setLineWidth(lineWidth)
  image.drawRect(0, 0, width, height, color)
  screen.drawImage(image, x, y, boundingBox[0], boundingBox[1])
end

screen.fillPixelRect = function(x, y, width, height, angle, color)
  local boundingBox = calculateBoundingBox(width, height, angle, 0)
  local image = new PixelImage(boundingBox[0], boundingBox[1], true)
  
  image.setDrawRotation(angle)
  image.fillRect(0, 0, width, height, color)
  screen.drawImage(image, x, y, boundingBox[0], boundingBox[1])
end

screen.drawPixelRound = function(x, y, width, height, angle, lineWidth, color)
  local boundingBox = calculateBoundingBox(width, height, angle, lineWidth)
  local image = new PixelImage(boundingBox[0], boundingBox[1], true)
  
  image.setDrawRotation(angle)
  image.setLineWidth(lineWidth)
  image.drawRound(0, 0, width, height, color)
  screen.drawImage(image, x, y, boundingBox[0], boundingBox[1])
end

screen.fillPixelRound = function(x, y, width, height, angle, color)
  local boundingBox = calculateBoundingBox(width, height, angle, 0)
  local image = new PixelImage(boundingBox[0], boundingBox[1], true)
  
  image.setDrawRotation(angle)
  image.fillRound(0, 0, width, height, color)
  screen.drawImage(image, x, y, boundingBox[0], boundingBox[1])
end

screen.drawPixelRoundRect = function(x, y, width, height, roundedRadius, angle, lineWidth, color)
  local boundingBox = calculateBoundingBox(width, height, angle, lineWidth)
  local image = new PixelImage(boundingBox[0], boundingBox[1], true)
  
  image.setDrawRotation(angle)
  image.setLineWidth(lineWidth)
  image.drawRoundRect(0, 0, width, height, roundedRadius, color)
  screen.drawImage(image, x, y, boundingBox[0], boundingBox[1])
end

screen.fillPixelRoundRect = function(x, y, width, height, roundedRadius, angle, color)
  local boundingBox = calculateBoundingBox(width, height, angle, 0)
  local image = new PixelImage(boundingBox[0], boundingBox[1], true)
  
  image.setDrawRotation(angle)
  image.fillRoundRect(0, 0, width, height, roundedRadius, color)
  screen.drawImage(image, x, y, boundingBox[0], boundingBox[1])
end

screen.drawPixelLine = function(x1, y1, x2, y2, angle, lineWidth, color)
  local rawBoundingBox = calculatePathRawBoundingBox([x1, y1, x2, y2])
  if not rawBoundingBox then return end
  
  local x = rawBoundingBox[0]
  local y = rawBoundingBox[1]
  
  local boundingBox = calculateBoundingBox(rawBoundingBox[2], rawBoundingBox[3], angle, lineWidth)
  local image = new PixelImage(boundingBox[0], boundingBox[1], true)
  delete rawBoundingBox
  
  image.setDrawRotation(angle)
  image.setLineWidth(lineWidth)
  image.setTranslation((image.width / 2) - x, (image.height / 2) - y)
  image.drawLine(x1, y1, x2, y2, color)
  screen.drawImage(image, x, y, boundingBox[0], boundingBox[1])
end

screen.drawPixelPolyline = function(path, angle, lineWidth, color)
  local rawBoundingBox = calculatePathRawBoundingBox(path)
  if not rawBoundingBox then return end
  
  local x = rawBoundingBox[0]
  local y = rawBoundingBox[1]
  
  local boundingBox = calculateBoundingBox(rawBoundingBox[2], rawBoundingBox[3], angle, lineWidth)
  local image = new PixelImage(boundingBox[0], boundingBox[1], true)
  delete rawBoundingBox
  
  image.setDrawRotation(angle)
  image.setLineWidth(lineWidth)
  image.setTranslation((image.width / 2) - x, (image.height / 2) - y)
  image.drawPolyline(path, color)
  screen.drawImage(image, x, y, boundingBox[0], boundingBox[1])
end

screen.drawPixelPolygon = function(path, angle, lineWidth, color)
  local rawBoundingBox = calculatePathRawBoundingBox(path)
  if not rawBoundingBox then return end
  
  local x = rawBoundingBox[0]
  local y = rawBoundingBox[1]
  
  local boundingBox = calculateBoundingBox(rawBoundingBox[2], rawBoundingBox[3], angle, lineWidth)
  local image = new PixelImage(boundingBox[0], boundingBox[1], true)
  delete rawBoundingBox
  
  image.setDrawRotation(angle)
  image.setLineWidth(lineWidth)
  image.setTranslation((image.width / 2) - x, (image.height / 2) - y)
  image.drawPolygon(path, color)
  screen.drawImage(image, x, y, boundingBox[0], boundingBox[1])
end

screen.fillPixelPolygon = function(path, angle, color)
  local rawBoundingBox = calculatePathRawBoundingBox(path)
  if not rawBoundingBox then return end
  
  local x = rawBoundingBox[0]
  local y = rawBoundingBox[1]
  
  local boundingBox = calculateBoundingBox(rawBoundingBox[2], rawBoundingBox[3], angle, 0)
  local image = new PixelImage(boundingBox[0], boundingBox[1], true)
  delete rawBoundingBox
  
  image.setDrawRotation(angle)
  image.setTranslation((image.width / 2) - y, (image.height / 2) - y)
  image.fillPolygon(path, color)
  screen.drawImage(image, x, y, boundingBox[0], boundingBox[1])
end

screen.drawPixelArc = function(x, y, radius, start_angle, end_angle, counter_clockwise, angle, lineWidth, color)
  local boundingBox = calculateBoundingBox(radius * 2, radius * 2, angle, lineWidth)
  local image = new PixelImage(boundingBox[0], boundingBox[1], true)
  
  image.setDrawRotation(angle)
  image.setLineWidth(lineWidth)
  image.drawArc(0, 0, radius, start_angle, end_angle, counter_clockwise, color)
  screen.drawImage(image, x, y, boundingBox[0], boundingBox[1])
end

screen.fillPixelArc = function(x, y, radius, start_angle, end_angle, counter_clockwisse, angle, color)
  local boundingBox = calculateBoundingBox(radius * 2, radius * 2, angle, 0)
  local image = new PixelImage(boundingBox[0], boundingBox[1], true)
  
  image.setDrawRotation(angle)
  image.drawArc(0, 0, radius, start_angle, end_angle, counter_clockwise, color)
  screen.drawImage(image, x, y, boundingBox[0], boundingBox[1])
end

screen.drawPixelQuadCurve = function(path, angle, lineWidth, color)
  local rawBoundingBox = calculatePathRawBoundingBox(path)
  if not rawBoundingBox then return end
  
  local x = rawBoundingBox[0]
  local y = rawBoundingBox[1]
  
  local boundingBox = calculateBoundingBox(rawBoundingBox[2], rawBoundingBox[3], angle, lineWidth)
  local image = new PixelImage(boundingBox[0], boundingBox[1], true)
  delete rawBoundingBox
  
  image.setDrawRotation(angle)
  image.setLineWidth(lineWidth)
  image.setTranslation((image.width / 2) - x, (image.height / 2) - y)
  image.drawQuadCurve(path, color)
  screen.drawImage(image, x, y, boundingBox[0], boundingBox[1])
end

screen.drawPixelBezierCurve = function(path, angle, lineWidth, color)
  local rawBoundingBox = calculatePathRawBoundingBox(path)
  if not rawBoundingBox then return end
  
  local x = rawBoundingBox[0]
  local y = rawBoundingBox[1]
  
  local boundingBox = calculateBoundingBox(rawBoundingBox[2], rawBoundingBox[3], angle, lineWidth)
  local image = new PixelImage(boundingBox[0], boundingBox[1], true)
  delete rawBoundingBox
  
  image.setDrawRotation(angle)
  image.setLineWidth(lineWidth )
  image.setTranslation((image.width / 2) - x, (image.height / 2) - y)
  image.drawBezierCurve(pixel, color)
  screen.drawImage(image, x, y, boundingBox[0], boundingBox[1])
end

