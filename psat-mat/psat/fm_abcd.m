function fm_abcd
% FM_ABCD sets up matrices A, B, C and D for linear analysis
%         The matrices are stored in the structure LA.
%
% Synthax:
%
% FM_ABCD
%
%Author:    Federico Milano
%Date:      29-Mar-2008
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global LA DAE Exc Tg Line
global Svc Tcsc Statcom Sssc Upfc Hvdc

fm_disp

% Check for dynamic components
if ~DAE.n
  fm_disp('No dynamic component is loaded.')
  fm_disp('Computation of linear dynamic matrices aborted.')
  return
end

fm_disp('Computation of input/output matrices A,B,C,D:')
fm_disp
fm_disp('[Delta dx/dt] = [A] [Delta x] + [B] [Delta u]')
fm_disp('    [Delta y] = [C] [Delta x] + [D] [Delta u]')
fm_disp
fm_disp('These matrices are stored in structure LA.')

n = DAE.n+DAE.m;

% -------------------------------------------------------------------
% B & D matrices
% -------------------------------------------------------------------

LA.d_y = 0;

bdmatrix(Exc);      % define LA.b_avr       LA.d_avr
bdmatrix(Tg);       % define LA.b_tg        LA.d_tg
bdmatrix(Svc);      % define LA.b_svc       LA.d_svc
bdmatrix(Tcsc);     % define LA.b_tcsc      LA.d_tcsc
bdmatrix(Statcom);  % define LA.b_statcom   LA.d_statcom
bdmatrix(Sssc);     % define LA.b_sssc      LA.d_sssc
bdmatrix(Upfc);     % define LA.b_upfc      LA.d_upfc
bdmatrix(Hvdc);     % define LA.b_hvdc      LA.d_hvdc

% -------------------------------------------------------------------
% C matrices
% -------------------------------------------------------------------

LA.c_y = -full(DAE.Gy\DAE.Gx); % define LA.c_y (algebraic variables as output)

% -------------------------------------------------------------------
% H matrices
% -------------------------------------------------------------------

hmatrix(Line); % define LA.h_ps LA.h_qs LA.h_is
               %        LA.h_pr LA.h_qr LA.h_ir

% -------------------------------------------------------------------
% A matrix
% -------------------------------------------------------------------

LA.a = full(DAE.Fx + DAE.Fy*LA.c_y);

fm_disp('Computation of input/output matrices completed.')