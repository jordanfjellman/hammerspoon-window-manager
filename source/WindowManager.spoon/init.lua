local WindowManager = {}

WindowManager.__index = WindowManager

-- Metadata
WindowManager.name = "WindowManager"
WindowManager.version = "0.1.0"
WindowManager.author = "Jordan Fjellman"
WindowManager.homepage = "https://github.com/jordanfjellman/hammerspoon-window-manager"
WindowManager.license = "ISC - https://opensource.org/licenses/ISC"

--- WindowManager.modifiers
--- Variable
--- Modifier keys used when managing windows
---
--- Notes:
--- * Default Value: `{ "shift", "alt", "ctrl" }` (also known as "meh")
WindowManager.modifiers = { "shift", "alt", "ctrl" }

--- WindowManager.animationDuration
--- Variable
--- Number setting the window animation duration
---
--- Notes:
--- * Default Value: 0
WindowManager.animationDuration = 0

--- WindowManager:resizeAndMove(location)
--- Method
--- Handles the resizing and moving of the focused window
function WindowManager:resizeAndMove(location)
  local currentWidth = 50

  local resizeDirectionally = function (direction)
    return function (newWidthPercentage)
      hs.window.focusedWindow():moveToUnit(hs.layout[direction .. newWidthPercentage])
      return newWidthPercentage
    end
  end

  local resizeOnCenter = function(newWidthPercentage)
      local width = hs.screen.mainScreen():frame().w * (newWidthPercentage / 100)
      local height = hs.screen.mainScreen():frame().h
      hs.window.focusedWindow():setSize(width, height)
      hs.window.focusedWindow():centerOnScreen()
      return newWidthPercentage
  end

  local nextWidth = {
    [30] = 50,
    [50] = 70,
    [70] = 30,
  }

  local _resizeAndMove = function ()
    if location == 'fullscreen' then
      hs.window.focusedWindow():toggleFullscreen()
      return currentWidth
    end
    local update = location == 'center' and resizeOnCenter or resizeDirectionally(location)
    return update(nextWidth[currentWidth])
  end

  return function()
      currentWidth = _resizeAndMove()
  end
end

--- WindowManager:bindHotKeys(mapping)
--- Method
--- Binds hotkeys for WindowManager
function WindowManager:bindHotKeys(mapping)
  for key, location in pairs(mapping) do
    hs.hotkey.bind(WindowManager.modifiers, key, WindowManager:resizeAndMove(location))
  end
end

--- WindowManager:init()
--- Method
--- Sets window animation duration. Called when Spoon is loaded.
function WindowManager:init()
  hs.window.animationDuration = WindowManager.animationDuration
end

