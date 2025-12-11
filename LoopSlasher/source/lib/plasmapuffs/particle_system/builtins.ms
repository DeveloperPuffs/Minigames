
// Some cool builtin emitters you can use with this library
// Use them as references for creating your own custom emitters!
Emitter = object end

/*
Emitter.fire = function(size)
Emitter.rain = function(raininess, angle, width = screen.width, height = screen.height)
Emitter.explosion = function(size)
*/

Emitter.fire = function(size)
  size = max(size, 1)
  
  local fire = new ParticleEmitter()
  fire.name = "Builtin Fire Particle Emitter"
  fire.particlesPerSecond = 30
  fire.blendingMode = "screen"
  fire.setLineEmission(-size * 1.5, 0, size * 1.5, 0, size / 2, 0.5)
  
  fire.prototype.lifespan.setRange(3, 4)
  
  fire.prototype.speed.setRange(5 * size, 7 * size)
  fire.prototype.direction.setRange(0, 180)
  fire.prototype.direction.biasStrength = 0.95
  
  fire.prototype.functionName = "fillRound"
  fire.prototype.functionArguments = [0, 0, size, size]
  
  fire.prototype.scale.x.start.setRange(1.5, 2)
  fire.prototype.scale.x.end.setRange(1, 1.5)
  fire.prototype.scale.square = "x"
  
  fire.prototype.alpha.start.setRange(0.5, 0.8)
  fire.prototype.alpha.end.setRange(0.5, 0.8)
  
  fire.prototype.color[0] = object red = 1 green = 1 blue = 1 alpha = 1 end
  fire.prototype.color[0.01] = object red = 1 green = 1 blue = 0 alpha = 1 end
  fire.prototype.color[0.05] = object red = 1 green = 0.5 blue = 0 alpha = 1 end
  fire.prototype.color[0.2] = object red = 1 green = 0 blue = 0 alpha = 0.5 end
  fire.prototype.color[1] = object red = 0 green = 0 blue = 0 alpha = 0 end
  fire.setSamples(50, true)
  
  local embers = new ParticleEmitter()
  embers.name = "Builtin Fire Particle Emitter: Embers"
  embers.particlesPerSecond = 2
  embers.gravity.y = size * -20
  
  embers.prototype.lifespan.setRange(1, 1.5)
  
  embers.prototype.speed.setRange(16 * size, 20 * size)
  embers.prototype.direction.setRange(0, 180)
  embers.prototype.biasStrength = -0.2
  
  embers.prototype.functionName = "fillRect"
  embers.prototype.functionArguments = [0, 0, size, size]
  
  embers.prototype.scale.x.start.setRange(0.2, 0.5)
  embers.prototype.scale.x.end.set(0)
  embers.prototype.scale.square = "x"
  
  embers.prototype.alpha.start.setRange(0.8, 1)
  embers.prototype.alpha.end.setRange(0.5, 0.8)
  
  embers.prototype.color[0] = object red = 1 green = 1 blue = 1 alpha = 1 end
  embers.prototype.color[0.2] = object red = 1 green = 1 blue = 0 alpha = 1 end
  embers.prototype.color[1] = object red = 1 green = 0 blue = 0 alpha = 0 end
  
  local smoke = new ParticleEmitter()
  smoke.name = "Builtin Smoke Particle Emitter: Smoke"
  smoke.setLineEmission(-size * 2, 0, size * 2, 0)
  smoke.particlesPerSecond = 20
  smoke.blendingMode = "darken"
  smoke.gravity.y = size * 5
  
  smoke.prototype.lifespan.setRange(3, 4)
  
  smoke.prototype.speed.setRange(1 * size, 3 * size)
  smoke.prototype.direction.setRange(0, 180)
  
  smoke.prototype.functionName = "fillRound"
  smoke.prototype.functionArguments = [0, 0, size * 1.5, size * 1.5]
  
  smoke.prototype.scale.x.start.setRange(1, 1)
  smoke.prototype.scale.x.end.setRange(4, 5)
  smoke.prototype.scale.square = "x"
  
  smoke.prototype.alpha.start.setRange(0.5, 0.8)
  smoke.prototype.alpha.end.setRange(0.2, 0.5)
  
  smoke.prototype.color[0] = object red = 0.5 green = 0.3 blue = 0.3 alpha = 1 end
  smoke.prototype.color[0.3] = object red = 0.2 green = 0.2 blue = 0.2 alpha = 0.5 end
  smoke.prototype.color[1] = object red = 0 green = 0 blue = 0 alpha = 0 end
  smoke.setSamples(20, true)
  
  fire.children[1] = embers
  fire.children[-1] = smoke
  return fire
end

