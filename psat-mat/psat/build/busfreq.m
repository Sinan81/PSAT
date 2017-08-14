% User Defined Component busfreq
% Created with PSAT v1.2.2
% 
% Date: 19-Dec-2003 17:46:09

% Struct: Comp

Comp.init(1,1) = 1;

Comp.descr = 'Bus frequency measurement';

Comp.name = 'busfreq';

Comp.shunt(1,1) = 1;

% Struct: Buses

Buses.name{1,1} = 'bus1';

Buses.n(1,1) = 1;

% Struct: Algeb

Algeb.name{1,1} = 'theta1';
Algeb.name{2,1} = 'V1';

Algeb.n(1,1) = 2;

Algeb.idx{1,1} = 'V1';
Algeb.idx{2,1} = 'theta1';

Algeb.eq{1,1} = 'null';
Algeb.eq{2,1} = 'null';

Algeb.eqidx{1,1} = 'P1';
Algeb.eqidx{2,1} = 'Q1';

Algeb.neq(1,1) = 2;

% Struct: State

State.name{1,1} = 'x';
State.name{2,1} = 'w';

State.n(1,1) = 2;

State.eq{1,1} = ' -(theta1-theta1_0)/Tf/2/pi/f0-x';
State.eq{2,1} = 'x+(theta1-theta1_0)/2/pi/f0/Tf+1-w';

State.eqidx{1,1} = 'p(x)';
State.eqidx{2,1} = 'p(w)';

State.neq(1,1) = 2;

State.init{1,1} = '0';
State.init{2,1} = '0';

State.limit{1,1} = 'None';
State.limit{1,2} = 'None';
State.limit{2,1} = 'None';
State.limit{2,2} = 'None';

State.fn{1,1} = 'x';
State.fn{2,1} = '\omega';

State.un{1,1} = 'x';
State.un{2,1} = 'w';

State.time{1,1} = 'Tf';
State.time{2,1} = 'Tw';

State.offset{1,1} = 'No';
State.offset{1,2} = 'No';
State.offset{2,1} = 'No';
State.offset{2,2} = 'No';

State.nodyn{1,1} = 'No';
State.nodyn{2,1} = 'No';

% Struct: Servc

Servc.name = [];

Servc.n(1,1) = 0;

Servc.idx{1,1} = 'Syn.pm';
Servc.idx{2,1} = 'Syn.vf';
Servc.idx{3,1} = 'Exc.vrif';
Servc.idx{4,1} = 'P1';
Servc.idx{5,1} = 'Q1';

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

Param.name{1,1} = 'Tf';
Param.name{2,1} = 'Tw';
Param.name{3,1} = 'pi';
Param.name{4,1} = 'f0';

Param.n(1,1) = 4;

Param.descr{1,1} = 'Time constant of the frequency deviation filter';
Param.descr{2,1} = 'Time constant of the frequency filter';
Param.descr{3,1} = 'pi';
Param.descr{4,1} = 'Nominal frequency';

Param.type{1,1} = 'Time Constant';
Param.type{2,1} = 'Time Constant';
Param.type{3,1} = 'None';
Param.type{4,1} = 'None';

Param.unit{1,1} = 'Second';
Param.unit{2,1} = 'Second';
Param.unit{3,1} = 'None';
Param.unit{4,1} = 'None';

% Struct: Initl

Initl.name{1,1} = 'theta1_0';

Initl.n(1,1) = 1;

Initl.idx{1,1} = 'V1_0';
Initl.idx{2,1} = 'theta1_0';
Initl.idx{3,1} = 'P1_0';
Initl.idx{4,1} = 'Q1_0';
Initl.idx{5,1} = 'x_0';
Initl.idx{6,1} = 'w_0';

