
global.Coin = class
  BRONZE = ["Bronze", "bronze", 1, 0.5]
  SILVER = ["Silver", "silver", 10, 1]
  GOLD = ["Gold", "gold", 100, 2]
  
  constructor = function(game, x, y, scatter, data)
    this.game = game
    this.name = data[0]
    this.sprite = data[1]
    this.value = data[2]
    this.pitch = data[3]
    
    this.x = x
    this.y = y
    
    this.width = 8
    this.height = 8
    
    local power = random.nextInt(30) + 20
    this.vx = cosd(scatter) * power
    this.vy = sind(scatter) * power
    
    this.hitbox = new global.Hitbox()
    this.hitbox.rectangle.width = this.width
    this.hitbox.rectangle.height = this.height
    this.hitbox.rectangle.x = this.x
    this.hitbox.rectangle.y = this.y
  end
  
  update = function()
    this.x += this.vx * this.game.timer.deltaTime
    this.y += this.vy * this.game.timer.deltaTime
    this.vx -= this.vx * 2 * this.game.timer.deltaTime
    this.vy -= this.vy * 2 * this.game.timer.deltaTime
    
    this.hitbox.rectangle.x = this.x
    this.hitbox.rectangle.y = this.y
    
    if global.tilemapCollision(this) then
      this.x -= this.vx * this.game.timer.deltaTime
      this.y -= this.vy * this.game.timer.deltaTime
      this.vx = 0
      this.vy = 0
    end
    
    local player = this.game.player
    if (
      this.x < player.x + player.width and
      this.x + this.width > player.x and
      this.y < player.y + player.height and
      this.y + this.height > player.y
    ) then
      local sound = audio.playSound("coin", 0.2)
      sound.setPitch(this.pitch)
      this.game.player.balance += this.value
      this.game.coins.removeElement(this)
    end
  end
  
  draw = function()
    local sprite = "coins/" + this.sprite
    screen.drawSprite(sprite, this.x, this.y, this.width, this.height)
  end
end

