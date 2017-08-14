function a = restore_tap(a)

if isempty(a.store)
  a = init_tap(a);
else
  a.con = a.store;
  a = setup_tap(a);
end
