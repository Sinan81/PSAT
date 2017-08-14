function a = setx0(a)

global DAE PQ

if ~a.n, return, end

V1 = DAE.y(a.vbus);
t1 = DAE.y(a.bus);
 
for k = 1:a.n
  idx = findbus(PQ,a.bus(k));
  if isempty(idx)
    warn(a,idx,'No PQ load found for initialization.')
    a.con(k,6) = 0;
    a.con(k,10) = 0;
  else
    P = a.u(k)*PQ.P0(idx)*sum(a.con(k,6))/100;
    Q = a.u(k)*PQ.Q0(idx)*sum(a.con(k,10))/100;
    PQ = pqsub(PQ,idx,P,Q);
    a.con(k,6) = a.con(k,6)*PQ.P0(idx)/100;
    a.con(k,10) = a.con(k,10)*PQ.Q0(idx)/100;
    PQ = remove(PQ,idx,'zero');
  end
end

%check time constants
idx = find(a.con(:,13) == 0);
if idx
  warn(a,idx, 'Time constant Tfv cannot be zero. Tfv = 0.001 s will be used.'),
end
a.con(idx,13) = 0.001;
idx = find(a.con(:,14) == 0);
if idx
  warn(a,idx, 'Time constant Tft cannot be zero. Tft = 0.001 s will be used.'),
end
a.con(idx,14) = 0.001;

%variable initialization
DAE.x(a.x) = -a.u.*V1./a.con(:,13);
x = DAE.x(a.x);
DAE.x(a.y) = 0;
y = DAE.x(a.y);
a.dat(:,1) = V1;
a.dat(:,2) = t1;

%check limits
fm_disp('Initialization of mixed loads completed.')
