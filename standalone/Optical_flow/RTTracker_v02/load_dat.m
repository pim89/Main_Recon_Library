function [image,dimx,dimy,dimz,no_dyn] = load_dat(file_name)

disp('Loading data file...');

%% Open the data file
f = fopen(file_name, 'r');

%% Extract the header size
header_size = fread(f, 1, 'int');

%% Extract the header data
header = fread(f, header_size, 'int');

%% Store image resolution parameters
dimx = header(1);
dimy = header(2);
if (header_size == 3)
  dimz   = 1;
  no_dyn = header(3);
end
if (header_size == 4)
  dimz   = header(3);
  no_dyn = header(4);
end

%% Extract data from file
image = fread(f, 'float');
image = reshape(image,dimx,dimy,dimz,no_dyn);

%% Close data file
fclose(f);
