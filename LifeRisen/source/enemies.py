
class Enemy:
  def __init__(self: object, target: object, sprite_name: str, width: int, height: int) -> None:
    Physics.create_body(self)
    self.friction_x = self.friction_y = 0.1
    
    self.life = randint(300, 600)
    self.damage = 10
    self.tracker = Tracker(self, target)
    self.target = target
    
    self.state = EnemyState.SPAWNING
    self.scale_x = self.scale_y = 1
    self.alpha = float()
    self.width = width
    self.height = height
    self.sprite_name = f'enemies/{sprite_name}'
  
  def update(self: object) -> None:
    if self.state == EnemyState.SPAWNING:
      if self.alpha >= 1:
        self.alpha = self.scale_x = self.scale_y = 1
        self.state = EnemyState.PLAYING
      else:
        self.alpha += 0.01
        self.angle += 6
        self.scale_x = self.scale_y = self.alpha
    elif self.state == EnemyState.DESPAWNING:
      if self.alpha <= int():
        self.alpha = self.scale_x = self.scale_y = int()
        enemies.remove(self)
      else:
        self.alpha -= 0.01
        self.angle += 6
        self.scale_x = self.scale_y = self.alpha
    elif self.state == EnemyState.PLAYING:
      self.angle = self.tracker.get_angle()
      self.react()
      Physics.apply_physics(self)
      Physics.screen_swap(self, self.width, self.height)
      for enemy in enemies:
        if enemy is self or not Physics.intersection_check(self, enemy): continue
        Physics.apply_impulse(self, (self.x - enemy.x) / 10, (self.y - enemy.y) / 10, int())
      if self.life <= 0:
        self.life = 0
        self.state = EnemyState.DESPAWNING
      else: self.life -= 1
    
  def react(self: object) -> None: return

  def draw(self: object) -> None:
    screen.setAlpha(self.alpha)
    screen.setDrawRotation(self.angle)
    screen.setDrawScale(self.scale_x, self.scale_y)
    screen.drawSprite(self.sprite_name, self.x, self.y, self.width, self.height)
    screen.setDrawScale(1, 1)
    screen.setDrawRotation(int())
    screen.setAlpha(1)

class Bumbler(Enemy):
  def __init__(self: object, target: object) -> None:
    super().__init__(target, 'bumbler', 8, 8)
  
  def react(self: object) -> None:
    if not frames_elapsed % 60 == int(): return
    force = randint(4, 8)
    Physics.apply_impulse_angle(self, self.angle, force)

class Chucker(Enemy):
  def __init__(self: object, target: object) -> None:
    super().__init__(target, 'chucker', 8, 8)
    
  def react(self: object) -> None:
    if not frames_elapsed % 80 == int(): return
    new_projectile = Projectile('small', 4, 4, 120)
    new_projectile.damage = 5
    new_projectile.x = self.x
    new_projectile.y = self.y
    new_projectile.angle = self.angle
    Physics.apply_impulse(new_projectile, 0, 0, randint(-6, 6))
    Physics.apply_impulse_angle(new_projectile, new_projectile.angle, 2)
    projectiles.append(new_projectile)

class Crosser(Enemy):
  def __init__(self: object, target: object) -> None:
    super().__init__(target, 'crosser', 16, 16)
    
  def react(self: object) -> None:
    if not frames_elapsed % 120 == int(): return
    for angle in (0, 90, 180, 270):
      new_projectile = Projectile('round/medium', 8, 8, 90)
      new_projectile.damage = 10
      new_projectile.x = self.x
      new_projectile.y = self.y
      new_projectile.angle = (self.angle + angle) % 360
      Physics.apply_impulse(new_projectile, 0, 0, randint(-6, 6))
      Physics.apply_impulse_angle(new_projectile, new_projectile.angle, 2)
      projectiles.append(new_projectile)

class Piercer(Enemy):
  def __init__(self: object, target: object) -> None:
    super().__init__(target, 'piercer', 16, 16)
    
  def react(self: object) -> None:
    if not frames_elapsed % 40 == int(): return
    for angle in (0, 90, 180, 270):
      Physics.apply_impulse_angle(self, self.angle, 3)
      new_projectile = Projectile('small', 4, 4, 120)
      new_projectile.damage = 5
      new_projectile.x = self.x
      new_projectile.y = self.y
      new_projectile.angle = (self.angle + 180) % 360
      Physics.apply_impulse(new_projectile, 0, 0, randint(-6, 6))
      Physics.apply_impulse_angle(new_projectile, new_projectile.angle, 2)
      projectiles.append(new_projectile)

class Blocker(Enemy):
  def __init__(self: object, target: object) -> None:
    super().__init__(target, 'blocker', 16, 16)
  
  def react(self: object) -> None:
    if not frames_elapsed % 60 == int(): return
    for angle in (-30, 0, 30):
      new_projectile = Projectile('square/medium', 8, 8, 120)
      new_projectile.damage = 10
      new_projectile.x = self.x
      new_projectile.y = self.y
      new_projectile.angle = (self.angle + angle) % 360
      Physics.apply_impulse(new_projectile, 0, 0, randint(-6, 6))
      Physics.apply_impulse_angle(new_projectile, new_projectile.angle, 2)
      projectiles.append(new_projectile)

class Jammer(Enemy):
  def __init__(self: object, target: object) -> None:
    super().__init__(target, 'jammer', 32, 32)
  
  def react(self: object) -> None:
    if not frames_elapsed % 90 == int(): return
    for angle in (-30, 0, 30):
      new_projectile = Projectile('square/big', 16, 16, 120)
      new_projectile.damage = 50
      new_projectile.x = self.x
      new_projectile.y = self.y
      new_projectile.angle = (self.angle + angle) % 360
      Physics.apply_impulse(new_projectile, 0, 0, randint(-6, 6))
      Physics.apply_impulse_angle(new_projectile, new_projectile.angle, 2)
      projectiles.append(new_projectile)



