function a = restore_breaker(a)

if isempty(a.store)
  a = init_breaker(a);
else
  a.con = a.store;
  a = setup_breaker(a);
end
