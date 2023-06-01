% Generate co2 file for a single (but large) box mesh
% Usage:
%   octave ./driver_octave.m 40 30 10

warning ("off");

n=length(argv());
if n==4
   iversion = str2num(argv(){4});
else
   iversion = 2;
   assert(n==3,'Need three arguments');
end

nelx = str2num(argv(){1});
nely = str2num(argv(){2});
nelz = str2num(argv(){3});
E = nelx*nely*nelz;

cname='output'; % All new files will go this folder

fprintf('  nelx = %d\n',nelx);
fprintf('  nely = %d\n',nely);
fprintf('  nelz = %d\n',nelz);

if (E>300^3); iversion=3; end
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

fout = sprintf('%s/nelx%d_nely%d_nelz%d',cname,nelx,nely,nelz);
dump_nek_con(fout,Hexes,1);      % .co2
%dump_nek_con(fout,Hexes,0);     % .con

fprintf('FINISH, reaching EOF\n');
