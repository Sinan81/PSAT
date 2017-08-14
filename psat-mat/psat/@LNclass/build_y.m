function a = build_y(a)
% build admittance matrix

global Bus Settings

if ~a.n, return, end
if a.no_build_y, return, end

nb = Bus.n;

% process line data and build admittance matrix [Y]
chrg = 0.5*a.u.*a.con(:,10);
y = a.u./(a.con(:,8) + j*a.con(:,9));
ts = a.con(:,11).*exp(j*a.con(:,12)*pi/180);
ts2= ts.*conj(ts);

a.Y = sparse(a.fr,a.to,-y./conj(ts),nb,nb) + ...
      sparse(a.to,a.fr,-y./ts,nb,nb) + ...
      sparse(a.fr,a.fr,(y+j*chrg)./ts2,nb,nb)+ ...
      sparse(a.to,a.to,y+j*chrg,nb,nb);

% check for missing connections (0 diagonal elements)
b = find(diag(a.Y) == 0);
if ~isempty(b)
  a.Y = a.Y - sparse(b,b,j*1e-6,nb,nb);
end
