function a = restore_cluster(a)

if isempty(a.store)
  a = init_cluster(a);
else
  a.con = a.store;
  a = setup_cluster(a);
end
