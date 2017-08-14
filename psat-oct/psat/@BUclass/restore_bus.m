function a = restore_bus(a)

if isempty(a.store)
  a = init_bus(a);
else
  a.con = a.store;
  a = setup_bus(a);
end
