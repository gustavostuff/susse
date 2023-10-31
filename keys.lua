local keys = {
  escape = 'escape',
  c = 'c',

  ctrlDown = function ()
    return love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl')
  end,
  shiftDown = function ()
    return love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')
  end,
  isEnterKey = function (key)
    return key == 'return' or key == 'kpenter' or key == 'enter'
  end,
  spaceDown = function ()
    return love.keyboard.isDown('space')
  end,
  anyDown = function (keys)
    for _, k in ipairs(keys) do
      if love.keyboard.isDown(k) then
        return true
      end
    end
    return false
  end,
  isAnyOf = function(key, keys)
    for _, k in ipairs(keys) do
      if key == k then
        return true
      end
    end
    return false
  end,
}

return keys
