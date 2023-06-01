function Hexes = gencon_box_v3(nelx,nely,nelz)
fprintf('  generating connectivity ...')

E = nelx*nely*nelz;
Hexes = zeros(E,8);

lx = nelx + 1;
ly = nely + 1;
lz = nelz + 1;

% version 3, mem speed balanced?
t0=tic;

for iz=1:nelz
   [ex,ey] = ndgrid(1:nelx,1:nely);
   ex=ex(:);ey=ey(:);ez=0*ex(:)+iz;
   
   idx = [ex, ex+1, ex, ex+1, ex, ex+1, ex, ex+1];
   idy = [ey, ey, ey+1, ey+1, ey, ey, ey+1, ey+1];
   idz = [ez, ez, ez, ez, ez+1, ez+1, ez+1, ez+1];
   
   itmp = (idz-1)*ly*lx + (idy-1)*lx + idx;
   itmp = reshape(itmp,nelx*nely,8);
   
   i0 = (ez-1)*nely*nelx+1;
   i1 = (ez-1)*nely*nelx+nely*nelx;
   
   Hexes(i0:i1,:) = itmp;
end
fprintf('done!! (%2.2e sec)\n',toc(t0));

Hexes = Hexes(:,[1,2,4,3,5,6,8,7]); % This is stupid

