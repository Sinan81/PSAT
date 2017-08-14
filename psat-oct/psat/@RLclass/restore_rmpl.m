function a = restore_rmpl(a)

if isempty(a.store)
  a = init_rmpl(a);
else
  a.con = a.store;
  a = setup_rmpl(a);
end
