function a = restore_busfreq(a)

if isempty(a.store)
  a = init_busfreq(a);
else
  a.con = a.store;
  a = setup_busfreq(a);
end
