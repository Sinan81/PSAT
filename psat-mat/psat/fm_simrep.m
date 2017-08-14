function fm_simrep(varargin)
% FM_SIMREP generate data report in Simulink models
%
% FM_SIMREP(FLAG,FONTSIZE,FONTNAME)
%       FLAG: 1 - set up voltage report on current loaded network
%             2 - wipe voltage report on current loaded network
%             3 - set up power flows on current loaded network
%             4 - wipe power flows on current loaded network
%             5 - hide component names except for buses
%             6 - show component names
%             7 - hide bus names
%             8 - show bus names
%             9 - set font name
%            10 - set font size
%            11 - save model diagram to eps file
%       FONTSIZE: font size (integer)
%       FONTNAME: font name (string)
%
%see also FM_LIB, FM_SIMSET
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

fm_var

global Settings

type = 1;

switch nargin
 case 1
  flag = varargin{1};
 case 3
  flag = varargin{1};
  fontsize = varargin{2};
  fontname = varargin{3};
 case 4
  flag = varargin{1};
  maptype = varargin{2};
  type = varargin{3};
  method = varargin{4};
end

if isempty(File.data) && type,
  fm_disp('No loaded system is present at the moment.',2),
  return
end
if isempty(strfind(File.data,'(mdl)')) && type
  fm_disp('The actual data file is not generated from a Simulink model.',2),
  return
end
if ~Settings.init && ~strcmp(flag,{'mdl2eps','ViewModel','DrawModel'}) & type
  fm_disp('Perform Power Flow before using this utility.',2),
  return
end

lasterr('');

% load Simulink model
cd(Path.data);
filedata = File.data(1:end-5);
open_sys = find_system('type','block_diagram');
if ~sum(strcmp(open_sys,filedata))
  try
    if nargin > 3
      load_system(filedata)
    else
      open_system(filedata);
    end
  catch
    fm_disp(lasterr,2)
    return
  end
end
cur_sys = get_param(filedata,'Handle');
if ~strcmp(flag,'DrawModel'), set_param(cur_sys,'Open','on'), end
blocks = find_system(cur_sys,'Type','block');
lines = find_system(cur_sys, ...
                    'FindAll','on', ...
                    'type','line');
masks = get_param(blocks,'Masktype');
nblock = length(blocks);

