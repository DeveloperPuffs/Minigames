
class Physics:
  ID = '_PHYSICS'
  
  @staticmethod
  def create_body(self: object) -> None:
    setattr(self, Physics.ID, None)
    self.x = self.y = self.angle = int()
    self.velocity_x = int()
    self.velocity_y = int()
    self.velocity_angular = int()
    self.acceleration_x = int()
    self.acceleration_y = int()
    self.acceleration_angular = int()
    self.friction_x = int()
    self.friction_y = int()
    self.friction_angular = int()
  
  @staticmethod
  def reset_forces(self: object) -> None:
    if not hasattr(self, Physics.ID): return
    self.velocity_x = int()
    self.velocity_y = int()
    self.velocity_angular = int()
    self.acceleration_x = int()
    self.acceleration_y = int()
    self.acceleration_angular = int()
    
  @staticmethod
  def apply_force(self: object, x: int, y: int, angular: int) -> None:
    if not hasattr(self, Physics.ID): return
    self.acceleration_x += x
    self.acceleration_y += y
    self.acceleration_angular += angular
  
  @staticmethod
  def apply_impulse(self: object, x: int, y: int, angular: int) -> None:
    if not hasattr(self, Physics.ID): return
    self.velocity_x += x
    self.velocity_y += y
    self.velocity_angular += angular
  
  @staticmethod
  def apply_force_angle(self: object, angle: int | float, force: int) -> None:
    if not hasattr(self, Physics.ID): return
    x = math.cos(radians(angle))
    y = math.sin(radians(angle))
    Physics.apply_force(self, int(x * force), int(y * force), int())
  
  @staticmethod
  def apply_impulse_angle(self: object, angle: int | float, force: int) -> None:
    if not hasattr(self, Physics.ID): return
    x = math.cos(radians(angle))
    y = math.sin(radians(angle))
    Physics.apply_impulse(self, int(x * force), int(y * force), int())
    
  @staticmethod
  def apply_physics(self: object) -> None:
    if not hasattr(self, Physics.ID): return
    self.velocity_x += self.acceleration_x
    self.velocity_y += self.acceleration_y
    self.velocity_angular += self.acceleration_angular
    self.velocity_x -= self.velocity_x * self.friction_x
    self.velocity_y -= self.velocity_y * self.friction_y
    self.velocity_angular -= self.velocity_angular * self.friction_angular
    self.x += self.velocity_x
    self.y += self.velocity_y
    self.angle += self.velocity_angular
  
  @staticmethod
  def screen_swap(self: object, width: int, height: int) -> None:
    if self.velocity_x < int() and self.x + (width / 2) < screen.width * -0.5:
      self.x = (screen.width * 0.5) + (width / 2)
    elif self.velocity_x > int() and self.x - (width / 2) > screen.width * 0.5:
      self.x = (screen.width * -0.5) - (width / 2)
    if self.velocity_y < int() and self.y + (height / 2) < screen.height * -0.5:
      self.y = (screen.height * 0.5) + (height / 2)
    elif self.velocity_y > int() and self.y - (height / 2) > screen.height * 0.5:
      self.y = (screen.height * -0.5) - (height / 2)
  
  intersection_check = staticmethod(lambda a,b:abs(a.x-b.x)<(a.width+b.width)/2 and abs(a.y-b.y)<(a.height+b.height)/2)




    
  