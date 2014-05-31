function [eNodeB_id sector_id] = LTE_common_get_SINR(UE_id)

    interfering_eNodeBs = UE_id.attached_eNodeB.neighbors;
    nr_of_sectors = interfering_eNodeBs.sectors;
    
    eNodeB_id = UE_id.attached_eNodeB.id;
    sector_id = UE_id.attached_sector;
    
    max_SINR = 0;
    
    Tx_Power =  UE_id.attached_eNodeB.sectors(UE_id.attached_sector).max_power; % Watts
    Tx_CableLoss = 1; % dB
    Tx_Antenna_Gain = UE_id.attached_eNodeB.sectors(UE_id.attached_sector).antenna.mean_antenna_gain; % dBi
    aDistance = LTE_common_aerial_distance(UE_id.pos,UE_id.attached_eNodeB.pos); % meteres
    Rx_Antenna_Gain = 0; % dBi "LTE, the UMTS long term evolution: from theory to practic by Stefania Sesia, Issam Toufik, Matthew Baker pg 517 (22.4.1)"
    Rx_CableLoss = 0; % dB
    %Rx_Sensitivity = 87; % dBm

    Total_Gain = 10*log10(Tx_Power*1000) + Tx_Antenna_Gain - Tx_CableLoss + Rx_Antenna_Gain - Rx_CableLoss;

    macroscopic_pathloss_model = LTE_common_get_macroscopic_pathloss_model;
    
    Path_Loss = macroscopic_pathloss_model.pathloss(aDistance);
    
    max_SINR = Total_Gain - Path_Loss;
    

    for e_= 1:length(interfering_eNodeBs)
        for s_ = 1:length(nr_of_sectors)
            %system_Frequency = LTE_config.frequency;
            Tx_Power = interfering_eNodeBs(e_).sectors(s_).max_power; % Watts
            Tx_CableLoss = 1; % dB
            Tx_Antenna_Gain = interfering_eNodeBs(e_).sectors(s_).antenna.mean_antenna_gain; % dBi
            aDistance = LTE_common_aerial_distance(UE_id.pos,interfering_eNodeBs(e_).pos); % meteres
            Rx_Antenna_Gain = 0; % dBi "LTE, the UMTS long term evolution: from theory to practic by Stefania Sesia, Issam Toufik, Matthew Baker pg 517 (22.4.1)"
            Rx_CableLoss = 0; % dB
            %Rx_Sensitivity = 87; % dBm

            Total_Gain = 10*log10(Tx_Power*1000) + Tx_Antenna_Gain - Tx_CableLoss + Rx_Antenna_Gain - Rx_CableLoss;

            macroscopic_pathloss_model = LTE_common_get_macroscopic_pathloss_model;
            
            Path_Loss = macroscopic_pathloss_model.pathloss(aDistance);
            
            Received_Signal = Total_Gain - Path_Loss;
            
            if (-inf < Received_Signal && Received_Signal < inf)
                if(Received_Signal > max_SINR)
                    eNodeB_id = interfering_eNodeBs(e_).id;
                    sector_id = interfering_eNodeBs(e_).sectors(s_).id;
                end
            end
        end
    end

end