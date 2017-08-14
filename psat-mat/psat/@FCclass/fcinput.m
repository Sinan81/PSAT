function [Input,Umax,Umin] = fcinput(a)

global DAE

Vk = DAE.x(a.Vk);
qH2 = DAE.x(a.qH2);
Sn = a.con(:,2);
Vn = a.con(:,3);
Kr = a.con(:,7);
Pref = a.con(:,21).*a.con(:,23);

V = Vk + (~a.u);
idx = find(a.con(:,25));
if idx, V(idx) = a.con(idx,25); end

Input = Sn.*Pref./Vn./V;
Umax = 0.5*a.con(:,15).*qH2./Kr;
Umin = 0.5*a.con(:,16).*qH2./Kr;
