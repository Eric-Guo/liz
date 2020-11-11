class Obstacle

    attr_accessor :x, :y, :width, :height, :sprite_name, :image, :type, :tree
    def initialize(x, y, width, height, sprite_name, type, tree=[nil, nil])
        @x = x
        @y = y
        @width = width
        @height = height
        @sprite_name = sprite_name
        @image = {
            x: x,
            y: y,
            w: width,
            h: height,
            path: "sprites/" + sprite_name
        }
        @type = type
        @display = true
        @tree = tree
    end



    def serialize
        { 
            x: @x,
            y: @y,
            width: @width,
            height: @height,
            image: @image,
            type: @type, 
            display: @display
        }
    end

    def inspect
        serialize.to_s
    end
        
    def to_s
        serialize.to_s
    end
    
    def updated_image(speed)
        self.x = self.x + speed
        @image = {
            x: self.x,
            y: self.y,
            w: self.width,
            h: self.height,
            path: "sprites/" + self.sprite_name
        }
    end

    def tree_image
        {
            x: self.x + 10,
            y: self.tree[1],
            w: 100,
            h: 88,
            path: "sprites/tree.png"
        }
    end

    def grass
        {
            x: self.x,
            y: self.y + 100,
            w: self.width,
            h: 8,
            path: "sprites/platform-grass.png"
        }
    end

    def current_pos
        {
            "x_gauche" => self.x,
            "x_droite" => self.x + self.width,
            "y_bas" => self.y,
            "y_haut" => self.y + self.height,            
        }
    end

    def collision_points_fall
        [self.x, self.x + self.width, self.y + self.height]
    end

    def in_the_middle
        return ((self.x > 400) && (self.x < 800))
    end

    def visible(speed=0)
        current_pos = self.current_pos
        if current_pos["y_bas"] < 0
            return false
        elsif speed == 0
            return true
        elsif speed < 0
            return !(current_pos["x_droite"] < 0)
        elsif speed > 0
            return !(current_pos["x_gauche"] > 1280)
        end
    end

    def self.generate(speed=-1, last_obstacles=[], timer=1)
        last_obstacles_3 = last_obstacles.last(3)
        bottom_y = 0
        middle_y = 250
        high_y = 500
        new_obstacles = []
        
        if last_obstacles_3 == []
            tree1 = [nil, nil]
            tree2 = [nil, nil]
            tree3 = [nil, nil]
            if speed > 0
                tree = (timer % 10)
                if tree == 1
                    tree1 = [-130, bottom_y + 100]
                elsif tree == 2
                    tree2 = [-530, middle_y + 100]
                elsif tree == 3
                    tree3 = [-930, high_y + 100]
                end
                new_obstacles << Obstacle.new(-130, bottom_y, 200, 100, "platform.png", "3", tree1)
                new_obstacles << Obstacle.new(-530, middle_y, 200, 100, "platform.png", "3", tree2)
                new_obstacles << Obstacle.new(-930, high_y, 200, 100, "platform.png", "3", tree3)
            elsif speed < 0
                tree = rand(10)
                if tree == 1
                    tree1 = [1300, bottom_y + 100]
                elsif tree == 2
                    tree2 = [1700, middle_y + 100]
                elsif tree == 3
                    tree3 = [2100, high_y + 100]
                end
                new_obstacles << Obstacle.new(1300, bottom_y, 200, 100, "platform.png", "3", tree1)
                new_obstacles << Obstacle.new(1700, middle_y, 200, 100, "platform.png", "3", tree2)
                new_obstacles << Obstacle.new(2100, high_y, 200, 100, "platform.png", "3", tree3)
            end
        elsif speed != 0
            if speed > 0
                obstacle_ref = last_obstacles_3.last
            elsif speed < 0
                obstacle_ref = last_obstacles.first
            end

            if obstacle_ref.y == middle_y
                if rand(2) == 0
                    line_height = bottom_y
                else
                    line_height = high_y
                end
            elsif obstacle_ref.y == bottom_y || obstacle_ref.y == high_y
                if rand(10) > 1
                    line_height = middle_y
                else
                    line_height = obstacle_ref.y
                end
            end
            treeX = [nil, nil]
            if (timer % 10 == 0)
                tree_pos = (speed > 0 ? -300 : 1500)
                treeX = [tree_pos, line_height + 100]
            end

            if speed > 0
                new_obs = Obstacle.new(-300, line_height, 200, 100, "platform.png", "3", treeX)
                if (new_obs.collision_points_fall[0]..new_obs.collision_points_fall[1]).to_a & (obstacle_ref.collision_points_fall[0]..obstacle_ref.collision_points_fall[1]).to_a == []
                    new_obstacles << new_obs
                end
            elsif speed < 0
                new_obs = Obstacle.new(1500, line_height, 200, 100, "platform.png", "3", treeX)
                if rand(100) == 0 && (new_obs.collision_points_fall[0]..new_obs.collision_points_fall[1]).to_a & (obstacle_ref.collision_points_fall[0]..obstacle_ref.collision_points_fall[1]).to_a == []
                    new_obstacles << new_obs
                end
            end
            
        end
        return new_obstacles
    end

    def self.check_intervalles(obstacles, new_obstacles)
        validated_obstacles = []
        new_obstacles.each do |new_obs|
            new_obstacles_plateform_elements = new_obs.collision_points_fall
            rejected = false
            obstacles.each do |obs|
                obstacles_plateform_elements = obs.collision_points_fall
                if ((obstacles_plateform_elements[0]..obstacles_plateform_elements[1]).to_a & (new_obstacles_plateform_elements[0]..new_obstacles_plateform_elements[1]).to_a != []) && obstacles_plateform_elements[2] == new_obstacles_plateform_elements[2]
                    rejected = true
                    break
                end
            end
            if rejected == false
                validated_obstacles << new_obs
            end
        end
        obstacles + validated_obstacles
    end

    def self.new_in_the_middle
        Obstacle.new(550, 250, 200, 100, "platform.png", "3")
    end
end
