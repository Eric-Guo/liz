class FinishDoor

    attr_accessor :x, :y, :current_sprite_number, :image
    def initialize(x, y)
        @x = x
        @y = y
        @image = [x, y, 50, 210, "sprites/finish_door-0.png"]
    end
end