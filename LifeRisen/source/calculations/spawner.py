
class Spawner:
  def __init__(self: object) -> None:
    self.difficulty = int()
    self.enemy_queue = [int(), int(), int()]
  
  def update(self: object) -> None:
    if len(enemies) == int() and sum(self.enemy_queue) == int():
        self.difficulty += 1
        if self.difficulty < 3:
          easy_enemy_multiplier = 1.0
          normal_enemy_multiplier = 0.0
          hard_enemy_multiplier = 0.0
        elif self.difficulty < 5:
          easy_enemy_multiplier = 0.8
          normal_enemy_multiplier = 0.2
          hard_enemy_multiplier = 0.0
        elif self.difficulty < 10:
          easy_enemy_multiplier = 0.6
          normal_enemy_multiplier = 0.3
          hard_enemy_multiplier = 0.1
        elif self.difficulty < 15:
          easy_enemy_multiplier = 0.4
          normal_enemy_multiplier = 0.4
          hard_enemy_multiplier = 0.2
        else:
          easy_enemy_multiplier = 0.3
          normal_enemy_multiplier = 0.3
          hard_enemy_multiplier = 0.4
        
        total_enemy_count = self.difficulty + 2
        self.enemy_queue = [
          math.ceil(total_enemy_count * easy_enemy_multiplier),
          math.ceil(total_enemy_count * normal_enemy_multiplier),
          math.ceil(total_enemy_count * hard_enemy_multiplier)
        ]
    
    if random() > 0.9:
      if sum(self.enemy_queue) > int():
        enemy_difficulty = choices((0, 1, 2), self.enemy_queue)[int()]
        self._load_enemy(enemy_difficulty)
        self.enemy_queue[enemy_difficulty] -= 1
    
  def _load_enemy(self: object, enemy_difficulty: int) -> None:
    enemy_type = choice((
      (Bumbler, Chucker),
      (Crosser, Piercer, Blocker),
      (Jammer,)
    )[enemy_difficulty])
    new_enemy = enemy_type(player)
    while True:
      new_enemy.x = randint(int(screen.width / -2), int(screen.width / 2))
      new_enemy.y = randint(int(screen.height / -2), int(screen.height / 2))
      if Physics.intersection_check(new_enemy, player): continue
      found_spawn = True
      for enemy in enemies:
        if Physics.intersection_check(new_enemy, enemy): found_spawn = False
      if found_spawn: break
    enemies.append(new_enemy)



