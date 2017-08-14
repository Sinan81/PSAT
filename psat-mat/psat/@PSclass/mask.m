function [x,y,s] = mask(a,idx,orient,vals)

[xp,yp] = fm_draw('P','Pss',orient);
[xs,ys] = fm_draw('S','Pss',orient);

x = cell(4,1);
y = cell(4,1);
s = cell(4,1);

x{1} = [-1.8 4.1 4.1 -1.8 -1.8];
y{1} = [-1.5 -1.5 1.5 1.5 -1.5];
s{1} = 'k';

x{2} = 1.5*xp-0.7;
y{2} = 2*yp;
s{2} = 'r';

x{3} = 1.2+1.5*xs;
y{3} = 2*ys;
s{3} = 'r';

x{4} = 2.8+1.5*xs;
y{4} = 2*ys;
s{4} = 'r';
