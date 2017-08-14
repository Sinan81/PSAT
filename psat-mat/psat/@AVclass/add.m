function a = add(a,data)

if isempty(data), return, end

a.con = [a.con; data];
a = setup(a);
