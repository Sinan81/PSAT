function [x,y,s] = mask(a,idx,orient,vals)

[xc,yc] = fm_draw('circle','Ind',orient);
[xs,ys] = fm_draw('sinus','Ind',orient);

x = cell(3,1);
y = cell(3,1);
s = cell(3,1);

x{1} = xc+1.4;
y{1} = yc;
s{1} = 'k';

x{2} = 0.12*xs+1;
y{2} = 0.15*ys-0.6;
s{2} = 'k';

x{3} = [1 1 1.4 1.8 1.8];
y{3} = [-0.05 0.7 0.4 0.7 -0.05];
s{3} = 'b';
