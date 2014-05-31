classdef beachWalkingModel < walking_models.walkingModel
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
        function obj = beachWalkingModel(speed,varargin)
            % If angle is specified, use it, if not assign a random one
            %obj.direction = 135;
            obj.speed = speed;
        end
        % Based on the current position, outputs the next TTI's position
        function new_pos = move(obj,current_pos)
            xx = current_pos(1);
            yy = current_pos(2);
            
            
                if (xx > 500)
                    xx = xx - obj.speed;
                    %yy = yy;
                elseif(xx <=500 && xx >=0)
                    xx = xx - obj.speed;
                    yy = yy - obj.speed;  
                elseif(xx < 0 && xx >= -500 )
                    xx = xx - obj.speed;
                    yy = yy + obj.speed;
                elseif (xx < -500)
                    xx = xx - obj.speed;
                    %yy = yy;
                end
                    
            
            new_pos = [xx yy];
           
%                b = (sqrt((500^2)-a^2));
%                mov_vector = obj.speed * [a b];
%                new_pos = mov_vector;
            
            
%             if((current_pos(1)<=-500))
%                 xx = current_pos(1)+ 10*obj.speed;
%                 yy = current_pos(2);
%                 new_pos = [xx yy];
%                 
%             elseif((current_pos(1)>-500) && (current_pos(1)<=0))
%                 xx = current_pos(1)+ 10*obj.speed;
%                 yy = - (sqrt(500^2 - xx^2))-500;
%                 new_pos = [xx yy];
%             elseif((current_pos(1)>0) && (current_pos(1)<500))
%                 xx = current_pos(1) - obj.speed;
%                 print_log(2,['XX ' num2str(xx) ' - ']);
%                 yy = (sqrt(500^2 - xx^2))-500;
%                 print_log(2,['YY ' num2str(yy) '\n']);
%                 new_pos = [xx yy];
%             elseif(current_pos(1)>=500)
%                 xx = current_pos(1)+ 10*obj.speed;
%                 yy = current_pos(2);
%                 new_pos = [xx yy];
%             end
%                
%            else
%                
%                
%            end

        end
        % Based on the current position, outputs the last TTI's position
        function old_pos = move_back(obj,current_pos)
            mov_vector = obj.speed * [ cos(obj.direction) sin(obj.direction) ];
            old_pos = current_pos - mov_vector;
        end
        % Print some info
        function print(obj)
            fprintf('  direction: %d°, %d m/s*TTI\n',obj.direction,obj.speed);
        end
    end
end
