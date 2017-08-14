function [x,y,s] = mask(a,idx,orient,vals)

[xc,yc] = fm_draw('circle','Statcom',orient);
[xr,yr] = fm_draw('cap','Statcom',orient);
[xa,ya] = fm_draw('acdc2','Statcom',orient);

x = cell(10,1);
y = cell(10,1);
s = cell(10,1);

x{1} = [9.2 4.8 4.8 9.2 9.2];
y{1} = [0.3 0.3 -0.95 -0.95 0.3];
s{1} = 'k';

x{2} = [9.2 12.5  12.5];
y{2} = [-0.75 -0.75 -0.4];
s{2} = 'k';

x{3} = [9.2 12.5  12.5];
y{3} = [0.1 0.1 -0.25];
s{3} = 'k';

x{4} = [11.5 13.5];
y{4} = [-0.4 -0.4];
s{4} = 'k';

x{5} = 12.5-yr;
y{5} = -0.15+0.1*xr;
s{5} = 'k';

x{6} = [4.8 4];
y{6} = [-0.325 -0.325];
s{6} = 'k';

x{7} = [0.6 0];
y{7} = [-0.325 -0.325];
s{7} = 'k';

x{8} = 3-yc;
y{8} = 0.25*xc-0.325;
s{8} = 'k';

x{9} = 1.6-yc;
y{9} = 0.25*xc-0.325;
s{9} = 'k';

x{10} = 7.5-ya;
y{10} = xa;
s{10} = 'm';

[x,y] = fm_maskrotate(x,y,orient);
