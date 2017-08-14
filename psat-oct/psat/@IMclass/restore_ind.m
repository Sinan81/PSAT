function a = restore_ind(a)

if isempty(a.store)
  a = init_ind(a);
else
  a.con = a.store;
  a = setup_ind(a);
end
