% User Defined Component pmu
% Created with PSAT v1.3.3
% 
% Date: 04-Mar-2005 19:39:48

% Struct: Comp

Comp.init(1,1) = 0;

Comp.descr = 'Phasor measurement unit';

Comp.name = 'pmu';

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

Algeb.eq{1,1} = 'null';
Algeb.eq{2,1} = 'null';

Algeb.eqidx{1,1} = 'P1';
Algeb.eqidx{2,1} = 'Q1';

Algeb.neq(1,1) = 2;

% Struct: State

State.name{1,1} = 'vm';
State.name{2,1} = 'thetam';

State.n(1,1) = 2;

State.eq{1,1} = 'V1-vm';
State.eq{2,1} = 'theta1-thetam';

State.eqidx{1,1} = 'p(vm)';
State.eqidx{2,1} = 'p(thetam)';

State.neq(1,1) = 2;

State.init{1,1} = '1';
State.init{2,1} = '0';

State.limit{1,1} = 'None';
State.limit{1,2} = 'None';
State.limit{2,1} = 'None';
State.limit{2,2} = 'None';

State.fn{1,1} = 'v_{pmu}';
State.fn{2,1} = '\theta_{pmu}';

State.un{1,1} = 'vm';
State.un{2,1} = 'thetam';

State.time{1,1} = 'Tv';
State.time{2,1} = 'Ta';

State.offset{1,1} = 'No';
State.offset{1,2} = 'No';
State.offset{2,1} = 'No';
State.offset{2,2} = 'No';

State.nodyn{1,1} = 'Yes';
State.nodyn{2,1} = 'Yes';

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

Param.name{1,1} = 'Tv';
Param.name{2,1} = 'Ta';

Param.n(1,1) = 2;

Param.descr{1,1} = 'Time constant of the low pass filter of the voltage measure';
Param.descr{2,1} = 'Time constant of the low pass filter for the angle measure';

Param.type{1,1} = 'Time Constant';
Param.type{2,1} = 'Time Constant';

Param.unit{1,1} = 'Second';
Param.unit{2,1} = 'Second';

% Struct: Initl

Initl.name = [];

Initl.n(1,1) = -1;

Initl.idx{1,1} = 'vm_0';
Initl.idx{2,1} = 'V1_0';
Initl.idx{3,1} = 'theta1_0';
Initl.idx{4,1} = 'P1_0';
Initl.idx{5,1} = 'Q1_0';
Initl.idx{6,1} = 'thetam_0';

