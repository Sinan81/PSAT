% User Defined Component mixed
% Created with PSAT v1.3.3
% 
% Date: 23-May-2005 09:52:49

% Struct: Comp

Comp.init(1,1) = 1;

Comp.descr = 'Mixed load';

Comp.name = 'mixed';

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

Algeb.eq{1,1} = 'Kpf*(y+k*(theta1-theta1_0)/Tft)+Kpv*((V1/V1_0)^alpha+Tpv*(x+V1/Tfv))';
Algeb.eq{2,1} = 'Kqf*(y+k*(theta1-theta1_0)/Tft)+Kqv*((V1/V1_0)^beta+Tqv*(x+V1/Tfv))';

Algeb.eqidx{1,1} = 'P1';
Algeb.eqidx{2,1} = 'Q1';

Algeb.neq(1,1) = 2;

% Struct: State

State.name{1,1} = 'x';
State.name{2,1} = 'y';

State.n(1,1) = 2;

State.eq{1,1} = '-V1/Tfv-x';
State.eq{2,1} = '-k*(theta1-theta1_0)/Tft-x';

State.eqidx{1,1} = 'p(x)';
State.eqidx{2,1} = 'p(y)';

State.neq(1,1) = 2;

State.init{1,1} = '0';
State.init{2,1} = '0';

State.limit{1,1} = 'None';
State.limit{1,2} = 'None';
State.limit{2,1} = 'None';
State.limit{2,2} = 'None';

State.fn{1,1} = 'x';
State.fn{2,1} = 'y';

State.un{1,1} = 'x';
State.un{2,1} = 'y';

State.time{1,1} = 'Tfv';
State.time{2,1} = 'Tft';

State.offset{1,1} = 'No';
State.offset{1,2} = 'No';
State.offset{2,1} = 'No';
State.offset{2,2} = 'No';

State.nodyn{1,1} = 'No';
State.nodyn{2,1} = 'No';

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

Param.name{1,1} = 'Kpf';
Param.name{2,1} = 'Kpv';
Param.name{3,1} = 'alpha';
Param.name{4,1} = 'Tpv';
Param.name{5,1} = 'Kqf';
Param.name{6,1} = 'Kqv';
Param.name{7,1} = 'beta';
Param.name{8,1} = 'Tqv';
Param.name{9,1} = 'Tfv';
Param.name{10,1} = 'Tft';
Param.name{11,1} = 'k';

Param.n(1,1) = 11;

Param.descr{1,1} = 'None';
Param.descr{2,1} = 'None';
Param.descr{3,1} = 'None';
Param.descr{4,1} = 'None';
Param.descr{5,1} = 'None';
Param.descr{6,1} = 'None';
Param.descr{7,1} = 'None';
Param.descr{8,1} = 'None';
Param.descr{9,1} = 'None';
Param.descr{10,1} = 'None';
Param.descr{11,1} = 'None';

Param.type{1,1} = 'None';
Param.type{2,1} = 'None';
Param.type{3,1} = 'None';
Param.type{4,1} = 'Time Constant';
Param.type{5,1} = 'None';
Param.type{6,1} = 'None';
Param.type{7,1} = 'None';
Param.type{8,1} = 'Time Constant';
Param.type{9,1} = 'Time Constant';
Param.type{10,1} = 'Time Constant';
Param.type{11,1} = 'None';

Param.unit{1,1} = 'None';
Param.unit{2,1} = 'None';
Param.unit{3,1} = 'None';
Param.unit{4,1} = 'Second';
Param.unit{5,1} = 'None';
Param.unit{6,1} = 'None';
Param.unit{7,1} = 'None';
Param.unit{8,1} = 'Second';
Param.unit{9,1} = 'Second';
Param.unit{10,1} = 'Second';
Param.unit{11,1} = 'None';

% Struct: Initl

Initl.name{1,1} = 'V1_0';
Initl.name{2,1} = 'theta1_0';

Initl.n(1,1) = 1;

Initl.idx{1,1} = 'V1_0';
Initl.idx{2,1} = 'theta1_0';
Initl.idx{3,1} = 'P1_0';
Initl.idx{4,1} = 'Q1_0';
Initl.idx{5,1} = 'x_0';
Initl.idx{6,1} = 'y_0';

