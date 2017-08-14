function a = add_tg(a,data)
% add one or more instances of the device
a.con = [a.con; data];
a = setup_tg(a);
