function a = restore_pl(a)

if isempty(a.store)
  a = init_pl(a);
else
  a.con = a.store;
  a = setup_pl(a);
end
