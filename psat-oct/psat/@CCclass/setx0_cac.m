function a = setx0_cac(a)

global DAE

if ~a.n, return, end

% variable initialization
DAE.x(a.q1) = 1;
DAE.y(a.q) = 1;

% pilot bus voltage reference
a.con(:,5) = DAE.y(a.vbus);

fm_disp('Initialization of Central Area Controllers completed.')

