function a = setx0(a)

if ~a.n, return, end

global PQ DAE Bus

V = DAE.y(a.vbus);

i = find(a.con(:,11));
for j = 1:length(i)
  k = i(j);
  idx = findbus(PQ,a.bus(k));
  if isempty(idx)
    fm_disp(['No PQ load found for initializing ZIP load ', ...
             'at bus ',Bus.names{a.bus(k)}])
  else
    P = a.u(k)*PQ.P0(idx)*sum(a.con(k,[5:7]))/100;
    Q = a.u(k)*PQ.Q0(idx)*sum(a.con(k,[8:10]))/100;
    PQ = pqsub(PQ,idx,P,Q);
    a.con(k,5)  = a.con(k,5)*PQ.P0(idx)/V(k)/V(k)/100;
    a.con(k,6)  = a.con(k,6)*PQ.P0(idx)/V(k)/100;
    a.con(k,7)  = a.con(k,7)*PQ.P0(idx)/100;
    a.con(k,8)  = a.con(k,8)*PQ.Q0(idx)/V(k)/V(k)/100;
    a.con(k,9)  = a.con(k,9)*PQ.Q0(idx)/V(k)/100;
    a.con(k,10) = a.con(k,10)*PQ.Q0(idx)/100;
    PQ = remove(PQ,idx,'zero');
  end
end

fm_disp('Initialization of ZIP loads completed.')
  
