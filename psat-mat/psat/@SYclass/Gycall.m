function a = Gycall(a)

global DAE

if ~a.n, return, end

delta = DAE.x(a.delta);
ag = DAE.y(a.bus);
vg = a.u.*DAE.y(a.vbus);
ss = sin(delta-ag);
cc = cos(delta-ag);

M1 = vg.*(a.c1.*cc-a.c3.*ss);
M2 = -vg.*(a.c2.*cc+a.c1.*ss);
M3 = -(a.c1.*ss+a.c3.*cc);
M4 = a.c2.*ss-a.c1.*cc;

a.J11 = vg.*((a.Id-M2).*cc-(M1+a.Iq).*ss);
a.J12 = -a.Id.*ss-a.Iq.*cc-vg.*(M3.*ss+M4.*cc);
a.J21 = vg.*((M2-a.Id).*ss-(M1+a.Iq).*cc);
a.J22 = -a.Id.*cc+a.Iq.*ss-vg.*(M3.*cc-M4.*ss);

DAE.Gy = DAE.Gy - sparse(a.bus,a.p,a.u,DAE.m,DAE.m);
DAE.Gy = DAE.Gy - sparse(a.vbus,a.q,a.u,DAE.m,DAE.m);
DAE.Gy = DAE.Gy - sparse(a.p,a.p,1,DAE.m,DAE.m);
DAE.Gy = DAE.Gy - sparse(a.q,a.q,1,DAE.m,DAE.m);
DAE.Gy = DAE.Gy - sparse(a.p,a.bus, a.J11,DAE.m,DAE.m);
DAE.Gy = DAE.Gy - sparse(a.p,a.vbus,a.J12,DAE.m,DAE.m);
DAE.Gy = DAE.Gy - sparse(a.q,a.bus, a.J21,DAE.m,DAE.m);
DAE.Gy = DAE.Gy - sparse(a.q,a.vbus,a.J22,DAE.m,DAE.m);
DAE.Gy = DAE.Gy - sparse(a.pm,a.pm,1,DAE.m,DAE.m);
DAE.Gy = DAE.Gy - sparse(a.vf,a.vf,1,DAE.m,DAE.m);

is2  = find(a.con(:,5) == 2);
if ~isempty(is2)
  Kp = a.con(is2,21);
  q1 = vg(is2).*(ss(is2).*a.c3(is2)+cc(is2).*a.c1(is2));
  q2 = vg(is2).*(cc(is2).*a.c3(is2)-ss(is2).*a.c1(is2));
  DAE.Gy = DAE.Gy + sparse(a.p(is2),a.vf(is2),q1,DAE.m,DAE.m);
  DAE.Gy = DAE.Gy + sparse(a.q(is2),a.vf(is2),q2,DAE.m,DAE.m);
  DAE.Gy = DAE.Gy - sparse(a.p(is2),a.p(is2),Kp.*q1,DAE.m,DAE.m);
  DAE.Gy = DAE.Gy - sparse(a.q(is2),a.p(is2),Kp.*q2,DAE.m,DAE.m);
end
