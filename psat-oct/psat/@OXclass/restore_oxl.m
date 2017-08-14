function a = restore_oxl(a)

if isempty(a.store)
  a = init_oxl(a);
else
  a.con = a.store;
  a = setup_oxl(a);
end
