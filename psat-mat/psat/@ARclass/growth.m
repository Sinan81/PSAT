function growth(a,type)

global Bus PQ PV SW Demand Supply

rr = a.con(:,6)/100;

if sum(abs(rr)) < 1e-5
  fm_disp('Likely no annual growth has been defined.',2)
  return
end

switch type
 case 'area'
  idx = a.int(getarea(Bus,0,0));
 case 'region'
  idx = a.int(getregion(Bus,0,0));
end
    
ddata = growth(PQ,rr,idx);
sdata = growth(PV,rr,idx);
sdata = [sdata; growth(SW,rr,idx)];

Demand = remove(Demand,[1:Demand.n]);
Demand  = add(Demand,ddata);

Supply = remove(Supply,[1:Supply.n]);
Supply = add(Supply,sdata);

