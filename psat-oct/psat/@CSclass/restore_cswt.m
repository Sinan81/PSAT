function a = restore_cswt(a)

if isempty(a.store)
  a = init_cswt(a);
else
  a.con = a.store;
  a = setup_cswt(a);
end
