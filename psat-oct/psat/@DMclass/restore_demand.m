function a = restore_demand(a)

if isempty(a.store)
  a = init_demand(a);
else
  a.con = a.store;
  a = setup_demand(a);
end
