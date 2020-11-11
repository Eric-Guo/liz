class Letter

    attr_accessor :x, :y, :letter, :image, :sens, :current_sprite_number
    def initialize(x, y, letter)
        @x = x
        @y = y
        @letter = letter
        @sens = (rand(2) == 0 ? 1 : -1)
        @image = {
            x: x,
            y: y,
            w: 50,
            h: 50,
            path: "sprites/" + letter + ".png"
        }
        @current_sprite_number = 0
    end

    def serialize
        {}
    end
    
    def inspect
        serialize.to_s
    end
        
    def to_s
        serialize.to_s
    end

    def move_x(mov_x)
        self.x += mov_x

        if self.current_sprite_number < 5
            self.current_sprite_number += 1
        else
            self.current_sprite_number = 0
        end

        @image = {
            x: x,
            y: y,
            w: 50,
            h: 50,
            path: "sprites/" + self.letter + "-" + self.current_sprite_number.to_s + ".png"
        }
    end

    def move_to_sky(mov_x, mov_y)
        self.x += mov_x
        self.y += mov_y
    end

    def goal_pos
        [self.x, self.y]
    end

    def is_in_bag_zone?(bag_zone)
        return (bag_zone["x"].include? self.x) && (bag_zone["y"].include? self.y)
    end
end

class Timer < Letter
end

class Food < Letter
end