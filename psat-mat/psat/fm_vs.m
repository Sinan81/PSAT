function vars = fm_vs
% FM_VS computes determinants and eigenvalues during
%       time domain integrations
%
% FM_VS(K)
%      K    integration step number
%      IDX0 starting index of the output array
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Settings Bus DAE Varout

% As
As = DAE.Fx - DAE.Fy*(DAE.Gy\DAE.Gx);
detAs = det(As);
AutoState = round(eig(full(As))*1e5)/1e5;

% % Jlf
% detGy = det(DAE.Gy);
% Jlfr = (DAE.Gy(Bus.v,Bus.v)-DAE.Gy(Bus.v,Bus.a)*...
%        ((DAE.Gy(Bus.a,Bus.a)+1e-6*speye(Bus.n))\DAE.Gy(Bus.a,Bus.v)));
% AutoJlf = eig(full(Jlfr))';

% % Jlfd
% Jlfd = (DAE.Gy - DAE.Gx*((DAE.Fx-1e-6*speye(DAE.n))\DAE.Fy));
% detJlfd = det(Jlfd);
% Jlfdr = (Jlfd(Bus.v,Bus.v)-Jlfd(Bus.v,Bus.a)* ...
%          (Jlfd(Bus.a,Bus.a)\Jlfd(Bus.a,Bus.v)));
% AutoJlfd = eig(full(Jlfdr))';

%vars = [detAs,detGy,detJlfd,AutoState,AutoJlf,AutoJlfd];
vars = [detAs; AutoState];