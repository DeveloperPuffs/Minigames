
global.Afterimage = class
  constructor = function(sprite, x, y, width, height, fadeSpeed, alpha = 1)
    this.sprite = sprite
    this.x = x
    this.y = y
    this.width = width
    this.height = height
    this.fadeSpeed = fadeSpeed
    this.alpha = alpha
  end
  
  update = function()
    this.alpha -= this.fadeSpeed
    this.alpha = max(this.alpha, 0)
    return this.alpha
  end
  
  draw = function()
    screen.setAlpha(this.alpha)
    screen.drawSprite(
      sprite, this.x, this.y, 
      this.width, this.height
    )
    
    screen.setAlpha(1)
  end
end

