function Hexes = gencon_box_v3(nelx,nely,nelz,iperx,ipery,iperz)
fprintf('  generating connectivity ...')

E = nelx*nely*nelz;
Hexes = zeros(E,8);

lx=nelx+1; xlist=1:lx; if (iperx==1); xlist=[1:nelx,1]; lx=lx-1; end
ly=nely+1; ylist=1:ly; if (ipery==1); ylist=[1:nely,1]; ly=ly-1; end
lz=nelz+1; zlist=1:lz; if (iperz==1); zlist=[1:nelz,1]; lz=lz-1; end

% version 3, mem speed balanced?
t0=tic;

for k=1:nelz; cez0=zlist(k); cez1=zlist(k+1);
   [ex0,ey0] = ndgrid(xlist(1:nelx),    ylist(1:nely));
   [ex1,ey1] = ndgrid(xlist(2:(nelx+1)),ylist(2:(nely+1)));
   ex0=ex0(:);ey0=ey0(:);ez0=ex0*0+cez0;
   ex1=ex1(:);ey1=ey1(:);ez1=ex1*0+cez1;

   % lexicographic
   idx = [ex0, ex1, ex0, ex1, ex0, ex1, ex0, ex1];
   idy = [ey0, ey0, ey1, ey1, ey0, ey0, ey1, ey1];
   idz = [ez0, ez0, ez0, ez0, ez1, ez1, ez1, ez1];

%   % counter-clockwise
%   idx = [ex, ex+1, ex+1, ex, ex, ex+1, ex+1, ex];
%   idy = [ey, ey, ey+1, ey+1, ey, ey, ey+1, ey+1];
%   idz = [ez, ez, ez, ez, ez+1, ez+1, ez+1, ez+1];
   
   itmp = (idz-1)*ly*lx + (idy-1)*lx + idx;
   itmp = reshape(itmp,nelx*nely,8);
   
   i0 = (k-1)*nely*nelx+1;
   i1 = (k-1)*nely*nelx+nely*nelx;
   
   Hexes(i0:i1,:) = itmp;
end
fprintf('done!! (%2.2e sec)\n',toc(t0));

%Hexes = Hexes(:,[1,2,4,3,5,6,8,7]); % This is stupid

