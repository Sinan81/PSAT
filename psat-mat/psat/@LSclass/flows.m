function [Ps,Qs,Pr,Qr,varargout] = flows(a,Ps,Qs,Pr,Qr,varargin)

global DAE

if nargin == 7
  varargout{1} = [varargin{1}; a.bus1];
  varargout{2} = [varargin{2}; a.bus2];
end

if ~a.n, return, end

V1 = a.u.*DAE.y(a.v1);
V2 = a.u.*DAE.y(a.v2);
theta1 = DAE.y(a.bus1);
theta2 = DAE.y(a.bus2);
rl = a.con(:,6);
xl = a.con(:,7);
bl = a.con(:,8);
cos12 = cos(theta1-theta2);
sin12 = sin(theta1-theta2);

zl = rl.*rl+xl.*xl;

g12 = rl./zl;
b12 = -xl./zl;
bL2 = 0.5*bl;
V12 = V1.*V2;

P1 =  V1.*V1.*g12 - V12.*(g12.*cos12 + b12.*sin12);
P2 =  V2.*V2.*g12 - V12.*(g12.*cos12 - b12.*sin12);
Q1 = -V1.*V1.*(b12+bL2) - V12.*(g12.*sin12 - b12.*cos12);
Q2 = -V2.*V2.*(b12+bL2) + V12.*(g12.*sin12 + b12.*cos12);

Ps = [Ps; P1];
Qs = [Qs; Q1];
Pr = [Pr; P2];
Qr = [Qr; Q2];
