function fm_omib
%FM_OMIB computes the equivalent OMIB for a multimachine network and its
%        transient stability margin.
%
% see also FM_INT and FM_CONNECTIVITY
%
%Author:    Sergio Mora & Federico Milano
%Date:      July 2006
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2006 Segio Mora & Federico Milano

global OMIB Line Bus Syn DAE jay

% -------------------------------------------------------------------------
% initial conditions
% -------------------------------------------------------------------------

[gen,ib] = setdiff(getbus(Syn),Bus.island);
Pm = getvar(Syn,ib,'pm');
ang = getvar(Syn,ib,'delta');
omega = getvar(Syn,ib,'omega');
M = getvar(Syn,ib,'M');

to = 0;
do = sum(M.*ang)/sum(M);
wo = sum(M.*omega)/sum(M)-1;
E = getvar(Syn,ib,'e1q');
dt = 0.005;

ngen = length(ib);
ygen = -jay./getvar(Syn,ib,'xd1');
bgen = getbus(Syn,ib);
bus0 = [1:ngen]';
nbus = Bus.n + ngen;

Y11 = sparse(bus0, bus0,  ygen, ngen, ngen);
Y21 = sparse(bgen, bus0, -ygen, Bus.n, ngen);
Y12 = sparse(bus0, bgen, -ygen, ngen, Bus.n);

Yint = Y11 - Y12*[Line.Y\Y21];

% -------------------------------------------------------------------------
% sorting of rotor angles
% -------------------------------------------------------------------------

[delta,pos] = sort(ang);
difangle = delta(2:ngen) - delta(1:ngen-1);
[difmax,idxmax] = sort(difangle,1,'descend');

m = 1;
i = 1;

while (m <= 5) && (m <= fix(ngen/2))
  % select the m-th critical machine candidate
  cm = pos((idxmax(m)+1):ngen);
  ncm = pos(1:idxmax(m));
  if ~isempty(cm)
    % compute the m-th equivalent OMIB
    data = equiv_omib(M,Pm,cm,ncm,Yint,E);
    % compute the critical clearing time
    [du,tu,margen] = critical_time(data,dt,to,do,wo);
    CMvec{i} = cm;
    NCMvec{i} = ncm;
    MT(i) = data(1);
    Pmax(i) = data(2);
    sig(i) = data(3);
    PM(i) = data(4);
    Pc(i) = data(5);
    dif(i) = difmax(m);
    DU(:,i) = du;
    TU(:,i) = tu;
    MAR(:,i) = margen;
    i = i + 1;
  end
  m = m + 1;
end

[mcri,i] = min(MAR);

OMIB.cm = CMvec{i};
OMIB.ncm = NCMvec{i};
OMIB.mt = MT(i);
OMIB.pmax = Pmax(i);
OMIB.pc = Pc(i);
OMIB.sig = sig(i);
OMIB.du = DU(i);
OMIB.tu = TU(i);
OMIB.margin = MAR(i);

% -------------------------------------------------------------------------
function data = equiv_omib(M,Pm,cm,ncm,Y,E)

Mc = sum(M(cm));
Mn = sum(M(ncm));
Pc = (Mn*([E(cm)]'*[real(Y(cm,cm))*E(cm)]) - ...
      Mc*([E(ncm)]'*[real(Y(ncm,ncm))*E(ncm)]))/(Mc+Mn);
PM = (Mn*sum(Pm(cm))-Mc*sum(Pm(ncm)))/(Mc+Mn);
M = (Mc*Mn)/(Mc+Mn);

EE = [E(cm)]'*[Y(cm,ncm)*E(ncm)];

V = ((Mc-Mn)*real(EE))/(Mc+Mn)+j*imag(EE);
sig = -angle(V);
Pmax = abs(V);
data = [M,Pmax,sig,PM,Pc];
disp(data)

% -------------------------------------------------------------------------
function [deltau,omegau,margin] = critical_time(data,dt,to,delta0,omega0)

global Settings

Wb = 2*pi*Settings.freq;
iter_max = Settings.dynmit;
tol = Settings.dyntol;

%Pgen = inline('d(5)+d(2)*sin(delta-d(3))','d','delta');
t = 0;
tu = inf;
deltau = inf;
omegau = inf;

Mt = data(1);
Pmax = data(2);
d0 = data(3);
Pm = data(4);
Pc = data(5);
Pe_old = Pc + Pmax*sin(delta0-d0);
Pa_old = Pm - Pe_old;

f = zeros(2,1);
f(1) = Wb*omega0;
f(2) = Pa_old/Mt;
fn = f;
x = [delta0; omega0];
xa = x;
inc = ones(2,1);

k = 0;

while k < 200

  inc(1) = 1;
  h = 0;
  while max(abs(inc)) > tol
    if (h > iter_max), break,  end
    f(1) = Wb*x(2);
    f(2) = (Pm - Pc - Pmax*sin(x(1)-d0))/Mt;
    tn = x - xa - 0.5*dt*(f+fn);
    inc(1) =  tn(2)/(Pmax*cos(x(1)-d0));
    inc(2) = -tn(1)/Wb;
    x = x + inc;
    h = h + 1;
    disp([h, x(1), x(2), inc(1), inc(2), f(1), f(2)])
    pause
  end

  Pe = Pc + Pmax*sin(x(1)-d0);
  Pa = Pm - Pe;

  if (Pe_old > Pm) && (Pe < Pm) && ((Pa-Pa_old) > 0)
    deltau = 0.5*(x(1) + xa(1)); % instability condition
    omegau = 0.5*(x(2) + xa(2));
    tu = t - dt/2;
    break
  end

  if (Pa < 0) && (xa(2) > 0) && (x(2) < 0)
    deltau = 0.5*(x(1) + xa(1)); % stability condition
    omegau = 0.5*(x(2) + xa(2));
    tu = t - dt/2;
    break
  end

  xa = x;
  fn = f;
  k = k + 1;
  t = t + dt;

end
margin = -0.5*Mt*omegau*omegau;