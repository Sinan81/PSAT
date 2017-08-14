function [x,y,s] = mask(a,idx,orient,vals)

x = cell(3,1);
y = cell(3,1);
s = cell(3,1);

x{1} = [-2 2];
y{1} = [1 1];
s{1} = 'k';

x{2} = [1 -1 1 -1 -1];
y{2} = [1 -0.2 0.2 -1 -0.7];
s{2} = 'y';

x{3} = [-1 -0.2];
y{3} = [-1 -0.8];
s{3} = 'y';

%[x,y] = fm_maskrotate(x,y,orient);
