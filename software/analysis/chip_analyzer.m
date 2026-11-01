clear all 
clc
close all

basenames = {'chip25_r1' 'chip25f_r1' 'chip25_r2' 'chip26_r1' 'chip26f_r1' 'chip26_r2'}; %%%%%% Include chips you want to see!!!%%%%%%
nbase = length(basenames);
raw = cell(nbase, 1);
current_tot=zeros(480,nbase);
Dirac_index=zeros(6,nbase);
Dirac=zeros(6,nbase);
sweeps=6;
for K = 1 : nbase
    FileToLoad = [basenames{K} '.xlsx'];
    if exist(FileToLoad, 'file')
      [~,~,raw{K}] = xlsread(FileToLoad);
%     table(K) = xlsxread(FileToLoad);
    end
    current_tot(:,K)=cell2mat(raw{K,1}(2:end,3)); %% 3 because it's the source
    if K==1
        Gate_voltages=cell2mat(raw{K,1}(2:end,2));
    end
    %%% Sweeping figures 
    figure(K)
    for i=1:6
        if i<6
            hold on
            plot(Gate_voltages((1+(i-1)*80:(i*80)+1),1),current_tot((1+(i-1)*80:(i*80)+1),K)*1000);%%x1000 for mA
        elseif i==6
            plot(Gate_voltages((1+(i-1)*80:(i*80)),1),current_tot((1+(i-1)*80:(i*80)),K)*1000);%%x1000 for mA
            hold off
        end
    end
    title(basenames{K})
    xlabel('Gate voltage (mV)')
    ylabel('current (mA)')
    %%% Dirac point finding
    for i=1:6
        if i<6
            ch_minvalue=min(current_tot((1+(i-1)*80:(i*80)+1),K));
            [row,column]=find(current_tot((1+(i-1)*80:(i*80)+1),K)==ch_minvalue);
            Dirac_index(i,K)=row+(i-1)*80;
        elseif i==6
            ch_minvalue=min(current_tot((1+(i-1)*80:(i*80)),K));
            [row,column]=find(current_tot((1+(i-1)*80:(i*80)),K)==ch_minvalue);
            Dirac_index(i,K)=row+(i-1)*80;
        end
        Dirac(i,K)=Gate_voltages(Dirac_index(i,K),1);
    end
end
figure(nbase+1)
for K=1:nbase
    hold on
    plot(1:sweeps,Dirac(:,K))
%     legend(basenames{1:K})
    hold off
    title('Shift of Dirac point')
    xlabel('number of sweeps')
    ylabel('gate voltage (mV)')
%     Legends=compose('%d',basenames{K});
    legend(basenames{1:K})
end



