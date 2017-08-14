function pos = sizefig(dx,dy)
% FIGSIZE determine the figure size for the current screen resolution
%
% SIZES = SIZEFIG(DX,DY)
%     DX    = normalized width for a 1024x768 screen
%     DY    = normalized hight for a 1024x768 screen
%     POS = resulting figure normalized position [x y dx dy]
%
%Author:    Federico Milano
%Date:      22-Sep-2003
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

if ~strcmp(get(0,'Units'),'pixels')
  set(0,'Units','pixels')
end

% get screen size

scrnsize = get(0,'ScreenSize');
screenx = scrnsize(3);
screeny = scrnsize(4);
screenr = screeny/screenx;

% check screen ratio
% standard screen ratio 768/1024 = 0.75

if screenr > 0.75
  screeny = screenx*screenr;
elseif screenr < 0.75
  screenx = screeny/screenr;
end

% changes apply only if the screen resolution is higher than
% 1024x768

if screenx > 1024 || screeny > 768
  dx = 1024*dx/screenx;
  dy =  768*dy/screeny;
end

% offset (applies only if the video is a dual screen)
if screenx > 1800
  xoffset = 0.25;
else
  xoffset = 0;
end
if screeny > 1800
  yoffset = 0.25;
else
  yoffset = 0;
end

% output window position
pos = [(1-dx)*0.5-xoffset, (1-dy)*0.5-yoffset, dx, dy];