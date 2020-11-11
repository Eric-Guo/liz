class Bonus
    attr_accessor :x, :y, :type
    def initialize(x, y, type)
        @x = x
        @y = y
        @type = type
    end

    def serialize
        { 
            x: @x,
            y: @y,
            type: @type
        }
    end
end

class Lettre < Bonus
    attr_accessor :x, :y, :type, :nom
    def initialize(x, y, type, nom)
        @x = x
        @y = y
        @type = type
        @nom = nom
    end

    def serialize
        { 
            x: @x,
            y: @y,
            type: @type,
            nom: @nom
        }
    end
end