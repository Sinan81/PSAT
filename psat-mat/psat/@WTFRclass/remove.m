function a = remove(a,idx)

if ~a.n, return, end
if isempty(idx), return, end

a.con(idx,:) = [];
a.gen(idx) = [];
a.freq(idx) = [];
a.dat(idx,:) = [];
a.n = a.n - length(idx);
a.u(idx) = [];
a.we(idx) = [];
a.Df(idx) = [];
a.Dfm(idx) = [];
a.x(idx) = [];
a.csi(idx) = [];
a.pfw(idx) = [];
a.pwa(idx) = [];
a.pf1(idx) = [];
a.pout(idx) = [];
