function a = setx0(a)

global DAE PQ Bus

if ~a.n, return, end

V = DAE.y(a.vbus);

for i = 1:a.n
  idx = findbus(PQ,a.bus(i));
  if isempty(idx)
    fm_disp(['No PQ load found for initializing frequency ', ...
             'dependent load at bus ',Bus.names{a.bus(i)}])
  else
    P = a.u(i)*PQ.P0(idx)*a.con(i,2)/100;
    Q = a.u(i)*PQ.Q0(idx)*a.con(i,5)/100;
    PQ = pqsub(PQ,idx,P,Q);
    a.con(i,2) = a.con(i,2)*PQ.P0(idx)/(V(i)^a.con(i,3))/100;
    a.con(i,5) = a.con(i,5)*PQ.Q0(idx)/(V(i)^a.con(i,6))/100;
    PQ = remove(PQ,idx,'zero');
  end
end
DAE.x(a.x) = 0;
DAE.y(a.dw) = 0;
a.a0 = DAE.y(a.bus);

%check limits
fm_disp('Initialization of Frequency Dependent Loads completed.')
