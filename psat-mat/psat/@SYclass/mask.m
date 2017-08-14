function [x,y,s] = mask(a,idx,orient,vals)

[xc,yc] = fm_draw('circle','Syn');
[xg,yg] = fm_draw('G','Syn');
[xs,ys] = fm_draw('sinus','Syn');

x = cell(3,1);
y = cell(3,1);
s = cell(3,1);

x{1} = xc+1.4;
y{1} = yc;
s{1} = 'k';

x{2} = 0.12*xs+1;
y{2} = 0.15*ys-0.6;
s{2} = 'k';

x{3} = 1.4+0.45*xg;
y{3} = 0.3+0.45*yg;
s{3} = 'b';
