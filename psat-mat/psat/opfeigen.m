% Eigenvalue analysis
%________________________________________________________________________

I_smu = speye(n_s);
Z1 = sparse(n_s,n_y);
Z2 = sparse(n_s,n_s);
Z4 = sparse(n2,n_s);
H_s  = diag(s);
H_mu = diag(mu);
D2 = [H_mu,   H_s,   Z1,       Z4'; ...
      I_smu,   Z2,    Jh,       Z4'; ...
      Z1',     Jh',   D2xLms,  -Jg'; ...
      Z4,      Z4,   -Jg,       Z3];

% partition matrices
u1 = 2*n_s + n2 + n_gen;
u2 = u1 + Supply.n + Demand.n;
u3 = max(size(D2));

w1 = [u1+1:u2];
w2 = [1:u1,u2+1:u3];

A = D2(w1,w1);
B = D2(w1,w2);
C = D2(w2,w1);
D = D2(w2,w2);

% state matrix
As = -(A - B*(D\C));

OPF.eigs = sort(eig(full(As)));
%OPF.eigs = auto(1:min(length(auto),10));
%fm_disp(' ')
%fm_disp('Relevant eigenvalues of the electricity market:')
%fm_disp(' ')
%fm_disp(OPF.eigs)
