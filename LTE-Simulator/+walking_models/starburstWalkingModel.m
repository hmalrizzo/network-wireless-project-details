classdef starburstWalkingModel < walking_models.walkingModel
    % Defines a walking model that makes the UE walk in a straight line
    % (c) Wajahat Baig, RMIT, 2010
    
    properties
        % direction and speed of this UE in degrees
        direction
        % Speed of this UE, in meters/TTI
        speed
    end
    
    methods
        % Class constructor
        function obj = starburstWalkingModel(speed,varargin)
            % If angle is specified, use it, if not assign a random one
            if length(varargin)<1
                direction = floor(random('unif',0,359));
            else
                direction = varargin{1};
            end
            obj.direction = direction;
            obj.speed = speed;
        end
        % Based on the current position, outputs the next TTI's position
        function new_pos = move(obj,current_pos)
            mov_vector = obj.speed * [ cos(obj.direction) sin(obj.direction) ];
            new_pos = current_pos + mov_vector;
        end
        % Based on the current position, outputs the last TTI's position
        function old_pos = move_back(obj,current_pos)
            mov_vector = obj.speed * [ cos(obj.direction) sin(obj.direction) ];
            old_pos = current_pos - mov_vector;
        end
        % Print some info
        function print(obj)
            fprintf('  direction: %d�, %d m/s*TTI\n',obj.direction,obj.speed);
        end
    end
end
