function a = add_syn(a,data)

if isempty(data), return, end

a.con = [a.con; data];
a = setup_syn(a);
