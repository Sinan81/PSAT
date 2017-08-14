function a = restore_fl(a)

if isempty(a.store)
  a = init_fl(a);
else
  a.con = a.store;
  a = setup_fl(a);
end
