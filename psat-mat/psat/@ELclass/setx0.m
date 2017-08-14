function a = setx0(a)

global DAE PQ Bus

if ~a.n, return, end

% parameter initialization

% dat:
%  col #1: P0
%  col #2: Q0
%  col #3: V0

a.dat(:,3) = DAE.y(a.vbus);

for k = 1:a.n
  idx = findbus(PQ,a.bus(k));
  if isempty(idx)
    fm_disp(['No PQ load found for initializing Exponential ', ...
             'Recovery Load at bus ',Bus.names{a.bus(k)}])
  else
    a.dat(k,1) = a.u(k)*PQ.P0(idx)*a.con(k,3)/100;
    a.dat(k,2) = a.u(k)*PQ.Q0(idx)*a.con(k,4)/100;
    PQ = pqsub(PQ,idx,a.dat(k,1),a.dat(k,2));
    PQ = remove(PQ,idx,'zero');
  end
end

% state variable initialization
DAE.x(a.xp) = 0;
DAE.x(a.xq) = 0;

% message
fm_disp('Initialization of Exponential Recovery Loads completed.')

