
global.Emitter = class
  constructor = function(game, sample, parent)
    this.game = game
    this.sample = sample
    this.parent = parent
    this.particles = []
    
    this.duration = false
    this.infinite = true
    this.count = [1, 1]
    this.interval = 1
    this.chance = 1
    this.active = true
  end
  
  update = function()
    for particle in this.particles
      particle.update()
    end
    
    if this.duration < 0 and not this.infinite then
      if not this.particles.length then
        this.game.emitters.removeElement(this)
      end
      return
    end
    
    if not this.active then return end
    if not this.infinite then this.duration -= this.game.timer.deltaTime end
    if not (this.game.timer.frames % this.interval) then
      if random.next() < this.chance then
        for _ = 1 to random.integerRange(this.count[0], this.count[1])
          this.particles.push(this.sample(this.parent, this.game, this))
        end
      end
    end
  end
  
  draw = function(x, y)
    screen.setPixelated(true)
    screen.drawImage(this.render(), x, y, screen.width, screen.height)
  end
  
  render = function()
    "HOW DO YOU DISABLE ANTI-ALIASING !?!"
    
    local image = new Image(screen.width, screen.height, true)
    image.setPixelated(true)
    for particle in particles particle.paint(image) end
    image.setTranslation(0, 0)
    return image
  end
end

