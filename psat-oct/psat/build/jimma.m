% User Defined Component jimma
% Created with PSAT v1.3.3
% 
% Date: 04-Apr-2005 18:31:29

% Struct: Comp

Comp.init(1,1) = 1;

Comp.descr = 'Jimma''s load';

Comp.name = 'jimma';

Comp.shunt(1,1) = 1;

% Struct: Buses

Buses.name{1,1} = 'bus1';

Buses.n(1,1) = 1;

% Struct: Algeb

Algeb.name{1,1} = 'V1';

Algeb.n(1,1) = 1;

Algeb.idx{1,1} = 'V1';
Algeb.idx{2,1} = 'theta1';

Algeb.eq{1,1} = 'Plz*(V1/V1_0)^2+Pli*(V1/V1_0)+Plp';
Algeb.eq{2,1} = 'Qlz*(V1/V1_0)^2+Qli*(V1/V1_0)+Qlp+Kv*(x+V1/Tf)';

Algeb.eqidx{1,1} = 'P1';
Algeb.eqidx{2,1} = 'Q1';

Algeb.neq(1,1) = 2;

% Struct: State

State.name{1,1} = 'x';

State.n(1,1) = 1;

State.eq{1,1} = '-V1/Tf-x';

State.eqidx{1,1} = 'p(x)';

State.neq(1,1) = 1;

State.init{1,1} = '0';

State.limit{1,1} = 'None';
State.limit{1,2} = 'None';

State.fn{1,1} = 'x';

State.un{1,1} = 'x';

State.time{1,1} = 'Tf';

State.offset{1,1} = 'No';
State.offset{1,2} = 'No';

State.nodyn{1,1} = 'No';

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

Param.name{1,1} = 'Tf';
Param.name{2,1} = 'Plz';
Param.name{3,1} = 'Pli';
Param.name{4,1} = 'Plp';
Param.name{5,1} = 'Qlz';
Param.name{6,1} = 'Qli';
Param.name{7,1} = 'Qlp';
Param.name{8,1} = 'Kv';

Param.n(1,1) = 8;

Param.descr{1,1} = 'None';
Param.descr{2,1} = 'None';
Param.descr{3,1} = 'None';
Param.descr{4,1} = 'None';
Param.descr{5,1} = 'None';
Param.descr{6,1} = 'None';
Param.descr{7,1} = 'None';
Param.descr{8,1} = 'None';

Param.type{1,1} = 'Time Constant';
Param.type{2,1} = 'None';
Param.type{3,1} = 'None';
Param.type{4,1} = 'None';
Param.type{5,1} = 'None';
Param.type{6,1} = 'None';
Param.type{7,1} = 'None';
Param.type{8,1} = 'None';

Param.unit{1,1} = 'Second';
Param.unit{2,1} = 'None';
Param.unit{3,1} = 'None';
Param.unit{4,1} = 'None';
Param.unit{5,1} = 'None';
Param.unit{6,1} = 'None';
Param.unit{7,1} = 'None';
Param.unit{8,1} = 'None';

% Struct: Initl

Initl.name{1,1} = 'V1_0';

Initl.n(1,1) = 1;

Initl.idx{1,1} = 'V1_0';
Initl.idx{2,1} = 'theta1_0';
Initl.idx{3,1} = 'P1_0';
Initl.idx{4,1} = 'Q1_0';
Initl.idx{5,1} = 'x_0';