switch flag

 case 'ViewModel'

  % view the current Simulink model.
  hilite_system(cur_sys,'none')

 case 'DrawModel'

  maps = {'jet';'hot';'gray';'bone';'copper';'pink';
    'hsv';'cool';'autumn';'spring';'winter';'summer'};

  if ~method
    switch type
     case 0 % only one-line diagram
      zlevel = 0;
     case 1 % voltage magnitudes
      zlevel = 1.025*max(DAE.y(Bus.v));
     case 2 % voltage phases
      zmax = max(180*DAE.y(Bus.a)/pi);
      if zmax >= 0
        zlevel = 1.1*zmax;
      else
        zlevel = 0.9*zmax;
      end
     case 3 % line flows
      [sij,sji] = flows(Line,3);
      zlevel = 1.1*max(sij);
     case 4 % generator rotor angles
      if ~Syn.n
        if Settings.static
          fm_disp('Currently, synchronous machines are not loaded.')
          fm_disp('Uncheck the option "Discard dynamic data" and try again.')
        else
          fm_disp('There are no synchronous machines in the current system.',2)
        end
        return
      end
      zmax = max(180*DAE.x(Syn.delta)/pi);
      if zmax >= 0
        zlevel = 1.1*zmax;
      else
        zlevel = 0.9*zmax;
      end
     case 5 % generator rotor speeds
      if ~Syn.n
        if Settings.static
          fm_disp('Currently, synchronous machines are not loaded.')
          fm_disp('Uncheck the option "Discard dynamic data" and try again.')
        else
          fm_disp('There are no synchronous machines in the current system.',2)
        end
        return
      end
      zlevel = 1.005*max(DAE.x(Syn.omega));
     case 6 % locational marginal prices
      if ~OPF.init
        fm_disp(['Run OPF before displaying Locational Marginal ' ...
                 'Prices'],2)
        return
      end
      LMP = OPF.LMP;
      zlevel = 1.025*max(LMP);
     case 7 % nodal congestion prices
      if ~OPF.init
        fm_disp(['Run OPF before displaying Nodal Congestion Prices'], ...
                2)
        return
      end
      NCP = OPF.NCP(1:Bus.n);
      zlevel = 1.025*max(NCP);
     otherwise
      zlevel = 0;
    end
    Varout.zlevel = zlevel;
  end

  if ishandle(Fig.threed) && type
    figure(Fig.threed)
  elseif ishandle(Fig.dir) && ~type
    figure(Fig.dir)
    hdla = findobj(Fig.dir,'Tag','Axes1');
    cla(hdla)
  else
    figure
  end
  hold on

  if ~method
    if type, colorbar, end
    if ishandle(Fig.threed), cla(get(Fig.threed,'UserData')), end
    lines = get_param(cur_sys,'Lines');
  end

  pos = get_param(cur_sys,'Location');
  xl = [];
  yl = [];

  for i = 1:length(lines)*(~method)
    z = zlevel*ones(length(lines(i).Points(:,1)),1);
    plot3(lines(i).Points(:,1),lines(i).Points(:,2),z,'k')
    xl = [xl; lines(i).Points([1 end],1)];
    yl = [yl; lines(i).Points([1 end],2)];
  end

  xb = [];
  yb = [];
  zb = [];
  x_max = 0;
  x_min = 2000;
  y_max = 0;
  y_min = 2000;
  idx = 0;
  idx_line = 0;
  idx_gen = 0;
  Compnames = cell(0,0);
  Compidx = [];
  ncomp = 0;
  if ~method
    switch type
     case 3
      Varout.hdl = zeros(Line.n,1);
     case {4,5}
      Varout.hdl = zeros(Syn.n,1);
     otherwise
      Varout.hdl = zeros(Bus.n,1);
    end
  end

  for i = 1:length(blocks)*(~method)

    bmask = get_param(blocks(i),'MaskType');

    jdx = strmatch(bmask,Compnames,'exact');
    if isempty(jdx)
      ncomp = ncomp + 1;
      Compnames{ncomp,1} = bmask;
      Compidx(ncomp,1) = 0;
      jdx = ncomp;
    end
    Compidx(jdx) = Compidx(jdx)+1;

    bpos = get_param(blocks(i),'Position');
    bidx = Compidx(jdx); %str2double(get_param(blocks(i),'UserData'));
    borien = get_param(blocks(i),'Orientation');
    bports = get_param(blocks(i),'Ports');
    bvalues = get_param(blocks(i),'MaskValues');
    bin = sum(bports([1 6]));
    bou = sum(bports([2 7]));

    switch bmask
     case 'Varname'
      % nothing to do!
      x = cell(1,1);
      y = cell(1,1);
      s = cell(1,1);
      x{1} = 0;
      y{1} = 0;
      s{1} = 'k';
     case 'Ltc'
      bname = get_param(blocks(i),'NamePlacement');
      [x,y,s] = mask(eval(bmask),bidx,{borien;bname},bvalues);
     case 'Line'
      bdescr = get_param(blocks(i),'MaskDescription');
      [x,y,s] = mask(eval(bmask),bidx,borien,bdescr);
     case 'PQ'
      [x,y,s] = mask(eval(bmask),bidx,borien,'PQ');
     case 'PQgen'
      [x,y,s] = mask(eval(bmask),bidx,borien,'PQgen');
     case 'Link'

      rot = strcmp(get_param(blocks(i),'NamePlacement'),'normal');

      x = cell(6,1);
      y = cell(6,1);
      s = cell(6,1);

      x{1} = [0.45 0];
      y{1} = [0.5 0.5];
      s{1} = 'k';

      x{2} = [1 0.55];
      y{2} = [0.5 0.5];
      s{2} = 'k';

      x{3} = [0.45 0.55 0.55 0.45 0.45];
      y{3} = [0.45 0.45 0.55 0.55 0.45];
      s{3} = 'g';

      x{4} = [0.5 0.5];
      y{4} = rot*0.45+[0.1 0.45];
      s{4} = 'g';

      x{5} = [0.45 0.55 0.55 0.45 0.45];
      y{5} = rot*0.9+[0 0 0.1 0.1 0];
      s{5} = 'g';

      x{6} = 1-rot;
      y{6} = 1-rot;
      s{6} = 'w';

      [x,y] = fm_maskrotate(x,y,borien);

     case 'Link2'

      x = cell(10,1);
      y = cell(10,1);
      s = cell(10,1);

      x{1} = [0 0.45];
      y{1} = [0.5 0.5];
      s{1} = 'k';

      x{2} = [0.5 0.5];
      y{2} = [0 0.4];
      s{2} = 'k';

      x{3} = [0.5 0.5];
      y{3} = [0 0.4];
      s{3} = 'k';

      x{4} = [0.5 1];
      y{4} = [0 0];
      s{4} = 'k';

      x{5} = [0.5 0.5];
      y{5} = [0.6 1];
      s{5} = 'g';

      x{6} = [0.5 0.9];
      y{6} = [1 1];
      s{6} = 'g';

      x{7} = [0.9 0.985 0.985 0.9 0.9];
      y{7} = [0.1 0.1 -0.1 -0.1 0.1]+1;
      s{7} = 'g';

      x{8} = [0.45 0.55 0.55 0.45 0.45];
      y{8} = [0.6 0.6 0.4 0.4 0.6];
      s{8} = 'g';

      x{9} = 0;
      y{9} = -0.5;
      s{9} = 'w';

      x{10} = 0;
      y{10} = 1.5;
      s{10} = 'w';

      [x,y] = fm_maskrotate(x,y,borien);

     otherwise
      [x,y,s] = mask(eval(bmask),bidx,borien,bvalues);
    end

    xt = [];
    yt = [];
    for j = 1:length(x)
      xt = [xt, x{j}];
      yt = [yt, y{j}];
    end

    xmin = min(xt);
    xmax = max(xt);
    if xmax == xmin, xmax = xmin+1; end
    ymin = min(yt);
    ymax = max(yt);
    if ymax == ymin, ymax = ymin+1; end
    dx = bpos(3)-bpos(1);
    dy = bpos(4)-bpos(2);

    xscale = dx/(xmax-xmin);
    yscale = dy/(ymax-ymin);

    xcorr = -xscale*(xmax+xmin)/2 + 0.5*dx;
    ycorr = -yscale*(ymax+ymin)/2 + 0.5*dy;

    xmean = bpos(1)+xcorr+xscale*(xmax+xmin)/2;
    ymean = bpos(4)-ycorr-yscale*(ymax+ymin)/2;

    if strcmp(bmask,'Bus')
      idx = idx + 1;

      if type == 1 || type == 2 || type == 6 || type == 7
        xb = [xb; bpos(1)+xcorr+xscale*xmax; xmean];
        yb = [yb; bpos(4)-yscale*ymax-ycorr; ymean];
        xb = [xb; bpos(1)+xcorr+xscale*xmin];
        yb = [yb; bpos(4)-yscale*ymin-ycorr];
      end

      %bcolor = get_param(blocks(i),'BackgroundColor');
      bname = get_param(blocks(i),'Name');

      switch borien
       case {'right','left'}
        switch get_param(blocks(i),'NamePlacement')
         case 'normal'
          xtext = xmean;
          ytext = bpos(4)-ycorr-yscale*ymin+7;
          bha = 'center';
          bva = 'top';
         case 'alternate'
          xtext = xmean;
          ytext = bpos(4)-ycorr-yscale*ymax-7;
          bha = 'center';
          bva = 'bottom';
        end
       case {'up','down'}
        switch get_param(blocks(i),'NamePlacement')
         case 'normal'
          xtext = bpos(1)+xcorr+xscale*xmax+7;
          ytext = ymean;
          bha = 'left';
          bva = 'middle';
         case 'alternate'
          xtext = bpos(1)+xcorr+xscale*xmin-7;
          ytext = ymean;
          bha = 'right';
          bva = 'middle';
        end
      end

      % write bus names
      if type
        h = text(xtext,ytext,zlevel,bname);
        set(h,'HorizontalAlignment',bha,'VerticalAlignment',bva, ...
              'FontSize',8)
      end
      if type == 1 || type == 2 || type == 6 || type == 7
        switch type
         case 1, zpeak = DAE.y(Bus.v(idx));
         case 2, zpeak = 180*DAE.y(Bus.a(idx))/pi;
         case 6, zpeak = LMP(idx);
         case 7, zpeak = NCP(idx);
        end
        Varout.hdl(idx) = plot3([xmean xmean],[ymean ymean], ...
                              [zlevel,zpeak],'k:');
      end
    end
    if strcmp(bmask,'Line') && type == 3
      idx_line = idx_line + 1;

      xb = [xb; bpos(1)+xcorr+xscale*xmax; xmean];
      yb = [yb; bpos(4)-yscale*ymax-ycorr; ymean];
      xb = [xb; bpos(1)+xcorr+xscale*xmin];
      yb = [yb; bpos(4)-yscale*ymin-ycorr];

      Varout.hdl(idx_line) = plot3([xmean xmean],[ymean ymean],[zlevel,sij(idx_line)],'k:');

    elseif strcmp(bmask,'Syn') && (type == 4 || type == 5)

      idx_gen = idx_gen + 1;

      xb = [xb; bpos(1)+xcorr+xscale*xmax; xmean];
      yb = [yb; bpos(4)-yscale*ymax-ycorr; ymean];
      xb = [xb; bpos(1)+xcorr+xscale*xmin];
      yb = [yb; bpos(4)-yscale*ymin-ycorr];

      switch type
       case 4
        zpeak = 180*DAE.x(Syn.delta(idx_gen))/pi;
       case 5
        zpeak = DAE.x(Syn.omega(idx_gen));
      end
      Varout.hdl(idx_gen) = plot3([xmean xmean],[ymean ymean], ...
                              [zlevel,zpeak],'k:');
    end

    switch borien
     case 'right'
      len = yscale*(ymax-ymin);
      if bin, in_off = len/bin; end
      if bou, ou_off = len/bou; end
      for j = 1:bin
        yi = bpos(4)-ycorr-yscale*ymin-in_off/2-in_off*(j-1);
        xi = bpos(1)+xcorr+xscale*xmin;
        [yf,xf] = closerline(yi,xi-5,yl,xl);
        plot3([xi, xf],[yf, yf],[zlevel, zlevel],'k')
      end
      for j = 1:bou
        yi = bpos(4)-ycorr-yscale*ymin-ou_off/2-ou_off*(j-1);
        xi = bpos(1)+xcorr+xscale*xmax;
        [yf,xf] = closerline(yi,xi+5,yl,xl);
        plot3([xi, xf],[yf, yf],[zlevel, zlevel],'k')
      end
     case 'left'
      len = yscale*(ymax-ymin);
      if bin, in_off = len/bin; end
      if bou, ou_off = len/bou; end
      for j = 1:bin
        yi = bpos(4)-ycorr-yscale*ymin-in_off/2-in_off*(j-1);
        xi = bpos(1)+xcorr+xscale*xmax;
        [yf,xf] = closerline(yi,xi+5,yl,xl);
        plot3([xi, xf],[yf, yf],[zlevel, zlevel],'k')
      end
      for j = 1:bou
        yi = bpos(4)-ycorr-yscale*ymin-ou_off/2-ou_off*(j-1);
        xi = bpos(1)+xcorr+xscale*xmin;
        [yf,xf] = closerline(yi,xi-5,yl,xl);
        plot3([xi, xf],[yf, yf],[zlevel, zlevel],'k')
      end
     case 'up'
      len = xscale*(xmax-xmin);
      if bin, in_off = len/bin; end
      if bou, ou_off = len/bou; end
      for j = 1:bin
        yi = bpos(4)-ycorr-yscale*ymin;
        xi = bpos(1)+xcorr+xscale*xmin+in_off/2+in_off*(j-1);
        [xf,yf] = closerline(xi,yi+5,xl,yl);
        plot3([xf, xf],[yi, yf],[zlevel, zlevel],'k')
      end
      for j = 1:bou
        yi = bpos(4)-ycorr-yscale*ymax;
        xi = bpos(1)+xcorr+xscale*xmin+ou_off/2+ou_off*(j-1);
        [xf,yf] = closerline(xi,yi-5,xl,yl);
        plot3([xf, xf],[yi, yf],[zlevel, zlevel],'k')
      end
     case 'down'
      len = xscale*(xmax-xmin);
      if bin, in_off = len/bin; end
      if bou, ou_off = len/bou; end
      for j = 1:bin
        yi = bpos(4)-ycorr-yscale*ymax;
        xi = bpos(1)+xcorr+xscale*xmin+in_off/2+in_off*(j-1);
        [xf,yf] = closerline(xi,yi-5,xl,yl);
        plot3([xf, xf],[yi, yf],[zlevel, zlevel],'k')
      end
      for j = 1:bou
        yi = bpos(4)-ycorr-yscale*ymin;
        xi = bpos(1)+xcorr+xscale*xmin+ou_off/2+ou_off*(j-1);
        [xf,yf] = closerline(xi,yi+5,xl,yl);
        plot3([xf, xf],[yi, yf],[zlevel, zlevel],'k')
      end
    end

    for j = 1:length(x)
      z = zlevel*ones(length(x{j}),1);
      xx = bpos(1)+xcorr+xscale*(x{j});
      yy = bpos(4)-yscale*(y{j})-ycorr;
      if ~type
        if ~isempty(xx)
          x_max = max(x_max,max(xx));
          x_min = min(x_min,min(xx));
        end
        if ~isempty(yy)
          y_max = max(y_max,max(yy));
          y_min = min(y_min,min(yy));
        end
      end
      plot3(xx,yy,z,s{j})
    end
    x1 = [xlim]';
    x2 = [ylim]';
    x1mean = 0.5*(x1(1)+x1(2));
    x2mean = 0.5*(x2(1)+x2(2));
    xba = [xb;x1(1);x1(1);x1(2);x1(2);x1mean;x1mean;x1(1);x1(2)];
    yba = [yb;x2(1);x2(2);x2(1);x2(2);x2(1);x2(2);x2mean;x2mean];
    Varout.xb = xba;
    Varout.yb = yba;
  end

  if ~type % draw only one-line diagram
    xframe = 0.05*(x_max-x_min);
    yframe = 0.05*(y_max-y_min);
    set(hdla,'XLim',[x_min-xframe, x_max+xframe],'YLim',[y_min-yframe, y_max+yframe])
    hold off
    return
  end

  x1 = [xlim]';
  x2 = [ylim]';

  switch type
   case 1
    zb = formz(DAE.y(Bus.v),Bus.n);
    if abs(mean(DAE.y(Bus.v))-1) < 1e-3
      zba = [zb; 0.9999*ones(8,1)];
    else
      zba = [zb; ones(8,1)];
    end
   case 2
    zb = formz(180*DAE.y(Bus.a)/pi,Bus.n);
    zba = [zb; mean(180*DAE.y(Bus.a)/pi)*ones(8,1)];
   case 3
    [sij,sji] = flows(Line,3);
    zb = formz(sij,Line.n);
    zba = [zb; mean(sij)*ones(8,1)];
   case 4
    zb = formz(180*DAE.x(Syn.delta)/pi,Syn.n);
    zba = [zb; mean(180*DAE.x(Syn.delta)/pi)*ones(8,1)];
   case 5
    zb = formz(DAE.x(Syn.omega),Syn.n);
    zba = [zb; 0.999*ones(8,1)];
   case 6
    zb = formz(LMP,Bus.n);
    zba = [zb; mean(LMP)*ones(8,1)];
   case 7
    zb = formz(NCP,Bus.n);
    zba = [zb; mean(NCP)*ones(8,1)];
  end
  [XX,YY] = meshgrid(x1(1):5:x1(2),x2(1):5:x2(2));
  if length(zba) > length(Varout.xb)
    zba = zba(1:length(Varout.xb));
  elseif length(zba) < length(Varout.xb)
    zba = [zba, ones(1, length(Varout.xb)-length(zba))];
  end
  ZZ = griddata(Varout.xb,Varout.yb,zba,XX,YY,'cubic');
  if method
    zlevel = Varout.zlevel;
    switch type
     case 1
      for i = 1:Bus.n
        set(Varout.hdl(i),'ZData',[zlevel,DAE.y(Bus.v(i))]);
      end
     case 2
      for i = 1:Bus.n
        set(Varout.hdl(i),'ZData',[zlevel,180*DAE.y(Bus.a(i))/pi]);
      end
     case 3
      [sij,sji] = flows(Line,3);
      for i = 1:Line.n
        set(Varout.hdl(i),'ZData',[zlevel,sij(i)]);
      end
     case 4
      for i = 1:Syn.n
        set(Varout.hdl(i),'ZData',[zlevel,180*DAE.x(Syn.delta(i))/pi]);
      end
     case 5
      for i = 1:Syn.n
        set(Varout.hdl(i),'ZData',[zlevel,zlevel,DAE.x(Syn.omega(i))]);
      end
     case 6
      for i = 1:Bus.n
        set(Varout.hdl(i),'ZData',[zlevel,zlevel,LMP(i)]);
      end
     case 7
      for i = 1:Bus.n
        set(Varout.hdl(i),'ZData',[zlevel,zlevel,NCP(i)]);
      end
    end
    delete(Varout.surf)
    if strcmp(Settings.xlabel,'Loading Parameter \lambda (p.u.)')
      xlabel([Settings.xlabel,' = ',sprintf('%8.4f',DAE.lambda)])
    else
      xlabel([Settings.xlabel,' = ',sprintf('%8.4f',DAE.t)])
    end
    Varout.surf = surf(XX,YY,ZZ);
    alpha(Varout.alpha)
    shading interp
    axis manual
    Varout.movie(end+1) = getframe(findobj(Fig.threed,'Tag','Axes1'));
    %Varout.movie(end+1) = getframe(Fig.threed);
  else
    if type == 1 && Varout.caxis
      caxis([0.9 1.1])
    else
      caxis('auto')
    end
    Varout.surf = surf(XX,YY,ZZ);
    axis auto
    shading interp
    alpha(Varout.alpha)
    xlabel('')
    set(gca,'YDir','reverse')
    set(gca,'XTickLabel',[])
    set(gca,'YTickLabel',[])
    set(gca,'XTick',[])
    set(gca,'YTick',[])
    switch type
     case 1
      zlabel('Voltage Magnitudes [p.u.]')
     case 2
      zlabel('Voltage Angles [deg]')
     case 3
      zlabel('Line Flows [p.u.]')
     case 4
      zlabel('Gen. Rotor Angles [deg]')
     case 5
      zlabel('Gen. Rotor Speeds [p.u.]')
     case 6
      zlabel('Locational Marginal Prices [$/MWh]')
     case 7
      zlabel('Nodal Congestion Prices [$/MWh]')
    end
    colormap(maps{maptype})
    colorbar('EastOutside')
    xlim(x1)
    box on
  end

  hold off

 case 'VoltageReport'

  busidx = find(strcmp(masks,'Bus'));
  for i = 1:Bus.n
    valore = ['|V| = ', ...
              fvar(DAE.y(i+Bus.n),7), ...
              ' p.u.\n<V  = ', ...
              fvar(DAE.y(i),7), ...
              ' rad '];
    set_param(blocks(busidx(i)),'AttributesFormatString',valore);
  end

 case 'WipeVoltageReport'

  busidx = find(strcmp(masks,'Bus'));
  for i = 1:Bus.n,
    set_param(blocks(busidx(i)),'AttributesFormatString','');
  end

 case 'PowerFlowReport'

  simrep(Line, blocks, masks, lines)
  simrep(Hvdc, blocks, masks, lines)
  simrep(Ltc, blocks, masks, lines)
  simrep(Phs, blocks, masks, lines)
  simrep(Lines, blocks, masks, lines)
  simrep(Tg, blocks, masks, lines)
  simrep(Exc, blocks, masks, lines)
  simrep(Oxl, blocks, masks, lines)
  simrep(Pss, blocks, masks, lines)
  simrep(Syn, blocks, masks, lines)
  simrep(PQ, blocks, masks, lines)
  simrep(PV, blocks, masks, lines)
  simrep(SW, blocks, masks, lines)

  %for i = 1:Comp.n
  %  simrep(eval(Comp.names{i},blocks,masks,lines)
  %end

 case 'WipePowerFlowReport'

  for i = 1:length(lines)
    set_param(lines(i),'Name','')
  end

 case 'HideNames'

  nobusidx = find(~strcmp(masks,'Bus'));
  for i = 1:length(nobusidx)
    set_param(blocks(nobusidx(i)),'ShowName','off')
  end
  nobusidx = find(strcmp(masks,''));
  for i = 1:length(nobusidx)
    set_param(blocks(nobusidx(i)),'ShowName','on')
  end

 case 'ShowNames'

  for i = 1:nblock
    set_param(blocks(i),'ShowName','on')
  end

 case 'HideBusNames'

  busidx = find(strcmp(masks,'Bus'));
  for i = 1:Bus.n
    set_param(blocks(busidx(i)),'ShowName','off')
  end

 case 'ShowBusNames'

  busidx = find(strcmp(masks,'Bus'));
  for i = 1:Bus.n
    set_param(blocks(busidx(i)),'ShowName','on')
  end

 case 'FontType'

  for i = 1:nblock
    set_param(blocks(i),'FontName',fontname)
  end
  for i = 1:length(lines)
    set_param(lines(i),'FontName',fontname)
  end

 case 'FontSize'

  for i = 1:nblock,
    set_param(blocks(i),'FontSize',fontsize);
  end
  for i = 1:length(lines),
    set_param(lines(i),'FontSize',fontsize);
  end

 case 'mdl2eps'

  % fontsize == 0:  export to color eps
  % fontsize == 1:  export to grey-scale eps
  grey_eps = fontsize;
  pat = '^/c\d+\s\{.* sr\} bdef';

  cd(Path.data)
  fileeps = [filedata,'.eps'];
  a = dir(fileeps);
  Settings.ok = 1;
  if ~isempty(a)
    uiwait(fm_choice(['Overwrite "',fileeps,'" ?']))
  end
  if ~Settings.ok, return, end
  orient portrait
  print('-s','-depsc',fileeps)

  if ~Settings.noarrows
    cd(Path.local)
    fm_disp(['PSAT model saved in ',Path.data,fileeps])
    return
  end

  file = textread(fileeps,'%s','delimiter','\n');

  idx = [];
  d2 = zeros(1,4);

  for i = 1:length(file)
    if grey_eps && ~isempty(regexp(file{i},pat))
      matchexp = regexp(file{i},'^/c\d+\s\{','match');
      colors = strrep(file{i},matchexp{1},'[');
      colors = regexprep(colors,' sr\} bdef',']');
      rgb = sum(str2num(colors));
      colors = num2str([rgb rgb rgb]/3);
      file{i} = [matchexp{1},colors,' sr} bdef'];
    end
    if strcmp(file{i},'PP')
      if strcmp(file{i-1}(end-1:end),'MP')
        d1 = str2num(strrep(file{i-1},'MP',''));
        if length(d1) >= 6
          if ~d1(3)
            d2(2) = d1(6)-d1(2);
            d2(4) = d1(6)-d1(2);
            d2(1) = d1(5)-d1(2);
            d2(3) = d1(5)+d1(1);
          else
            d2(2) = d1(6)+d1(2);
            d2(4) = d1(6)-d1(1);
            d2(1) = d1(5)-d1(1);
            d2(3) = d1(5)-d1(1);
          end
          file{i-1} = sprintf('%4d %4d mt %4d %4d L',d2);
          idx = [idx, i];
        end
      end
    end
    if ~isempty(findstr(file{i}(max(1,end-1):end),'PO'))
      d1 = str2num(strrep(file{i},'PO',''));
      if ~isempty(findstr(file{i+1},'L'))
        nextline = strrep(file{i+1},'L','');
        d2 = str2num(strrep(nextline,'mt',''));
        if d1(4) == d2(2)
          if d2(1) > d1(3);
            d2(1) = d1(3)-d1(1);
          else
            d2(1) = d2(1)+d1(1)+abs(d1(3)-d2(1));
          end
        else
          if d2(2) > d1(4)
            d2(2) = d1(4)-d1(2);
          else
            d2(2) = d2(2)+d1(2)+abs(d1(4)-d2(2));
          end
        end
        file{i+1} = sprintf('%4d %4d mt %4d %4d L',d2);
      elseif ~isempty(findstr(file{i+2},'MP stroke'))
        d2 = str2num(strrep(file{i+2},'MP stroke',''));
        if d2(1)
          d2(3) = d2(3)-d2(1);
          if d2(1) < 0
            d2(3) = d2(3) - 4;
          end
        end
        if d2(2)
          d2(4) = d2(4)-d2(2);
          if d2(2) < 0
            d2(4) = d2(4) - 4;
          end
        end
        file{i+1} = sprintf('%4d %4d %4d %4d %4d MP stroke',d2);
      end
      idx = [idx, i];
    end
  end

  file(idx) = [];

  fid = fopen(fileeps,'wt+');
  for i = 1:length(file)
    fprintf(fid,'%s\n',file{i});
  end
  fclose(fid);
  cd(Path.local)
  fm_disp(['PSAT model saved in ',Path.data,fileeps])

 otherwise

  fm_disp('Unknown command for Simulink Settings GUI...',2)

end

cd(Path.local)

% -------------------------------------------------------------------------
function [xa,ya] = closerline(xa,ya,xl,yl)

[err,idx] = min(abs(sqrt((xl-xa).^2+(yl-ya).^2)));
if err < 15
  xa = xl(idx);
  ya = yl(idx);
end

% -------------------------------------------------------------------------
function zb = formz(vec,n)

zb = zeros(3*n,1);
zb(1:3:3*n) = vec;
zb(2:3:3*n) = vec;
zb(3:3:3*n) = vec;