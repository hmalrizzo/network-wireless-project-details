% LTE System Level simulator
% 
% (c) Josep Colom Ikuno, INTHFT, 2008
% 
% Star-up configurations added by Mirza Wajahat Baig, RMIT, 2010
%
%
%

close all;
clc;
clear;
clear global;
clear classes;

%% Load parameters. Now done outside
LTE_load_params;
print_log(1,'Loaded configuration file\n');


% eNodeB arrangment
% Hexagonal Ring = 0
% Linear = 1
% Polygon = 2
LTE_config.eNodeB_arrangment = 1;

%Selective Antenna
% Only Sector 1 = 0
% Only Sector 2 = 1
% Only Sector 3 = 2
% Give coverage to Linear Highway - one way = 3
%   (NOTE: ONLY to be used with LTE_config.eNodeB_arrangment = 1)
%
% Give coverage to Linear Highway - two way = 4 
%   (NOTE: ONLY to be used with LTE_config.eNodeB_arrangment = 2)

%Do Not switch off any Antennas = 5

LTE_config.switch_off_eNodeBs = 5;



%Wheather to locate all UEs at a pre-defined location - Wajahat Baig 02/09/2010
LTE_config.use_UE_initial_posn = true;

%Locate UE at the following location - Wajahat Baig 02/09/2010
LTE_config.UE_general_initial_posn = [0 0];


% UE Walking Model - Wajahat Baig 02/09/2010
% 'staticWalkingModel'          - 0
% 'starburstWalkingModel'       - 1
% 'trainloadWalkingModel'       - 2
% 'beachWalkingModel'           - 3
% 'starburtUniformWalkingModel' - 4
LTE_config.UE_walkingModel = 4;


% Decision Calculation Method for Hand-off - Wajahat Baig 02/09/2010
% Cell Assignment = 0
% SINR Calculation = 1
% Cell Assignment Original (No Handovers) = 2

method = 0;

switch (method)
    case 0
        LTE_sim_main;
        LTE_sim_main_loop_CELL;
    case 1
        LTE_sim_main;
        LTE_sim_main_loop_SINR;
    case 2
        LTE_sim_main_original;
    otherwise
end

 