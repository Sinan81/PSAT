function a = add_vltn(a,data)

if isempty(data), return, end

a.con = [a.con; data];
a = setup_vltn(a);

