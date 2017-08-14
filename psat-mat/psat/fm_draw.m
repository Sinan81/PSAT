function [x,y] = fm_draw(varargin)
% FM_DRAW draw the PSAT Simulink library component masks
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    31-Jan-2003
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Path Settings

if nargin == 0, return, end

switch varargin{1}
 case {'connections','controls','facts','ultc', ...
       'fault','machines','measures','loads', ...
       'opfcpf','powerflow','others','sae','wind'}
  pos = get_param(gcb,'Position');
  dy = pos(4)-pos(2);
  dx = pos(3)-pos(1);
  x = imread([Path.images,['sim_',varargin{1},'.png']],'png');
  try
    if Settings.hostver >= 7.04
      x = imresize(x,[dy dx],'bilinear');
    else
      x = imresize(x,[dy dx],'bilinear',0);
    end
  catch
    % imresize is not available!
  end
 case 'arrow'
  x = [0.8 1 0.8 1 0];
  y = [-0.1 0 0.1 0 0];
 case 'circle'
  t = 0:0.05:2*pi+0.05;
  x = cos(t);
  y = sin(t);
  return
 case 'semicircle'
  t = -pi/2:0.05:pi/2+0.05;
  x = cos(t);
  y = sin(t);
  return
 case 'rounded'
  t = 0:0.05:pi/2+0.05;
  a = 0.6;
  k = 0.4;
  xc = k*cos(t);
  yc = k*sin(t);
  x = [-a a a+yc 1  1  a+xc  a -a -a-yc -1 -1 -a-xc];
  y = [ 1 1 a+xc a -a -a-yc -1 -1 -a-xc -a  a  a+yc];
  return
 case 'quarter'
  t = 0:0.05:pi/2+0.05;
  x = cos(t);
  y = sin(t);
 case 'sinus'
  x = 0:0.05:2*pi+0.05;
  y = sin(x);
 case 'helix'
  t = 0:0.05:2*pi+0.05;
  y = sin(t);
  x = cos(t).*y;
 case 'C'
  t = 0:0.05:pi+0.05;
  x1 = cos(t);
  y1 = sin(t);
  x = [1+x1,0,0,1-x1]/2;
  y = [1+y1,1,-1,-1-y1]/4;
 case '$'
  t = -pi/2:0.05:pi/2+0.05;
  x1 = cos(t);
  y1 = sin(t);
  x = [-1.5,0.5,0.5+x1,0.5,-0.5,-0.5-x1,-0.5,1,0,0,0]/3;
  y = [-2,-2,-1+y1,0,0,1+y1,2,2,2,2.6,-2.6]/4;
 case 'S'
  t = -pi/2:0.05:pi/2+0.05;
  x1 = cos(t);
  y1 = sin(t);
  x = [-1.5,0.5,0.5+x1,0.5,-0.5,-0.5-x1,-0.5,1]/3;
  y = [-2,-2,-1+y1,0,0,1+y1,2,2]/4;
 case 'P'
  t = -pi/2:0.05:pi/2+0.05;
  x1 = cos(t);
  y1 = sin(t);
  x = [-1,0.5,0.5+x1,0.5,-1,-1]/2.5;
  y = [0,0,1+y1,2,2,-2]/4;
 case 'M'
  x = [-0.5,-0.5,0,0.5,0.5];
  y = [-0.5,0.5,-0.5,0.5,-0.5];
 case 'O'
  t = 0:0.05:pi+0.05;
  x1 = cos(t);
  y1 = sin(t);
  x = [1+x1,0,0,1-x1,2,2]/2;
  y = [1+y1,1,-1,-1-y1,-1,1]/4;
 case 'theta'
  t = 0:0.05:pi+0.05;
  x1 = cos(t);
  y1 = sin(t);
  x = [1+x1,0,0,2,0,0,1-x1,2,2]/2;
  y = [1+y1,1,0,0,0,-1,-1-y1,-1,1]/4;
 case 'D'
  t = pi/2:-0.05:-pi/2-0.05;
  x1 = cos(t);
  y1 = sin(t);
  x = [0,-1,-1,0,x1]/2;
  y = [-1,-1,1,1,y1]/2;
 case 'Q'
  t = 0:0.05:pi+0.05;
  x1 = cos(t);
  y1 = sin(t);
  x = [1+x1,0,0,1-x1,2,1.5,3,2,2]/2;
  y = [1+y1,1,-1,-1-y1,-1,-0.5,-2,-1,1]/4;
 case 'U'
  t = 0:0.05:pi+0.05;
  x1 = cos(t);
  y1 = sin(t);
  x = [0,0,1-x1,2,2]/2;
  y = [2,-1,-1-y1,-1,2]/4;
 case 'R'
  t = -pi/2:0.05:pi/2+0.05;
  x1 = cos(t);
  y1 = sin(t);
  x = [1.5,0.5,-1,0.5,0.5+x1,0.5,-1,-1]/2.5;
  y = [-2,0,0,0,1+y1,2,2,-2]/4;
 case 'J'
  t = 0:0.05:pi+0.05;
  x1 = cos(t);
  y1 = sin(t);
  x = [1-x1,2,2,2,1,3]/4-0.25;
  y = [-1-y1,-1,2,2,2,2]/4;
 case 'G'
  t = pi/4:0.05:2*pi-pi/10+0.025;
  x1 = cos(t);
  y1 = sin(t);
  x = [x1,0];
  y = [y1,-0.2934];
 case 'pi'
  x = [-0.2368 -0.2368 -0.5 0.5526 0.2895 0.2895 0.5];
  y = [-0.5 0.5 0.5 0.5 0.5 0 -0.5];
 case 'hill'
  t = pi/4:0.05:3*pi/4;
  x = cos(t);
  y = sin(t);
 case 'Y'
  x = [-0.3 0 0 0 0.3];
  y = [0.5 0 -0.5 0 0.5];
 case 'L'
  x = [0.3 -0.3 -0.3];
  y = [-0.5 -0.5 0.5];
 case '1'
  x = [-0.15 -0.0 0.15 0.15];
  y = [0.17 0.24 0.5 -0.5];
 case '2'
  x = [-0.3 -0.225 0 0.225 0.3 0.225 -0.225 -0.3 0.3];
  y = [0.3 0.435 0.5 0.435 0.25 0 -0.25 -0.5 -0.5];
 case '3'
  x = [-0.3 -0.225  0    0.225  0.3   0.225 0 0.225 0.3  0.225 0  -0.225 -0.3];
  y = [-0.3 -0.435 -0.5 -0.435 -0.25 -0.035 0 0.035 0.25 0.435 0.5 0.435  0.3];
 case 'cap'
  x = [-0.3420   -0.5000   -0.6428   -0.7660   -0.8660 ...
       -0.9397   -0.9848   -1.0000   -0.9848   -0.9397 ...
       -0.8660   -0.7660   -0.6428   -0.5000   -0.3420];
  y = [ 0.9397    0.8660    0.7660    0.6428    0.5000 ...
        0.3420    0.1736    0.0000   -0.1736   -0.3420 ...
       -0.5000   -0.6428   -0.7660   -0.8660   -0.9397];
 case 'ind'
  x = [0 0.174 0.342 0.5 0.643 0.766 0.866 0.94 0.985 1 0.985 ...
       0.94 0.866 0.766 0.643 0.5  0.342 0.174 0];
  y = [1 0.985 0.94 0.866 0.766 0.643 0.5 0.342 0.174 0 -0.174 ...
       -0.342 -0.5 -0.643 -0.766 -0.866 -0.94 -0.985 -1];
 case 'a'
  x = [ 0.8660    0.7071    0.5000    0.2588    0.0000   -0.2588  ...
       -0.5000   -0.7071   -0.8660   -0.9659   -1.0000   -0.9659  ...
       -0.8660   -0.7071   -0.5000   -0.2588   -0.0000    0.2588  ...
        0.5000    0.7071    0.8660    0.8660    0.8660    0.7071  ...
        0.5000    0.2588    0.0000   -0.2588   -0.5000];
  y = [ 0.5000    0.7071    0.8660    0.9659    1.0000    0.9659  ...
        0.8660    0.7071    0.5000    0.2588    0.0000   -0.2588  ...
       -0.5000   -0.7071   -0.8660   -0.9659   -1.0000   -0.9659  ...
       -0.8660   -0.7071   -0.5000   -1.0000    1.5000    1.7071  ...
        1.8660    1.9659    2.0000    1.9659    1.8660];
 case 'ramp'
  x = [-0.4 -0.4 -0.4 -0.5  0.4 -0.4  0.0  0.3];
  y = [ 0.4 -0.5 -0.4 -0.4 -0.4 -0.4  0.3  0.3];
 case 'acdc'
  x = [-0.45 -0.65 -0.65 -0.45 -0.45 -0.45 -0.45 ...
       -0.2 -0.2 -0.45 -0.5 -0.45 -0.2 -0.2 0 0 ...
       -0.2 -0.2 -0.2 -0.2 -0.45 -0.45 -0.45 -0.2 -0.15];
  y = [1.5   1.5  -0.5  -0.5 -1 0 -0.5 -1 0 -0.5 ...
       -0.75 -0.5 -1 -0.5 -0.5 1.5 1.5 2 1 1.5 ...
       2 1 1 1.5 1.75];
 case 'acdc2'
  x = [-0.45 -0.65 -0.65 -0.85 -0.65 -0.65 -0.45 ...
       -0.45 -0.45 -0.45 -0.2 -0.2 -0.45 -0.5 ...
       -0.45 -0.2 -0.2 0 0 0.2 0 0 -0.2 -0.2 -0.2 ...
       -0.2 -0.45 -0.45 -0.45 -0.2 -0.15];
  y = [ 1.5 1.5 0.5 0.5 0.5 -0.5 -0.5 -1 0 -0.5 ...
        -1 0 -0.5 -0.75 -0.5 -1 -0.5 -0.5 0.5 0.5 ...
        0.5 1.5 1.5 2 1 1.5 2 1 1 1.5 1.75];
 otherwise
  x = [];
  y = [];
