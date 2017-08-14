% User Defined Component testudm
% Created with PSAT v1.2.1
% 
% Date: 15-Sep-2003 13:37:42

% Struct: Comp

Comp.init(1,1) = 1;

Comp.descr = 'sample udm test';

Comp.name = 'testudm';

Comp.shunt(1,1) = 0;

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

State.name{1,1} = 'x1';
State.name{2,1} = 'x2';

State.n(1,1) = 2;

State.eq{1,1} = 'null';
State.eq{2,1} = 'null';

State.eqidx{1,1} = 'p(x1)';
State.eqidx{2,1} = 'p(x2)';

State.neq(1,1) = 2;

State.init{1,1} = '0';
State.init{2,1} = '0';

State.limit{1,1} = 'None';
State.limit{1,2} = 'None';
State.limit{2,1} = 'None';
State.limit{2,2} = 'None';

State.fn{1,1} = 'x1';
State.fn{2,1} = 'x2';

State.un{1,1} = 'x1';
State.un{2,1} = 'x2';

State.time{1,1} = 'None';
State.time{2,1} = 'None';

State.offset{1,1} = 'No';
State.offset{2,1} = 'No';

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

Servc.oldidx{1,1} = 'Syn.pm';
Servc.oldidx{2,1} = 'Syn.vf';
Servc.oldidx{3,1} = 'Exc.vrif';

% Struct: Param

Param.name{1,1} = 'a1';
Param.name{2,1} = 'a2';
Param.name{3,1} = 'a3';

Param.n(1,1) = 3;

Param.descr{1,1} = 'None';
Param.descr{2,1} = 'None';
Param.descr{3,1} = 'None';

Param.type{1,1} = 'None';
Param.type{2,1} = 'None';
Param.type{3,1} = 'None';

Param.unit{1,1} = 'None';
Param.unit{2,1} = 'None';
Param.unit{3,1} = 'None';

% Struct: Initl

Initl.name = [];

Initl.n(1,1) = 0;

Initl.idx{1,1} = 'V1_0';
Initl.idx{2,1} = 'theta1_0';
Initl.idx{3,1} = 'P1_0';
Initl.idx{4,1} = 'Q1_0';
Initl.idx{5,1} = 'x1_0';
Initl.idx{6,1} = 'x2_0';

