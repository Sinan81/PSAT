function hmatrix(a)

global LA DAE Bus

if ~a.n
  LA.h_ps = [];  
  LA.h_qs = [];  
  LA.h_is = [];  
  LA.h_pr = [];  
  LA.h_qr = [];  
  LA.h_ir = [];  
  fm_disp('No transmission line or transformer found')
  return
end

unos = ones(a.n,2*Bus.n);

[Iij,JIij,Iji,JIji] = fjh2(a,1);
[Pij,JPij,Pji,JPji] = fjh2(a,2);
[Sij,JSij,Sji,JSji] = fjh2(a,3);
[FPij,FQij,FPji,FQji] = flows(a,'pq');

JIs = 0.5*JIij./(diag(sqrt(Iij))*unos);
JIr = 0.5*JIji./(diag(sqrt(Iji))*unos);
JPs = 0.5*JPij./(diag(sqrt(Pij).*sign(FPij))*unos);
JPr = 0.5*JPji./(diag(sqrt(Pji).*sign(FPji))*unos);
JQs = 0.5*(JSij-JPij)./(diag(sqrt(Sij-Pij).*sign(FQij))*unos);
JQr = 0.5*(JSji-JPji)./(diag(sqrt(Sji-Pji).*sign(FQji))*unos);

[i,j,s] = find(JIs);
LA.h_is = full(sparse(i,j,s,a.n,DAE.m));

[i,j,s] = find(JIr);
LA.h_ir = full(sparse(i,j,s,a.n,DAE.m));

[i,j,s] = find(JPs);
LA.h_ps = full(sparse(i,j,s,a.n,DAE.m));

[i,j,s] = find(JPr);
LA.h_pr = full(sparse(i,j,s,a.n,DAE.m));

[i,j,s] = find(JQs);
LA.h_qs = full(sparse(i,j,s,a.n,DAE.m));

[i,j,s] = find(JQr);
LA.h_qr = full(sparse(i,j,s,a.n,DAE.m));
