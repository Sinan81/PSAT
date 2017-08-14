function H = hessian(a,ro)
% compute the Hessian matrix of PF equations
%

global DAE Bus jay

ang = exp(jay*DAE.y(Bus.a));
vol = DAE.y(Bus.v);
V = ones(1,Bus.n);
Ma = ang*V;
MW = ro(Bus.a)*V;
MM = ro(Bus.v)*V;

S1 = Ma.*conj(a.Y).*Ma';
S2 = conj(Ma.*a.Y.*Ma');

A1 = real(S1);
B1 = imag(S1);

A2 = real(S2);
B2 = imag(S2);

H22 = MW.*A1 + MW'.*A2 + MM.*B1 + MM'.*B2;
H11 = (vol*vol').*H22;
H11 = H11 - diag(sum(H11));
H21 = (V'*vol').*(MW.*B1 - MW'.*B2 - MM.*A1 + MM'.*A2);
H21 = H21 - diag(sum(H21'));
H = [H11,H21';H21,H22];
