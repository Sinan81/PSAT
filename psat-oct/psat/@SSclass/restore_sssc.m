function a = restore_sssc(a)

if isempty(a.store)
  a = init_sssc(a);
else
  a.con = a.store;
  a = setup_sssc(a);
end