end

switch nargin
 case 1
  mask = get_param(gcbh,'MaskType');
  orient = get_param(gcbh,'Orientation');
 case 2
  mask = varargin{2};
  orient = 'right';
 otherwise
  mask = varargin{2};
  orient = varargin{3};
end

% rotate in case of orientation sensitive block
if sum(strcmp(mask,{'Demand','Rmpl','Line','Lines','Shunt','Twt'}))
  switch orient
   case 'right'
    % nothing to do
   case 'left'
    xmax = max(x);
    xmin = min(x);
    x = xmax+xmin-x;
   case 'up'
    xmax = max(x);
    xmin = min(x);
    xold = x;
    x = y;
    y = xmax+xmin-xold;
    if sum(strcmp(varargin{1},{'1','2','3','a'})), return, end
    if sum(strcmp(mask,{'Line','Lines','Shunt'}))
      x = 0.5*x;
      y = 1.5*y;
    end
   case 'down'
    xmax = max(x);
    xmin = min(x);
    ymax = max(y);
    ymin = min(y);
    yold = y;
    y = xmax+xmin-x;
    x = ymax+ymin-yold;
    if sum(strcmp(varargin{1},{'1','2','3','a'})), return, end
    if sum(strcmp(mask,{'Line','Lines','Shunt'}))
      x = 0.5*x;
      y = 1.5*y;
    end
  end
end