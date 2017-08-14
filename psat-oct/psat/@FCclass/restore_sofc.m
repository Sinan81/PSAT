function a = restore_sofc(a)

if isempty(a.store)
  a = init_sofc(a);
else
  a.con = a.store;
  a = setup_sofc(a);
end
