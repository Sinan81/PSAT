function a = add_cac(a,data)

if isempty(data), return, end

a.con = [a.con; data];
a = setup_cac(a);
