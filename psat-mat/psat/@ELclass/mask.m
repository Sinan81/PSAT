function [x,y,s] = mask(a,idx,orient,vals)

[xr,yr] = fm_draw('R','Exload',orient);

x = cell(4,1);
y = cell(4,1);
s = cell(4,1);

x{1} = [1 0 0 1 1];
y{1} = [1 1 0 0 1];
s{1} = 'k';

x{2} = 0.7+0.3*xr;
y{2} = 0.6*yr+0.5;
s{2} = 'b';

x{3} = [0.4 0.1 0.1 0.4];
y{3} = [0.8 0.8 0.2 0.2];
s{3} = 'b';

x{4} = [0.1 0.25];
y{4} = [0.5 0.5];
s{4} = 'b';
