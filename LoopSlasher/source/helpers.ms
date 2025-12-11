global.DEBUG_MODE = false
global.TILE_SIZE = 16

global.GRAPHICS_LOW = 0
global.GRAPHICS_MEDIUM = 1
global.GRAPHICS_HIGH = 2

global.rgb = function(r, g, b)
  return "rgb(" + r + ", " + g + ", " + b + ")"
end

global.rgba = function(r, g, b, a)
  return "rgba(" + r + ", " + g + ", " + b + ", " + a + ")"
end

global.Layer = object
  DEBUG_BACKGROUND = 0
  
  SURFACE_GROUND = 10
  SURFACE_SPLATTER = 11
  SURFACE_SHADOW = 12
  SURFACE_TRAIL = 13
  
  ENEMY_EFFECTS = 20
  ENEMY_BODY = 21
  
  PLAYER_EFFECTS = 30
  PLAYER_BACK_HAND = 31
  PLAYER_BODY = 32
  PLAYER_FRONT_HAND = 33
  
  FLOATING_BULLET = 40
  GAME_EXPLOSION = 41
  FLOATING_TRAIL = 42
  VIGNETTE_OVERLAY = 43
  
  UI_OVERLAY = 50

  DEBUG_FOREGROUND = 60
end

screen.drawTextOutlined = function(text, x, y, size, textColor, lineColor)
  screen.setLineWidth(size / 2)
  screen.drawTextOutline(text, x, y, size, lineColor)
  screen.drawText(text, x, y, size, textColor)
  screen.resetLineWidth()
end

random.integer = function(minimum, maximum)
  return floor(random.next() * (maximum - minimum) + minimum)
end

random.number = function(minimum, maximum)
  return random.next() * (maximum - minimum) + minimum
end

random.choice = function(array)
  return array[random.nextInt(array.length)]
end

random.boolean = function()
  return random.nextInt(2)
end

random.sign = function()
  return if random.boolean() then 1 else -1 end
end

random.shuffle = function(array)
  array.sortList(function()
    return random.next() > 0.5
  end)
end

Afterimage = class
  constructor = function(sprite, x, y, width, height, duration, alpha = 1)
    this.sprite = sprite
    this.x = x
    this.y = y
    this.width = width
    this.height = height
    this.duration = duration
    this.lifespan = 1
    this.alpha = alpha
  end
  
  update = function(deltaTime)
    this.lifespan = max(this.lifespan - deltaTime / this.duration, 0)
    return this.lifespan
  end
  
  draw = function()
    screen.setAlpha(this.alpha * this.lifespan)
    screen.drawSprite(sprite, this.x, this.y, this.width, this.height)
    screen.resetAlpha()
  end
end