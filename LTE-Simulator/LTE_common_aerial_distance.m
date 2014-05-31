function aerial_distance = LTE_common_aerial_distance( UE_pos, eNodeB_pos)
% Calculates the aerial distance between UE and eNodeB
% (c) Wajahat Baig, RMIT, 2010
% input:    UE_pos             ... [x,y] Position of UE
%           eNodeB_pos         ... [x,y] Position of eNodeB
% output:   aerial_distance   ... [x,y] distance betweent the two

aerial_distance = sqrt((eNodeB_pos(1)-UE_pos(1))^2 + (eNodeB_pos(2)-UE_pos(2))^2);



