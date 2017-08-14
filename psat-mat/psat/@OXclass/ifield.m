function out = ifield(p,type)

global DAE

V_oxl = DAE.x(p.v);

xd = p.con(:,4);
xq = p.con(:,5);

Vg = DAE.y(p.vbus);
Pg = DAE.y(p.p);
Qg = DAE.y(p.q);

t1 = xq.*Qg;
t2 = 1./Vg;
t4 = Vg+t1.*t2;
t5 = t4.*t4;
t6 = Pg.*Pg;
t7 = t5+t6;
t8 = sqrt(t7);
t11 = xd./xq-1.0;
t12 = xq.*t4;
t13 = Qg.*t2;
t15 = xq.*xq;
t16 = t15.*t6;
t17 = Vg.*Vg;
t18 = 1./t17;
t21 = t11.*(t12.*t13+t16.*t18);
t22 = 1./t8;

switch type
 case 1
  
  out = t8+t21.*t22;  
  
 case 2
  
  t30 = t7.*t7;
  t32 = t8./t30;
  t36 = t22.*t4;
  t41 = t12.*t2;
  t49 = 1.0-t1.*t18;
  
  out = zeros(p.n,3);
  
  % partial derivatives of If with respect to Pg, Qg and Vg
  out(:,1) = t22.*Pg+2.0*t11.*t15.*Pg.*t18.*t22-t21.*t32.*Pg;
  out(:,2) = t36.*xq.*t2+t11.*(t15.*t18.*Qg+t41).*t22-t21.*t32.*t41;
  out(:,3) = (t36.*t49+t11.*(xq.*t49.*t13-t12.*Qg.*t18-2.0*t16./t17./Vg).*t22-t21.*t32.*t4.*t49);
  
end
