% LTE System Level simulator
% 
% (c) Josep Colom Ikuno, INTHFT, 2008
%

%% Load and plot BLER curves
[ BLER_curves CQI_mapper ] = LTE_init_load_BLER_curves;

%% Get the eNodeBs, the Macroscopic Pathloss and the Shadow Fading
[eNodeBs networkPathlossMap networkShadowFadingMap] = LTE_init_network_generation;  % Squeezed network generation code in this script for ease of reuse (cell capacity calculation) 

%% Calculate target sector
LTE_config.target_sector = LTE_common_get_target_sector(eNodeBs,networkPathlossMap);

%% Calculate average cell capacity
if exist('networkShadowFadingMap','var')
    [LTE_config.capacity_no_shadowing sector_SINR_no_shadowing] = LTE_common_calculate_cell_capacity(networkPathlossMap,eNodeBs,CQI_mapper);
    [LTE_config.capacity              sector_SINR             ] = LTE_common_calculate_cell_capacity(networkPathlossMap,eNodeBs,CQI_mapper,networkShadowFadingMap);
else
    [LTE_config.capacity              sector_SINR             ] = LTE_common_calculate_cell_capacity(networkPathlossMap,eNodeBs,CQI_mapper);
end

%% Plot network
if LTE_config.show_network>0
    if exist('networkShadowFadingMap','var')
        LTE_plot_sector_SINR_cdfs(sector_SINR,sector_SINR_no_shadowing);
        LTE_plot_loaded_network(eNodeBs,networkPathlossMap,networkShadowFadingMap);
    else
        LTE_plot_sector_SINR_cdfs(sector_SINR);
        LTE_plot_loaded_network(eNodeBs,networkPathlossMap);
    end
end

%% Add a clock to each network element
networkClock = network_elements.clock(LTE_config.TTI_length);

for b_=1:length(eNodeBs)
    eNodeBs(b_).clock = networkClock;
end

%% Create users (UEs)
UEs = LTE_init_generate_users(eNodeBs,networkPathlossMap);

%% Generate/load the fast fading traces
ff_file_exists = exist(LTE_config.pregenerated_ff_file,'file');
if LTE_config.recalculate_fast_fading || (~ff_file_exists && ~LTE_config.recalculate_fast_fading)
    % Generated UE fast fading
    print_log(1,['Generating UE fast fading and saving to ' LTE_config.pregenerated_ff_file '\n']);
    pregenerated_ff = LTE_init_get_microscale_fading_SL_trace;
    save(LTE_config.pregenerated_ff_file,'pregenerated_ff');
else
    % Load UE fast fading
    print_log(1,['Loading UE fast fading from ' LTE_config.pregenerated_ff_file '\n']);
    load(LTE_config.pregenerated_ff_file,'pregenerated_ff');
    
    % Wrong number of nTX or nRX antennas
    if LTE_config.nTX~=pregenerated_ff.nTX || LTE_config.nRX~=pregenerated_ff.nRX
        error('Trace is for a %dx%d system. Config defines a %dx%d system.',pregenerated_ff.nTX,pregenerated_ff.nRX,LTE_config.nRX);
    end
    
    % Wrong bandwidth case
    if LTE_config.bandwidth ~= pregenerated_ff.system_bandwidth
        error('Loaded FF trace is not at the correct frequency: %3.2f MHz required, %3.2f MHz found',LTE_config.bandwidth/1e6,pregenerated_ff.system_bandwidth/1e6);
    end
    
    % Wrong UE speed case (not applicable if trace UE_speed is NaN->speed independent)
    if (pregenerated_ff.UE_speed~=LTE_config.UE_speed) && ~isnan(pregenerated_UE_ff.UE_speed)
        error('Loaded FF trace is generated at %3.2f m/s. UE speed is %3.2f m/s. Trace cannot be used.',pregenerated_ff.UE_speed,LTE_config.UE_speed);
    end
    
    % Print microscale fading trace speed
    if isnan(pregenerated_ff.UE_speed)
        print_log(1,sprintf('Microscale fading trace is speed-independent\n'));
    else
        print_log(1,sprintf('UE Fast fading trace at %3.2f m/s (%3.2f Km/h)\n',pregenerated_ff.UE_speed,pregenerated_ff.UE_speed*3.6));
    end
    
end

