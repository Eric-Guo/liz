require 'app/classes/character.rb'
require 'app/classes/obstacle.rb'
require 'app/classes/bonus.rb'
require 'app/classes/letter.rb'
require 'app/classes/finish_door.rb'
require 'app/lib/helper.rb'

GRAVITATION = 8
STANDARD_SPEED = 4
MAGIC_WORDS = ["GIBBON", "VEAU", "SANGLIER", "HERISSON", "PORC"]
MAX_JUMP_HEIGHT = 1200
def tick args

  args.state.game_started ||= false
  args.state.speed ||= 0
  args.state.speed_increment ||= STANDARD_SPEED
  args.state.player ||= nil
  args.state.obstacles ||= []
  args.state.wabbits ||= []
  args.state.wabbits_goal_pos ||= []
  args.state.wabbits_toremove_pos ||= []
  args.state.score ||= 0
  args.state.game_over ||= false
  args.state.obstacle_platforms ||= []
  args.state.letters ||= []
  args.state.magic_word ||= MAGIC_WORDS.shuffle.last.split("").join("")
  args.state.missing_letters ||= args.state.magic_word.split("")
  args.state.collected_word ||= ''
  args.state.remaining_time ||= 45
  args.state.finish_door ||= nil
  args.state.victory ||= false
  args.state.foods ||= []
  args.state.hold_food ||= ""

  if args.state.game_started == false
    args.state.player = Player.new(500, 500, "sorcerer")
    args.state.obstacles << Obstacle.new(0, 0, 1280, 100, "platform-big.png", "3")
    args.state.game_started = true
    
    #sound_muted
    sound_rand = rand(3)
    if sound_rand == 0
      args.outputs.sounds << 'sounds/desert.ogg'
    elsif sound_rand == 1
      args.outputs.sounds << 'sounds/grass.ogg'
    elsif sound_rand == 2
      args.outputs.sounds << 'sounds/wood.ogg'
    end
  end

  #Gestion affichage
  args.outputs.sprites << [0, 0, 1280, 720, "sprites/background.png"]
  player_falling = true

  current_obstacles = []
  middle_platform = false
  args.state.obstacle_platforms = []
  args.state.obstacles.each do |obs|
    if obs.visible(args.state.speed) == true
      current_obstacles << obs
      args.outputs.sprites << obs.updated_image(args.state.speed)
      args.outputs.sprites << obs.grass
      args.outputs.sprites << obs.tree_image if obs.tree != [nil, nil]
      args.state.obstacle_platforms << obs.collision_points_fall
      if middle_platform == false && args.state.speed != 0 && obs.in_the_middle == true
        middle_platform = true
      end
    end
  end
  
  args.state.obstacles = current_obstacles.uniq
  args.state.obstacles << Obstacle.new_in_the_middle if middle_platform == false && args.state.speed != 0  && !args.state.player.in_the_middle
  remaining_letters = []
  args.state.letters.each do |letter|
    if letter.is_in_bag_zone?(args.state.player.bag_zone) 
      if letter.class.name == "Letter" && !args.state.missing_letters.index(letter.letter).nil?
        args.state.collected_word += letter.letter
        args.state.magic_word[0] = ""
        args.state.missing_letters.delete_at(args.state.missing_letters.index(letter.letter))
      elsif letter.class.name == "Timer"
        args.state.remaining_time += 15
      elsif letter.class.name == "Food"
        args.state.hold_food = letter.letter
        args.state.foods << letter.letter
      end
    else
      letter.move_x(args.state.speed)
      letter.sens = -letter.sens if rand(3) == 0
      letter.move_to_sky((STANDARD_SPEED*letter.sens/1.3).to_i, STANDARD_SPEED)
      if letter.class.name == "Timer" || letter.class.name == "Food"
        args.outputs.sprites << letter.image
      elsif letter.class.name == "Letter"
        args.outputs.labels << [letter.x, letter.y, letter.letter, 16, 0, 255, 255, 255, 255, "fonts/tooncast.ttf"]
      end
      remaining_letters << letter
    end
  end


  if args.state.remaining_time < 10
    args.outputs.labels << [610, 660, args.state.remaining_time, 50, 0, 255, 255, 255, 255, "fonts/tooncast.ttf"]
  end

  args.state.letters = remaining_letters
  args.outputs.labels << [600, 700, args.state.collected_word, 16, 0, 255, 255, 255, 255, "fonts/tooncast.ttf"]

  collision_intervalles = collision_intervalles(args.state.obstacle_platforms.uniq)
  if args.state.player.is_standing?(collision_intervalles) == true
    player_falling = false
    if !args.inputs.keyboard.right && !args.inputs.keyboard.left
      args.state.player.image[4] = "sprites/sorcerer-0.png"
    end
  end
  args.state.player.move_x(args.state.speed, false)

  if player_falling == true && args.state.victory == false
    args.state.player.fall(GRAVITATION)
    args.state.player.move_x(args.state.player.moving_direction*args.state.player.falling_distance(MAX_JUMP_HEIGHT))
  elsif player_falling == false
    args.state.player.moving_direction = 0
  end
  args.outputs.sprites << args.state.finish_door.image unless args.state.finish_door.nil?

  if args.state.victory == false
    args.outputs.sprites << args.state.player.image
  else
    args.outputs.sprites << args.state.player.victory_image
  end

  args.outputs.labels << [10, 700, args.state.remaining_time, 1, 0, 255, 255, 255, 255, "fonts/press_start.ttf"]
  args.outputs.sprites << [80, 665, 50, 50, "sprites/" + args.state.hold_food + "-0" + ".png"] unless args.state.hold_food == ""
  args.outputs.labels << [1230, 700, "x" + args.state.speed_increment.to_s, 1, 0, 255, 255, 255, 255, "fonts/press_start.ttf"]
  args.state.wabbits_goal_pos = []
  updated_wabbits = []
  args.state.wabbits.each do |wabbit|
    wabbit_positions = wabbit.goal_pos
    if wabbit.exploded == true && @current_sprite_number < 7
      wabbit.move_x(args.state.speed, true)
    elsif wabbit.exploded == true
      next
    elsif wabbit_positions.include? args.state.wabbits_toremove_pos
      next
    end
    wabbit.fall(GRAVITATION) if wabbit.is_standing?(collision_intervalles) == false
    wabbit.move_x(args.state.speed, false)
    args.outputs.sprites << wabbit.image
    args.state.wabbits_goal_pos += wabbit_positions
    updated_wabbits << wabbit
    random_mov = rand(10)
    if wabbit.limit_left > STANDARD_SPEED*2.5 && wabbit.moving_defaut < 0 && random_mov > 1
      wabbit.move_x(wabbit.moving_defaut*STANDARD_SPEED, true)
    elsif wabbit.limit_right > STANDARD_SPEED*2.5 && wabbit.moving_defaut > 0 && random_mov > 1
      wabbit.move_x(wabbit.moving_defaut*STANDARD_SPEED, true)
    else
      wabbit.moving_defaut = -wabbit.moving_defaut
    end
  end
  args.state.wabbits = updated_wabbits

  if args.state.finish_door != nil && args.state.player.in_win_zone == true
    args.state.victory = true
    args.state.game_over = true
  end

  if args.state.game_over == false 
    if args.state.missing_letters == []
      args.state.finish_door = FinishDoor.new(620, 250)
    end

    if args.state.tick_count % 60 == 0
      args.state.remaining_time -= 1
    end

    args.state.game_over = true if args.state.remaining_time < 1
    #Mouvements joueur
    if args.inputs.keyboard.left
      args.state.player.flip_vertically = true
      args.state.player.move_x(-10, true)
      args.state.player.moving_direction = -1
    elsif args.inputs.keyboard.right
      args.state.player.flip_vertically = false
      args.state.player.move_x(10, true)
      args.state.player.moving_direction = 1
    end

    player_goal_pos = args.state.player.goal_pos
    if args.state.wabbits_goal_pos.include? player_goal_pos
      #Detection wabbit touché
      args.state.wabbits_toremove_pos = player_goal_pos
      args.state.score += 100
      if args.state.missing_letters.count > 0
        args.state.letters << Letter.new(player_goal_pos[0], player_goal_pos[1] + 80, args.state.missing_letters.first)
      end
    end

    if (args.state.tick_count + args.state.wabbits.count) % 600 == 0
      args.state.letters << Timer.new((args.state.player.x > 640 ? (args.state.player.x/2) : 1280 - (args.state.player.x/2)), 0, "clock")
    end

    if args.state.hold_food == "" && ((args.state.tick_count + args.state.wabbits.count) % 600 == 300)
      args.state.letters << Food.new(580 + rand(100), 0, "mushroom")
    end

    if player_falling == false && (args.inputs.keyboard.up || args.inputs.keyboard.space)
      args.state.player.jump_height = MAX_JUMP_HEIGHT
    end

    if args.state.player.jump_height != 0
      jump_speed = 25
      args.state.player.move_y((jump_speed*args.state.player.jump_height/MAX_JUMP_HEIGHT).to_i)
      args.state.player.jump_height -= jump_speed
    end

    #Création d'obstacle
    if args.state.obstacles.last(3).count == 1 && rand(10) > 1
      obstacle_rand = rand(10)
    else
      obstacle_rand = rand(500)
    end
    
    if obstacle_rand == 0
      args.state.speed = -args.state.speed
      args.state.speed = STANDARD_SPEED if args.state.speed == 0
      args.state.obstacles = Obstacle.check_intervalles(args.state.obstacles, Obstacle.generate(args.state.speed, [], args.state.tick_count)) if rand(10) == 0
    else
      args.state.obstacles = Obstacle.check_intervalles(args.state.obstacles, Obstacle.generate(args.state.speed, args.state.obstacles, args.state.tick_count))
    end


    
    wabbit_place = [args.state.obstacles.last.x + (args.state.obstacles.last.width/2), args.state.obstacles.last.y + args.state.obstacles.last.height, args.state.obstacles.last.x, args.state.obstacles.last.x + args.state.obstacles.last.width]
    wabbit_gen_rand = rand(100)
    if wabbit_gen_rand < 10
      if args.state.wabbits.count > 3
        rand_wabbit = args.state.wabbits.shuffle.last
        rand_wabbit.explode
      end
      args.state.wabbits << Pnj.new(wabbit_place[0], wabbit_place[1], "wabbit", wabbit_place[0] - wabbit_place[2], wabbit_place[3] - wabbit_place[0])
    elsif wabbit_gen_rand == 11
    #   if args.state.wabbits.count > 4
    #     rand_wabbit = args.state.wabbits.shuffle.last
    #     rand_wabbit.explode
    #   end
      if args.state.wabbits.count > 6
        rand_wabbit = args.state.wabbits.shuffle.last
        rand_wabbit.explode
      end
      rand_wabbit_pos = rand(1280)
      args.state.wabbits << Pnj.new(rand_wabbit_pos, 800, "wabbit", rand_wabbit_pos - 50, rand_wabbit_pos + 50)
    end
    
    
  end

  #Partie terminée
  if args.state.player.y < 0 || args.state.victory == true
    magic_words = ["GIBBON", "VEAU", "SANGLIER", "HERISSON", "PORC"]
    args.state.speed = 0
    args.state.game_over = true


    if args.state.victory == false
      args.outputs.labels << [400, 360, "MORT AU NIVEAU " + (args.state.speed_increment - STANDARD_SPEED + 1).to_s, 1, 0, 255, 255, 255, 255, "fonts/press_start.ttf"]
      args.outputs.labels << [300, 330, "ESPACE POUR RECOMMENCER", 1, 0, 255, 255, 255, 255, "fonts/press_start.ttf"]
    else
      args.outputs.labels << [400, 360, "VICTOIRE AU NIVEAU " + (args.state.speed_increment - STANDARD_SPEED + 1).to_s, 1, 0, 255, 255, 255, 255, "fonts/press_start.ttf"]
      args.outputs.labels << [300, 330, "ESPACE POUR NIVEAU SUIVANT", 1, 0, 255, 255, 255, 255, "fonts/press_start.ttf"]    
    end

    if args.inputs.keyboard.space
      if args.state.victory == false
        args.state.speed_increment = STANDARD_SPEED
      else
        args.state.speed_increment = -args.state.speed_increment if args.state.speed_increment < 0
        if args.state.speed_increment < STANDARD_SPEED
          args.state.speed_increment = STANDARD_SPEED
        end
        args.state.speed_increment += 1
      end
      args.state.game_started = false
      args.state.speed = args.state.speed_increment
      args.state.player = nil
      args.state.obstacles = []
      args.state.wabbits = []
      args.state.wabbits_goal_pos = []
      args.state.wabbits_toremove_pos = []
      args.state.score = 0
      args.state.game_over = false
      args.state.obstacle_platforms = []
      args.state.letters = []
      args.state.magic_word = magic_words.shuffle.last
      args.state.missing_letters = args.state.magic_word.split("")
      args.state.collected_word = ''
      args.state.remaining_time = 45
      args.state.finish_door = nil
      args.state.victory = false
      args.state.hold_food = ""

    end
  end
end
