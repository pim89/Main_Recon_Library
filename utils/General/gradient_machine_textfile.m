function gradient_machine_textfile(GR,varargin)
%% Experimental gradient waveform machine template
% Input is 2D matrix with size [time-points 3].
% 3 represents the X/Y/Z gradients.
% dt = 1 us and values should be in T/m (SI-units)
%
% Function will create the output textfile of name/location=varargin.
% T.Bruijnen @ 20180706

% Check input
dim=size(GR);
if numel(dim) > 2 || dim(2) ~= 3 
    error('Input matrix has to be 2D [time-points 3].');
    return;
end

% Hardware constraints
if max(abs(GR(:))) > .05
    error('Input values have to be in T/m, not mT/m.');
    return;
else
    disp(['Maximum gradient strength = ',num2str(max(max(abs(GR(:))))),' T/m']);
end

if max(abs(diff(GR,1)))/(10^(-6)) > 200
    error('Input exceeds maximum slew rate of our systems (200 T/m/s)');
else
    disp(['Maximum slew rate = ',num2str(max(max(abs(diff(GR,1))))/(10^(-6))),' T/m/s']);
end

if max(GR(1,:)) > 0
    error('All inputs have to start with 0.');
    return;
end

if max(GR(end,:)) > 0
    error('All inputs have to end with 0.');
    return;
end

% Outputpath
if nargin < 2
    fout='machine_gradient_waveforms.txt';
else
    fout=[varargin{1},'/machine_gradient_waveforms.txt'];
end

% Visualize waveforms
figure,
set(gcf, 'Position', get(0, 'Screensize'));
plot(1:dim(1),GR','LineWidth',3);
xlabel('Time [us]');ylabel('G_{str} [T/m]');legend('X','Y','Z');
axis([0  dim(1) -0.05 0.05])
set(gca,'FontSize',16,'FontWeight','bold','LineWidth',2);

% Print textfile
dlmwrite(fout,GR,'precision','%1.10f');

%
end
% END