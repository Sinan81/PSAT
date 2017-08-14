function [x,y,s] = mask(a,idx,orient,vals)

x = cell(3,1);
y = cell(3,1);
s = cell(3,1);

x{1} = [1 2 2 1 1];
y{1} = [-1 -1 1 1 -1];
s{1} = 'k';

switch vals{2}
 case 'on'

  x{2} = [1 2];
  y{2} = [-1 1];
  s{2} = 'r';
  
  x{3} = [2 1];
  y{3} = [-1 1];
  s{3} = 'r';

end
