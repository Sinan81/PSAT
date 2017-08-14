function a = restore_spv(a)

if isempty(a.store)
  a = init_spv(a);
else
  a.con = a.store;
  a = setup_spv(a);
end
