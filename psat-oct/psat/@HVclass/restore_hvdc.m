function a = restore_hvdc(a)

if isempty(a.store)
  a = init_hvdc(a);
else
  a.con = a.store;
  a = setup_hvdc(a);
end
