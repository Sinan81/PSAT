%FM_VAR define PSAT global variables (script file)
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    30-Apr-2003
%Version:   1.0.1
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

%     General System Variables
global Settings Fig Path File Hdl clpsat
global History Snapshot Theme Source jay

%     User Defined Model variables
global Comp Algeb Buses Initl
global Param Servc State

%     Outputs and variable names
global Varout Varname

%     Basic System structures
global DAE LIB SNB OPF CPF SSSA PMU OMIB

%     Interface Structures
global GAMS UWPFLOW

%     Structure for linear analysis
global LA EQUIV

%     Traditional Power Flow Buses
global Bus Areas Regions Line SW PV PQ Shunt Lines Twt PQgen

%     Static and dynamic nonlinear loads
global Pl Mn Fl Thload Tap

%     Components for CPF and OPF
global Demand Supply Rsrv Rmpg Rmpl Vltn Ypdp

%     Fault Variables
global Fault Breaker

%     Basic Dyanmic Components
global Syn Ind Ltc

%     Regulators
global Exc Tg Pss Oxl Pod COI

%     FACTS
global Svc Tcsc Statcom Sssc Upfc

%     HVDC components
global Hvdc

%     Other dynamic components
global Mass SSR

%     Fuel Cell Model
global Sofc

%     Secondary Voltage Regulation
global Cac Cluster

%     Exponential recovery load
global Exload

%     Phase Shifting Transformer
global Phs

%     Wind Turbine
global Wind Cswt Dfig Ddsg WTFR

%     Measurements
global Busfreq Pmu

%     Jimma's load
global Jimma

%     Mixed load
global Mixload

%     Solar Photo-Voltaic Generators
global Spv Spq