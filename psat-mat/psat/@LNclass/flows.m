function varargout = flows(a,varargin)
%FLOWS computes flows in transmission lines and transformers
%
%[Fij,Fji] = FLOWS(LINE,TYPE,IDX)
%[Pij,Qij,Pji,Qji] = FLOWS(LINE,'pq',IDX)
%[Pij,Qij,Pji,Qji] = FLOWS(LINE)
%
%TYPE:   'pq'            ACTIVE AND REACTIVE POWERS 
%        1 OR 'current'  CURRENTS 
%        2 OR 'active'   ACTIVE POWERS 
%        3 OR 'apparent' APPARENT POWERS 
%        'reactive'      REACTIVE POWERS 
%        'complex'       COMPLEX POWERS 
%IDX:    LINE INDICES (DEFAULT ALL LINES)
%
%Author:    Federico Milano
%Date:      03-Aug-2006
%Version:   1.0.0
%
%E-mail:    fmilano@thunderbox.uwaterloo.ca
%Web-site:  http://thunderbox.uwaterloo.ca/~fmilano
%
%Copyright (C) 2006 Federico Milano

global DAE

switch nargout
 case 2
  varargout{1} = [];
  varargout{2} = [];
 case 4
  varargout{1} = [];
  varargout{2} = [];
  varargout{3} = [];
  varargout{4} = [];
end

if ~a.n, return, end

switch nargin
 case 1
  type = 'pq';
  idx = [1:a.n];
 case 2
  type = varargin{1};
  idx = [1:a.n];
 otherwise
  type = varargin{1};
  idx = varargin{2};
end

tps = a.con(idx,11).*exp(i*a.con(idx,12)*pi/180);
tpj = conj(tps);
r = a.con(idx,8);
x = a.con(idx,9);
chrg = a.u(idx).*a.con(idx,10)/2;

z = r + i*x;
y = a.u(idx)./z;
Vf = DAE.y(a.vfr(idx)).*exp(i*DAE.y(a.fr(idx)));
Vt = DAE.y(a.vto(idx)).*exp(i*DAE.y(a.to(idx)));  

MWs  = Vf.*conj(Vf.*(y + i*chrg)./(tps.*tpj) - Vt.*y./tpj);
MWr  = Vt.*conj(Vt.*(y + i*chrg) - Vf.*y./tps);

%MWs  = Vf.*conj((Vf-Vt.*tps).*y+i*Vf.*chrg);
%MWr  = Vt.*conj((Vt.*tps-Vf).*y.*conj(tps)+i*Vt.*chrg);

switch type
 case 'pq'
  varargout{1} = real(MWs);
  varargout{2} = imag(MWs);
  varargout{3} = real(MWr);
  varargout{4} = imag(MWr);
 case {'current','currents',1}
  varargout{1} = abs(MWs./Vf);
  varargout{2} = abs(MWr./Vt);
 case {'apparent',3}
  varargout{1} = abs(MWs);
  varargout{2} = abs(MWr);
 case {'active',2}
  varargout{1} = real(MWs);
  varargout{2} = real(MWr);
 case 'reactive'
  varargout{1} = imag(MWs);
  varargout{2} = imag(MWr);
 case 'complex'
  varargout{1} = MWs;
  varargout{2} = MWr;
end
