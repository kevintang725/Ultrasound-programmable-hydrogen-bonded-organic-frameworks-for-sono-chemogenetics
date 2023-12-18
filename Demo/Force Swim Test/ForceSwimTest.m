%% Force Swim Test Data Analysis
% Imports kinematic data from predicted poses using DeepLabCut and
% calculates force swimming test metrics including: 
% 1) Immobility Time
% 2) Mean Velocity
% 3) Total Distance Travelled
% 4) Immobility Score

clc
clear all
close all

%% Folder Names
folder_dir = "FILE_PATH";
folder_files = dir(fullfile(folder_dir));
for i = 1:length(folder_files)
  folder_filename{i} = folder_files(i).name;
end

plot_flag = 0;
plot_mobility_window = 0;
%% Run Analysis
 c = 1;
 for sample = 4:length(folder_filename)
    source_dir = folder_dir + "/" + folder_filename{sample};
    source_files = dir(fullfile(source_dir, '*.csv'));
    for i = 1:length(source_files)
      data{i} = (readtable(fullfile(source_dir, source_files(i).name)));
      filename{i} = source_files(i).name;
    end

    % Extract Data
    for i = 1:height(data{1,end})
        time(i,1) = str2double(string(table2array(data{1,end}(i,1))));
        pos(i,1:2) = str2double(strsplit(string(table2array(data{1,end}(i,2))),';'));
    end

    % Calculate Velocity and Displacement
    immobility = 0;
    threshold = 0.1; % Batch (1+2): 0.374
    window = 200;
    score = 0;

    i = 1;
    k = 1;
    n = 1;

    while i < height(data{1,end}) - 1
        immobility = 0;
        while (k < window && i < height(data{1,end}) - 1)
            distance = distance_between_two_points(pos(i,1), pos(i,2), pos(i+1,1), pos(i+1,2));
            [time_v(i,1), displacement(i,1), velocity(i,1), immobility_time] = vector_calculation(distance, time(i,1), time(i+1,1), threshold);
            immobility = immobility + immobility_time/1000;
            k = k + 1;
            i = i + 1;
        end
        time_windows(n) = (((time(i,1) - time(i-window+1,1)))/1000);
        immobility_window(n) = immobility;
        immobility_percentage(n) = immobility/time_windows(n);
        if immobility_percentage(n) < 0.5
            score(n) = 1;
        else
            score(n) = 0;
        end
        k = 1;
        n = n + 1;
    end
    
    % Log Immobility Window Data
    immobility_log{c} = immobility_percentage;
    writematrix((immobility_log{c}'), folder_dir + "/" + string(folder_files(sample).name) + string(threshold) + "_" + string(window) + ".xlsx")
    c = c+1;
    
    % Plot
    if (plot_flag == 1)
        h = figure;
        subplot(2,1,1)
        plot(time(1:end-1)/1000,velocity)
        title('Velocity')
        xlabel('Time (s)')
        ylabel('Velocity (px/s)')
        %set(gca,'XtickLabel',(0:1:time(end)/(60*1000)),'FontSize', 14);
        subplot(2,1,2)
        plot(time(1:end-1)/1000,displacement)
        title('Displacement')
        xlabel('Time (s)')
        ylabel('Displacement (px)')
        %set(gca,'XtickLabel',(0:1:time(end)/(60*1000)),'FontSize', 14);
    end

    if (plot_mobility_window == 1)
        h = figure;
        plot(cumsum(time_windows(1:end-1)'), immobility_percentage(1:end-1)*100,'-o', 'LineWidth', 2)
        xlabel('Time (s)')
        ylabel('Immobility Percentage (%)')
        set(gca,'FontSize', 14, 'LineWidth',2);
        saveas(h, folder_dir + "/" + folder_filename{sample},'png');
        ylim([0 100])
    end 

    % Display Data
    disp("Results: " + folder_filename{sample})
    disp("-----------------------------------------------------------")
    disp("Mean Velocity: " + string(mean(velocity)) + " px/s")
    disp("Total Distance: " + string(sum(displacement)) + " px")
    disp("Total Immobility Time: " + string(sum(immobility_window)) + " s")
    disp("Score: " + string(sum(score)/length(immobility_percentage)*100) + " %")

    folder_files(sample).immobility = sum(immobility_window);
    folder_files(sample).mean_velocity = mean(velocity);
    folder_files(sample).total_distance = sum(displacement);
    folder_files(sample).score = sum(score)/length(immobility_percentage);
    
    
    
    %Reset
    immobility = 0;
    time_windows = [];
    immobility_window = [];
    immobility_percentage = [];
    score = [];
    total_score = 0;
 end

%% Write to Excel Summary
writetable(struct2table(folder_files), folder_dir + "/" + "Summary_" + string(threshold) + "_" + string(window) + ".xlsx")


%% Function

function distance = distance_between_two_points(x1, y1, x2, y2)
    distance = sqrt((x2 - x1).^2 + (y2 - y1).^2);
end

function [time, displacement, velocity, immobility_time] = vector_calculation(distance, t1, t2, threshold)
    time = (t2 - t1)/2;
    displacement = distance;
    velocity = displacement/(t2 - t1);
    if (velocity < threshold)
        immobility_time = t2 - t1;
    else
        immobility_time = 0;
    end
end



