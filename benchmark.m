% Benchmarking 2D NUFFT
M=round(.5*1E06);
trajx=rand(1,M);
trajy=rand(1,M);
trajz=rand(1,M);
c=rand(1,M)+1j*rand(1,M);
X=20;
I=rand(X,X,X)+1j*rand(X,X,X);
eps=1E-08;

% FINUFFT
tic
finufft2d1(trajx,trajy,c,-1,eps,X,X);
a(1)=toc;

% GGNUFFT
tic
nufft2d1(numel(c),trajx,trajy,c,-1,eps,X,X);
a(2)=toc;

% FNUFFT
st=nufft_init([trajx; trajy]', [X X], [3 3], [X X], [0 0],'minmax:tuned');
tic
nufft_adj(c',st);
a(3)=toc;

disp(['FI=',num2str(a(1)),' | GG=',num2str(a(2)),' | FG=',num2str(a(3))])

% Benchmarking 3D NUFFT

% FINUFFT
tic
%a1=finufft3d1(trajx,trajy,trajz,c,-1,eps,X,X,X);
a1=finufft3d2(trajx,trajy,trajz,-1,eps,I);
b(1)=toc;

% GNUFFT
% tic
% nufft3d1(numel(c),trajx,trajy,trajz,c,-1,eps,X,X,X);
% b(2)=toc;

% NUFFT
st=nufft_init([trajx; trajy; trajz]', [X X X], [4 4 4], [X X X], [X/2 X/2 X/2],'minmax:tuned');
tic
%nufft_adj(c',st);
a3=nufft(I,st);
b(3)=toc;

nufft3d1(numel(c),trajx,trajy,trajz,c,-1,eps,X,X,X);
b(2)=toc;

disp(['FI=',num2str(b(1)),' | GG=',num2str(b(2))])


% Benchmarking type 3
tic
a=nufft3d3(M,trajx,trajy,trajz,c,-1,1E-01,M,trajx,trajy,trajz);
toc
tic
b=finufft3d3(trajx,trajy,trajz,c,-1,1.2E-01,trajx,trajy,trajz);
toc

% FNUFFT
st=nufft_init([trajx; trajy; trayz]', [X X], [3 3], [X Y], [0 0],'minmax:tuned');
tic
nufft_adj(c',st);
a(3)=toc;