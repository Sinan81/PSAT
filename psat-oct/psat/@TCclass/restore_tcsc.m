function a = restore_tcsc(a)

if isempty(a.store)
  a = init_tcsc(a);
else
  a.con = a.store;
  a = setup_tcsc(a);
end
