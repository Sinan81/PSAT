function gcall(p)

global DAE

if ~p.n, return, end

%VARIABLES INTERNAS DE ESTADO.

Dfm = DAE.x(p.Dfm);
x = DAE.x(p.x);
csi = DAE.x(p.csi);
pfw = DAE.x(p.pfw);

%VARIABLES EXTERNAS.

we = DAE.x(p.we);
Df = DAE.x(p.Df);

%VARIABLES INTERNAS ALGEBRAICAS.

pf1 = DAE.y(p.pf1);
pwa = DAE.y(p.pwa);
pout = DAE.y(p.pout);

Tr = p.con(:, 3);
Tw = p.con(:, 4);
R = p.con(:, 5);
we_max = p.con(:, 6);
we_min = p.con(:, 7);
KI = p.con(:, 8);
KP = p.con(:, 9);
csi_max = p.con(:, 10);
csi_min = p.con(:, 11);
TA = p.con(:, 12);
pfw_max = p.con(:, 13);
pfw_min = p.con(:, 14);

we_ref = p.dat(:, 1);

% quedan por definir las ecuaciones que se hacen con vectores
% dispersos. Cuidado con los signos!!!

DAE.g = DAE.g ...
        + sparse(p.pf1,  1, p.u.*(x + Dfm)./R - pf1, DAE.m, 1) ...
        + sparse(p.pwa,  1, p.u.*(csi + KP.*(we_ref - we)) - pwa, DAE.m, 1);

DAE.g(p.pout) = (~p.u).*DAE.g(p.pout) + p.u.*(pfw - pout);

% windup-limits

idx = find(we > we_max | we < we_min);
if ~isempty(idx), DAE.y(p.pf1(idx)) = 0; end

idx = find(pout > pfw_max);
if ~isempty(idx)
  DAE.y(p.pout(idx)) = pfw_max(idx); 
end
idx = find(pout < pfw_min);
if ~isempty(idx)
  DAE.y(p.pout(idx)) = pfw_min(idx); 
end
