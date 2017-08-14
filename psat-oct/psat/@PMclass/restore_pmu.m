function a = restore_pmu(a)

if isempty(a.store)
  a = init_pmu(a);
else
  a.con = a.store;
  a = setup_pmu(a);
end
