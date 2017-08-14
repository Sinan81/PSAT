function a = restore_cac(a)

if isempty(a.store)
  a = init_cac(a);
else
  a.con = a.store;
  a = setup_cac(a);
end
