function [x,y,s] = mask(a,idx,orient,type)

switch type
  
 case 'PQgen'

  [xc,yc] = fm_draw('circle','PQgen',orient);
  [xp,yp] = fm_draw('P','PQgen',orient);
  [xq,yq] = fm_draw('Q','PQgen',orient);

  x = cell(3,1);
  y = cell(3,1);
  s = cell(3,1);

  x{1} = xc;
  y{1} = yc;
  s{1} = 'k';

  x{2} = 0.3*xp-0.35;
  y{2} = 0.6*yp;
  s{2} = 'b';

  x{3} = 0.4*xq+0.1;
  y{3} = 0.6*yq;
  s{3} = 'b';
  
case 'PQ'
  
  x = cell(1,1);
  y = cell(1,1);
  s = cell(1,1);
  
  x{1} = [1 -0.5 -0.5 1];
  y{1} = [0 0.866 -0.866 0];
  s{1} = 'k';
  
  [x,y] = fm_maskrotate(x,y,orient);

end
