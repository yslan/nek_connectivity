% Generate co2 file for a single (but large) box mesh
% Usage:
%   octave ./driver_octave.m 40 30 10

n=length(argv());
assert(n==3,'Need three arguments');

nelx = str2num(argv(){1});
nely = str2num(argv(){2});
nelz = str2num(argv(){3});


cname='output'; % All new files will go this folder

fprintf('  nelx = %d\n',nelx);
fprintf('  nely = %d\n',nely);
fprintf('  nelz = %d\n',nelz);

Hexes = gencon_box(nelx,nely,nelz);

fout = sprintf('%s/nelx%d_nely%d_nelz%d',cname,nelx,nely,nelz);
dump_nek_con(fout,Hexes,1);      % .co2
%dump_nek_con(fout,Hexes,0);     % .con

fprintf('FINISH, reaching EOF\n');
