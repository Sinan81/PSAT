function a = restore_areas(a)

if isempty(a.store)
  a = init_areas(a);
else
  a.con = a.store;
  a = setup_areas(a);
end
