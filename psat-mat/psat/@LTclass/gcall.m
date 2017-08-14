function a = gcall(a)

global DAE Settings

if ~a.n, return, end

mmax  = a.con(:,9);
mmin  = a.con(:,10);
mstep = a.con(:,11);

mc = DAE.x(a.mc);
md = DAE.y(a.md);

% compute discrete tap ratio
idx = find(mstep);
for ii = 1:length(idx)
  jj = idx(ii);
  %seq = mmin(jj):mstep(jj):mmax(jj);
  %[val, jdx] = min(abs(seq-mc(jj)));
  %mval = seq(jdx);
  mval = mmin(jj) + mstep(jj)*round((mc(jj)-mmin(jj))/mstep(jj));
  DAE.g(a.md(jj)) = 0;
  if ~Settings.init
    DAE.y(a.md(jj)) = mval;
    a.mold(jj) = mval;
    mc(jj) = mval;
    md(jj) = mval;
  else
    %if mval ~= a.mold(jj) & DAE.t-a.delay(jj) > 0.333/a.con(jj,8)
    if abs(mc(jj)-mval) < (0.5-a.con(jj,17)/100)*mstep(jj)
      a.delay(jj) = DAE.t;
      a.mold(jj) = mval;
      DAE.y(a.md(jj)) = mval;
      mc(jj) = mval;
      md(jj) = mval;
    else
      DAE.y(a.md(jj)) = a.mold(jj);
      mc(jj) = a.mold(jj);
      md(jj) = a.mold(jj);
    end
  end
end

DAE.g = DAE.g + sparse(a.md, 1, a.u.*(mc-md), DAE.m, 1);

Vf = a.u.*DAE.y(a.v1).*exp(i*DAE.y(a.bus1));
Vt = a.u.*DAE.y(a.v2).*exp(i*DAE.y(a.bus2));  
y = admittance(a);

Ss = Vf.*conj((Vf./md-Vt).*y./md);
Sr = Vt.*conj((Vt-Vf./md).*y);

DAE.g = DAE.g ...
        + sparse(a.bus1, 1, real(Ss), DAE.m, 1) ...
        + sparse(a.bus2, 1, real(Sr), DAE.m, 1) ...
        + sparse(a.v1,   1, imag(Ss), DAE.m, 1) ...
        + sparse(a.v2,   1, imag(Sr), DAE.m, 1);
      
for ii = 1:length(idx)
  jj = idx(ii);
  ms = mstep(jj);
  if abs(DAE.g(a.bus1(jj))) < ms, DAE.g(a.bus1(jj)) = 0; end
  if abs(DAE.g(a.bus2(jj))) < ms, DAE.g(a.bus2(jj)) = 0; end
  if abs(DAE.g(a.v1(jj))) < ms, DAE.g(a.v1(jj)) = 0; end
  if abs(DAE.g(a.v2(jj))) < ms, DAE.g(a.v2(jj)) = 0; end
end

