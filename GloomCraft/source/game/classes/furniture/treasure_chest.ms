
global.TreasureChest = class
  constructor = function(game, spot)
    this.game = game
    this.spot = spot
    
    this.x = 0
    this.y = 0
    this.width = 16
    this.height = 16
    
    this.open = false
    this.empty = false
    this.frame = 0
    this.frameInterval = 4
    
    this.interaction = new global.Interaction(this.game, "E", "Open")
    this.coinDispenseThread = false
    this.coinQueue = []
  end
  
  update = function()
    if this.frame and not this.empty then
      if this.frame >= this.frameInterval * 7 then
        this.empty = true
        this.obtain()
      else this.frame += 1 end
    end
    
    if this.canInteract(this.game.player) and keyboard.press.E then
      this.openUp()
    end
  end
  
  draw = function()
    local frameIndex = floor(this.frame / this.frameInterval)
    local sprite = global.sprites["furniture/treasure_chest"].frames[frameIndex]
    screen.drawSprite(sprite, this.x, this.y, this.width, this.height)
  end
  
  openUp = function()
    if this.open then return end
    this.frame += 1
    this.open = true
  end
  
  canInteract = function(player)
    return (
      abs(this.spot[0] - player.column) < 2 and
      abs(this.spot[1] - player.row) < 2
    )
  end
  
  obtain = function()
    audio.playSound("transaction", 0.1)
    this.dropCoins()
  end
  
  dropCoins = function()
    local player = this.game.player
    local angle = atan2d(player.y - this.y, player.x - this.x)
    
    local createCoins = function(count, data, angle)
      local coins = []
      if not count then return coins end
      for index = 0 to count - 1
        local a = angle + random.nextInt(60) - 30
        local x = this.x + (16 * cosd(a))
        local y = this.y + (16 * sind(a))
        local coin = new global.Coin(this.game, x, y, a, data)
        coins.push(coin)
      end
      
      return coins
    end
    
    local money = random.integerRange(50, 150)
    local bronzeCoins = money % 10
    local silverCoins = floor((money / 10) % 10)
    local goldCoins = floor(((money - bronzeCoins) - (10 * silverCoins)) / 100)
    
    this.coinQueue += createCoins(bronzeCoins, global.Coin.BRONZE, angle)
    this.coinQueue += createCoins(silverCoins, global.Coin.SILVER, angle)
    this.coinQueue += createCoins(goldCoins, global.Coin.GOLD, angle)
    random.shuffle(this.coinQueue)
    
    this.coinDispenseThread = every 0.1 seconds do
      if this.coinQueue.length then
        local coin = this.coinQueue[0]
        this.game.coins.push(coin)
        this.coinQueue.removeElement(coin)
      else this.coinDispenseThread.stop() end
    end
  end
end

