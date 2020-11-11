class Character

    attr_accessor :x, :y, :sprite_name, :image, :jump_height, :moving_direction, :current_sprite_number, :flip_horizontally, :limit_right, :limit_left, :moving_defaut
    WIDTH = 50
    HEIGHT = 50
    def initialize(x, y, sprite_name, limit_left=0, limit_right=0)
        @x = x
        @y = y
        @sprite_name = sprite_name
        @current_sprite_number = 0
        @flip_horizontally = false
        @image = {
            x: x,
            y: y,
            w: WIDTH,
            h: HEIGHT,
            path: "sprites/" + sprite_name + "-" + current_sprite_number.to_s + ".png",
            flip_horizontally: false
          }
        @jump_height = 0
        @moving_direction = 0
        @limit_left = limit_left
        @limit_right = limit_right
        @moving_defaut = (rand(2) == 0 ? 1 : -1)
    end

    def serialize
        { 
            x: @x,
            y: @y,
            sprite_name: @sprite_name,
            image: @image
        }
    end

    def inspect
        serialize.to_s
    end
        
    def to_s
        serialize.to_s
    end

    def collision_points_fall
        [self.x, self.x + WIDTH, self.y]
    end
    
    def is_standing?(collision_inter)
        bottom_y = 0 + 100
        middle_y = 250 + 100
        high_y = 500 + 100
        tolerance = 20
        #Ajuster le self.y
        if self.y > high_y && self.y < (high_y + tolerance)
            self.y = high_y
            @image[:y] = self.y
        elsif self.y > middle_y && self.y < (middle_y + tolerance)
            self.y = middle_y
            @image[:y] = self.y
        elsif self.y > bottom_y && self.y < (bottom_y + tolerance)
            self.y = bottom_y
            @image[:y] = self.y
        end
        x, y = self.x, self.y

        if eval(collision_inter)
            return true
        end

        return false
    end

    def fall(gravitation)
        self.y -= gravitation
        @image = {
            x: self.x,
            y: self.y,
            w: WIDTH,
            h: HEIGHT,
            path: "sprites/" + self.sprite_name + "-0.png"
        }
        
    end

    def move_x(mov_x, sprite_animation=true)
        self.x += mov_x
        @image[:x] = self.x

        self.limit_left -= mov_x
        self.limit_right -= mov_x
        if sprite_animation == true
            if self.current_sprite_number < 5
                self.current_sprite_number += 1
            else
                self.current_sprite_number = 0
            end

            @image[:path] = "sprites/" + sprite_name + "-" + self.current_sprite_number.to_s + ".png"
            @image[:flip_horizontally] = self.flip_horizontally
        end
    end

    def move_y(mov_y)
        self.y += mov_y
        @image[:y] = self.y
        
    end

    def goal_pos
        [
            self.x + (WIDTH/2),
            self.y + (HEIGHT/2),
        ]
    end

    def in_the_middle
        return ((self.x > 400) && (self.x < 800))
    end

    def falling_distance(max_jump_height)
        # bottom_y = 0
        # middle_y = 250
        # high_y = 500
        # if self.y > (high_y + 100)
        #     current_height = self.y - (high_y + 100)
        # elsif self.y > (middle_y + 100)
        #     current_height = self.y - (middle_y + 100)
        # elsif self.y > (bottom_y + 100)
        #     current_height = self.y - (middle_y + 100)
        # else
        #     return 0
        # end
        # return Math.sqrt(Math.sqrt(max_jump_height - current_height)).to_i
        5
    end


end

class Pnj < Character
    attr_accessor :exploded
    def goal_pos
        nbr = 50
        width_add = WIDTH/nbr
        (0..nbr).to_a.map {|i| [self.x + (i*width_add), self.y + (HEIGHT/2)]}
    end

    def explode
        self.exploded = true
        @current_sprite_number = 0
        @image[:path] = "sprites/explosion-2.png"
    end

end

class Player < Character
    def bag_zone
        tolerance = 20
        {
            "x" => ((self.x-tolerance)..(self.x+WIDTH+tolerance)).to_a,
            "y" => ((self.y-tolerance)..(self.y+HEIGHT+tolerance)).to_a
        }
    end

    def in_win_zone
        return ((self.x > 615) && (self.x < 680) && (self.y > 250) && (self.y < 480))
    end

    def victory_image
        {
            x: self.x,
            y: self.y,
            w: WIDTH,
            h: HEIGHT,
            path: "sprites/star.png"
        }
    end

    def neutral_image
        @image[:path] = "sprites/sorcerer-0.png"
    end
end
