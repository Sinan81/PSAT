function a = restore_jimma(a)

if isempty(a.store)
  a = init_jimma(a);
else
  a.con = a.store;
  a = setup_jimma(a);
end
