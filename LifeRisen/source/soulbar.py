
class Soulbar:
  def __init__(self: object) -> None:
    self.soul = 200
    self.x = 48 - (screen.width / 2)
    self.y = (screen.height / 2) - 12
    self.width, self.height = 64, 8
  
  def update(self: object) -> None:
    global soul
    if soul > self.soul: self.soul += 1
    elif soul < self.soul: self.soul -= 1
    if self.soul <= int():
      self.soul = soul = 200
      game_over.time = current_time - timer_start
      global game_state
      game_state = GameState.GAME_OVER
      audio.cancelBeeps()
      audio.playMusic('liferisenmenu', 1, True)
  
  def draw(self: object) -> None:
    screen.drawSprite('soulbar/background', self.x, self.y, self.width, self.height)
    screen.setDrawScale(self.soul / 200, 1)
    screen.setDrawAnchor(-1, int())
    screen.drawSprite('soulbar/foreground', self.x - 32, self.y, self.width, self.height)
    screen.setDrawAnchor(int(), int())
    screen.setDrawScale(1, 1)
    screen.drawSprite('soulbar/outline', self.x, self.y, self.width, self.height)
    screen.setDrawAnchor(-1, int())
    screen.drawText(f'{self.soul}/200', self.x + 40, self.y, 8, 999)
    screen.setDrawAnchor(int(), int())

