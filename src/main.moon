math.randomseed os.time!
import graphics from love
import max, random, sin, cos, floor, fmod from math
import insert, remove from table

w, h = graphics.getWidth!, graphics.getHeight!
tau = math.pi * 2
arcOffset = 40
spawnRadius = 100 + max(w, h) / 2

gfx = {
  "pine-tree": graphics.newImage "gfx/pine-tree.png"
  "burning-tree": graphics.newImage "gfx/burning-tree.png"
  "log": graphics.newImage "gfx/log.png"
  "missile-launcher": graphics.newImage "gfx/missile-launcher.png"
}

objects = {}

local Tree3032
class Cone3032
  new: (path) =>
    unless path
      r = random! * tau
      path = {
        w/2 + spawnRadius * cos r,
        h/2 + spawnRadius * sin r,
        nil, nil,
        arcOffset + random! * (w - arcOffset * 2),
        arcOffset + random! * (h - arcOffset * 2)
      }
      r = random! * tau
      path[3] = (path[1] + path[5]) / 2 + arcOffset * cos r
      path[4] = (path[2] + path[6]) / 2 + arcOffset * sin r

    @path = love.math.newBezierCurve(path)\render!
    @time = 0
    @location = 1
    @speed = 0.8 + random! * 1.2

  update: (dt) =>
    @time += dt * @speed
    if @time >= 1
      @location += 2
      @time -= 1
      unless @path[@location]
        insert objects, Tree3032(@path[#@path - 1], @path[#@path])
        return false
    return true

  draw: =>
    graphics.setColor 0.75, 0.75, 0.75, 0.5
    graphics.line(@path)

    graphics.setColor 1, 0, 0, 0.8
    x, y = @path[@location], @path[@location + 1]
    x2, y2 = @path[@location + 2], @path[@location + 3]
    if x2 and y2
      x += (x2 - x) * @time
      y += (y2 - y) * @time
    graphics.circle "fill", x, y, 3

class Missile3032
  new: (x, y) =>
    if x and y
      x, y = x + 10, y + 10
    else
      x, y = 8 + random! * (w - 16), 8 + random! * (h - 16)

    r = random! * tau
    path = {
      x, y, nil, nil,
      -- TODO target missile sites FIRST, then random locations
      arcOffset + random! * (w - arcOffset * 2),
      arcOffset + random! * (h - arcOffset * 2)
    }
    r = random! * tau
    path[3] = (path[1] + path[5]) / 2 + arcOffset * cos r
    path[4] = (path[2] + path[6]) / 2 + arcOffset * sin r

    @path = love.math.newBezierCurve(path)\render!
    @time = 0
    @location = 1
    @speed = 1.5 + random! * 1.75
    @green = 0
    @timing = {100, 110, 115} -- lazy hack for when to fire cones

  fire: =>
    x, y = @path[@location], @path[@location + 1]
    x2, y2 = @path[@location + 2], @path[@location + 3]
    if x2 and y2
      x += (x2 - x) * @time
      y += (y2 - y) * @time
    path = {
      x, y, nil, nil
    }
    path[1] = @path[#@path - 1] unless path[1]
    path[2] = @path[#@path] unless path[2]
    -- lazy, square distribution instead of circular
    path[5] = path[1] + random! * 40
    path[6] = path[2] + random! * 40
    r = random! * tau
    path[3] = (path[1] + path[5]) / 2 + arcOffset * cos r
    path[4] = (path[2] + path[6]) / 2 + arcOffset * sin r
    insert objects, Cone3032(path)
    @green = max 0.9, @green + 0.25

  update: (dt) =>
    @time += dt * @speed
    if @time >= 1
      @location += 2
      if #@timing > 0 and @location >= @timing[1]
        @fire!
        remove(@timing, 1)
      @time -= 1
      unless @path[@location]
        @fire!
        return false
    return true

  draw: =>
    graphics.setColor 0.8, 0.6, 0.6, 0.75
    graphics.line(@path)

    graphics.setColor 1, 0, 0, 1
    x, y = @path[@location], @path[@location + 1]
    x2, y2 = @path[@location + 2], @path[@location + 3]
    if x2 and y2
      x += (x2 - x) * @time
      y += (y2 - y) * @time
    graphics.draw gfx["log"], x - 8, y - 8, 0, 16/512, 16/512

class Tree3032
  new: (x, y) =>
    if x and y
      @x, @y = x - 10, y - 10
    else
      @x, @y = 10 + random! * (w - 20), 10 + random! * (h - 20)

    @time = 255
    @speed = 8 + random! * 4

  update: (dt) =>
    @time -= dt * @speed
    if @time <= 0
      insert objects, Missile3032(@x, @y)
      return false
    return true

  draw: =>
    graphics.setColor 1, @time/255, @time/255, 0.9
    if @time > 25
      graphics.draw gfx["pine-tree"], @x, @y, 0, 20/512, 20/512
    else
      graphics.draw gfx["burning-tree"], @x, @y, 0, 20/512, 20/512

love.update = (dt) ->
  for i = 1, #objects
    object = objects[i]
    unless object\update dt
      remove objects, i
      i -= 1

love.draw = ->
  for object in *objects
    object\draw!

love.keypressed = (key) ->
  if key == "escape"
    love.event.quit!

  -- TEMPORARY
  if key == "c"
    insert objects, Cone3032!
  if key == "t"
    insert objects, Tree3032!
  if key == "m"
    insert objects, Missile3032!

-- 3032 -> spawns randomly by projectile paths of cones impacting and then growing slowly to maturity
--  upon maturity, will fire into random arc, and fling more cones out to repeat the process
--
-- 3017 -> person wanders on-screen, tap (repeatedly) to capture (will draw wall around him)
--  after a time, one section of the wall will randomly disappear, allowing him to move again
