function a = restore_twt(a)

if isempty(a.store)
  a = init_twt(a);
else
  a.con = a.store;
  a = setup_twt(a);
end
