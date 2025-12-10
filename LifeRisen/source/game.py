
from datetime import date
date = date.today()

from time import time
start_time = time()
current_time = time()
seconds_delta = float()
frames_elapsed = int()
timer_start = None

background_color = 111
game_state = None
soul = 200

main_menu = None
cutscene = None
game_over = None
soulbar = None
player = None
spawner = None
enemies = list()
projectiles = list()

def init() -> None:
  asset_manager.loadFont("enchanted_echoes")
  screen.setFont("enchanted_echoes")
  
  global main_menu
  main_menu = MainMenu()
  global cutscene
  cutscene = Cutscene()
  global game_over
  game_over = GameOver()
  global soulbar
  soulbar = Soulbar()
  global spawner
  spawner = Spawner()
  global game_state
  game_state = GameState.MAIN_MENU
  audio.playMusic('liferisenmenu', 0.6, True)

def update() -> None:
  global current_time
  global seconds_delta
  global frames_elapsed
  new_current_time = time()
  seconds_delta = new_current_time - current_time
  current_time = new_current_time
  frames_elapsed += 1
  
  if game_state == GameState.MAIN_MENU: main_menu.update()
  elif game_state == GameState.CUTSCENE: cutscene.update()
  elif game_state == GameState.PLAYING:
    spawner.update()
    soulbar.update()
    player.update()
    for game_object in enemies + projectiles: game_object.update()
  elif game_state == GameState.GAME_OVER: game_over.update()

def draw() -> None:
  screen.clear(background_color)
  if game_state == GameState.MAIN_MENU: main_menu.draw()
  if game_state == GameState.CUTSCENE: cutscene.draw()
  elif game_state == GameState.PLAYING:
    for game_object in enemies + projectiles: game_object.draw()
    player.draw()
    soulbar.draw()
    
    screen.setDrawAnchor(1, 1)
    screen.drawText(seconds_string(current_time - timer_start), (screen.width / 2) - 8, (screen.height / 2) - 8, 16, 999)
    screen.setDrawAnchor(int(), int())
  elif game_state == GameState.GAME_OVER: game_over.draw()

def start_game() -> None:
  global game_state
  game_state = GameState.PLAYING
  global player
  player = Player()
  global enemies
  enemies.clear()
  global projectiles
  projectiles.clear()
  global timer_start
  timer_start = time()
  global soul
  soulbar.soul = soul = 200
  spawner.difficulty = int()
  audio.cancelBeeps()
  audio.playMusic('liferisen', 1, True)
  


