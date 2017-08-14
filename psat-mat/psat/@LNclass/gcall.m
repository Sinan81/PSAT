function a = gcall(a)

global Bus DAE

if ~a.n, return, end

DAE.g = zeros(DAE.m,1);

na = Bus.a;
nv = Bus.v;

DAE.y(nv) = max(DAE.y(nv),1e-6);
Vc = DAE.y(nv).*exp(i*DAE.y(na));
S = Vc.*conj(a.Y*Vc);
a.p = real(S);
a.q = imag(S);

DAE.g(na) = a.p;
DAE.g(nv) = a.q;

