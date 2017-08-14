function a = restore_upfc(a)

if isempty(a.store)
  a = init_upfc(a);
else
  a.con = a.store;
  a = setup_upfc(a);
end
