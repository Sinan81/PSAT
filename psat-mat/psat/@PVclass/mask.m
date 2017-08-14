function [x,y,s] = mask(a,idx,orient,vals)

[xc,yc] = fm_draw('circle','PV');
[xp,yp] = fm_draw('P','PV');

x = cell(3,1);
y = cell(3,1);
s = cell(3,1);

x{1} = xc;
y{1} = yc;
s{1} = 'k';

type = length(vals);

switch type
  
 case 6
  
  [xc,yc] = fm_draw('C','PV'); 
  
  x{2} = 0.5*xc-0.25;
  y{2} = yc;
  s{2} = 'b';
  
 otherwise
  
  [xp,yp] = fm_draw('P','PV');
  
  x{2} = 0.3*xp-0.35;
  y{2} = 0.6*yp;
  s{2} = 'b';
  
  x{3} = [0.1 0.3 0.5];
  y{3} = [0.3 -0.3 0.3];
  s{3} = 'b';
  
end
