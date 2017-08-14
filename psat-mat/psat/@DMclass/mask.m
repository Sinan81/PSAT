function [x,y,s] = mask(a,idx,orient,vals)

[xs,ys]=fm_draw('$','Demand',orient);

x = cell(2,1);
y = cell(2,1);
s = cell(2,1);

x{1} = [1.0000 -0.5 -0.5 1];
y{1} = [0 0.866 -0.866 0];
s{1} = 'k';

x{2} = 0.6*xs;
y{2} = 0.6*ys;
s{2} = 'b';

[x,y] = fm_maskrotate(x,y,orient);
