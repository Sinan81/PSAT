function a = restore_pv(a)

if isempty(a.store)
  a = init_pv(a);
else
  a.con = a.store;
  a = setup_pv(a);
end
