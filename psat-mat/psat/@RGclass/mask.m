function [x,y,s] = mask(a,idx,orient,vals)

[xc,yc] = fm_draw('circle','Rmpg',orient);
[xr,yr] = fm_draw('ramp','Rmpg',orient);

x = cell(2,1);
y = cell(2,1);
s = cell(2,1);

x{1} = xc;
y{1} = yc;
s{1} = 'k';

x{2} = xr;
y{2} = yr;
s{2} = 'b';
