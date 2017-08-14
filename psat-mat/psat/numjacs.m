fm_call('i')

ffn = DAE.f;
ggn = DAE.g;
xa  = DAE.x;
ya  = DAE.y;
tol = 1e-8;

Gx = zeros(DAE.m,DAE.n);
Fx = zeros(DAE.n,DAE.n);
Gy = zeros(DAE.m,DAE.m);
Fy = zeros(DAE.n,DAE.m);

black_list = [Ddsg.theta_p; Dfig.theta_p; Oxl.v; Hvdc.xi];

for j = 1:DAE.m;

  deltaa = max(tol,abs(tol*DAE.y(j)));
  DAE.y(j)=DAE.y(j)+deltaa;
  
  fm_call('i')

  if DAE.n, Fy(:,j)=(DAE.f-ffn)./deltaa; end
  Gy(:,j)=(DAE.g-ggn)./deltaa;

  DAE.x  = xa;
  DAE.y  = ya;

end

fm_call('i')

for j = 1:DAE.n;

  deltaX = max(tol,abs(tol*DAE.x(j)));
  Xinc = deltaX;
  if ~isempty(black_list)
    if ~isempty(find(black_list == j))
      Xinc = 0;
    end
  end
  DAE.x(j)=DAE.x(j)+Xinc;
  
  fm_call('i')

  Fx(:,j)=(DAE.f-ffn)./deltaX;
  Gx(:,j)=(DAE.g-ggn)./deltaX;

  DAE.x  = xa;
  DAE.y  = ya;

end

Sbus = getbus(SW);
Gbus = [getbus(SW,'v');getbus(PV,'v')];

if ~DAE.n
  Fx = 1;
  Gx = zeros(DAE.m,1);
  Fy = zeros(1,DAE.m);
end

if ~isempty(black_list)
  for i = 1:length(black_list)
    k = black_list(i);
    Fx(k,k) = DAE.Fx(k,k);
  end
end

for i = 1:length(Hvdc.cosg)
  k = Hvdc.cosg(i);
  Gy(k,k) = DAE.Gy(k,k);
  k = Hvdc.xi(i);
  h = Hvdc.yi(i);
  Fy(k,h) = DAE.Fy(k,h);
  k = Hvdc.xr(i);
  h = Hvdc.yr(i);
  Fy(k,h) = DAE.Fy(k,h);
end

Gy(Gbus,:) = 0;
Gy(:,Gbus) = 0;
Gy(Gbus,Gbus) = eye(getnum(PV)+getnum(SW));
Gy(:,Sbus) = 0;
Gy(Sbus,:) = 0;
Gy(Sbus,Sbus) = eye(getnum(SW));
Fy(:,Sbus) = 0;
Gx(Sbus,:) = 0;
Fy(:,Gbus) = 0;
Gx(Gbus,:) = 0;

