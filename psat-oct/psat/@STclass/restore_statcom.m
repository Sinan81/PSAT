function a = restore_statcom(a)

if isempty(a.store)
  a = init_statcom(a);
else
  a.con = a.store;
  a = setup_statcom(a);
end
