function a = restore_mixload(a)

if isempty(a.store)
  a = init_mixload(a);
else
  a.con = a.store;
  a = setup_mixload(a);
end
