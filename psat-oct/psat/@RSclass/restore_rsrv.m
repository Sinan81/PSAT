function a = restore_rsrv(a)

if isempty(a.store)
  a = init_rsrv(a);
else
  a.con = a.store;
  a = setup_rsrv(a);
end
