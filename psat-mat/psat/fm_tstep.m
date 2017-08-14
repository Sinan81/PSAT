function h = fm_tstep(flag, convergency, iteration,t)
% FM_TSTEP determine the time step during time domain
%          simulations
%
% H = FM_TSTEP(FLAG,CONV,ITER,T)
%       FLAG: 1 - initialized time step and fix maximum time
%                 step
%             2 - check time step and change it if necessary
%       CONV: 1 - last time step computation converged
%             0 - last time step computation did not converge
%       ITER: number of iterations needed for getting the
%             convergence of the last time step computation
%       T:    actual time
%       H:    new time step
%
%see also FM_INT
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    07-Mar-2004
%Version:   1.1.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global DAE Settings Fault

switch flag
 case 1

  % estimate the minimum time step
  if DAE.n == 0
    freq = 1;
  elseif DAE.n == 1,
    As = DAE.Fx - DAE.Fy*(DAE.Gy\DAE.Gx);
    freq = abs(As);
  else,
    try
      opts.disp = 0;
      if DAE.n <= 6
        freq = max(abs(eig(full(DAE.Fx))));
      else
        freq = max(abs(eigs(DAE.Fx,nfreq,'LI',opts)));
      end
    catch
      freq = 40;
    end
    if freq > Settings.freq,
      freq = Settings.freq;
    end
  end

  if freq == 0, freq = 40; end

  % set the minimum time step
  deltaT = abs(Settings.tf-Settings.t0);
  Tstep = 1/freq;
  Settings.deltatmax = min(5*Tstep,deltaT/100);
  Settings.chunk = 100;
  Settings.deltat = min(Tstep,deltaT/100);
  Settings.deltatmin = min(Tstep/64,Settings.deltatmax/20);
  if Settings.fixt
    if Settings.tstep < 0
      fm_disp('Error: fixed time step is negative or zero',2)
      fm_disp('Automatic time step has been set',1)
      Settings.fixt = 0;
    elseif Settings.tstep < Settings.deltatmin
      fm_disp('Warning: fixed time step is less than estimated minimum time step',2)
      Settings.deltat = Settings.tstep;
    else
      Settings.deltat = Settings.tstep;
    end
  end

 case 2

  % check time step
  switch convergency
   case 1,  % should we change the time step?
    if iteration >= 15,
      Settings.deltat = max(Settings.deltat*0.9,Settings.deltatmin);
    end
    if iteration <= 10,
      Settings.deltat = min(Settings.deltat*1.3,Settings.deltatmax);
    end
    if Settings.fixt,
      Settings.deltat = min(Settings.tstep,Settings.deltat);
    end
   case 0,  % bisecting time step if no convergence
    Settings.deltat = Settings.deltat*0.5;
    if Settings.deltat < Settings.deltatmin;
      Settings.deltat = 0;
    end
  end

  % check fault occurrencies
  if istime(Fault,t)
    Settings.deltat = min(Settings.deltat,0.0025);
  end

end

h = Settings.deltat;