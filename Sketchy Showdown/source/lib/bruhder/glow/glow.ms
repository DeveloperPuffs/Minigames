glow = class
  constructor = function(quality=256) //Bigger number = less pixelated
    this.imageSize = quality
    this.storedColor = object end
  end
  addColor = function(color)
    storedColor[color] = new Image(imageSize,imageSize,true)
    storedColor[color].setRadialGradient(0,0,imageSize/2,color,'transparent')
    storedColor[color].fillRect(0,0,imageSize,imageSize)
    return storedColor[color]
  end
  draw = function(x,y,size,color,opacity=1)
    local drawColor = if storedColor[color] then storedColor[color] else addColor(color) end
    screen.setAlpha(opacity)
    screen.drawImage(drawColor,x,y,size,size)
    screen.setAlpha(1)
  end
end

glow.justDraw = function(x, y, width, height, color, quality = 256)
  local image = new Image(quality, quality, true)
  image.setRadialGradient(false, false, quality / 2, color, "transparent")
  image.fillRect(false, false, quality, quality)
  screen.drawImage(image, x, y, width, height)
end

