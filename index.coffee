DEBUG = false
SPEED = 160
GRAVITY = 1100
FLAP = 320
SPAWN_RATE = 1 / 1200
OPENING = 100
SCALE = 1

HEIGHT = 384
WIDTH = 288
GAME_HEIGHT = 336
GROUND_HEIGHT = 64
GROUND_Y = HEIGHT - GROUND_HEIGHT

parent = document.querySelector("#screen")
gameStarted = undefined
gameOver = undefined

deadTubeTops = []
deadTubeBottoms = []
deadInvs = []

bg = null
tubes = null
invs = null
bird = null
ground = null

score = null
scoreText = null
instText = null
gameOverText = null

flapSnd = null
scoreSnd = null
hurtSnd = null
fallSnd = null
swooshSnd = null

tubesTimer = null

character = window.localStorage.getItem("character")
if character == null
  window.localStorage.setItem "character", "ksu"
  character = window.localStorage.getItem("character")


floor = Math.floor

main = ->
  spawntube = (openPos, flipped) ->
    tube = null

    tubeKey = if flipped then "tubeTop" else "tubeBottom"
    if flipped
      tubeY = floor(openPos - OPENING / 2 - 320)
    else
      tubeY = floor(openPos + OPENING / 2)

    if deadTubeTops.length > 0 and tubeKey == "tubeTop"
      tube = deadTubeTops.pop().revive()
      tube.reset(game.world.width, tubeY)
    else if deadTubeBottoms.length > 0 and tubeKey == "tubeBottom"
      tube = deadTubeBottoms.pop().revive()
      tube.reset(game.world.width, tubeY)
    else
      tube = tubes.create(game.world.width, tubeY, tubeKey)
      game.physics.enable(tube, Phaser.Physics.ARCADE)
      tube.body.allowGravity = false

    # Move to the left
    tube.body.velocity.x = -SPEED
    tube

  spawntubes = ->
    # check dead tubes
    tubes.forEachAlive (tube) ->
      if tube.x + tube.width < game.world.bounds.left
        deadTubeTops.push tube.kill() if tube.key == "tubeTop"
        deadTubeBottoms.push tube.kill() if tube.key == "tubeBottom"
      return
    invs.forEachAlive (invs) ->
      deadInvs.push invs.kill() if invs.x + invs.width < game.world.bounds.left
      return

    tubeY = game.world.height / 2 + (Math.random()-0.5) * game.world.height * 0.2

    # Bottom tube
    bottube = spawntube(tubeY)

    # Top tube (flipped)
    toptube = spawntube(tubeY, true)

    # Add invisible thingy
    if deadInvs.length > 0
      inv = deadInvs.pop().revive().reset(toptube.x + toptube.width / 2, 0)
    else
      inv = invs.create(toptube.x + toptube.width / 2, 0)
      inv.width = 2
      inv.height = game.world.height
      game.physics.enable(inv, Phaser.Physics.ARCADE)
      inv.body.allowGravity = false
    inv.body.velocity.x = -SPEED
    return

  addScore = (_, inv) ->
    invs.remove inv
    score += 1
    scoreText.setText score
    scoreSnd.play()
    return

  setGameOver = ->
    gameOver = true
    bird.body.velocity.y = 100 if bird.body.velocity.y > 0
    bird.animations.stop()
    bird.frame = 1
    instText.setText "TOUCH\nTO TRY AGAIN"
    instText.renderable = true
    hiscore = window.localStorage.getItem("hiscore")
    hiscore = (if hiscore then hiscore else score)
    hiscore = (if score > parseInt(hiscore, 10) then score else hiscore)
    window.localStorage.setItem "hiscore", hiscore
    gameOverText.setText "Brownback Wins!\n\nHIGH SCORE\n\n" + hiscore
    gameOverText.renderable = true

    # Stop all tubes
    tubes.forEachAlive (tube) ->
      tube.body.velocity.x = 0
      return

    invs.forEach (inv) ->
      inv.body.velocity.x = 0
      return


    # Stop spawning tubes
    game.time.events.remove(tubesTimer)

    # Make bird reset the game
    game.time.events.add 1000, ->
      game.input.onTap.addOnce ->
        reset()
        swooshSnd.play()

    hurtSnd.play()
    return

  flap = ->
    start()  unless gameStarted
    unless gameOver
      # bird.body.velocity.y = -FLAP
      bird.body.gravity.y = 0;
      bird.body.velocity.y = -100;
      tween = game.add.tween(bird.body.velocity).to(y:-FLAP, 25, Phaser.Easing.Bounce.In,true);
      tween.onComplete.add ->
        bird.body.gravity.y = GRAVITY
      flapSnd.play()
    return

  preload = ->
  
  	if (character == "ksu")
  	  assets =
  	    spritesheet:
          bird: [
            "assets/characters/ksu.png"
            31
            24
          ]
        image:
          tubeTop: ["assets/tube1.png"]
          tubeBottom: ["assets/tube2.png"]
          ground: ["assets/ground.png"]
          bg: ["assets/bg.png"]

        audio:
          flap: ["assets/sfx_wing.mp3"]
          score: ["assets/sfx_point.mp3"]
          hurt: ["assets/sfx_hit.mp3"]
          fall: ["assets/sfx_die.mp3"]
          swoosh: ["assets/sfx_swooshing.mp3"]
          
    else if (character == "ku")
  	  assets =
  	    spritesheet:
          bird: [
            "assets/characters/ku.png"
            34
            20
          ]
        image:
          tubeTop: ["assets/tube1.png"]
          tubeBottom: ["assets/tube2.png"]
          ground: ["assets/ground.png"]
          bg: ["assets/bg.png"]

        audio:
          flap: ["assets/sfx_wing.mp3"]
          score: ["assets/sfx_point.mp3"]
          hurt: ["assets/sfx_hit.mp3"]
          fall: ["assets/sfx_die.mp3"]
          swoosh: ["assets/sfx_swooshing.mp3"]
          
    else if (character == "wsu")
  	  assets =
  	    spritesheet:
          bird: [
            "assets/characters/wsu.png"
            28
            23
          ]
        image:
          tubeTop: ["assets/tube1.png"]
          tubeBottom: ["assets/tube2.png"]
          ground: ["assets/ground.png"]
          bg: ["assets/bg.png"]

        audio:
          flap: ["assets/sfx_wing.mp3"]
          score: ["assets/sfx_point.mp3"]
          hurt: ["assets/sfx_hit.mp3"]
          fall: ["assets/sfx_die.mp3"]
          swoosh: ["assets/sfx_swooshing.mp3"]
          
    else
  	  assets =
  	    spritesheet:
          bird: [
            "assets/characters/fhsu.png"
            24
            23
          ]
        image:
          tubeTop: ["assets/tube1.png"]
          tubeBottom: ["assets/tube2.png"]
          ground: ["assets/ground.png"]
          bg: ["assets/bg.png"]

        audio:
          flap: ["assets/sfx_wing.mp3"]
          score: ["assets/sfx_point.mp3"]
          hurt: ["assets/sfx_hit.mp3"]
          fall: ["assets/sfx_die.mp3"]
          swoosh: ["assets/sfx_swooshing.mp3"]
          
    Object.keys(assets).forEach (type) ->
      Object.keys(assets[type]).forEach (id) ->
        game.load[type].apply game.load, [id].concat(assets[type][id])
        return

      return

    return

  create = ->
    ratio = window.innerWidth / window.innerHeight
    document.querySelector('#loading').style.display = 'none'

    # Set world dimensions
    Phaser.Canvas.setSmoothingEnabled(game.context, false)
    game.scale.scaleMode = Phaser.ScaleManager.SHOW_ALL
    game.world.width = WIDTH
    game.world.height = HEIGHT

    # Draw bg
    bg = game.add.tileSprite(0, 0, WIDTH, HEIGHT, 'bg')

    # # Add clouds group
    # clouds = game.add.group()

    # Add tubes
    tubes = game.add.group()

    # Add invisible thingies
    invs = game.add.group()

    # Add bird
    bird = game.add.sprite(0, 0, "bird")
    game.physics.enable(bird, Phaser.Physics.ARCADE)
    bird.anchor.setTo 0.5, 0.5
    
    bird.body.collideWorldBounds = true
    # This was removed in phaser update. Need to make better polygons for each avatar anyway.
    # bird.body.setPolygon(
    #   24,1,
    #   34,16,
    #   30,32,
    #   20,24,
    #   12,34,
    #   2,12,
    #   14,2
    # )

    # Add ground
    ground = game.add.tileSprite(0, GROUND_Y, WIDTH, GROUND_HEIGHT, "ground")
    ground.tileScale.setTo SCALE, SCALE

    # Add score text
    scoreText = game.add.text(game.world.width / 2, game.world.height / 4, "",
      font: "16px \"Press Start 2P\""
      fill: "#fff"
      stroke: "#430"
      strokeThickness: 4
      align: "center"
    )
    scoreText.anchor.setTo 0.5, 0.5

    # Add instructions text
    instText = game.add.text(game.world.width / 2, game.world.height - game.world.height / 4, "",
      font: "8px \"Press Start 2P\""
      fill: "#fff"
      stroke: "#430"
      strokeThickness: 4
      align: "center"
    )
    instText.anchor.setTo 0.5, 0.5

    # Add game over text
    gameOverText = game.add.text(game.world.width / 2, game.world.height / 2, "",
      font: "16px \"Press Start 2P\""
      fill: "#fff"
      stroke: "#430"
      strokeThickness: 4
      align: "center"
    )
    gameOverText.anchor.setTo 0.5, 0.5
    gameOverText.scale.setTo SCALE, SCALE

    # Add sounds
    flapSnd = game.add.audio("flap")
    scoreSnd = game.add.audio("score")
    hurtSnd = game.add.audio("hurt")
    fallSnd = game.add.audio("fall")
    swooshSnd = game.add.audio("swoosh")

    # Add controls
    game.input.onDown.add flap

    # RESET!
    reset()
    return

  reset = ->
    gameStarted = false
    gameOver = false
    score = 0
    scoreText.setText "Thread\nBrownback's Cuts"
    instText.setText "Try your best to avoid\nBrownback's pay cuts.\n\nTAP TO FLY"
    gameOverText.renderable = false
    bird.body.allowGravity = false
    bird.reset game.world.width * 0.3, game.world.height / 2
    bird.angle = 0
    bird.animations.play "fly"
    tubes.removeAll()
    invs.removeAll()
    return

  start = ->

    bird.body.allowGravity = true
    bird.body.gravity.y = GRAVITY

    # SPAWN tubeS!
    tubesTimer = game.time.events.loop 1 / SPAWN_RATE, spawntubes


    # Show score
    scoreText.setText score
    instText.renderable = false

    # START!
    gameStarted = true
    return

  update = ->
    if gameStarted
      if !gameOver
        # Make bird dive
        bird.angle = (90 * (FLAP + bird.body.velocity.y) / FLAP) - 180
        bird.angle = -30  if bird.angle < -30
        if bird.angle > 80
          bird.angle = 90
          bird.animations.stop()
          bird.frame = 1
        else
          bird.animations.play()

        # Check game over
        game.physics.arcade.overlap bird, tubes, ->
          setGameOver()
          fallSnd.play()
        setGameOver() if not gameOver and bird.body.bottom >= GROUND_Y

        # Add score
        game.physics.arcade.overlap bird, invs, addScore

      else
        # rotate the bird to make sure its head hit ground
        tween = game.add.tween(bird).to(angle: 90, 100, Phaser.Easing.Bounce.Out, true);
        if bird.body.bottom >= GROUND_Y + 3
          bird.y = GROUND_Y - 13
          bird.body.velocity.y = 0
          bird.body.allowGravity = false
          bird.body.gravity.y = 0

    else
      bird.y = (game.world.height / 2) + 8 * Math.cos(game.time.now / 200)
      bird.angle = 0


    # Scroll ground
    ground.tilePosition.x -= game.time.physicsElapsed * SPEED unless gameOver
    return

  render = ->
    if DEBUG
      game.debug.renderSpriteBody bird
      tubes.forEachAlive (tube) ->
        game.debug.renderSpriteBody tube
        return

      invs.forEach (inv) ->
        game.debug.renderSpriteBody inv
        return

    return

  state =
    preload: preload
    create: create
    update: update
    render: render

  game = new Phaser.Game(WIDTH, HEIGHT, Phaser.CANVAS, parent, state, false, false)
  return

WebFontConfig =
  google:
    families: [ 'Press+Start+2P::latin' ]
  active: main
(->
  wf = document.createElement('script')
  wf.src = (if 'https:' == document.location.protocol then 'https' else 'http') +
    '://ajax.googleapis.com/ajax/libs/webfont/1/webfont.js'
  wf.type = 'text/javascript'
  wf.async = 'true'
  s = document.getElementsByTagName('script')[0]
  s.parentNode.insertBefore(wf, s)
)()