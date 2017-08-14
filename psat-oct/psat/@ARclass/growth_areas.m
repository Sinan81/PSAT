function growth_areas(a,type)

global Bus PQ PV SW Demand Supply

rr = a.con(:,6)/100;

if sum(abs(rr)) < 1e-5
  fm_disp('Likely no annual growth has been defined.',2)
  return
end

switch type
 case 'area'
  idx = a.int(getarea_bus(Bus,0,0));
 case 'region'
  idx = a.int(getregion_bus(Bus,0,0));
end
    
ddata = growth_pq(PQ,rr,idx);
sdata = growth_pv(PV,rr,idx);
sdata = [sdata; growth_sw(SW,rr,idx)];

Demand = remove_demand(Demand,[1:Demand.n]);
Demand  = add_demand(Demand,ddata);

Supply = remove_supply(Supply,[1:Supply.n]);
Supply = add_supply(Supply,sdata);

