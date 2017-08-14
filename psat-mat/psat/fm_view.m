function fm_view(flag)
% FM_VIEW functions for matrix visualizations
%
% FM_VIEW(FLAG)
%      FLAG matrix visualization type
%
%see also FM_MATRX
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global DAE Bus Theme Line

if isempty(Bus.con)
  fm_disp('No loaded system. Matrix visualization cannot be run.',2)
  return
end

switch flag
 case 1
  if DAE.n > 0
    matrice = [DAE.Fx, DAE.Fy; DAE.Gx, DAE.Gy];
  else
    fm_disp('Since no dynamic component is loaded, AC coincides with Jlfv.',2)
    matrice = DAE.Gy;
  end
  titolo = 'Complete System Matrix A_c';
  visual(matrice,titolo)
 case 2
  if DAE.n > 0
    matrice = DAE.Fx - DAE.Fy*inv(DAE.Gy)*DAE.Gx;
  else
    fm_disp('No dynamic component loaded.',2);
    return
  end
  titolo = 'State jacobian matrix A_s';
  visual(matrice,titolo)
 case 3
  matrice = build_gy(Line);
  titolo = 'Jacobian matrix J_l_f';
  visual(matrice,titolo)
 case 4
  matrice = DAE.Gy;
  titolo = 'Jacobian matrix J_l_f_v';
  visual(matrice,titolo)
 case 5
  if DAE.n > 0
    Fx_mod = DAE.Fx+diag(-1e-5*ones(DAE.n,1));
    matrice = DAE.Gy - DAE.Gx*inv(Fx_mod)*DAE.Fy;
  else
    fm_disp(['Since no dynamic component is loaded, ', ...
             'Jlfd coincides with Jlfv.'],2)
    matrice = DAE.Gy;
  end
  titolo = 'Jacobian matrix J_l_f_d';
  visual(matrice,titolo)
 case 6
  ch(1) = findobj(gcf,'Tag','toggle1');
  ch(2) = findobj(gcf,'Tag','toggle2');
  ch(3) = findobj(gcf,'Tag','toggle3');
  ch(4) = findobj(gcf,'Tag','toggle4');
  ca = find(ch == gcbo);
  vals = zeros(4,1);
  vals(ca) = 1;
  for i = 1:4, set(ch(i),'Value',vals(i)); end
  hdl = findobj(gcf,'Tag','toggle5');
  if ca == 3
    set(hdl,'Enable','off');
  else
    set(hdl,'Enable','on');
  end
end


%======================================================================
function visual(matrice,titolo)

global DAE Theme

ch(1) = findobj(gcf,'Tag','toggle1');
ch(2) = findobj(gcf,'Tag','toggle2');
ch(3) = findobj(gcf,'Tag','toggle3');
ch(4) = findobj(gcf,'Tag','toggle4');
vals = get(ch,'Value');
for i = 1:4, valn(i) = vals{i}; end
tre_d = find(valn);

switch tre_d
 case 1
  surf(full(matrice));
  shading('interp')
 case 2
  mesh(full(matrice));
 case 3
  rotate3d off
  hdl = findobj(gcf,'Tag','toggle5');
  set(hdl,'Value',0);
  spy(matrice);
  if flag == 1
    hold on
    plot([0,DAE.n+DAE.m+2],[DAE.n+0.5,DAE.n+0.5],'k:');
    plot([DAE.n+0.5,DAE.n+0.5],[0,DAE.n+DAE.m+2],'k:');
    hold off
  end
 case 4
  surf(full(matrice));
end
hdl = findobj(gcf,'Tag','toggle6');
if get(hdl,'Value'), grid on, else grid off, end
hdl = findobj(gcf,'Tag','toggle7');
if get(hdl,'Value'), zoom on, else zoom off, end

set(gca,'Color',Theme.color11);
title(titolo);