function gcall(a)

global Settings DAE

if ~a.n, return, end

V = DAE.y(a.vbus);
dw = DAE.y(a.dw);

DAE.g = DAE.g + sparse(a.bus,1,a.u.*a.con(:,2).*(V.^a.con(:,3)).* ...
                         (1+dw).^a.con(:,4),DAE.m,1);
DAE.g = DAE.g + sparse(a.vbus,1,a.u.*a.con(:,5).*(V.^a.con(:,6)).* ...
                         (1+dw).^a.con(:,7),DAE.m,1);
DAE.g = DAE.g + sparse(a.dw,1,DAE.x(a.x)+(DAE.y(a.bus)-a.a0)./a.con(:,8)/ ...
                       (2*pi*Settings.freq)-dw,DAE.m,1);
