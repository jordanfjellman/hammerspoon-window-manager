local obj = {}

obj.__index = obj

-- Metadata
obj.name = "WindowManager"
obj.version = "0.0.7"
obj.author = "Jordan Fjellman"
obj.homepage = "https://github.com/jordanfjellman/hammerspoon-window-manager"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- WindowManager.modifiers
--- Variable
--- Modifier keys used when managing windows
---
--- Notes:
--- * Default Value: `{ "shift", "alt", "ctrl" }` (also known as "meh")
obj.modifiers = { "shift", "alt", "ctrl" }

--- WindowManager.animationDuration
--- Variable
--- Number setting the window animation duration
---
--- Notes:
--- * Default Value: 0
obj.animationDuration = 0

--- WindowManager:resizeAndMove(location)
--- Method
--- Handles the resizing and moving of the focused window
function obj:resizeAndMove(location)
  local previousWidth = 50
  local previouslyFocusedWindowId = nil

  local checkForNewlyFocusedWindow = function ()
    local isDifferentWindow = previouslyFocusedWindowId ~= hs.window.focusedWindow():id()
    if isDifferentWindow then
      previouslyFocusedWindowId = hs.window.focusedWindow():id()
    end
    return isDifferentWindow
  end

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
      return previousWidth
    end
    local update = location == 'center' and resizeOnCenter or resizeDirectionally(location)
    local width = checkForNewlyFocusedWindow() and 50 or nextWidth[previousWidth]
    return update(width)
  end

  return function()
      previousWidth = _resizeAndMove()
  end
end

--- WindowManager:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for WindowManager
function obj:bindHotkeys(mapping)
  for key, location in pairs(mapping) do
    hs.hotkey.bind(obj.modifiers, key, obj:resizeAndMove(location))
  end
end

--- WindowManager:init()
--- Method
--- Sets window animation duration. Called when Spoon is loaded.
function obj:init()
  hs.window.animationDuration = obj.animationDuration
end

return obj
