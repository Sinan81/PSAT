function a = restore_lines(a)

if isempty(a.store)
  a = init_lines(a);
else
  a.con = a.store;
  a = setup_lines(a);
end
