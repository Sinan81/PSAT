% User Defined Component ddsg
% Created with PSAT v1.3.0
% 
% Date: 12-May-2004 11:33:37

% Struct: Comp

Comp.init(1,1) = 1;

Comp.descr = 'Direct Drive Synchronous Generator';

Comp.name = 'ddsg';

Comp.shunt(1,1) = 1;

% Struct: Buses

Buses.name{1,1} = 'bus1';

Buses.n(1,1) = 1;

% Struct: Algeb

Algeb.name{1,1} = 'V1';
Algeb.name{2,1} = 'theta1';

Algeb.n(1,1) = 2;

Algeb.idx{1,1} = 'V1';
Algeb.idx{2,1} = 'theta1';

Algeb.eq{1,1} = '(-rs*ids+omega_m*xq*iqs)*ids+(-rs*iqs-omega_m*(xd*ids-phip))*iqs';
Algeb.eq{2,1} = 'V1*idc/cos(theta1)+tan(theta1)*(-rs*ids+omega_m*xq*iqs)*ids+(-rs*iqs-omega_m*(xd*ids-phip))*iqs';

Algeb.eqidx{1,1} = 'P1';
Algeb.eqidx{2,1} = 'Q1';

Algeb.neq(1,1) = 2;

% Struct: State

State.name{1,1} = 'omega_m';
State.name{2,1} = 'theta_p';
State.name{3,1} = 'idc';
State.name{4,1} = 'ids';
State.name{5,1} = 'iqs';
State.name{6,1} = 'vw';

State.n(1,1) = 6;

State.eq{1,1} = '0.5*((0.5*rho*(0.22*(116/(1/(k*omega_m/vw+0.08*theta_p)-0.035/(theta_p^3+1))-0.4*theta_p-5)*exp(-12.5/(1/(k*omega_m/vw+0.08*theta_p)-0.035/(theta_p^3+1))))*Ar*vw^3)/omega_m-(-xd*ids+phip)*iqs-xq*iqs*ids)';
State.eq{2,1} = 'Kp*(omega_m-omega_ref)-theta_p';
State.eq{3,1} = '-idc+Kv*(Vref-V1)';
State.eq{4,1} = 'phip/xd-sqrt(phip*phip/xd/xd-Qref/omega_m/xd)-ids';
State.eq{5,1} = '(0.5*rho*(0.22*(116/(1/(k*omega_m/vw+0.08*theta_p)-0.035/(theta_p^3+1))-0.4*theta_p-5)*exp(-12.5/(1/(k*omega_m/vw+0.08*theta_p)-0.035/(theta_p^3+1))))*Ar*vw^3)/omega_m/(phip-xd*ids)-iqs';
State.eq{6,1} = '1';

State.eqidx{1,1} = 'p(omega_m)';
State.eqidx{2,1} = 'p(theta_p)';
State.eqidx{3,1} = 'p(idc)';
State.eqidx{4,1} = 'p(ids)';
State.eqidx{5,1} = 'p(iqs)';
State.eqidx{6,1} = 'p(vw)';

State.neq(1,1) = 6;

State.init{1,1} = '1';
State.init{2,1} = '0';
State.init{3,1} = '0';
State.init{4,1} = '0';
State.init{5,1} = '0';
State.init{6,1} = '0';

State.limit{1,1} = 'None';
State.limit{1,2} = 'None';
State.limit{2,1} = 'None';
State.limit{2,2} = 'None';
State.limit{3,1} = 'idc_max';
State.limit{3,2} = 'idc_min';
State.limit{4,1} = 'ids_max';
State.limit{4,2} = 'ids_min';
State.limit{5,1} = 'iqs_max';
State.limit{5,2} = 'iqs_min';
State.limit{6,1} = 'None';
State.limit{6,2} = 'None';

State.fn{1,1} = '\omega_m';
State.fn{2,1} = '\theta_p';
State.fn{3,1} = 'i_{dc}';
State.fn{4,1} = 'ids';
State.fn{5,1} = 'iqs';
State.fn{6,1} = 'vw';

State.un{1,1} = 'omega_m';
State.un{2,1} = 'theta_p';
State.un{3,1} = 'idc';
State.un{4,1} = 'ids';
State.un{5,1} = 'iqs';
State.un{6,1} = 'vw';

State.time{1,1} = 'Hm';
State.time{2,1} = 'Tp';
State.time{3,1} = 'Tv';
State.time{4,1} = 'Teq';
State.time{5,1} = 'Tep';
State.time{6,1} = 'None';

