Bus.con = [ ...
   1   20     1.05    0;
   2   20    1.081    0;
   3   20        1    0];
% Column Variable Description Unit
% 1  Bus number int
% 2  Voltage base kV
% 3† Voltage amplitude initial guess p.u.
% 4† Voltage phase initial guess rad
% 5† Area number (not used yet...) int
% 6† Region number (not used yet...) int

SW.con = [ ...
   2  100   20  1.081  0]; 
% Column Variable Description Unit
% 1  Bus number int
% 2  Power rating MVA
% 3  Voltage rating kV
% 4  Voltage magnitude p.u.
% 5  Reference Angle p.u.
% 6† Maximum reactive power p.u.
% 7† Minimum reactive power p.u.
% 8† Maximum voltage p.u.
% 9† Minimum voltage p.u.
%10† Active power guess p.u.
%11† Loss participation coefficient 
%12† Reference bus {0, 1}
%13† Connection status {0, 1}

PV.con = [ ...
   1   100   20  0.9  1.05 ]; 
% Column Variable Description Unit
% 1  Bus number int
% 2  Power rating MVA
% 3  Voltage rating kV
% 4  Active Power p.u.
% 5  Voltage Magnitude p.u.
% 6† Maximum reactive power p.u.
% 7† Minimum reactive power p.u.
% 8† Maximum voltage p.u.
% 9† Minimum voltage p.u.
%10† Loss participation coefficient -
%11† Connection status {0, 1}
 
Line.con = [ ...
   1   3  100   20   50   0   1   0   0.1   0;
   2   3  100   20   50   0   0   0   0.1   0;
   2   3  100   20   50   0   0   0   0.1   0];

% Column Variable Description Unit
% 1  From Bus int
% 2  To Bus int
% 3  Power rating MVA
% 4  Voltage rating kV
% 5  Frequency rating Hz
% 6  Line length km
% 7  - not used -
% 8  Resistance p.u.(omega/km)
% 9  Reactance p.u. (H/km)
%10  Susceptance p.u. (F/km)
%11† - not used -
%12† - not used -
%13† Current limit p.u.
%14† Active power limit p.u.
%15† Apparent power limit p.u.
%16† Connection status {0, 1}

% Column Variable Description Unit
% 1  From Bus int
% 2  To Bus int
% 3  Power rating MVA
% 4  Voltage rating of primary winding kV
% 5  Frequency rating Hz
% 6  - not used -
% 7  kT = Vn1/Vn2 Nominal voltage ratio kV/kV
% 8  Resistance p.u.
% 9  Reactance p.u.
%10  - not used -
%11† Fixed tap ratio p.u./p.u.
%12† Fixed phase shift deg
%13† Current limit p.u.
%14† Active power limit p.u.
%15† Apparent power limit p.u.
%16† Connection status {0, 1}

Syn.con = [ ...
%  machine 1 uses mac_sub model 
%  1  2       3   4    5    6    7  8    9      10    11  12     13    14   15    16   17   18  19  20  21 22 23 24 25  26  27 28               
%    1  991     20  50  5.2   0    0  1.1  0.25   0.2   5   0.05   0.7   0    0.2   0    0.1   6   0  ; 
   1  991     20  50  6     0.15 0  2    0.245  0.2   5   0.031  1.91  0.42 0.2   0.66 0.061 2.8755*2 0  ;
   2  1e+005  20  50  2     0    0  0    0.01   0     0   0      0     0    0     0    0     6   2  ];
   
