def falling_collision(player_pts, obs_pts)
    ((player_pts[0]..player_pts[1]).to_a & (obs_pts[0]..obs_pts[1]).to_a != []) && player_pts[2] == obs_pts[2]
end

def collision_intervalles(solid_points)
    statement = ''
    tolerance = 10
    solid_points.each do |sp|
        statement += '((' + (sp[0]-tolerance).to_s + '..' + (sp[1]+tolerance).to_s + ').to_a.include?(x) && ' + sp[2].to_s + ' == y) ||' 
    end
    return statement.delete_suffix(' ||')
end