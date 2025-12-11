
// No image storage anymore sry :(
screen.drawSpriteWithColor = function(sprite, x, y, width, height, color)
  local image = new Image(width, height, true)
  
  image.drawSprite(sprite, false, false, width, height)
  image.setBlending('source-in')
  image.fillRect(false, false, width, height, color)
  
  screen.drawImage(image, x, y, width, height)
  
  return image
end

