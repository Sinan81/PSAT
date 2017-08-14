function a = restore_line(a)

if isempty(a.store)
  a = init_line(a);
else
  a.con = a.store;
  a = setup_line(a);
end
