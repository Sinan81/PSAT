function a = build_b(a)

% build admittance matrix B' and B" for fast decoupled
% power flow algorithm (FDPF)
%
% see also BUILD_Y and Settings

global Bus Settings

if ~a.n, return, end

nb = Bus.n;

% process line data and build admittance matrix [B']
ts = exp(j*a.con(:,12)*pi/180);

% XB method
switch Settings.pfsolver
 case 2
  y = -j*a.u./a.con(:,9);
 case 3
  y = a.u./(a.con(:,8) + j*a.con(:,9));
end

a.Bp = sparse(a.fr, a.to, -y./conj(ts), nb, nb) + ...
       sparse(a.to, a.fr, -y./ts, nb, nb) + ...
       sparse(a.fr, a.fr, y./ts, nb, nb) + ...
       sparse(a.to, a.to, y, nb, nb);
a.Bp = -imag(a.Bp);

% process line data and build admittance matrix [B"]
chrg = a.u.*a.con(:,10);
ts = a.con(:,11);
ts2= ts.*ts;

% BX method
switch Settings.pfsolver
 case 3
  y = -j*a.u./a.con(:,9);
 case 2
  y = a.u./(a.con(:,8) + j*a.con(:,9));
end

a.Bpp = sparse(a.fr, a.to, -y./conj(ts), nb, nb) + ...
        sparse(a.to, a.fr, -y./ts, nb, nb) + ...
        sparse(a.fr, a.fr, (y+j*chrg)./ts2, nb, nb) + ...
        sparse(a.to, a.to, y+j*chrg, nb, nb);
a.Bpp = -imag(a.Bpp);
