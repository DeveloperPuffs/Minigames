
class Cutscene:
  story = (
    '... thud! ...',
    'I wake up ...',
    'see familliar surroundings ...',
    'but ... where am I?',
    'It feels ... unsetteling.',
    'ominous and eerie ...',
    "something just isn't right ...",
    '...',
    
    'wait ... I remember ...',
    'the collision ...',
    'the impact ...',
    'No!',
    "It can't be ...",
    'it must have ... all been a dream!',
    '...',
    
    'Flashes of memory ...',
    'Is this how its supposed to be?',
    'Death is not the end ... after all.',
    
    'Controls',
    'WASD or Arrow Keys to move around',
    'Space while moving to Dash',
    'Do not touch the red things',
    'Good luck!'
  )
  
  def __init__(self: object) -> None:
    self.typing_interval = 4
    self.current_text = str()
    self.text_index = int()
  
  def _proceed(self: object) -> None:
    self.current_text = str()
    if self.text_index == len(Cutscene.story) - 1:
      self.text_index = int()
      start_game()
    else: self.text_index += 1
  
  def update(self: object) -> None:
    if check_input(keyboard, 'ENTER'): start_game(); return
    if check_input(mouse, 'press'): self._proceed()
    if not frames_elapsed % self.typing_interval == int(): return
    
    target_text = Cutscene.story[self.text_index]
    if not self.current_text == target_text:
      next_index = len(self.current_text)
      next_character = Cutscene.story[self.text_index][next_index]
      self.current_text += next_character
      if not next_character == ' ':
        yap = audio.playSound(f'yap{randint(int(), 4)}')
        yap.setVolume(0.2)
  
  def draw(self: object) -> None:
    screen.drawText(self.current_text, int(), int(), 16, 999)
    screen.setAlpha(0.6)
    screen.drawText('Click to proceed', int(), 24 - (screen.height / 2), 8, 999)
    screen.setAlpha(0.4)
    screen.drawText('Enter to skip', int(), 12 - (screen.height / 2), 8, 999)
    screen.setAlpha(1)



