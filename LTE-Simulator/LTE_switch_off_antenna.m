function [ eNodeBs ] = LTE_switch_off_antenna(eNodeB_id, sector_id)

global LTE_config;

eNodeBs(eNodeB_id).sectors(sector_id).max_power = 0;

end

