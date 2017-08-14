function a = restore_spq(a)

if isempty(a.store)
  a = init_spq(a);
else
  a.con = a.store;
  a = setup_spq(a);
end
