function a = restore_mn(a)

if isempty(a.store)
  a = init_mn(a);
else
  a.con = a.store;
  a = setup_mn(a);
end
