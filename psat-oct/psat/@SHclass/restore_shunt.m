function a = restore_shunt(a)

if isempty(a.store)
  a = init_shunt(a);
else
  a.con = a.store;
  a = setup_shunt(a);
end