% Add a downlink and uplink channel object to each user
% The downlink will contain pathloss maps, so depending on the user's
% position, it will 'see' a certain pathloss.
% The uplink is simply a delay between the UE and the eNodeB.
for u_=1:length(UEs)
    
    % Add downlink channel (includes macroscopic pathloss, shadow fading
    % and fast fading models)
    UEs(u_).downlink_channel = channel_models.downlinkChannelModel(UEs(u_));
    
    % Macroscopic pathloss
    UEs(u_).downlink_channel.set_macroscopic_pathloss_model(networkPathlossMap);
    
    % Shadow fading (data obtained from planning tools already have this information incorporated)
    if ~strcmp(LTE_config.network_source,'odyssey')
        UEs(u_).downlink_channel.set_shadow_fading_model(networkShadowFadingMap);
    end

    % Set fast fading from the eNodeB to an attached UE.
    if LTE_config.use_fast_fading
        UEs(u_).downlink_channel.set_fast_fading_model_model(channel_gain_wrappers.fastFadingWrapper(pregenerated_ff,'random',length(eNodeBs),length(eNodeBs(1).sectors)));
    end
    
    % Set UE SINR averaging algorithm
    switch LTE_config.SINR_averaging.algorithm
        case 'MIESM'
            UEs(u_).SINR_averager = utils.miesmAverager(LTE_config.SINR_averaging.BICM_capacity_tables);
        case 'EESM'
            UEs(u_).SINR_averager = utils.eesmAverager(LTE_config.SINR_averaging.betas,LTE_config.SINR_averaging.MCSs);
        otherwise
            error('SINR averaging algorithm not supported');
    end
    
    % Set signaling channel (eNodeB to UE)
    UEs(u_).eNodeB_signaling = network_elements.eNodebSignaling;
    
    % Number of RX antennas
    UEs(u_).nRX = LTE_config.nRX;
    
    % Thermal noise in dBm
    UEs(u_).downlink_channel.thermal_noise_watts_RB = 10^(0.1*LTE_config.UE.thermal_noise_density)/1000 * LTE_config.RB_bandwidth;
    UEs(u_).downlink_channel.thermal_noise_dBW_RB   = 10*log10(UEs(u_).downlink_channel.thermal_noise_watts_RB);
    
    % Set BLER curves for ACK/NACK calculation
    UEs(u_).BLER_curves = BLER_curves;
    
    % Uplink channel
    UEs(u_).uplink_channel = channel_models.uplinkChannelModel(...
        UEs(u_),...
        LTE_config.N_RB,...
        LTE_config.maxStreams,...
        LTE_config.feedback_channel_delay);
    UEs(u_).clock = networkClock;
    UEs(u_).CQI_mapper = CQI_mapper;
    
    % Configure unquantized feedback
    if LTE_config.unquantized_CQI_feedback
        UEs(u_).unquantized_CQI_feedback = true;
    end
end

%% Initialise schedulers
LTE_init_add_schedulers(eNodeBs,UEs,CQI_mapper,BLER_curves);

%% Initialise the tracing
% Global traces
simulation_traces = tracing.simTraces;
% Traces from received UE feedbacks (eNodeB side)
simulation_traces.eNodeB_rx_feedback_traces = tracing.receivedFeedbackTrace(...
    LTE_config.simulation_time_tti,...
    length(UEs),...
    LTE_config.N_RB,...
    LTE_config.maxStreams,...
    LTE_config.traces_config.unquantized_CQI_feedback);

for b_=1:length(eNodeBs)
    for s_=1:length(eNodeBs(b_).sectors)
        eNodeBs(b_).sectors(s_).feedback_trace = simulation_traces.eNodeB_rx_feedback_traces;
        
        % Scheduler trace
        scheduler_trace = tracing.schedulerTrace(LTE_config.simulation_time_tti);
        eNodeBs(b_).sectors(s_).scheduler.trace   = scheduler_trace;
        simulation_traces.scheduler_traces{b_,s_} = scheduler_trace;
    end
end
% eNodeB traces
simulation_traces.eNodeB_tx_traces = tracing.enodebTrace(eNodeBs(1),UEs(1).downlink_channel.RB_grid,LTE_config.maxStreams,LTE_config.simulation_time_tti);
for b_=2:length(eNodeBs)
    simulation_traces.eNodeB_tx_traces(b_) = tracing.enodebTrace(eNodeBs(b_),UEs(1).downlink_channel.RB_grid,LTE_config.maxStreams,LTE_config.simulation_time_tti);
end
% UE traces
for u_=1:length(UEs)
    UEs(u_).trace = tracing.ueTrace(LTE_config.simulation_time_tti,LTE_config.N_RB,LTE_config.maxStreams,LTE_config.traces_config,LTE_config.latency_time_scale,LTE_config.TTI_length);
    if u_==1
        simulation_traces.UE_traces = UEs(u_).trace;
    else
        simulation_traces.UE_traces(u_) = UEs(u_).trace;
    end
end

%% Give the schedulers access to the UE traces
% Then they can make decisions base on their received throughput. More
% complex and realistic solutions may be possible, but then the eNodeB
% should dynamically allocate resources to store UE-related data (and then
% release once the UE is not attached to it anymore). It is easier like this :P
for b_=1:length(eNodeBs)
    for s_=1:length(eNodeBs(b_).sectors)
        eNodeBs(b_).sectors(s_).scheduler.UE_traces = simulation_traces.UE_traces;
    end
end

%% Print all the eNodeBs
% Print the eNodeBs (debug)
print_log(2,'eNodeB List\n');
if LTE_config.debug_level >=2
    for b_=1:length(eNodeBs)
        eNodeBs(b_).print;
    end
end
print_log(2,'\n');

%% Print all the Users
print_log(2,'User List\n');
if LTE_config.debug_level >=2
    for u_=1:length(UEs)
        UEs(u_).print;
    end
end
print_log(2,'\n');
