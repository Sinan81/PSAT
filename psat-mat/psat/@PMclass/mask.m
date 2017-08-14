function [x,y,s] = mask(a,idx,orient,vals)

x = cell(4,1);
y = cell(4,1);
s = cell(4,1);

[xp,yp] = fm_draw('P','Pmu',orient);
[xu,yu] = fm_draw('U','Pmu',orient);
[xm,ym] = fm_draw('M','Pmu',orient);

x{1} = [-1 0  4 5  4 0 -1];
y{1} = [0 1 1 0 -1 -1 0];
s{1} = 'k';

x{2} = xp+0.5;
y{2} = yp;
s{2} = 'y';

x{3} = xu+3;
y{3} = yu;
s{3} = 'y';

x{4} = xm+2;
y{4} = ym;
s{4} = 'y';
