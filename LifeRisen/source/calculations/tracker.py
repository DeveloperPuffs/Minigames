
class Tracker:
  def __init__(self: object, pursuer: object, target: object) -> None:
    self.pursuer = pursuer
    self.target = target
  
  def get_angle(self: object) -> int | float:
    if not hasattr(self.pursuer, Physics.ID): return int()
    if not hasattr(self.target, Physics.ID): return int()
    
    target_points = [
      [
        (
          self.target.x + (column * screen.width),
          self.target.y + (row * screen.height)
        ) for column in range(-1, 1, 1)
      ] for row in range(-1, 1, 1)
    ]
    
    target_points = tuple(element for sublist in target_points for element in sublist)
    
    points_distances = tuple(
      hypot(
        self.pursuer.x - target_point[0],
        self.pursuer.y - target_point[1]
      ) for target_point in target_points
    )
    
    closest_point = min(points_distances)
    target_point = target_points[points_distances.index(closest_point)]
    return degrees(atan2(target_point[1] - self.pursuer.y, target_point[0] - self.pursuer.x))
    

