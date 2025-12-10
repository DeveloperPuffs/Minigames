
class MainMenu:
  def __init__(self: object) -> None: return
  def update(self: object) -> None:
    if check_input(mouse, 'press'):
      global game_state
      game_state = GameState.CUTSCENE
  def draw(self: object) -> None:
    title_scale = 0.8 + wave(0.05, 2, current_time, cos)
    screen.drawText('LifeRisen', 0, 0, title_scale * 48, 999)
    screen.setAlpha(0.6)
    screen.drawText('Click anywhere on the screen to play.', 0, 20 - (screen.height / 2), 12, 999)
    screen.setAlpha(1)


