function fm_xy(flag)
% FM_XY draw network topology
%
% FM_XY(FLAG)x
%    FLAG 'ytree' -> graph on a circle
%         'etree' -> elimination tree
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Line Bus File Theme

if ~Line.n
  fm_disp('No static network is loaded. Network tree cannot be drawn.',1)
  return
end

if ~Bus.n
  fm_disp('No data is loaded. Network tree cannot be drawn.',1)
  return
end

switch flag
 case 'ytree'
  a = 6.2832/Bus.n;
  t = [0:a:6.2832-a]';
  xy = [sin(t), cos(t)];
  figure;
  p = Bus.a; %colamd(Line.Y);
  gplot(Line.Y(p,p),xy)
  hold on
  h = plot(xy(:,1),xy(:,2),'ro');
  set(h,'MarkerFaceColor',Theme.color08)
  hold off
  title(['Graph Representation of "',strrep(File.data,'_','-'),'" Network'])
  limite = 1.5;
  xlim([-limite limite]);
  ylim([-limite limite]);
  for i = 1:Bus.n
    h = text(1.1*xy(i,1),1.1*xy(i,2),strrep(Bus.names(p(i)),'_',' '));
    if xy(i,1) < 0; set(h,'HorizontalAlignment','right'); end
    if abs(xy(i,1)) < 1e-2; set(h,'HorizontalAlignment','center'); end
  end
  set(gca,'XTick',[],'YTick',[]);
 case 'etree'
  figure
  etreeplot(Line.Y,'ro','b')
  title(['Elimination Tree of "',strrep(File.data,'_','\_'),'" Network.'])
end