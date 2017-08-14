function [x,y] = fm_maskrotate(x,y,orient)

xt = [];
yt = [];
for j = 1:length(x)
  xt = [xt, x{j}]; %#ok<AGROW>
  yt = [yt, y{j}]; %#ok<AGROW>
end

xmin = min(xt);
xmax = max(xt);
ymin = min(yt);
ymax = max(yt);

for i = 1:length(x)
  switch orient
   case 'left'
    x{i} = xmax+xmin-x{i};
   case 'up'
    y{i} = ymax+ymin-y{i}; 
   case 'down'
    y{i} = ymax+ymin-y{i};
    x{i} = xmax+xmin-x{i};
  end
end

if strcmp(orient,'up') || strcmp(orient,'down')
  xold = x;
  x = y;
  y = xold;
end
