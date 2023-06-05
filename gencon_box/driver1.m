% Generate co2 file for a single (but large) box mesh

warning off;clear all; close all;format compact;profile off;diary off;restoredefaultpath;warning on; pause(.1);

cname='output'; % All new files will go this folder

nelx = 40;
nely = 30;
nelz = 20;
E = nelx*nely*nelz;

fprintf('  nelx = %d\n',nelx);
fprintf('  nely = %d\n',nely);
fprintf('  nelz = %d\n',nelz);

iversion = 2; if (E>300^3); iversion=3; end
fprintf('  E = %d, version: %d\n',E,iversion);

switch iversion
   case 1
      Hexes = gencon_box_v1(nelx,nely,nelz);
   case 2
      Hexes = gencon_box_v2(nelx,nely,nelz);
   case 3
      Hexes = gencon_box_v3(nelx,nely,nelz);

   case -1
      fprintf('dbg mode, compare results from each versions\n');
      Hexes1 = gencon_box_v1(nelx,nely,nelz);
      Hexes2 = gencon_box_v2(nelx,nely,nelz);
      Hexes3 = gencon_box_v3(nelx,nely,nelz);
      err1 = max(abs(Hexes1(:)-Hexes2(:)));
      err2 = max(abs(Hexes1(:)-Hexes3(:)));
      err3 = max(abs(Hexes2(:)-Hexes3(:)));

      fprintf('dbg mode, err= %d %d %d\n',err1,err2,err3);
      Hexes = Hexes1;

   otherwise
      fprintf('iversion = %d is not support! [1/2/3/-1]',iversion); error();
end

ifperm=0;
fout = sprintf('%s/nelx%d_nely%d_nelz%d',cname,nelx,nely,nelz);
fprintf('  dump into file %s ...\n',fout);
dump_nek_con(fout,Hexes,1,ifperm);      % mesh.co2
%dump_nek_con(fout,Hexes,0,ifperm);      % mesh.co2


fprintf('FINISH, reaching EOF\n');

