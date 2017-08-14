function [x,y,s] = mask(a,idx,orient,vals)

[xa,ya] = fm_draw('arrow','Wind',orient);

x = cell(5,1);
y = cell(5,1);
s = cell(5,1);

x{1} = xa;
y{1} = ya;
s{1} = 'c';

x{2} = xa-0.2;
y{2} = ya-0.2;
s{2} = 'c';

x{3} = xa-0.4;
y{3} = ya-0.4;
s{3} = 'c';

x{4} = xa+0.2;
y{4} = ya+0.2;
s{4} = 'c';

x{5} = xa+0.4;
y{5} = ya+0.4;
s{5} = 'c';

[x,y] = fm_maskrotate(x,y,orient);
