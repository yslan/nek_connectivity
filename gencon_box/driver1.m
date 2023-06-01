% Generate co2 file for a single (but large) box mesh

warning off;clear all; close all;format compact;profile off;diary off;restoredefaultpath;warning on; pause(.1);

cname='output'; % All new files will go this folder

nelx = 40;
nely = 30;
nelz = 20;

fprintf('  nelx = %d\n',nelx);
fprintf('  nely = %d\n',nely);
fprintf('  nelz = %d\n',nelz);

Hexes = gencon_box(nelx,nely,nelz);

fout = sprintf('%s/nelx%d_nely%d_nelz%d',cname,nelx,nely,nelz);
dump_nek_con(fout,Hexes,1);      % mesh.co2
%dump_nek_con(fout,Hexes,0);      % mesh.co2


fprintf('FINISH, reaching EOF\n');

