function a = restore_mass(a)

if isempty(a.store)
  a = init_mass(a);
else
  a.con = a.store;
  a = setup_mass(a);
end
