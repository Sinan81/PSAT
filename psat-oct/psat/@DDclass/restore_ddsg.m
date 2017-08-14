function a = restore_ddsg(a)

if isempty(a.store)
  a = init_ddsg(a);
else
  a.con = a.store;
  a = setup_ddsg(a);
end
