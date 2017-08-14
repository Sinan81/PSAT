function a = add_wind(a,data)

global Line

a.con = [a.con; data];
a = setup_wind(a);
