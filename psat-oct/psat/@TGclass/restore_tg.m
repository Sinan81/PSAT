function a = restore_tg(a)
% restores device properties as given in the data file
if isempty(a.store)
  a = init_tg(a);
else
  a.con = a.store;
  a = setup_tg(a);
end
