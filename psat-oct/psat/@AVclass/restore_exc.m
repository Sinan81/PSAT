function a = restore_exc(a)

if isempty(a.store)
  a = init_exc(a);
else
  a.con = a.store;
  a = setup_exc(a);
end
