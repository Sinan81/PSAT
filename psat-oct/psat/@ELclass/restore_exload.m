function a = restore_exload(a)

if isempty(a.store)
  a = init_exload(a);
else
  a.con = a.store;
  a = setup_exload(a);
end
