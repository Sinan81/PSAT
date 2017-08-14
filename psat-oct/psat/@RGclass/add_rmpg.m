function a = add_rmpg(a,data)

if isempty(data), return, end

a.con = [a.con; data];
a = setup_rmpg(a);

