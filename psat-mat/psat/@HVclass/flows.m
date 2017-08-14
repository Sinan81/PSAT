function [Ps,Qs,Pr,Qr,varargout] = flows(a,Ps,Qs,Pr,Qr,varargin)

global DAE

if nargin == 7
  varargout{1} = [varargin{1}; a.bus1];
  varargout{2} = [varargin{2}; a.bus2];
end

if ~a.n, return, end

Idc = a.u.*DAE.x(a.Idc);
phir = a.u.*DAE.y(a.phir);
phii = a.u.*DAE.y(a.phii);
Vrdc = DAE.y(a.Vrdc);
Vidc = DAE.y(a.Vidc);
V1 = DAE.y(a.v1);
V2 = DAE.y(a.v2);

k = 0.995*3*sqrt(2)/pi;
mr = a.con(:,11);
mi = a.con(:,12);

P1 = Vrdc.*Idc;
P2 = Vidc.*Idc;
Q1 = k*V1.*mr.*Idc.*sin(phir);
Q2 = k*V2.*mi.*Idc.*sin(phii);

Ps = [Ps; P1];
Pr = [Pr;-P2];
Qs = [Qs; Q1];
Qr = [Qr; Q2];  
