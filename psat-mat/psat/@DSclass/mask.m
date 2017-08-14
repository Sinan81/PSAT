function [x,y,s] = mask(a,idx,orient,vals)

[xc,yc] = fm_draw('circle','Mass',orient);
[x1,y1] = fm_draw('semicircle','Mass',orient);

x = cell(5,1);
y = cell(5,1);
s = cell(5,1);

x{1} = -x1;
y{1} = y1;
s{1} = 'k';

x{2} = 3+xc;
y{2} = yc;
s{2} = 'b';

x{3} = [0 3];
y{3} = [1 1];
s{3} = 'b';

x{4} = [0 3];
y{4} = [-1 -1];
s{4} = 'b';

x{5} = [3 5];
y{5} = [0 0];
s{5} = 'b';

[x,y] = fm_maskrotate(x,y,orient);
