function a = restore_pss(a)

if isempty(a.store)
  a = init_pss(a);
else
  a.con = a.store;
  a = setup_pss(a);
end
