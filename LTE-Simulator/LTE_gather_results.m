result_BLER = zeros(length(simulation_traces.scheduler_traces{1,1}.mean_BLER));
result_BLER = [simulation_traces.scheduler_traces{1,1}.mean_BLER];
result_BLER = [result_BLER;simulation_traces.scheduler_traces{1,2}.mean_BLER];
result_BLER = [result_BLER;simulation_traces.scheduler_traces{1,3}.mean_BLER];
result_BLER = [result_BLER;simulation_traces.scheduler_traces{2,1}.mean_BLER];
result_BLER = [result_BLER;simulation_traces.scheduler_traces{2,2}.mean_BLER];
result_BLER = [result_BLER;simulation_traces.scheduler_traces{2,3}.mean_BLER];
result_BLER = [result_BLER;simulation_traces.scheduler_traces{3,1}.mean_BLER];
result_BLER = [result_BLER;simulation_traces.scheduler_traces{3,2}.mean_BLER];
result_BLER = [result_BLER;simulation_traces.scheduler_traces{3,3}.mean_BLER];
result_BLER = [result_BLER;simulation_traces.scheduler_traces{4,1}.mean_BLER];
result_BLER = [result_BLER;simulation_traces.scheduler_traces{4,2}.mean_BLER];
result_BLER = [result_BLER;simulation_traces.scheduler_traces{4,3}.mean_BLER];
result_BLER = [result_BLER;simulation_traces.scheduler_traces{5,1}.mean_BLER];
result_BLER = [result_BLER;simulation_traces.scheduler_traces{5,2}.mean_BLER];
result_BLER = [result_BLER;simulation_traces.scheduler_traces{5,3}.mean_BLER];
result_BLER = [result_BLER;simulation_traces.scheduler_traces{6,1}.mean_BLER];
result_BLER = [result_BLER;simulation_traces.scheduler_traces{6,2}.mean_BLER];
result_BLER = [result_BLER;simulation_traces.scheduler_traces{6,3}.mean_BLER];
result_BLER = [result_BLER;simulation_traces.scheduler_traces{7,1}.mean_BLER];
result_BLER = [result_BLER;simulation_traces.scheduler_traces{7,2}.mean_BLER];
result_BLER = [result_BLER;simulation_traces.scheduler_traces{7,3}.mean_BLER];