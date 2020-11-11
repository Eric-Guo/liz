class FinishDoor

    attr_accessor :x, :y, :current_sprite_number, :image
    def initialize(x, y)
        @x = x
        @y = y
        @image = {
            x: x,
            y: y,
            w: 50,
            h: 210,
            path: "sprites/finish_door-0.png"
        }
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
end