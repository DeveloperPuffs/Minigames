
Introduction = class
  constructor = function()
    this.plasmapuffsAlpha = 0
    this.typingPlasmapuffsProductions = 0
    this.plasmapuffsProductionsTyped = ""
    this.typingMadeWith = 0
    this.madeWithTyped = ""
    this.microstudioAlpha = 0
    this.animation = false
  end
  
  start = function()
    this.animation = TweenService.createTween(this, "plasmapuffsAlpha", this.plasmapuffsAlpha, 1, 1, Tween.sineInOut)
    this.animation.completionHandlers.push(function(tween)
      tween.parent.animation = TweenService.createTween(tween.parent, "typingPlasmapuffsProductions", tween.parent.typingPlasmapuffsProductions, 1, 2, Tween.linear)
      tween.parent.animation.completionHandlers.push(function(innerTween)
        after 1000 do
          innerTween.parent.animation = TweenService.createTween(innerTween.parent, "typingMadeWith", innerTween.parent.typingMadeWith, 1, 1, Tween.linear)
          innerTween.parent.animation.completionHandlers.push(function(innerInnerTween)
            innerInnerTween.parent.animation = TweenService.createTween(innerInnerTween.parent, "microstudioAlpha", innerInnerTween.parent.microstudioAlpha, 1, 2, Tween.sineInOut)
            innerInnerTween.parent.animation.completionHandlers.push(function(innerInnerInnerTween)
              after 500 do global.transition.go(function() global.gameState = GameState.MAIN_MENU end) end
            end)
          end)
        end
      end)
    end)
  end
  
  typingEffect = function(text, progress)
    if not progress then return "" end
    
    local length = text.length
    local currentLength = ceil(text.length * progress)
    
    if currentLength == 1 then return text[0] end
    
    local currentText = ""
    for index = 0 to currentLength - 1 currentText += text[index] end
    return currentText
  end
  
  draw = function()
    screen.setAlpha(this.plasmapuffsAlpha)
    screen.drawSprite("plasmapuffs", 0, 16, 128, 128)
    screen.setAlpha(1)
    
    screen.setDrawAnchor(-1, 0)
    
    local plasmapuffsProductionsText = this.typingEffect("PlasmaPuffsProductions", this.typingPlasmapuffsProductions)
    if not (plasmapuffsProductionsText == this.plasmapuffsProductionsTyped) then
      this.plasmapuffsProductionsTyped = plasmapuffsProductionsText
      if not (plasmapuffsProductionsText[plasmapuffsProductionsText.length - 1] == " ") then
        audio.playSound("click", 0.2)
      end
    end
    
    screen.drawText(plasmapuffsProductionsText, -80, -44, 12, Palette.yellow)
    
    local madeWithText = this.typingEffect("Made with:", this.typingMadeWith)
    if not (madeWithText == this.madeWithTyped) then
      this.madeWithTyped = madeWithText
      if not (madeWithText[madeWithText.length - 1] == " ") then
        audio.playSound("click", 0.1)
      end
    end
    
    screen.drawText(madeWithText, -92, -84, 6, Palette.yellow)
    
    screen.setDrawAnchor(0, 0)
    
    screen.setAlpha(this.microstudioAlpha)
    screen.drawSprite("microstudio_logo", 0, -80, 300 / 3, 41 / 3)
    screen.drawSprite("microstudio_icon", 68, -80, 24, 24)
    screen.setAlpha(1)
  end
end

