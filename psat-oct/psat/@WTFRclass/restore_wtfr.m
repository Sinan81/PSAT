function a = restore_wtfr(a)

if isempty(a.store)
  a = init_wtfr(a);
else
  a.con = a.store;
  a = setup_wtfr(a);
end
