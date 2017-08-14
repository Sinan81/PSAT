function [x,y,s] = mask(a,idx,orient,descr)

if ~isempty(strfind(descr,'auto'))

  [xc,yc] = fm_draw('circle');
  [xq,yq] = fm_draw('quarter');
  x = cell(4,1);
  y = cell(4,1);
  s = cell(4,1);
  x{1} = xc;
  y{1} = yc;
  s{1} = 'k';
  x{2} = 1.75*xq;
  y{2} = yq;
  s{2} = 'k';
  x{3} = [-1 -1.3];
  y{3} = [0 0];
  s{3} = 'k';
  x{4} = [1.75 2.05];
  y{4} = [0 0];
  s{4} = 'k';

elseif ~isempty(strfind(descr,'former'))

  tap = ~isempty(strfind(descr,'ratio'));
  phs = ~isempty(strfind(descr,'shifter'));
  [xc,yc] = fm_draw('circle','Line',orient);
  [x1,y1] = fm_draw('1','Line',orient);
  [x2,y2] = fm_draw('2','Line',orient);
  [xa,ya] = fm_draw('a','Line',orient);

  if tap && ~phs
  
    x = cell(8,1);
    y = cell(8,1);
    s = cell(8,1);
    x{5} = [-0.8 0.7];
    y{5} = [-1.2 1.2];
    s{5} = 'g';    
    x{7} = [0.5 0.7];
    y{7} = [1.1 1.2];    
    s{7} = 'g';
    x{8} = [0.7 0.7];    
    y{8} = [1.0 1.2];
    s{8} = 'g';
  
  elseif ~tap && phs
  
    x = cell(9,1);
    y = cell(9,1);
    s = cell(9,1);
    x{5} = -0.1+0.65*x1;
    y{5} = 0.65*y1;
    s{5} = 'g';
    x{7} = 3.35+0.2*xa;
    y{7} = -0.1+0.15*ya;
    s{7} = 'r';
    x{8} = [2.7 2.7 4 4 2.7];
    y{8} = [-0.5 0.5 0.5 -0.5 -0.5];
    s{8} = 'k';
    x{9} = [4 4.3];
    y{9} = [0 0];
    s{9} = 'k';
  
  elseif tap && phs
  
    x = cell(11,1);
    y = cell(11,1);
    s = cell(11,1);
    x{5} = [-0.8 0.7];
    y{5} = [-1.2 1.2];
    s{5} = 'g';
    x{7} = [0.5 0.7];
    y{7} = [1.1 1.2];
    s{7} = 'g';
    x{8} = [0.7 0.7];
    y{8} = [1.0 1.2];
    s{8} = 'g';
    x{9} = [2.7 2.7 4 4 2.7];
    y{9} = [-0.5 0.5 0.5 -0.5 -0.5];
    s{9} = 'k';
    x{10} = [4 4.3];
    y{10} = [0 0];
    s{10} = 'k';
    x{11} = 3.35+0.2*xa;
    y{11} = -0.1+0.15*ya;
    s{11} = 'r';
  
  else   
  
    x = cell(6,1);
    y = cell(6,1);
    s = cell(6,1);
    x{5} = -0.1+0.65*x1;
    y{5} = 0.65*y1;
    s{5} = 'g';
  
  end
  
  x{1} = xc;
  y{1} = yc;
  s{1} = 'k';
  x{2} = xc+1.4;
  y{2} = yc;
  s{2} = 'k';
  x{3} = [-1 -1.3];
  y{3} = [0 0];
  s{3} = 'k';
  x{4} = [2.4 2.7];
  y{4} = [0 0];
  s{4} = 'k';
  x{6} = 1.5+0.65*x2;
  y{6} = 0.65*y2;
  s{6} = 'g';

elseif ~isempty(strfind(descr,'line'))

  [xp,yp] = fm_draw('pi','Line',orient);
  x = cell(2,1);
  y = cell(2,1);
  s = cell(2,1);
  x{1} = [-1  1  1 -1 -1];
  y{1} = [-0.2 -0.2 0.2 0.2 -0.2];
  s{1} = 'k';
  x{2} = 0.35*xp;
  y{2} = 0.2*yp;
  s{2} = 'b';

elseif ~isempty(strfind(descr,'cable'))

  [xc,yc] = fm_draw('circle');
  [x1,y1] = fm_draw('semicircle');
  x = cell(7,1);
  y = cell(7,1);
  s = cell(7,1);
  x{1} = 10+0.433*xc;
  y{1} = 0.5+0.433*yc;
  s{1} = 'y';
  x{2} = 9.567+0.433*xc;
  y{2} = -0.25+0.433*yc;
  s{2} = 'y';
  x{3} = 10.433+0.433*xc;
  y{3} = -0.25+0.433*yc;
  s{3} = 'y';
  x{4} = -x1;
  y{4} = y1;
  s{4} = 'k';
  x{5} = 10+xc;
  y{5} = yc;
  s{5} = 'k';
  x{6} = [0 10];
  y{6} = [1 1];
  s{6} = 'k';
  x{7} = [0 10];
  y{7} = [-1 -1];
  s{7} = 'k';

end

[x,y] = fm_maskrotate(x,y,orient);
