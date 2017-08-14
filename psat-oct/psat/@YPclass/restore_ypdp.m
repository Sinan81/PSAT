function a = restore_ypdp(a)

if isempty(a.store)
  a = init_ypdp(a);
else
  a.con = a.store;
  a = setup_ypdp(a);
end
