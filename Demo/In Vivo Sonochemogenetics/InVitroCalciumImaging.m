%% In Vitro Sono-chemogenetic Fluorescent Calcium Imaging Data Analysis
% Imports fluorscent intensity data over time extracted via ImageJ
% Detrends, normalize and corrects baseline of fluorescent data due to
% photobleaching across all cells.

clc
clear all
close all
%% Import Data

source_dir = "FILE_PATH";
source_files = dir(fullfile(source_dir, '*.xlsx'));
for i = 1:length(source_files)
  data{i} = table2array(readtable(fullfile(source_dir, source_files(i).name)));
  filename{i} = source_files(i).name;
end

%% Data Pre-processing
i = 1;
%Remove first 2 min data
for N = 1:length(data)
    data{1,N}(1:240,:) = [];
    for M = 2:2:width(data{1,N})
        T{N}(:,i) = data{1,N}(:,M);
        i = i+1;
    end
     i =1;
end

%% Detrend and Normalize

%Find max value in all data
max = [0 0 0 0];
for N = 1:length(T)
    for j = 1:width(T{N})
        for i = 1:length(T{N})
            if (T{N}(i,j) > max(N))
                max(N) = T{N}(i,j);
            end
        end
    end
end

% Use second order polynomial to detrend photobleaching
order = 4;
for N = 1:length(T)
    for k = 1:width(T{N})
        T_detrend{N}(:,k) = detrend(T{N}(:,k));
        T_detrend{N}(:,k) = T_detrend{N}(:,k) - mean(T_detrend{N}(1:120,k)); % remove offset from zero
        T_detrend{N}(:,k) = T_detrend{N}(:,k)./max(N);
    end
end

%% Export File
for N = 1:length(T_detrend)
    writematrix(T_detrend{N},filename{N} + "_detrend.xlsx") 
end

%% Plots
figure
for N = 1:length(data)
    subplot(4,2,N)
    plot(T{N})
    set(gca,'XTick',(1:120:length(T_detrend{N})),'XtickLabel',(2:1:8));
    ylabel('Fluorescent Intensity (a.u)')
    xlabel('Time (min)');
    title(filename{N});
    subplot(4,2,N+4)
    plot(T_detrend{N});
    title(filename{N});
    %ylim([-0.1 1])
    set(gca,'XTick',(1:120:length(T_detrend{N})),'XtickLabel',(2:1:8));
    ylabel('\Delta F/F_0 ')
    xlabel('Time (min)');
end

figure
for N = 1:length(data)
    subplot(2,2,N)
    pcolor(T_detrend{N}')
    shading(gca,'interp')
    set(gca,'YTick',(1:10:width(T_detrend{N})),'YtickLabel',(0:10:width(T_detrend{N})));
    set(gca,'XTick',(100:20:length(T_detrend{N})),'XtickLabel',(0:20:80));
    title(filename{N});
    ylabel('Neuron Number')
    xlabel('Time (s)')
    xlim([100 180])
    colormap(turbo)
    c = colorbar;
    caxis([0 1]);
    %c.Limits = [0 10];
    c.Label.String = '\Delta F/F_0';
end
