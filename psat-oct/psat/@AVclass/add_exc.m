function a = add_exc(a,data)

if isempty(data), return, end

a.con = [a.con; data];
a = setup_exc(a);
