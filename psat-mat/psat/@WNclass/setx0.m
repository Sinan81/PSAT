function a = setx0(a)

global DAE Settings Cswt Ddsg Dfig

if ~a.n, return, end

check = 1;

% initialize average wind speed
a.vwa = DAE.x(a.vw);
DAE.y(a.ws) = DAE.x(a.vw);

% be sure that each wind turbine is associated with a single wind speed
wind_idx = [Cswt.wind.*Cswt.u; 
            Dfig.wind.*Dfig.u;
            Ddsg.wind.*Ddsg.u];
wind_uni = unique(wind_idx);
if length(wind_idx) ~= length(wind_uni)
  check = 0;
  for idx = 1:length(wind_uni)
    nwind = length(find(wind_idx == wind_uni(idx)));
    if nwind > 1
      fm_disp(['Error: Wind <', num2str(idx), '> is associated with more than one wind turbine.'])
    end
  end
end

for i = 1:a.n
  t0 = Settings.t0;
  tf = Settings.tf;
  dt = a.con(i,5);
  a.speed(i).time = [t0:dt:tf]';
  type = a.con(i,1);
  
  switch type
    
   case 1 % resample data in case of measurement data
    
    if ~isfield(a.speed,'vw')
      a.speed.vw = [];
    end
    if ~isempty(a.speed(i).vw)
      told = a.speed(i).vw(:,1);
      vold = a.speed(i).vw(:,2);
      a.speed(i).vw = interp1(told,vold,a.speed(i).time)/a.con(i,2);
      a.speed(i).vw(1) = a.vwa(i);
    else % if no data is found, Weibull distribution is used
      n = length(a.speed(i).time);
      c = a.con(i,6);
      if c <= 0, c = 5; end
      k = a.con(i,7);
      if k <= 0, k = 2; end
      a.speed(i).vw = (-log(rand(n,1))/c).^(1/k);
      % set average wind speed as initial wind speed
      mean_vw = mean(a.speed(i).vw);
      a.speed(i).vw(1) = a.vwa(i);
      a.speed(i).vw(2:end) = abs(1+a.speed(i).vw(2:end)-mean_vw)*a.vwa(i);
    end
    
   case 2 % Weibull random distribution
    
    n = length(a.speed(i).time);
    c = a.con(i,6);
    if c <= 0, c = 5; end
    k = a.con(i,7);
    if k <= 0, k = 2; end
    a.speed(i).vw = (-log(rand(n,1))/c).^(1/k);
    % set average wind speed as initial wind speed
    mean_vw = mean(a.speed(i).vw);
    a.speed(i).vw(1) = a.vwa(i);
    a.speed(i).vw(2:end) = abs(1+a.speed(i).vw(2:end)-mean_vw)*a.vwa(i);

   case 4 % Mexican hat wavelet model
    
    n = length(a.speed(i).time);
    % average wind speed
    vwa = a.vwa(i);
    vwg = a.con(i,13)/a.con(i,2);
    x = ((a.speed(i).time - a.con(i,18)).^2)/a.con(i,19)/a.con(i,19);
    a.speed(i).vw = vwa + (vwg - vwa)*(1 - x).*exp(-0.5*x);
    
   case 3 % Composite wind model
    
    n = length(a.speed(i).time);
    % average wind speed
    vwa = a.vwa(i);
    
    % wind ramp
    Tsr = a.con(i,8);
    Ter = a.con(i,9);
    Awr = a.con(i,10);
    if Tsr > Ter
      fm_disp(['Start ramp time Tsr cannot be greater than end ramp ' ...
               'time Ter'],2)
      fm_disp('Ter = Tsr + 10s will be used.')
      Ter = Tsr + 10;
    end
    vwr = zeros(n,1);
    idxmax = find(a.speed(i).time > Ter);
    if ~isempty(idxmax)
      vwr(idxmax) = Awr;
    end
    idxramp = find(a.speed(i).time <= Ter & ...
                   a.speed(i).time >= Tsr);
    if ~isempty(idxramp)
      vwr(idxramp) = Awr*(a.speed(i).time(idxramp)-Tsr)/(Ter-Tsr);
    end
    
    % wind gust
    Tsg = a.con(i,11);
    Teg = a.con(i,12);
    Awg = a.con(i,13);
    if Tsg > Teg
      fm_disp(['Start gust time Tsg cannot be greater than end gust ' ...
               'time Teg'],2)
      fm_disp('Teg = Tsg + 10s will be used.')
      Teg = Tsg + 10;
    end
    vwg = zeros(n,1);
    idxmax = find(a.speed(i).time > Teg);
    if ~isempty(idxmax)
      vwg(idxmax) = Awg;
    end
    idxgust = find(a.speed(i).time <= Teg & ...
                   a.speed(i).time >= Tsg);
    if ~isempty(idxgust)
      vwg(idxgust) = 0.5*Awg*(1-cos(2*pi*(a.speed(i).time(idxgust)-Tsr)/(Ter-Tsr)));
    end
    
    % wind turbolence
    h  = a.con(i,14);
    z0 = a.con(i,15);
    df = a.con(i,16);
    nh = round(a.con(i,17));
    if h < 30
      el = 20*h;
    else
      el = 600;
    end
    f = 0;
    vwt = zeros(n,1);
    for hh = 1:nh
      f = f + df;
      phi = 2*pi*rand;
      Swt = (el*vwa/(log(h/z0))^2)/(1+1.5*f*el/vwa)^(5/3);
      vwt = vwt + sqrt(Swt*df)*cos(2*pi*a.speed(i).time*f+phi+0.05*pi*rand(n,1));
    end
    
    % composite wind
    a.speed(i).vw = vwa + vwr + vwg + vwt;
    a.speed(i).vw(1) = vwa;
    
  end
  
end

if ~check
  fm_disp('Winds cannot be properly initialized.')
else
  fm_disp('Initialization of Winds completed.')  
end

