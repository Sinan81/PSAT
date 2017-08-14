function a = restore_fault(a)

if isempty(a.store)
  a = init_fault(a);
else
  a.con = a.store;
  a = setup_fault(a);
end
