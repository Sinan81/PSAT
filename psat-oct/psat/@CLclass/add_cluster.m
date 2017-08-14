function a = add_cluster(a,data)

if isempty(data), return, end

a.con = [a.con; data];
a = setup_cluster(a);
