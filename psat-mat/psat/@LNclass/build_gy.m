function Gy = build_gy(a)

global Bus DAE

Gy = 1e-6*speye(DAE.m,DAE.m);
nb = Bus.n;

if ~a.n, return, end

n1 = Bus.a;
U = exp(i*DAE.y(n1));
V = DAE.y(Bus.v).*U;
I = a.Y*V;

diagVc = sparse(n1,n1,V,nb,nb);
diagVn = sparse(n1,n1,U,nb,nb);
diagIc = sparse(n1,n1,I,nb,nb);
dS = diagVc * conj(a.Y * diagVn) + conj(diagIc) * diagVn;
dR = conj(diagVc) * (diagIc - a.Y * diagVc);

[h,k,s] = find([imag(dR),real(dS);real(dR),imag(dS)]);
Gy = sparse(h,k,s,DAE.m,DAE.m);


