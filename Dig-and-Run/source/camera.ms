
/*
Camera inspired from the game 'Meowy's Adventure' by mrLman.
*/
Camera = class
  constructor = function()
    this.x = 0
    this.y = 0
    this.tx = 0
    this.ty = 0
    this.ox = 0
    this.oy = 0
    this.dx = screen.width / 8
    this.dy = screen.height / 8
    this.speed = 0.05
  end
  
  update = function()
    this.tx = min(max(this.tx, this.ox - this.dx), this.ox + this.dx)
    this.ty = min(max(this.ty, this.oy - this.dy), this.oy + this.dy)
    
    this.x += (this.tx - this.x) * this.speed
    this.y += (this.ty - this.y) * this.speed
  end
  
  draw = function()
    screen.setTranslation(-this.x, -this.y)
  end
end

screen.shake = function(a, b, c) end


