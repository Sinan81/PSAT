function a = restore_rmpg(a)

if isempty(a.store)
  a = init_rmpg(a);
else
  a.con = a.store;
  a = setup_rmpg(a);
end
