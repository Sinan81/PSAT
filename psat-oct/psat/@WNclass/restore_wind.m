function a = restore_wind(a)

if isempty(a.store)
  a = init_wind(a);
else
  a.con = a.store;
  a = setup_wind(a);
end
