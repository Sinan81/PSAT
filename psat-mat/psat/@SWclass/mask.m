function [x,y,s] = mask(a,idx,orient,vals)

switch vals{8}

 case 'on'

  x = cell(4,1);
  y = cell(4,1);
  s = cell(4,1);
  
  x{1} = [0 1 1 0 0];
  y{1} = [0 0 1 1 0];
  s{1} = 'k';
  
  x{2} = [0 1];
  y{2} = [0 1];
  s{2} = 'b';
  
  x{3} = [0 1];
  y{3} = [1 0];
  s{3} = 'b';
  
  x{4} = [0.5 1 0.5 0 0.5];
  y{4} = [0 0.5 1 0.5 0];
  s{4} = 'b';

 case 'off'

  x = cell(3,1);
  y = cell(3,1);
  s = cell(3,1);
  
  [xc,yc] = fm_draw('circle','SW',orient);
  [xt,yt] = fm_draw('theta','SW',orient);  
  
  x{1} = xc;
  y{1} = yc;
  s{1} = 'k';
  
  x{2} = [0.1 0.3 0.5]-0.6;
  y{2} = [0.3 -0.3 0.3];
  s{2} = 'b';
  
  x{3} = 0.45*xt+0.1;
  y{3} = 0.6*yt;
  s{3} = 'b';
  
end
