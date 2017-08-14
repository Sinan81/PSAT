function a = restore_pod(a)

if isempty(a.store)
  a = init_pod(a);
else
  a.con = a.store;
  a = setup_pod(a);
end
