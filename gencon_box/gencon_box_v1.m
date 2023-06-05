function Hexes = gencon_box_v1(nelx,nely,nelz)
fprintf('  generating connectivity ...')

E = nelx*nely*nelz;
Hexes = zeros(E,8);

lx = nelx + 1;
ly = nely + 1;
lz = nelz + 1;

% version 1, slow when nel ~ 100^3
t0=tic;
for ez=1:nelz
for ey=1:nely
for ex=1:nelx

   e = (ez-1)*nelx*nely + (ey-1)*nelx + ex;

   ix = [ex, ex+1, ex, ex+1, ex, ex+1, ex, ex+1];
   iy = [ey, ey, ey+1, ey+1, ey, ey, ey+1, ey+1];
   iz = [ez, ez, ez, ez, ez+1, ez+1, ez+1, ez+1];

   Hexes(e,:) = (iz-1)*ly*lx + (iy-1)*lx + ix;

end
end
end
fprintf('done!! (%2.2e sec)\n',toc(t0));

%Hexes = Hexes(:,[1,2,4,3,5,6,8,7]); % This is stupid

