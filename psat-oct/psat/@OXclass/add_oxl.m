function a = add_oxl(a,data)

if isempty(data), return, end

a.con = [a.con; data];
a = setup_oxl(a);
