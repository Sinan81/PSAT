% CLOSEPSAT clear all PSAT global variables from workspace
%
% CLOSEPSAT
%
% Author:    Federico Milano
% Date:      22-Feb-2004
% Version:   1.0.0
%
% E-mail:    federico.milano@ucd.ie
% Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

%     General System Variables
clear Settings Fig Path File Hdl clpsat
clear History Snapshot Theme Source jay

%     User Defined Model variables
clear Comp Algeb Buses Initl Param Servc State

%     Outputs and variable names
clear Varout Varname

%     Basic System structures
clear DAE LIB SNB OPF CPF SSSA PMU

%     Libraries
clear LA EQUIV

%     Interface Structures
clear GAMS UWPFLOW

%     Traditional Power Flow Buses
clear Bus Line SW PV PQ Shunt Lines Twt

%     Static and dynamic nonlinear loads
clear Pl Mn Fl Thload Tap

%     Components for CPF and OPF
clear Demand Supply Rsrv Rmpg Rmpl Vltn Ypdp

%     Fault Variables
clear Fault Breaker

%     Basic Dyanmic Components
clear Syn Ind Ltc

%     Regulators
clear Exc Tg Pss Oxl Pod COI

%     FACTS
clear Svc Tcsc Statcom Sssc Upfc

%     HVDC components
clear Hvdc

%     Other dynamic components
clear Mass SSR

%     Fuel Cell Model
clear Sofc

%     Secondary Voltage Regulation
clear Cac Cluster

%     Exponential recovery load
clear Exload

%     Phase Shifting Transformer
clear Phs

%     Wind Turbine
clear Wind Cswt Dfig Ddsg WTFR

%     Bus frequency measurement
clear Busfreq

%     Phasor measurement unit
clear Pmu

%     Jimma's load
clear Jimma

%     Mixed load
clear Mixload

%     Solar Photo-voltaic generators
clear Spv Spq