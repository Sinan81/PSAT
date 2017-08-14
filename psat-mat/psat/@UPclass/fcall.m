function fcall(p)

global DAE

if ~p.n, return, end

V1 = DAE.y(p.v1);
vp = DAE.x(p.vp);
vq = DAE.x(p.vq);
iq = DAE.x(p.iq);

Kr = p.con(:,7);
Tr = p.con(:,8);

DAE.f(p.vp) = p.u.*(DAE.y(p.vp0)-vp)./Tr; 
DAE.f(p.vq) = p.u.*(DAE.y(p.vq0)-vq)./Tr;
DAE.f(p.iq) = p.u.*(Kr.*(DAE.y(p.vref)-V1)-iq)./Tr;

% anti-windup limits
fm_windup(p.vp,p.con(:,9), p.con(:,10),'f')
fm_windup(p.vq,p.con(:,11),p.con(:,12),'f')
fm_windup(p.iq,p.con(:,13),p.con(:,14),'f')
