function varargout = fjh2(p,type,varargin)
% FJH2 compute the square of current, active power and apparent 
%      power flows of transmission lines and the associated 
%      Jacobian and Hessian matrices
%
% Synthax:
%
%                  [FIJ,FJI] = FJH2(LINE,TYPE)
%          [FIJ,JIJ,FJI,JJI] = FJH2(LINE,TYPE)
%  [FIJ,JIJ,HIJ,FJI,JJI,HJI] = FJH2(LINE,TYPE)
%  [FIJ,JIJ,HIJ,FJI,JJI,HJI] = FJH2(LINE,TYPE,MU1,MU2)
%
% TYPE -> type of flows computations: (1) square current flows
%                                     (2) square active power flows
%                                     (3) square apparent power flows
%
% MU1 -> column vector (Line.n,1) of Lagrangian multipliers for (i->j)
% MU2 -> column vector (Line.n,1) of Lagrangian multipliers for (j->i)
%
% FIJ -> column vector (Line.n,1) of flows from bus "i" to bus "j"
% JIJ -> Jacobian matrix (Line.n,Bus.n) from bus "i" to bus "j"
% HIJ -> Hessian matrix (Bus.n,Bus.n) from bus "i" to bus "j"
%
% FJI -> column vector (Line.n,1) of flows from bus "j" to bus "i"
% JJI -> Jacobian matrix (Line.n,Bus.n) from bus "j" to bus "i"
% HJI -> Hessian matrix (Bus.n,Bus.n) from bus "j" to bus "i"
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Version:   1.0.0
%
%E-mail:    fmilano@thunderbox.uwaterloo.ca
%Web-site:  http://thunderbox.uwaterloo.ca/~fmilano
%
% Copyright (C) 2002-2007 Federico Milano

global Bus DAE jay

% ==========================================================================
% line flow solution
% ==========================================================================

tps = p.con(:,11).*exp(jay*p.con(:,12)*pi/180);
Vfr = DAE.y(p.vfr).*exp(jay*DAE.y(p.fr));
Vto = DAE.y(p.vto).*exp(jay*DAE.y(p.to));
r = p.con(:,8);
x = p.con(:,9);
chrg = p.u.*p.con(:,10)/2;
z = r + jay*x;
y = p.u./z;
g = real(y);
b = imag(y);
nl = [1:p.n];
nb = Bus.n;

if nargout == 6
  if nargin == 2
    mu1 = ones(p.n,1);
    mu2 = ones(p.n,1);
  else
    mu1 = varargin{1};
    mu2 = varargin{2};  
  end
end

