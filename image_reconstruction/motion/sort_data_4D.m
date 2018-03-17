function [index] = sort_data_4D(par)

% Function to sort the data for 4D-MRI
%
%
% par.sort_data =   'amplitude'
%                   'phase'
%                   'hybrid'

if ~any(strcmp('sort_data',fieldnames(par)))
    fprintf('No sorting mechanism found, using amplitude binning ... \n');
    par.sort_data = 'amplitude';
end;

if strcmpi('amplitude',par.sort_data);
    fprintf('Performing amplitude binning \n');
    [~,index] = sort(par.respiration,'descend');
%     k = traj(:,index,:);
%     w = dcf(:,index);
%     kdata_sort = kdata(:,index,:,:);
elseif strcmpi('phase',par.sort_data);
    fprintf('Performing phase binning \n');
    [maxtab,mintab] = peakdet(par.respiration,0.1);
    plot(par.respiration); hold on;
    plot(maxtab(:,1),maxtab(:,2),'.','MarkerSize',20);
    plot(mintab(:,1),mintab(:,2),'.','MarkerSize',20);
    hold off;
    title('Peak detection');
    peaks = zeros(length(par.respiration),1);
    peaks(maxtab(:,1)) = 1;
    peaks(mintab(:,1)) = -1;
    phase = calc_phase(peaks);
    figure; plot( phase,'*-')
    [~,index] = sort(phase,'descend'); 
    % Sort it
%     k = traj(:,index,:);
%     w = dcf(:,index);
%     kdata_sort = kdata(:,index,:,:);
elseif strcmpi('hybrid',par.sort_data);
    fprintf('Performing hybrid binning \n');
    [maxtab,mintab] = peakdet(par.respiration,0.05);
    plot(par.respiration); hold on;
    plot(maxtab(:,1),maxtab(:,2),'.','MarkerSize',20);
    plot(mintab(:,1),mintab(:,2),'.','MarkerSize',20);
    hold off;
    title('Peak detection');
    peaks = zeros(length(par.respiration),1);
    peaks(maxtab(:,1)) = 1;
    peaks(mintab(:,1)) = -1;
    phase = calc_phase(peaks);
    figure; plot( phase,'*-')
    
    inexhale = zeros(length(phase),1);
    for npa = 1:length(phase);
        if phase(npa) >= pi
            inexhale(npa) = 1;
        else
            inexhale(npa) = -1;
        end
    end;
    
    respiration_inhale = par.respiration(inexhale == 1);
    nline_in = floor(length(respiration_inhale)/par.resp_phases);
    respiration_exhale = par.respiration(inexhale == -1);
    nline_ex = floor(length(respiration_exhale)/par.resp_phases);
    if nline_in > nline_ex
        nline_in = nline_ex;
    else
        nline_ex = nline_in;
    end;
    
    [val_inhale,~] = sort(respiration_inhale(1:nline_in*par.resp_phases),'descend');
    [val_exhale,~] = sort(respiration_exhale(1:nline_ex*par.resp_phases),'ascend');
    for t=1:length(val_inhale);
        real_in_index(t) = find(par.respiration == val_inhale(t));
        real_ex_index(t) = find(par.respiration == val_exhale(t));
    end;
    
%     k = cat(2,traj(:,real_in_index,:).traj(:,real_ex_index,:));
%     w = cat(2,dcf(:,real_in_index),dcf(:,real_in_index));
%     kdata_sort = cat(2,kdata(:,real_in_index,:,:),kdata(:,real_ex_index,:,:));
    index = [real_in_index,real_ex_index];
    
else
    error('Wrong input for par.sort_data \n');
end;