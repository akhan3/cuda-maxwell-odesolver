fprintf('Animating %d timepoints\n', sp.Nt);

%% Normalize M
mx = squeeze(M(1,:,:,:)) / sp.Ms;
my = squeeze(M(2,:,:,:)) / sp.Ms;
mz = squeeze(M(3,:,:,:)) / sp.Ms;

clf;
subplot(121); 
ih = imagesc(mz(:,:,1), [-1 1]); 
axis equal; 
axis ij; 
axis([1 sp.Nx 1 sp.Ny]); 
ith = title('m_z(n = 0)');
colormap('hot'); 
% colormap('jet'); 
% colorbar;

subplot(122);
[X Y] = meshgrid([1:sp.Nx],[1:sp.Ny]); Z = zeros(size(X)); surf(X,Y,Z, 'facealpha',0.5, 'edgealpha',0); hold on;
axis ij; axis equal; grid off; axis([1 sp.Nx 1 sp.Ny -1 1]);
qh = quiver3(X,Y,Z, mx(:,:,1), my(:,:,1), mz(:,:,1)); %view(0,90);
xlabel('x'); ylabel('y'); zlabel('z');
view(0,90);



for i = 1:20:sp.Nt
    set(ih, 'cdata', double(mz(:,:,i)));
    set(ith, 'string', ['m_z(n = ', num2str(i), ')']);
    set(qh, 'udata', mx(:,:,i), 'vdata',my(:,:,i), 'wdata',mz(:,:,i));
    pause(0.01);
    drawnow;
end