% Column Variable Description Unit Model
% 1  Bus number int all
% 2  Power rating MVA all
% 3  Voltage rating kV all
% 4  Frequency rating Hz all
% 5  - Machine model - all
% 6  Leakage reactance (not used) p.u. all
% 7  Armature resistance p.u. all
% 8  d-axis synchronous reactance p.u. all but II
% 9  d-axis transient reactance p.u. all
%10  d-axis sub-transient reactance p.u. V.2, VI, VIII
%11  d-axis open circuit transient time constant s all but II
%12  d-axis open circuit sub-transient time constant s V.2, VI, VIII
%13  q-axis synchronous reactance p.u. all but II
%14  q-axis transient reactance p.u. IV, V.1, VI, VIII
%15  q-axis sub-transient reactance p.u. V.2, VI, VIII
%16  q-axis open circuit transient time constant s IV, V.1, VI, VIII
%17  q-axis open circuit sub-transient time constant s V.1, V.2, VI, VIII
%18  M = 2H Mechanical starting time (2 × inertia constant) kWs/kVA all
%19  Damping coefficient ? all
%20† Speed feedback gain gain all but V.3 and VIII
%21† Active power feedback gain gain all but V.3 and VIII
%22† Active power ratio at node [0,1] all
%23† Reactive power ratio at node [0,1] all
%24† d-axis additional leakage time constant s V.2, VI, VIII
%25† S(1.0) First saturation factor - all but II and V.3
%26† S(1.2) Second saturation factor - all but II and V.3
%27† nCOI Center of inertia number int all
%28† Connection status {0, 1} all

Exc.con = [ ...
   1    2    11.5  -11.5  400  0.1  0.45  1  0.01  1  0.001  0.0006  0.9  1];
% Column Variable Description Unit
% 1  Generator number int
% 2  Exciter type int
% 3  Maximum regulator voltage p.u.
% 4  Minimum regulator voltage p.u.
% 5  Ka Amplifier gain p.u./p.u.
% 6  Ta Amplifier time constant s
% 7  Kf Stabilizer gain p.u./p.u.
% 8  Tf Stabilizer time constant s
% 9  Ke Field circuit integral deviation p.u./p.u.
%10  Te Field circuit time constant s
%11  Tr Measurement time constant s
%12  Ae 1st ceiling coefficient -
%13  Be 2nd ceiling coefficient -
%14† Connection status {0, 1}

Tg.con = [ ...
%Model3
  1  3  1  0.2    1  0  0.1  -0.1  0.04  5.0  0.04  0.3  1  0.5  1  1.5  1  1];
%Model4
%  1  4  1  0.2    1  0  0.1  -0.1  0.04  5.0  0.04  0.3  1  0.5  1  1.5  1  1.163 0.105 1];
%Model5
%  1  5  1  0.2    1  0  0.1  -0.1  0.05  1    0.04  3    0.5  1];
%Model6
%  1  6  1  10/3   1  0  0.1  -0.1  0.07  2.67  0.1  1.163  0.105  0 0.01  0.04  1];

Fault.con = [ 3  100  20  50  20  20.02  0.15  0];
% Column Variable Description Unit
% 1 Bus number int
% 2 Sn Power rating MVA
% 3 Vn Voltage rating kV
% 4 fn Frequency rating Hz
% 5 tf Fault time s
% 6 tc Clearance time s
% 7 rf Fault resistance p.u.
% 8 xf Fault reactance p.u.

% Breaker.con = [ 3  3  100   20   50   1   20   20.02];
% Column Variable Description Unit
% 1  Line number int
% 2  Bus number int
% 3  Power rating MVA
% 4  Voltage rating kV
% 5  Frequency rating Hz
% 6  Connection status {0, 1} 
% 7  First intervention time s
% 8  Second intervention time s
% 9† Apply first intervention {0, 1}
%10† Apply second intervention {0, 1}

Settings.t0 = 0;
Settings.tf = 50;


Varname.idx = [...
    1;     2;     3;     4;     5;     6;     7;
    8;     9;    10;    11;    12;    13;    14;
   15;    16;    17;    18;    19;    20;    21;
   22;    23;    24;    25;    26;    27;    28;
   29;    30;    31;    32;    33;    34;    35;
   ];

Varname.areas = [...
    0; 
   ];

Varname.regions = [...
    0; 
   ];
