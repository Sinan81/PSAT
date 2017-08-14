function a = setx0(a)

global DAE PQ

if ~a.n, return, end

V1 = DAE.y(a.vbus);

for k = 1:a.n
  idx = findbus(PQ,a.bus(k));
  if isempty(idx)
    warn(a,k,'No PQ load found.')
    a.con(k,6) = 0;
    a.con(k,7) = 0;
    a.con(k,8) = 0;
    a.con(k,9) = 0;
    a.con(k,10) = 0;
    a.con(k,11) = 0;
  else
    P = a.u(k)*PQ.P0(idx)*sum(a.con(k,[6:8]))/100;
    Q = a.u(k)*PQ.Q0(idx)*sum(a.con(k,[9:11]))/100;
    PQ = pqsub(PQ,idx,P,Q);
    a.con(k,6) = a.con(k,6)*PQ.P0(idx)/100;
    a.con(k,7) = a.con(k,7)*PQ.P0(idx)/100;
    a.con(k,8) = a.con(k,8)*PQ.P0(idx)/100;
    a.con(k,9) = a.con(k,9)*PQ.Q0(idx)/100;
    a.con(k,10) = a.con(k,10)*PQ.Q0(idx)/100;
    a.con(k,11) = a.con(k,11)*PQ.Q0(idx)/100;
    PQ = remove(PQ,idx,'zero');
  end
end

%check time constants
idx = find(a.con(:,5) == 0);
if idx
  warn(a,idx,'Tf cannot be zero. Tf = 0.001 s will be used.')
  a.con(idx,5) = 0.001;
end

%variable initialization
DAE.x(a.x) = -a.u.*V1./a.con(:,5);
a.dat(:,1) = V1;

%check limits
fm_disp('Initialization of Jimma''s loads completed.')
