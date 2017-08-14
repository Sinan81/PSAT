function a = restore_sw(a)

if isempty(a.store)
  a = init_sw(a);
else
  a.con = a.store;
  a = setup_sw(a);
end