Emitter.rain = function(raininess, angle, width = screen.width, height = screen.height)
  raininess = min(max(width * raininess / 2, 0), width / 2)
  angle = min(max(angle, -30), 30) + 270
  
  local rain = new ParticleEmitter()
  rain.name = "Builtin Rain Particle Emitter"
  rain.particlesPerSecond = raininess
  rain.setLineEmission(-width, height / 1.8, width, height / 1.8)
  
  rain.prototype.lifespan.set(1)
  
  rain.prototype.faceDirection = true
  rain.prototype.speed.setRange(height, height * 2)
  rain.prototype.direction.set(angle)
  
  rain.prototype.functionName = "fillRect"
  rain.prototype.functionArguments = [0, 0, height / 200, height / 10]
  
  rain.prototype.scale.y.start.setRange(0.5, 1)
  rain.prototype.scale.y.static = true
  
  rain.prototype.alpha.start.setRange(0.5, 1)
  rain.prototype.alpha.static = true
  
  rain.prototype.color[0] = object red = 0.2 green = 0.6 blue = 0.8 alpha = 1 end
  rain.prototype.color[1] = object red = 0.2 green = 0.6 blue = 0.8 alpha = 1 end
  
  return rain
end

Emitter.explosion = function(size)
  size = max(size, 1)
  
  local explosion = new ParticleEmitter()
  explosion.name = "Builtin Explosion Particle Emitter"
  explosion.particlesPerSecond = 400
  explosion.infinite = false
  explosion.shakeDecay = 5
  explosion.length = 0.2
  
  explosion.onTrigger.shake = function(explosion) explosion.shakePower = 4 end
  
  explosion.prototype.lifespan.setRange(1, 1.5)
  
  explosion.prototype.speed.setRange(10 * size, 15 * size)
  explosion.prototype.direction.setRange(0, 360)
  explosion.prototype.friction.velocity.set(5)
  
  explosion.prototype.functionName = "fillRound"
  explosion.prototype.functionArguments = [0, 0, 2 * size, 2 * size]
  
  explosion.prototype.scale.x.start.setRange(0.8, 1)
  explosion.prototype.scale.x.end.setRange(3, 4)
  explosion.prototype.scale.square = "x"
  
  explosion.prototype.alpha.start.set(1)
  explosion.prototype.alpha.end.set(0)
  
  explosion.prototype.color[0] = object red = 1 green = 1 blue = 1 alpha = 1 end
  explosion.prototype.color[0.1] = object red = 1 green = 1 blue = 0 alpha = 1 end
  explosion.prototype.color[0.2] = object red = 1 green = 0.5 blue = 0 alpha = 1 end
  explosion.prototype.color[0.3] = object red = 0.5 green = 0.2 blue = 0.2 alpha = 1 end
  explosion.prototype.color[0.5] = object red = 0.2 green = 0.2 blue = 0.2 alpha = 0.5 end
  explosion.prototype.color[1] = object red = 0 green = 0 blue = 0 alpha = 0 end
  
  return explosion
end

Emitter.confetti = function(size)
  size = max(size, 1)
  
  local confetti = new ParticleEmitter()
  confetti.name = "Builtin Confetti Particle Emitter"
  confetti.particlesPerSecond = 500
  confetti.infinite = false
  confetti.length = 0.1
  confetti.gravity.y = size * -120
  
  confetti.prototype.lifespan.setRange(3, 4)
  
  confetti.prototype.speed.setRange(50 * size, 70 * size)
  confetti.prototype.direction.setRange(0, 360)
  confetti.prototype.torque.setRange(60, 80)
  
  confetti.prototype.scale.x.start.setRange(2, 5)
  confetti.prototype.scale.x.static = true
  
  confetti.prototype.scale.y.start.setRange(2, 5)
  confetti.prototype.scale.y.static = true
  
  confetti.prototype.functionName = "fillRect"
  confetti.prototype.functionArguments = [0, 0, size, size]
  
  confetti.prototype.color = function()
    local color = object end
    color.red = random.next()
    color.green = random.next()
    color.blue = random.next()
    color.alpha = 1
    
    local colorObject = object end
    colorObject[0] = color
    colorObject[1] = color
    return colorObject
  end
  
  return confetti
end

Emitter.snow = function(snowiness, angle, width = screen.width, height = screen.height)
  snowiness = min(max(width * snowiness / 2, 0), width / 2)
  angle = min(max(angle, -30), 30) + 270
  
  local snow = new ParticleEmitter()
  snow.name = "Builtin Snow Particle Emitter"
  snow.particlesPerSecond = snowiness
  snow.setLineEmission(-width, height / 1.8, width, height / 1.8)
  
  snow.prototype.lifespan.set(3)
  
  snow.prototype.speed.setRange(height / 2.5, height / 2)
  snow.prototype.direction.setAround(angle, 30)
  snow.prototype.biasStrength = 0.5
  
  snow.prototype.functionName = "fillRound"
  snow.prototype.functionArguments = [0, 0, height / 50, height / 50]
  
  snow.prototype.scale.y.start.setRange(0.5, 1)
  snow.prototype.scale.y.static = true
  
  snow.prototype.alpha.start.setRange(0.25, 1)
  snow.prototype.alpha.static = true
  
  snow.prototype.color[0] = object red = 1 green = 1 blue = 1 alpha = 1 end
  snow.prototype.color[1] = object red = 1 green = 1 blue = 1 alpha = 1 end
  
  return snow
end

