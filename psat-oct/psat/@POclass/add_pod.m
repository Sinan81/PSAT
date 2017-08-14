function a = add_pod(a,data)

if isempty(data), return, end

a.con = [a.con; data];
a = setup_pod(a);
