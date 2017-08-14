function [x,y,s] = mask(a,idx,orient,vals)

[xc,yc] = fm_draw('circle','Supply');
[xs,ys] = fm_draw('$','Supply');

x = cell(2,1);
y = cell(2,1);
s = cell(2,1);

x{1} = xc;
y{1} = yc;
s{1} = 'k';

x{2} = xs;
y{2} = ys;
s{2} = 'b';
