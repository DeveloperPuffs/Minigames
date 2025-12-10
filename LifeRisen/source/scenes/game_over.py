
class GameOver:
  def __init__(self: object) -> None:
    self.time = float()
  
  def update(self: object) -> None:
    if check_input(mouse, 'press'): start_game()
  
  def draw(self: object) -> None:
    screen.drawText('Game Over!', 0, 0, 40, 999)
    screen.setAlpha(0.8)
    screen.drawText(f'Your spirit survived for {seconds_string(self.time)}', 0, -24, 16, 999)
    screen.setAlpha(0.6)
    screen.drawText('Click anywhere on the screen to restart.', 0, 20 - (screen.height / 2), 12, 999)
    screen.setAlpha(1)


