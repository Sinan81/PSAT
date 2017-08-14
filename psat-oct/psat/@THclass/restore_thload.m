function a = restore_thload(a)

if isempty(a.store)
  a = init_thload(a);
else
  a.con = a.store;
  a = setup_thload(a);
end
