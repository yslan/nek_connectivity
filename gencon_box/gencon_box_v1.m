function Hexes = gencon_box_v1(nelx,nely,nelz,iperx,ipery,iperz)
fprintf('  generating connectivity ...')

E = nelx*nely*nelz;
Hexes = zeros(E,8);

lx=nelx+1; xlist=1:lx; if (iperx==1); xlist=[1:nelx,1]; lx=lx-1; end
ly=nely+1; ylist=1:ly; if (ipery==1); ylist=[1:nely,1]; ly=ly-1; end
lz=nelz+1; zlist=1:lz; if (iperz==1); zlist=[1:nelz,1]; lz=lz-1; end

% version 1, slow when nel ~ 100^3
t0=tic;
for k=1:nelz; ez0=zlist(k); ez1=zlist(k+1);
for j=1:nely; ey0=ylist(j); ey1=ylist(j+1);
for i=1:nelx; ex0=xlist(i); ex1=xlist(i+1);

   e = (k-1)*nelx*nely + (j-1)*nelx + i;

   ix = [ex0, ex1, ex0, ex1, ex0, ex1, ex0, ex1];
   iy = [ey0, ey0, ey1, ey1, ey0, ey0, ey1, ey1];
   iz = [ez0, ez0, ez0, ez0, ez1, ez1, ez1, ez1];

   Hexes(e,:) = (iz-1)*ly*lx + (iy-1)*lx + ix;

end
end
end
fprintf('done!! (%2.2e sec)\n',toc(t0));

%Hexes = Hexes(:,[1,2,4,3,5,6,8,7]); % This is stupid

