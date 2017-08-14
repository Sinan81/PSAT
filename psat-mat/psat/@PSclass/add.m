function a = add(a,data)

global Bus Syn Exc

a.n = a.n + length(data(1,:));
a.con = [a.con; data];
a.exc = [a.exc; data(:,1)];
a.syn = Exc.syn(a.exc);
a.bus = getbus(Syn,a.syn);
a.vbus= a.bus + Bus.n;

