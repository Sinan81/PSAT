function a = restore(a)
% restores device properties as given in the data file
if isempty(a.store)
  a = init(a);
else
  a.con = a.store;
  a = setup(a);
end
