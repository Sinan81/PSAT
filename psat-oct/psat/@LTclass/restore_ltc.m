function a = restore_ltc(a)

if isempty(a.store)
  a = init_ltc(a);
else
  a.con = a.store;
  a = setup_ltc(a);
end