switch type
 case 1

  % ========================================================================
  % AC Current Flows, Jacobian and Hessian
  % ========================================================================

  Vi = DAE.y(p.vfr);
  Vj = DAE.y(p.vto);
  ti = DAE.y(p.fr);
  tj = DAE.y(p.to);
  b0 = p.u.*p.con(:,10)/2;
  yij = abs(y);
  fij = angle(y);
  m = p.con(:,11);
  a = p.con(:,12)*pi/180;
  ki = abs(y+i*b0).^2;
  kj = abs(y.*m.*m+i*b0).^2;
  Vij = Vi.*Vj;
  y2 = yij.*yij;
  m2 = m.*m;
  m3 = m2.*m;
  k1 = 2*yij.*m.*b0;
  k2 = k1.*m2;
  k3 = 2*y2.*m;
  k4 = k3.*m2;
  k5 = m2.*y2;
  cij = cos(ti-tj-a);
  sij = sin(ti-tj-a);
  sfij = sin(ti-tj-fij-a);
  cfij = cos(ti-tj-fij-a);
  sfji = sin(tj-ti-fij+a);
  cfji = cos(tj-ti-fij+a);
  
  Fij = Vi.*Vi.*ki + Vj.*Vj.*k5 - Vij.*k3.*cij + Vij.*k1.*sfij;
  Fji = Vj.*Vj.*kj + Vi.*Vi.*k5 - Vij.*k4.*cij + Vij.*k2.*sfji;
  
  if nargout == 2
    varargout{1} = Fij;
    varargout{2} = Fji;
    return
  end
  
  Jij = [sparse(nl,p.fr, Vij.*k3.*sij + Vij.*k1.*cfij,p.n,nb) + ...
         sparse(nl,p.to,-Vij.*k3.*sij - Vij.*k1.*cfij,p.n,nb), ...
         sparse(nl,p.fr, 2*Vi.*ki - Vj.*k3.*cij + Vj.*k1.*sfij,p.n,nb) + ...
         sparse(nl,p.to, 2*Vj.*k5 - Vi.*k3.*cij + Vi.*k1.*sfij,p.n,nb)];
  Jji = [sparse(nl,p.fr, Vij.*k4.*sij - Vij.*k2.*cfji,p.n,nb) + ...
         sparse(nl,p.to,-Vij.*k4.*sij + Vij.*k2.*cfji,p.n,nb), ...
         sparse(nl,p.fr, 2*Vi.*k5 - Vj.*k4.*cij + Vj.*k2.*sfji,p.n,nb) + ...
         sparse(nl,p.to, 2*Vj.*kj - Vi.*k4.*cij + Vi.*k2.*sfji,p.n,nb)];

  if nargout == 4
    varargout{1} = Fij;
    varargout{2} = Jij;
    varargout{3} = Fji;
    varargout{4} = Jji;
    return
  end

  a1 = mu1.*(Vij.*k3.*cij - Vij.*k1.*sfij);
  a2 = mu1.*(Vj.*k3.*sij + Vj.*k1.*cfij);
  a3 = mu1.*(Vi.*k3.*sij + Vi.*k1.*cfij);
  a4 = 2*mu1.*ki;
  a5 = mu1.*(-k3.*cij + k1.*sfij);
  a6 = 2*mu1.*k5;

  Hij = [sparse(p.fr, p.fr, a1, nb, nb) + ...
         sparse(p.fr, p.to,-a1, nb, nb) + ...
         sparse(p.to, p.fr,-a1, nb, nb) + ...
         sparse(p.to, p.to, a1, nb, nb), ...
         sparse(p.fr, p.fr, a2, nb, nb) + ...
         sparse(p.fr, p.to, a3, nb, nb) + ...
         sparse(p.to, p.fr,-a2, nb, nb) + ...
         sparse(p.to, p.to,-a3, nb, nb); ...
         sparse(p.fr, p.fr, a2, nb, nb) + ...
         sparse(p.fr, p.to,-a2, nb, nb) + ...
         sparse(p.to, p.fr, a3, nb, nb) + ...
         sparse(p.to, p.to,-a3, nb, nb), ...
         sparse(p.fr, p.fr, a4, nb, nb) + ...
         sparse(p.fr, p.to, a5, nb, nb) + ...
         sparse(p.to, p.fr, a5, nb, nb) + ...
         sparse(p.to, p.to, a6, nb, nb)];

  a1 = mu2.*(-Vij.*k4.*cij + Vij.*k2.*sfji);
  a2 = mu2.*( Vj.*k4.*sij - Vj.*k2.*cfji);
  a3 = mu2.*( Vi.*k4.*sij - Vi.*k2.*cfji);
  a4 = 2*mu2.*k5;
  a5 = mu2.*(-k4.*cij + k2.*sfji);
  a6 = 2*mu2.*kj;

  Hji = [sparse(p.fr, p.fr, a1, nb, nb) + ...
         sparse(p.fr, p.to,-a1, nb, nb) + ...
         sparse(p.to, p.fr,-a1, nb, nb) + ...
         sparse(p.to, p.to, a1, nb, nb), ...
         sparse(p.fr, p.fr, a2, nb, nb) + ...
         sparse(p.fr, p.to, a3, nb, nb) + ...
         sparse(p.to, p.fr,-a2, nb, nb) + ...
         sparse(p.to, p.to,-a3, nb, nb); ...
         sparse(p.fr, p.fr, a2, nb, nb) + ...
         sparse(p.fr, p.to,-a2, nb, nb) + ...
         sparse(p.to, p.fr, a3, nb, nb) + ...
         sparse(p.to, p.to,-a3, nb, nb), ...
         sparse(p.fr, p.fr, a4, nb, nb) + ...
         sparse(p.fr, p.to, a5, nb, nb) + ...
         sparse(p.to, p.fr, a5, nb, nb) + ...
         sparse(p.to, p.to, a6, nb, nb)];

  if nargout == 6
    varargout{1} = Fij;
    varargout{2} = Jij;
    varargout{3} = Hij;
    varargout{4} = Fji;
    varargout{5} = Jji;
    varargout{6} = Hji;
  end

 case 2

  % ========================================================================
  % AC active power flows in each line from bus i to bus j
  % ========================================================================

  Vi = DAE.y(p.vfr);
  Vj = DAE.y(p.vto);
  ti = DAE.y(p.fr);
  tj = DAE.y(p.to);
  yij = abs(y);
  fij = angle(y);
  m = p.con(:,11);
  a = p.con(:,12)*pi/180;
  y2 = yij.*yij;
  m2 = m.*m;
  ki = y2.*cos(fij).*cos(fij);
  kj = ki.*m2.*m2;
  Vij = Vi.*Vj;
  Vi2 = Vi.*Vi;
  Vj2 = Vj.*Vj;
  m3 = m2.*m;
  k1 = 2*y2.*m.*cos(fij);
  k2 = k1.*m2;
  k5 = m2.*y2;
  cij = cos(ti-tj-a);
  sij = sin(ti-tj-a);
  sfij = sin(ti-tj-fij-a);
  cfij = cos(ti-tj-fij-a);
  sfji = sin(tj-ti-fij+a);
  cfji = cos(tj-ti-fij+a);

  Fij = Vi2.*(Vi2.*ki + Vj2.*k5.*cfij.*cfij - Vij.*k1.*cfij);
  Fji = Vj2.*(Vj2.*kj + Vi2.*k5.*cfji.*cfji - Vij.*k2.*cfji);
  
  if nargout == 2
    varargout{1} = Fij;
    varargout{2} = Fji;
    return
  end

  Jij = [sparse(nl,p.fr, Vi2.*(-2*Vj2.*k5.*cfij.*sfij + Vij.*k1.*sfij),p.n,nb) + ...
         sparse(nl,p.to, Vi2.*( 2*Vj2.*k5.*cfij.*sfij - Vij.*k1.*sfij),p.n,nb), ...
         sparse(nl,p.fr, 4*Vi.*Vi2.*ki + 2*Vi.*Vj2.*k5.*cfij.*cfij - 3.*Vi.*Vij.*k1.*cfij,p.n,nb) + ...
         sparse(nl,p.to, 2*Vi2.*Vj.*k5.*cfij.*cfij - Vi2.*Vi.*k1.*cfij,p.n,nb)];
  Jji = [sparse(nl,p.fr, Vj2.*(-2*Vi2.*k5.*cfji.*sfji + Vij.*k2.*sfji),p.n,nb) + ...
         sparse(nl,p.to, Vj2.*( 2*Vi2.*k5.*cfji.*sfji - Vij.*k2.*sfji),p.n,nb), ...
         sparse(nl,p.fr, 2*Vj2.*Vi.*k5.*cfji.*cfji - Vj2.*Vj.*k2.*cfji,p.n,nb) + ...
         sparse(nl,p.to, 4*Vj.*Vj2.*kj + 2*Vj.*Vi2.*k5.*cfji.*cfji - 3*Vj.*Vij.*k2.*cfji,p.n,nb)];
  
  if nargout == 4
    varargout{1} = Fij;
    varargout{2} = Jij;
    varargout{3} = Fji;
    varargout{4} = Jji;
    return
  end

  a1 = mu1.*Vi2.*(-2*Vj2.*k5.*cos(2*(ti-tj-fij-a)) + Vij.*k1.*cfij);
  a2 = mu1.*(-4*Vi.*Vj2.*k5.*cfij.*sfij + 3.*Vi.*Vij.*k1.*sfij);
  a3 = mu1.*(-4*Vi2.*Vj.*k5.*cfij.*sfij + Vi2.*Vi.*k1.*sfij);
  a4 = mu1.*(12*Vi2.*ki + 2*Vj2.*k5.*cfij.*cfij - 6.*Vij.*k1.*cfij);
  a5 = mu1.*(4*Vij.*k5.*cfij.*cfij - 3*Vi2.*k1.*cfij);
  a6 = 2*mu1.*Vi2.*k5.*cfij.*cfij;

  Hij = [sparse(p.fr, p.fr, a1, nb, nb) + ...
         sparse(p.fr, p.to,-a1, nb, nb) + ...
         sparse(p.to, p.fr,-a1, nb, nb) + ...
         sparse(p.to, p.to, a1, nb, nb), ...
         sparse(p.fr, p.fr, a2, nb, nb) + ...
         sparse(p.fr, p.to, a3, nb, nb) + ...
         sparse(p.to, p.fr,-a2, nb, nb) + ...
         sparse(p.to, p.to,-a3, nb, nb); ...
         sparse(p.fr, p.fr, a2, nb, nb) + ...
         sparse(p.fr, p.to,-a2, nb, nb) + ...
         sparse(p.to, p.fr, a3, nb, nb) + ...
         sparse(p.to, p.to,-a3, nb, nb), ...
         sparse(p.fr, p.fr, a4, nb, nb) + ...
         sparse(p.fr, p.to, a5, nb, nb) + ...
         sparse(p.to, p.fr, a5, nb, nb) + ...
         sparse(p.to, p.to, a6, nb, nb)];

  a1 = mu2.*Vj2.*(-2*Vi2.*k5.*cos(2*(tj-ti-fij+a)) + Vij.*k2.*cfji);
  a2 = mu2.*(-4*Vj2.*Vi.*k5.*cfji.*sfji + Vj2.*Vj.*k2.*sfji);
  a3 = mu2.*(-4*Vj.*Vi2.*k5.*cfji.*sfji + 3*Vj.*Vij.*k2.*sfji);
  a4 = 2*mu2.*Vj2.*k5.*cfji.*cfji;
  a5 = mu2.*(4*Vij.*k5.*cfji.*cfji - 3*Vj2.*k2.*cfji);
  a6 = mu2.*(12*Vj2.*kj + 2*Vi2.*k5.*cfji.*cfji - 6*Vij.*k2.*cfji);

  Hji = [sparse(p.fr, p.fr, a1, nb, nb) + ...
         sparse(p.fr, p.to,-a1, nb, nb) + ...
         sparse(p.to, p.fr,-a1, nb, nb) + ...
         sparse(p.to, p.to, a1, nb, nb), ...
         sparse(p.fr, p.fr, a2, nb, nb) + ...
         sparse(p.fr, p.to, a3, nb, nb) + ...
         sparse(p.to, p.fr,-a2, nb, nb) + ...
         sparse(p.to, p.to,-a3, nb, nb); ...
         sparse(p.fr, p.fr, a2, nb, nb) + ...
         sparse(p.fr, p.to,-a2, nb, nb) + ...
         sparse(p.to, p.fr, a3, nb, nb) + ...
         sparse(p.to, p.to,-a3, nb, nb), ...
         sparse(p.fr, p.fr, a4, nb, nb) + ...
         sparse(p.fr, p.to, a5, nb, nb) + ...
         sparse(p.to, p.fr, a5, nb, nb) + ...
         sparse(p.to, p.to, a6, nb, nb)];

  if nargout == 6
    varargout{1} = Fij;
    varargout{2} = Jij;
    varargout{3} = Hij;
    varargout{4} = Fji;
    varargout{5} = Jji;
    varargout{6} = Hji;
  end

 case 3

  % ========================================================================
  % AC apparent power flows
  % ========================================================================

  Vi = DAE.y(p.vfr);
  Vj = DAE.y(p.vto);
  ti = DAE.y(p.fr);
  tj = DAE.y(p.to);
  b0 = p.u.*p.con(:,10)/2;
  yij = abs(y);
  fij = angle(y);
  m = p.con(:,11);
  a = p.con(:,12)*pi/180;
  ki = abs(y+i*b0).^2;
  kj = abs(y.*m.*m+i*b0).^2;
  Vij = Vi.*Vj;
  Vi2 = Vi.*Vi;
  Vj2 = Vj.*Vj;
  y2 = yij.*yij;
  m2 = m.*m;
  m3 = m2.*m;
  k1 = 2*yij.*m.*b0;
  k2 = k1.*m2;
  k3 = 2*y2.*m;
  k4 = k3.*m2;
  k5 = m2.*y2;
  cij = cos(ti-tj-a);
  sij = sin(ti-tj-a);
  sfij = sin(ti-tj-fij-a);
  cfij = cos(ti-tj-fij-a);
  sfji = sin(tj-ti-fij+a);
  cfji = cos(tj-ti-fij+a);
  
  Fij = Vi2.*(Vi2.*ki + Vj2.*k5 - Vij.*k3.*cij + Vij.*k1.*sfij);
  Fji = Vj2.*(Vj2.*kj + Vi2.*k5 - Vij.*k4.*cij + Vij.*k2.*sfji);
  
  if nargout == 2
    varargout{1} = Fij;
    varargout{2} = Fji;
    return
  end
  
  Jij = [sparse(nl,p.fr, Vi2.*Vij.*k3.*sij + Vi2.*Vij.*k1.*cfij,p.n,nb) + ...
         sparse(nl,p.to,-Vi2.*Vij.*k3.*sij - Vi2.*Vij.*k1.*cfij,p.n,nb), ...
         sparse(nl,p.fr, 4*Vi2.*Vi.*ki + 2*Vi.*Vj2.*k5 - 3*Vi2.*Vj.*k3.*cij + 3*Vi2.*Vj.*k1.*sfij,p.n,nb) + ...
         sparse(nl,p.to, 2*Vi2.*Vj.*k5 - Vi2.*Vi.*k3.*cij + Vi2.*Vi.*k1.*sfij,p.n,nb)];
  Jji = [sparse(nl,p.fr, Vj2.*Vij.*k4.*sij - Vj2.*Vij.*k2.*cfji,p.n,nb) + ...
         sparse(nl,p.to,-Vj2.*Vij.*k4.*sij + Vj2.*Vij.*k2.*cfji,p.n,nb), ...
         sparse(nl,p.fr, 2*Vj2.*Vi.*k5 - Vj2.*Vj.*k4.*cij + Vj2.*Vj.*k2.*sfji,p.n,nb) + ...
         sparse(nl,p.to, 4*Vj2.*Vj.*kj + 2*Vj.*Vi2.*k5 - 3*Vj2.*Vi.*k4.*cij + 3*Vj2.*Vi.*k2.*sfji,p.n,nb)];

  if nargout == 4
    varargout{1} = Fij;
    varargout{2} = Jij;
    varargout{3} = Fji;
    varargout{4} = Jji;
    return
  end

  a1 = mu1.*Vi2.*(Vij.*k3.*cij - Vij.*k1.*sfij);
  a2 = mu1.*(3*Vi2.*Vj.*k3.*sij + 3*Vi2.*Vj.*k1.*cfij);
  a3 = mu1.*(Vi2.*Vi.*k3.*sij + Vi2.*Vi.*k1.*cfij);
  a4 = mu1.*(12*Vi2.*ki + 2*Vj2.*k5 - 6*Vij.*k3.*cij + 6*Vij.*k1.*sfij);
  a5 = mu1.*(4*Vij.*k5 - 3*Vi2.*k3.*cij + 3*Vi2.*k1.*sfij);
  a6 = 2*Vi2.*mu1.*k5;

  Hij = [sparse(p.fr, p.fr, a1, nb, nb) + ...
         sparse(p.fr, p.to,-a1, nb, nb) + ...
         sparse(p.to, p.fr,-a1, nb, nb) + ...
         sparse(p.to, p.to, a1, nb, nb), ...
         sparse(p.fr, p.fr, a2, nb, nb) + ...
         sparse(p.fr, p.to, a3, nb, nb) + ...
         sparse(p.to, p.fr,-a2, nb, nb) + ...
         sparse(p.to, p.to,-a3, nb, nb); ...
         sparse(p.fr, p.fr, a2, nb, nb) + ...
         sparse(p.fr, p.to,-a2, nb, nb) + ...
         sparse(p.to, p.fr, a3, nb, nb) + ...
         sparse(p.to, p.to,-a3, nb, nb), ...
         sparse(p.fr, p.fr, a4, nb, nb) + ...
         sparse(p.fr, p.to, a5, nb, nb) + ...
         sparse(p.to, p.fr, a5, nb, nb) + ...
         sparse(p.to, p.to, a6, nb, nb)];

  a1 = mu2.*Vj2.*(-Vij.*k4.*cij + Vij.*k2.*sfji);
  a2 = mu2.*( Vj2.*Vj.*k4.*sij - Vj2.*Vj.*k2.*cfji);
  a3 = mu2.*( 3*Vj2.*Vi.*k4.*sij - 3*Vj2.*Vi.*k2.*cfji);
  a4 = 2*Vj2.*mu2.*k5;
  a5 = mu2.*(4*Vij.*k5 - 3*Vj2.*k4.*cij + 3*Vj2.*k2.*sfji);
  a6 = mu2.*(12*Vj2.*kj + 2*Vi2.*k5 - 6*Vij.*k4.*cij + 6*Vij.*k2.*sfji);

  Hji = [sparse(p.fr, p.fr, a1, nb, nb) + ...
         sparse(p.fr, p.to,-a1, nb, nb) + ...
         sparse(p.to, p.fr,-a1, nb, nb) + ...
         sparse(p.to, p.to, a1, nb, nb), ...
         sparse(p.fr, p.fr, a2, nb, nb) + ...
         sparse(p.fr, p.to, a3, nb, nb) + ...
         sparse(p.to, p.fr,-a2, nb, nb) + ...
         sparse(p.to, p.to,-a3, nb, nb); ...
         sparse(p.fr, p.fr, a2, nb, nb) + ...
         sparse(p.fr, p.to,-a2, nb, nb) + ...
         sparse(p.to, p.fr, a3, nb, nb) + ...
         sparse(p.to, p.to,-a3, nb, nb), ...
         sparse(p.fr, p.fr, a4, nb, nb) + ...
         sparse(p.fr, p.to, a5, nb, nb) + ...
         sparse(p.to, p.fr, a5, nb, nb) + ...
         sparse(p.to, p.to, a6, nb, nb)];

  if nargout == 6
    varargout{1} = Fij;
    varargout{2} = Jij;
    varargout{3} = Hij;
    varargout{4} = Fji;
    varargout{5} = Jji;
    varargout{6} = Hji;
  end

end
