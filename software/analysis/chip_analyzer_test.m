clear all 
clc
close all
%% Settings of experiments
sweepfigure=0; %Printing out sweeping figures 0=NO, 1=yes!
%'chip26_r1' 'chip26f_r1' 'chip26_r2' 'chip26_r3' 'chip26_r4' 'chip26_r5' 'chip26_r6'
%'chip131_r1' 'chip131_r2' 'chip131_r3' 'chip131_r4' 'chip131_r5' 'chip131_r6'
basenames = {'chip133_r2' 'chip133_r3' 'chip133_r5' 'chip133_r4' 'chip135_r1' 'chip135_r2'...
    'chip137_r1' 'chip137_r2' 'chip137_r3' 'chip137_r4' 'chip139_r1' 'chip139_r2' 'chip139_r3' 'chip139_r4'...
    'chip140_r1' 'chip140_r2' 'chip140_r3' 'chip140_r4' 'chip143_r1' 'chip143_r2' 'chip143_r3' 'chip143_r4'}; %%%%%% Include chips you want to see!!!%%%%%%
%%%%%% !!! Comment/uncomment the lines needed !!! %%%%%%
%%%%%%%%%%% Use this if all settings are exactly the same %%%%%%%%%%%
setted_range=1000;
setted_steps=12.5;
setted_sweeps=6;
range=ones(1,length(basenames))*setted_range;
steps=ones(1,length(basenames))*setted_steps;
sweeps=ones(1,length(basenames))*setted_sweeps;
%%%%%%%%%%% Use this if the settings are NOT all the same %%%%%%%%%%%
% range=[1000,1000];%%fx from 0-1000mV=1000
% steps=[12.5,12.5]; %%steps of 12.5mV
% sweeps=[6,6,6,6,6,6,6,6]; %Input number of sweeps for each run fx chip25 had 3sweeps forward & backward so 6. 
%% Code
nbase = length(basenames);
raw = cell(nbase, 1);
current_tot=zeros(max(sweeps)*max(range)/min(steps),nbase);
Gate_voltages=zeros(max(sweeps)*max(range)/min(steps),nbase);
Dirac_index=zeros(6,nbase);
Dirac=zeros(6,nbase);
if nbase~=length(sweeps)||nbase~=length(range)||nbase~=length(steps) %%Just stoping the code if sweep numbers and amount of excel files isn't the same.
    msgbox('Not enough arrays in range/steps or sweeps compared to the amount of excel files being analysed. Please check to have the same amount of arrays in all!')
    return
end
for K = 1 : nbase
    FileToLoad = [basenames{K} '.xlsx'];
    if exist(FileToLoad, 'file')
      [~,~,raw{K}] = xlsread(FileToLoad);
    end
    current_tot(1:sweeps(K)*range(K)/steps(K),K)=cell2mat(raw{K,1}(2:end,3)); %% 3 because it's the source
    Gate_voltages(1:sweeps(K)*range(K)/steps(K),K)=cell2mat(raw{K,1}(2:end,2));
    %%% Sweeping figures 
    if sweepfigure==1
    figure(K)
    for i=1:sweeps(K)
        if i<sweeps(K)
            hold on
            plot(Gate_voltages((1+(i-1)*range(K)/steps(K):(i*range(K)/steps(K))+1),K),current_tot((1+(i-1)*range(K)/steps(K):(i*range(K)/steps(K))+1),K)*1000);%%x1000 for mA
        elseif i==sweeps(K)
            plot(Gate_voltages((1+(i-1)*range(K)/steps(K):(i*range(K)/steps(K))),K),current_tot((1+(i-1)*range(K)/steps(K):(i*range(K)/steps(K))),K)*1000);%%x1000 for mA
            hold off
        end
    end
    title(basenames{K})
    xlabel('Gate voltage (mV)')
    ylabel('current (mA)')
    end
    
    %%% Dirac point finding
    for i=1:sweeps(K)
        if i<sweeps(K)
            ch_minvalue=min(current_tot((1+(i-1)*range(K)/steps(K):(i*range(K)/steps(K))+1),K));
            [row,column]=find(current_tot((1+(i-1)*range(K)/steps(K):(i*range(K)/steps(K))+1),K)==ch_minvalue);
            Dirac_index(i,K)=row+(i-1)*range(K)/steps(K);
        elseif i==sweeps(K)
            ch_minvalue=min(current_tot((1+(i-1)*range(K)/steps(K):(i*range(K)/steps(K))),K));
            [row,column]=find(current_tot((1+(i-1)*range(K)/steps(K):(i*range(K)/steps(K))),K)==ch_minvalue);
            Dirac_index(i,K)=row+(i-1)*range(K)/steps(K);
        end
        Dirac(i,K)=Gate_voltages(Dirac_index(i,K),K);
    end
end
figure(nbase+1)
% for K=1:nbase
for K=1:6
    hold on
    plot(1:sweeps(K),Dirac(1:sweeps(K),K))
    hold off
    title('Shift of Dirac point')
    xlabel('number of sweeps')
    ylabel('gate voltage (mV)')
    legend(basenames{1:K})
end

figure(nbase+2)
% for K=1:nbase
for K=7:14
    hold on
    plot(1:sweeps(K),Dirac(1:sweeps(K),K))
    hold off
    title('Shift of Dirac point')
    xlabel('number of sweeps')
    ylabel('gate voltage (mV)')
    legend(basenames{7:K})
end

figure(nbase+3)
% for K=1:nbase
for K=15:nbase
    hold on
    plot(1:sweeps(K),Dirac(1:sweeps(K),K))
    hold off
    title('Shift of Dirac point')
    xlabel('number of sweeps')
    ylabel('gate voltage (mV)')
    legend(basenames{15:K})
end
%% Calculation of means and STD for different experiments

% %% Chip 133 & 135
% ch133_s1=mean(Dirac(:,2)-Dirac(:,3))
% ch133_s4=mean(Dirac(:,1)-Dirac(:,4))
% ch135_s1=mean(Dirac(:,5)-Dirac(:,6))
% ch137_s1=mean(Dirac(:,7)-Dirac(:,9))
% ch137_s2=mean(Dirac(:,8)-Dirac(:,10))
% ch139_s1=mean(Dirac(2:end,11)-Dirac(2:end,13))
% ch139_s2=mean(Dirac(:,12)-Dirac(:,14))
% ch140_s1=mean(Dirac(2:end,15)-Dirac(2:end,17))
% ch140_s2=mean(Dirac(:,16)-Dirac(:,18))
% ch143_s1=mean(Dirac(:,19)-Dirac(:,21))
% ch143_s2=mean(Dirac(:,20)-Dirac(:,22))
ch133_s1=mean(Dirac(4,2)-Dirac(4,3))
ch133_s4=mean(Dirac(4,1)-Dirac(4,4))
ch135_s1=mean(Dirac(4,5)-Dirac(4,6))
ch137_s1=mean(Dirac(4,7)-Dirac(4,9))
ch137_s2=mean(Dirac(4,8)-Dirac(4,10))
ch139_s1=mean(Dirac(4,11)-Dirac(4,13))
ch139_s2=mean(Dirac(4,12)-Dirac(4,14))
ch140_s1=mean(Dirac(4,15)-Dirac(4,17))
ch140_s2=mean(Dirac(4,16)-Dirac(4,18))
ch143_s1=mean(Dirac(4,19)-Dirac(4,21))
ch143_s2=mean(Dirac(4,20)-Dirac(4,22))