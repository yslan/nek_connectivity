function Hexes = gencon_box_v2(nelx,nely,nelz)
fprintf('  generating connectivity ...')

E = nelx*nely*nelz;
Hexes = zeros(E,8);

lx = nelx + 1;
ly = nely + 1;
lz = nelz + 1;

% version 2, faster but mem bounded
t0=tic;

[ex,ey,ez] = ndgrid(1:nelx,1:nely,1:nelz);
ex=ex(:);ey=ey(:);ez=ez(:);

ix = [ex, ex+1, ex, ex+1, ex, ex+1, ex, ex+1];
iy = [ey, ey, ey+1, ey+1, ey, ey, ey+1, ey+1];
iz = [ez, ez, ez, ez, ez+1, ez+1, ez+1, ez+1];

itmp = (iz-1)*ly*lx + (iy-1)*lx + ix;
Hexes= reshape(itmp,E,8);
fprintf('done!! (%2.2e sec)\n',toc(t0));

Hexes = Hexes(:,[1,2,4,3,5,6,8,7]); % This is stupid

