function a = setx0(a)

if ~a.n, return, end

global PQ DAE Bus

V = DAE.y(a.vbus);

i = find(a.con(:,8));
for j = 1:length(i)
  k = i(j);
  idx = findbus(PQ,a.bus(k));
  if isempty(idx),
    fm_disp(['No PQ load found for initializing monomial ', ...
             'load at bus ',Bus.names{a.bus(k)}])
  else
    P = a.u(k)*PQ.P0(idx)*a.con(k,4)/100;
    Q = a.u(k)*PQ.Q0(idx)*a.con(k,5)/100;
    PQ = pqsub(PQ,idx,P,Q);
    a.con(k,4)  = a.con(k,4)*PQ.P0(idx)/(V(k)^a.con(k,6))/100;
    a.con(k,5)  = a.con(k,5)*PQ.Q0(idx)/(V(k)^a.con(k,7))/100;
    PQ = remove(PQ,idx,'zero');
  end
end

fm_disp('Initialization of Monomial Loads completed.')