State.offset{1,1} = 'No';
State.offset{1,2} = 'No';
State.offset{2,1} = 'No';
State.offset{2,2} = 'No';
State.offset{3,1} = 'No';
State.offset{3,2} = 'No';
State.offset{4,1} = 'No';
State.offset{4,2} = 'No';
State.offset{5,1} = 'No';
State.offset{5,2} = 'No';
State.offset{6,1} = 'No';
State.offset{6,2} = 'No';

State.nodyn{1,1} = 'No';
State.nodyn{2,1} = 'No';
State.nodyn{3,1} = 'No';
State.nodyn{4,1} = 'No';
State.nodyn{5,1} = 'No';
State.nodyn{6,1} = 'No';

% Struct: Servc

Servc.name = [];

Servc.n(1,1) = 0;

Servc.idx{1,1} = 'P1';
Servc.idx{2,1} = 'Q1';

Servc.eq = [];

Servc.eqidx = [];

Servc.neq(1,1) = 0;

Servc.init = [];

Servc.limit = [];

Servc.fn = [];

Servc.un = [];

Servc.type = [];

Servc.offset = [];

Servc.oldidx = [];

% Struct: Param

Param.name{1,1} = 'Hm';
Param.name{2,1} = 'Tp';
Param.name{3,1} = 'Kp';
Param.name{4,1} = 'omega_ref';
Param.name{5,1} = 'Tv';
Param.name{6,1} = 'Kv';
Param.name{7,1} = 'Vref';
Param.name{8,1} = 'xd';
Param.name{9,1} = 'xq';
Param.name{10,1} = 'k';
Param.name{11,1} = 'Teq';
Param.name{12,1} = 'Qref';
Param.name{13,1} = 'Tep';
Param.name{14,1} = 'Ar';
Param.name{15,1} = 'rho';
Param.name{16,1} = 'phip';
Param.name{17,1} = 'rs';

Param.n(1,1) = 17;

Param.descr{1,1} = 'Rotor Inertia';
Param.descr{2,1} = 'Pitch Control Time Constant';
Param.descr{3,1} = 'Pitch Control Gain';
Param.descr{4,1} = 'Reference speed';
Param.descr{5,1} = 'Time constant of the voltage control';
Param.descr{6,1} = 'Gain of the voltage control';
Param.descr{7,1} = 'Reference voltage';
Param.descr{8,1} = 'd-axis reactance';
Param.descr{9,1} = 'q-axis reactance';
Param.descr{10,1} = 'None';
Param.descr{11,1} = 'Time constant for reactive power control';
Param.descr{12,1} = 'Reference reactive power';
Param.descr{13,1} = 'Time constant for speed control';
Param.descr{14,1} = 'None';
Param.descr{15,1} = 'None';
Param.descr{16,1} = 'None';
Param.descr{17,1} = 'None';

Param.type{1,1} = 'Time Constant';
Param.type{2,1} = 'Time Constant';
Param.type{3,1} = 'Gain';
Param.type{4,1} = 'Frequency';
Param.type{5,1} = 'Time Constant';
Param.type{6,1} = 'Gain';
Param.type{7,1} = 'Voltage';
Param.type{8,1} = 'Reactance';
Param.type{9,1} = 'Reactance';
Param.type{10,1} = 'None';
Param.type{11,1} = 'Time Constant';
Param.type{12,1} = 'Power';
Param.type{13,1} = 'Time Constant';
Param.type{14,1} = 'None';
Param.type{15,1} = 'None';
Param.type{16,1} = 'None';
Param.type{17,1} = 'None';

Param.unit{1,1} = 'Second';
Param.unit{2,1} = 'Second';
Param.unit{3,1} = 'p.u.';
Param.unit{4,1} = 'p.u.';
Param.unit{5,1} = 'Second';
Param.unit{6,1} = 'p.u.';
Param.unit{7,1} = 'p.u.';
Param.unit{8,1} = 'p.u.';
Param.unit{9,1} = 'p.u.';
Param.unit{10,1} = 'None';
Param.unit{11,1} = 'Second';
Param.unit{12,1} = 'p.u.';
Param.unit{13,1} = 'Second';
Param.unit{14,1} = 'None';
Param.unit{15,1} = 'None';
Param.unit{16,1} = 'None';
Param.unit{17,1} = 'None';

% Struct: Initl

Initl.name = [];

Initl.n(1,1) = -8;

Initl.idx{1,1} = 'omega_m_0';
Initl.idx{2,1} = 'V1_0';
Initl.idx{3,1} = 'theta1_0';
Initl.idx{4,1} = 'P1_0';
Initl.idx{5,1} = 'Q1_0';
Initl.idx{6,1} = 'theta_p_0';
Initl.idx{7,1} = 'idc_0';
Initl.idx{8,1} = 'ids_0';
Initl.idx{9,1} = 'iqs_0';
Initl.idx{10,1} = 'vw_0';

