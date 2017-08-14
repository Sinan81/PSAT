function a = restore_ssr(a)

if isempty(a.store)
  a = init_ssr(a);
else
  a.con = a.store;
  a = setup_ssr(a);
end
