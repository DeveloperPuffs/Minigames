
Clock = object end
Clock.time = function() system.time() / 1000 end
Clock.startTime = Clock.time()
Clock.currentTime = Clock.time()
Clock.elapsedTime = 0
Clock.deltaTime = 0
Clock.tick = 0
Clock.fps = 0

Clock.update = function()
  Clock.deltaTime = Clock.time() - Clock.currentTime
  Clock.currentTime = Clock.time()
  Clock.elapsedTime = Clock.currentTime - Clock.startTime
  Clock.fps = system.fps
  Clock.tick += 1
end

