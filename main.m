%clc
clear

%% Messages
disp 'Running simulation...'
mex odeStepComp.c

%% parameters
sp.tf = 5e-10;
sp.dt = 1e-13;
sp.Ny = 50;   %  Nx*Ny MUST NOT exceed (3,000)^2 = 9,000,000
sp.Nx = 50;
sp.Ms = 8.6e5;
sp.gamma = 2.21e5;
sp.alpha = 0.05;
sp.cCoupl = -0.2;
sp.cDemag = single([.4 .4 .2]);
sp.odeSolver_rk4 = 0;   % if false, Euler-ODE-solver will be used
sp.useGPU = 0;          % if true, GPU will be used

%% allocate data
t = [0:sp.dt:sp.tf];
sp.Nt = length(t);
M = zeros(3,sp.Ny,sp.Nx,sp.Nt);
Hext = zeros(size(M));
% if sp.useGPU
%     M = gpuArray(M);
%     Hext = gpuArray(Hext);
% end

%% External field
Hext(1, sp.Ny/3:sp.Ny/2, sp.Nx/3:sp.Nx/2, :) = 5*sp.Ms;



%% initial condition for M
% start from random
random = 0;
if random
	theta = pi .* rand(sp.Ny, sp.Nx);
	phi = 2*pi .* rand(sp.Ny, sp.Nx);
else
	theta = 40 * pi/180 .* ones(sp.Ny, sp.Nx);
	phi   = 2*pi .* rand(sp.Ny, sp.Nx);
end
ic.M(1,:,:) = sp.Ms .* sin(theta) .* cos(phi);
ic.M(2,:,:) = sp.Ms .* sin(theta) .* sin(phi);
ic.M(3,:,:) = sp.Ms .* cos(theta);

%% Boundary conditions for M
bc.Mtop = zeros(3,sp.Nx);    % +x top
bc.Mbot = zeros(3,sp.Nx);    % -x bottom
bc.Mrig = zeros(3,sp.Ny);    % +y right
bc.Mlef = zeros(3,sp.Ny);    % -y left
% merge all bc in one large matrix
% bcM = zeros(3,sp.Ny+2,sp.Nx+2);
% bcM(:,1,2:end-1) = bc.Mtop;
% bcM(:,end,2:end-1) = bc.Mbot;
% bcM(:,2:end-1,1) = bc.Mrig;

%% Time marching
M(:,:,:,1) = ic.M;
% H = zeros(3,sp.Ny,sp.Nx); % could pre-allocate Hfield to save time
for it = 1:length(t)-1      % all but last
	%break;
	%fprintf('t = %g s\n', t(it));
    M(:,:,:,it+1) = odeStep(sp, bc, M(:,:,:,it), Hext(:,:,:,it));
    % timeTaken = toc;
    % fprintf('ODE step executed in %g runtime seconds\n', timeTaken);
end

%% Animate
% visualize_dots
M = M/sp.Ms;
Mx = squeeze(M(1,:,:,:));
My = squeeze(M(2,:,:,:));
Mz = squeeze(M(3,:,:,:));