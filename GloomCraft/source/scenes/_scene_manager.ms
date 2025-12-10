
global.SceneManager = class
  INTRODUCTION = "Introduction"
  MAIN_MENU = "Main Menu"
  INSTRUCTIONS = "Instructions"
  GAME = "Game"
  GAME_OVER = "Game Over"
  
  constructor = function()
    this.scene = false
  end
  
  update = function()
    if this.scene then this.scene.update() end
  end
  
  draw = function()
    if this.scene then this.scene.draw() end
  end
  
  setScene = function(name = global.SceneManager.INTRODUCTION)
    if this.scene then if this.scene.name == name then return end end
    
    if name == global.SceneManager.INTRODUCTION then
      this.scene = new global.IntroductionScene(name)
    elsif name == global.SceneManager.MAIN_MENU then
      this.scene = new global.MainMenuScene(name)
    elsif name == global.SceneManager.INSTRUCTIONS then
      this.scene = new global.InstructionsScene(name)
    elsif name == global.SceneManager.GAME then
      this.scene = new global.GameScene(name)
    elsif name == global.SceneManager.GAME_OVER then
      this.scene = new global.GameOverScene(name)
    end
  end
end

