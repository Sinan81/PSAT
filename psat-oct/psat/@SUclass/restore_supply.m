function a = restore_supply(a)

if isempty(a.store)
  a = init_supply(a);
else
  a.con = a.store;
  a = setup_supply(a);
end
