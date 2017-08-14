function [x,y,s] = mask(a,idx,orient,vals)

[xl,yl] = fm_draw('L','Lines',orient);

x = cell(2,1);
y = cell(2,1);
s = cell(2,1);

x{1} = [-1  1  1 -1 -1];
y{1} = [-0.2 -0.2 0.2 0.2 -0.2];
s{1} = 'k';

x{2} = 0.35*xl;
y{2} = 0.2*yl;
s{2} = 'b';

[x,y] = fm_maskrotate(x,y,orient);

