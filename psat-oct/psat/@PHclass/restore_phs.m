function a = restore_phs(a)

if isempty(a.store)
  a = init_phs(a);
else
  a.con = a.store;
  a = setup_phs(a);
end
