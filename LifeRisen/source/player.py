
class Player:
  def __init__(self: object) -> None:
    Physics.create_body(self)
    self.friction_x = self.friction_y = 0.15
    self.invincibility_timer = None
    
    self.flip = 1
    self.width = self.height = 16
    self.sprite_name = 'player'
    self.afterimages = list()
    self.dashing = None
  
  def update(self: object) -> None:
    if self.invincibility_timer is not None:
      if self.invincibility_timer <= int(): self.invincibility_timer = None
      else: self.invincibility_timer -= 1
    for afterimage in self.afterimages: afterimage.update()
    if self.dashing is not None:
      if self.dashing >= 20: self.dashing = None
      else: self.dashing += 1
    elif check_input(keyboard, 'SPACE'):
      woosh = audio.playSound('dash')
      woosh.setVolume(0.1)
      self.dashing = int()
      self.velocity_x *= 5
      self.velocity_y *= 5
    left_input = check_input(keyboard, 'LEFT') or check_input(gamepad, 'LEFT')
    right_input = check_input(keyboard, 'RIGHT') or check_input(gamepad, 'RIGHT')
    up_input = check_input(keyboard, 'UP') or check_input(gamepad, 'UP')
    down_input = check_input(keyboard, 'DOWN') or check_input(gamepad, 'DOWN')
    horizontal_input = right_input - left_input
    vertical_input = up_input - down_input
    diagonal_movement_factor = sqrt(2) if horizontal_input and vertical_input else 1
    acceleration_x = 0.5 * horizontal_input / diagonal_movement_factor
    acceleration_y = 0.5 * vertical_input / diagonal_movement_factor
    self.acceleration_x = int()
    self.acceleration_y = int()
    Physics.apply_force(self, acceleration_x, acceleration_y, int())
    Physics.apply_physics(self)
    Physics.screen_swap(self, self.width, self.height)
    
    if (
      (self.flip == 1 and self.velocity_x < int()) or
      (self.flip == -1 and self.velocity_x > int())
    ): self.flip *= -1
    
    if self.invincibility_timer is None:
      damage_taken = int()
      for enemy in enemies:
        if Physics.intersection_check(self, enemy):
          if enemy.state == EnemyState.PLAYING:
            enemy.state = EnemyState.DESPAWNING
            damage_taken += enemy.damage
      for projectile in projectiles:
        if Physics.intersection_check(self, projectile):
          if projectile.life > 1:
            projectile.life = 1
            damage_taken += projectile.damage
      if damage_taken > int():
        global soul
        soul = max(int(), soul - damage_taken)
    if self.dashing and (not round(self.velocity_x) == int() or not round(self.velocity_y) == int()): PlayerAfterimage(self)
  
  def draw(self: object) -> None:
    for afterimage in self.afterimages: afterimage.draw()
    screen.setDrawScale(self.flip, 1)
    screen.drawSprite(self.sprite_name, self.x, self.y, self.width, self.height) 
    screen.setDrawScale(1, 1)
  
class PlayerAfterimage:
  def __init__(self: object, player: object) -> None:
    player.afterimages.append(self)
    self.player = player
    self.x = self.player.x
    self.y = self.player.y
    self.life_percent = 20
  
  def update(self: object) -> None:
    if self.life_percent <= int(): self.player.afterimages.remove(self)
    else: self.life_percent -= 2
  
  def draw(self: object) -> None:
    screen.setAlpha(self.life_percent / 100)
    screen.drawSprite(self.player.sprite_name, self.x, self.y, self.player.width, self.player.height)
    screen.setAlpha(1)
    
    
    
    