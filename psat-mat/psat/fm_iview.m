function hfig = fm_iview(x,map,name)

% IMAGEVIEW Show image in figure window
% IMAGEVIEW(FILENAME) Shows figure with preview of image, filename is title.
% IMAGEVIEW(X) Shows figure with preview of image data in X.
% IMAGEVIEW(X,MAP) Same as above using colormap data in MAP.
% IMAGEVIEW(X,MAP,NAME) Same as above using NAME in title.
%
% H = IMAGEVIEW(...) Returns handle to figure.
%
% Zoom is on by default.
%
% See also UILOAD, OPEN, SOUNDVIEW, MOVIEVIEW

% Copyright 1984-2001 The MathWorks, Inc.
% $Revision: 1.8 $  $Date: 2001/04/15 12:03:37 $
%
%Modified by:    Federico Milano
%Date:      11-Nov-2002
%Update:    12-Aug-2003
%Version:   2.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html

global Theme Settings

if Settings.hostver <= 5.03
  uiwait(fm_choice('Image viewer not supported on Matlab 5.3',2))
  return
end

figname = 'PSAT-viewer';

if nargin < 2, map = []; end

if ischar(x)
    testo = x;
    s = importdata(x);
    if ~isstruct(s)
        x = s;
    else
        x = s.cdata;
        map = s.colormap;
    end
end

if ischar(x) || iscell(x)
    fm_disp(['File "',testo,'" damaged or not an image file.'])
    return
end

imsize = size(x);
if nargin == 3
    testo = name;
end

h = figure('menubar','none', ...
           'toolbar','none', ...
           'name',figname, ...
           'numbertitle','off', ...
           'visible','off', ...
           'resize','off', ...
           'color',Theme.color01, ...
           'userdata',x);
if nargout
    hfig = h;
end
set(h,'units','pixels');
ss = get(0,'screensize');
fs = get(h,'position');
b1 = uicontrol('style','pushbutton',...
              'string','Zoom Out',...
              'BackgroundColor', Theme.color02, ...
              'HandleVisibility','callback', ...
              'units','pixels',...
              'position',[5 5 100 30],...
              'enable','off',...
              'callback','zoom(gcbf,''out''),zoom(gcbf,''on'')');

b2 = uicontrol('style','pushbutton',...
              'string','Done',...
              'BackgroundColor', Theme.color03, ...
              'ForegroundColor', Theme.color04, ...
              'FontWeight','bold', ...
              'HandleVisibility','callback', ...
              'units','pixels',...
              'position',[110 5 100 30],...
              'callback','try, close(gcbf), end');
a = gca;
set(a,'visible','off')
pos = size(x);

btop = 5 + 30 + 5;

% resize figure to fit buttons and movie
width = max(pos(2) + 10, 215);
height = btop + 5 + pos(1) + 5 + 30;
set(h,'position',[fs(1) fs(2) width height])
fs = get(h,'position');

% recenter figure on screen
set(h,'position',[(ss(3) - fs(3))/2 (ss(4) - fs(4))/2 fs(3) fs(4)])

% recenter buttons on figure
if width ~= 215
    leftGap = 5 + (width - 215) / 2;
    p1 = get(b1,'position');
    set(b1,'position',[leftGap p1(2:end)]);
    p2 = get(b2,'position');
    set(b2,'position',[leftGap + 110 p2(2:end)]);
end

% place image
imagesc(x);
if ~isempty(map)
    colormap(map);
end
set(a,'units','pixels','position',[(fs(3)-pos(2))/2 btop pos(2) pos(1)])

title(sprintf(testo));
set(get(a,'title'),'color','k','interpreter','none')

axis('off');
axis('image');
set(h,'visible','on')
zoom('on')

if nargout == 0
    set(h,'HandleVisibility','callback');
end