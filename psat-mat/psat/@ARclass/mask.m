function [x,y,s] = mask(a,idx,orient,vals)

[xc,yc] = fm_draw('rounded');

x = cell(1,1);
y = cell(1,1);
s = cell(1,1);

x{1} = xc;
y{1} = yc;
s{1} = 'k';
