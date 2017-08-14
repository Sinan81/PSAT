function a = restore(a)

if isempty(a.store)
  a = init(a);
else
  a.con = a.store;
  a = setup(a);
end
