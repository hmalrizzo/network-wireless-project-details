%% Main simulation loop
print_log(1,['Entering main simulation loop, ' num2str(LTE_config.simulation_time_tti,'%5.0f') ' TTIs\n']);

% Inititialize timer
tic;
starting_time = toc;

%UE_log = [0 0];

% I moved this line out of the loop to save time - Wajahat Baig 02/09/2010
[ x_range y_range ] = networkPathlossMap.valid_range;

% Network clock is initialised to 0
while networkClock.current_TTI < LTE_config.simulation_time_tti
    % First of all, advance the network clock
    networkClock.advance_1_TTI;
        
    % Print all the eNodeBs and UEs from their absolute coordinates
    if LTE_config.show_network>1 || networkClock.current_TTI==1
        LTE_plot_show_network(eNodeBs,UEs,LTE_config.map_resolution,networkClock.current_TTI);
    end
    
    % Move users. To improve
    for u_ = 1:length(UEs)
        
        % I added these lines - Wajahat Baig 02/09/2010
        old_UE_position = UEs(u_).pos;
        old_eNodeB_id = UEs(u_).attached_eNodeB.id;
        old_Sector_id = UEs(u_).attached_sector;
        
        UEs(u_).move;
              
        
        % If user went outside of ROI, relocate him somewhere else. Beam me
        % up, Scotty! Take me somewhere in the map!!
        if ~UEs(u_).is_in_roi(x_range,y_range)
            % Select a random position within the ROI
            new_UE_position = networkPathlossMap.random_position;
            
            % Actually it should not be done like this. Measure all the
            % neighboring cells' SNR and then decide which one is better
            [new_eNodeB_id new_eNodeB_sector] = networkPathlossMap.cell_assignment(new_UE_position);
            
            % Teleport UE
            UEs(u_).pos = new_UE_position;
            
            % Deattach UE from old eNodeB and reattach to new one
            UEs(u_).start_handover(eNodeBs(new_eNodeB_id),new_eNodeB_sector);
            
            if LTE_config.show_network>1
                scatter(new_UE_position(1),new_UE_position(2),'Marker','o','MarkerEdgeColor','green');
            end
            
            % Print some debug
            print_log(2,['TTI ' num2str(networkClock.current_TTI) ': UE ' num2str(UEs(u_).id) ' going out of ROI, teleporting to ' num2str(new_UE_position(1)) ' ' num2str(new_UE_position(2)) '. eNodeB ' num2str(old_eNodeB_id) ' -> eNodeB ' num2str(new_eNodeB_id) '\n']);
            
        else % else condition implemented by Wajahat Baig - 02/09/2010
            if (networkClock.current_TTI > 1)
                new_UE_position = UEs(u_).pos;
                
                [new_eNodeB_id new_eNodeB_sector] = LTE_common_get_SINR(UEs(u_));
                % Disabled this line, as all cell_assignment or hand over
                % is going to take place on the basis of SINR - Wajahat
                % Baig - 03/09/2010
                
                %[new_eNodeB_id new_eNodeB_sector] = networkPathlossMap.cell_assignment(new_UE_position);

                if ~((old_Sector_id == new_eNodeB_sector)&&(old_eNodeB_id == new_eNodeB_id))
                    UEs(u_).start_handover(eNodeBs(new_eNodeB_id),new_eNodeB_sector);
                    print_log(2,['TTI ' num2str(networkClock.current_TTI) ': UE ' num2str(UEs(u_).id) ' Handed-Off: ' num2str(old_eNodeB_id) '_' num2str(old_Sector_id) '---> ' num2str(new_eNodeB_id) '_' num2str(new_eNodeB_sector) '\n']);
                end
            end
        end
    end
    
    % Placing the link measurement model here allows us to simulate
    % transmissions with 0 delay
    for u_ = 1:length(UEs)
        % Measure SINR and prepare CQI feedback
        UEs(u_).link_quality_model;
    end
    
    % The eNodeBs receive the feedbacks from the UEs
    for b_ = 1:length(eNodeBs)
        % Receives and stores the received feedbacks from the UEs
        eNodeBs(b_).receive_UE_feedback;
        % Schedule users
        eNodeBs(b_).schedule_users;
    end
    
    % Transmit data
    % Needs to be separated because in order to correctly calculate the
    % inter-cell interference each enodeB needs to have finished the
    % scheduling
    %for b_ = 1:length(eNodeBs)
        % Transmit data or prepare some kind of simulation of it (marking
        % the data that will be transmitted (eg. an H.264/AVC stream) so
        % after the data is received we know if we should mark the data as
        % correctly receive or incorrect)
    %end
    
    % Call link performance model (evaluates whether TBs are received
    % corretly according to the information conveyed by the link quality
    % model. Additionally, send feedback (channel quality indicator +
    % ACK/NACK)
    for u_ = 1:length(UEs)
        UEs(u_).link_performance_model;
        UEs(u_).send_feedback;
    end
    
    %fprintf('.');
    if mod(networkClock.current_TTI,5)==0
        elapsed_time = toc;
        time_per_iteration = elapsed_time / networkClock.current_TTI;
        estimated_time_to_finish = (LTE_config.simulation_time_tti - networkClock.current_TTI)*time_per_iteration;
        estimated_time_to_finish_h = floor(estimated_time_to_finish/3600);
        estimated_time_to_finish_m = estimated_time_to_finish/60 - estimated_time_to_finish_h*60;
        
        fprintf('Time to finish: %3.0f hours and %3.2f minutes\n',estimated_time_to_finish_h,estimated_time_to_finish_m);
    end
end

print_log(1,'Simulation finished\n');

if LTE_config.delete_ff_trace_at_end
    pregenerated_ff.traces = [];
end

print_log(1,['Saving results to ' LTE_config.results_file '\n']);
save(LTE_config.results_file);

print_log(1,'You can execute LTE_sim_results to plot the figures\n');
