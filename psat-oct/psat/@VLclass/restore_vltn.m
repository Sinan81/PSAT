function a = restore_vltn(a)

if isempty(a.store)
  a = init_vltn(a);
else
  a.con = a.store;
  a = setup_vltn(a);
end
