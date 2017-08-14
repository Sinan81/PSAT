function a = restore_svc(a)

if isempty(a.store)
  a = init_svc(a);
else
  a.con = a.store;
  a = setup_svc(a);
end
