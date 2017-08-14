function [x,y,s] = mask(a,idx,orient,vals)

[xj,yj] = fm_draw('J','Jimma',orient);

x = cell(2,1);
y = cell(2,1);
s = cell(2,1);

x{1} = [-1 -1 1 1 -1];
y{1} = [-1 1 1 -1 -1];
s{1} = 'k';

x{2} = xj;
y{2} = yj;
s{2} = 'b';
