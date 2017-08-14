function a = restore_dfig(a)

if isempty(a.store)
  a = init_dfig(a);
else
  a.con = a.store;
  a = setup_dfig(a);
end
