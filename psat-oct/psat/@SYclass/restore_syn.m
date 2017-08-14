function a = restore_syn(a)

if isempty(a.store)
  a = init_syn(a);
else
  a.con = a.store;
  a = setup_syn(a);
end
