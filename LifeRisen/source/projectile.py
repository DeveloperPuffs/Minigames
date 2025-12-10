
class Projectile:
  def __init__(self: object, sprite_name: str, width: int, height: int, life: int) -> None:
    Physics.create_body(self)
    
    self.life = life
    self.damage = int()
    self.width = width
    self.height = height
    self.sprite_name = f'projectiles/{sprite_name}'
  
  def update(self: object) -> None:
    if self.life <= 1:
      if self.life <= int():
        self.life = int()
        projectiles.remove(self)
        return
      else: self.life = max(int(), self.life - 0.1)
    else: self.life -= 1
    Physics.apply_physics(self)
    Physics.screen_swap(self, self.width, self.height)
  
  def draw(self: object) -> None:
    if self.life < 1: screen.setAlpha(self.life)
    screen.setDrawRotation(self.angle)
    screen.drawSprite(self.sprite_name, self.x, self.y, self.width, self.height)
    screen.setDrawRotation(int())
    screen.setAlpha(1)
