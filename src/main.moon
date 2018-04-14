math.randomseed os.time!
import graphics from love
import random, sin, cos from math

w, h = graphics.getWidth!, graphics.getHeight!
tau = math.pi * 2
borderProtection = 50
spawnRadius = borderProtection + math.max(w, h) / 2

objects = {}

class Cone3032
  new: (path) =>
    unless path
      r = random! * tau
      path = {
        w/2 + spawnRadius * cos r,
        h/2 + spawnRadius * sin r,
        nil, nil,
        borderProtection + random! * (w - borderProtection * 2),
        borderProtection + random! * (h - borderProtection * 2)
      }
      r = random! * tau
      path[3] = (path[1] + path[5]) / 2 + borderProtection * cos r
      path[4] = (path[2] + path[6]) / 2 + borderProtection * sin r

    @path = love.math.newBezierCurve(path)\render!
    @projectile = 1
    @time = 0

  update: (dt) =>
    @time += dt
    if @time >= 1
      @time -= 1
      @projectile += 2
      -- TEMPORARY
      unless @path[@projectile]
        @projectile -= 2

  draw: =>
    graphics.setColor 150, 150, 150, 25
    graphics.line(@path)

    -- TEMPORARY
    graphics.setColor 255, 0, 0, 200
    graphics.circle "fill", @path[@projectile], @path[@projectile+1], 3

love.update = (dt) ->
  for object in *objects
    object\update dt

love.draw = ->
  for object in *objects
    object\draw!

love.keypressed = (key) ->
  if key == "escape"
    love.event.quit!

  -- TEMPORARY
  if key == "c"
    table.insert objects, Cone3032!

-- 3032 -> spawns randomly by projectile paths of cones impacting and then growing slowly to maturity
--  upon maturity, will fire into random arc, and fling more cones out to repeat the process
--
-- 3017 -> person wanders on-screen, tap (repeatedly) to capture (will draw wall around him)
--  after a time, one section of the wall will randomly disappear, allowing him to move again
