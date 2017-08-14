function a = add(a,data)
% add one or more instances of the device
a.con = [a.con; data];
a = setup(a);
