function a = add_rmpl(a,data)

if isempty(data), return, end

a.con = [a.con; data];
a = setup_rmpl(a);

