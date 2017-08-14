function Fxcall(p)

global DAE Line

if ~p.n, return, end

Vs = DAE.y(p.Vs);
u = p.u & Vs < p.con(:,5) & Vs > p.con(:,6);

Kw = p.u.*p.con(:,7);
Tw = p.con(:,8);
T1 = p.con(:,9);
T2 = p.con(:,10);
T3 = p.con(:,11);
T4 = p.con(:,12);

A = p.u.*T1./T2;
B = p.u - A;
C = p.u.*T3./T4;
D = p.u - C;

DAE.Fx = DAE.Fx - sparse(p.v1,p.v1,1./Tw,DAE.n,DAE.n);   % df1/dv1
DAE.Fx = DAE.Fx - sparse(p.v2,p.v1,p.u./T2,DAE.n,DAE.n); % df2/dv1
DAE.Fx = DAE.Fx - sparse(p.v2,p.v2,1./T2,DAE.n,DAE.n);   % df2/dv2
DAE.Fx = DAE.Fx - sparse(p.v3,p.v1,A./T4,DAE.n,DAE.n);   % df3/dv1
DAE.Fx = DAE.Fx + sparse(p.v3,p.v2,B./T4,DAE.n,DAE.n);   % df3/dv2
DAE.Fx = DAE.Fx - sparse(p.v3,p.v3,1./T4,DAE.n,DAE.n);   % df3/dv3

DAE.Gx = DAE.Gx - sparse(p.Vs,p.v1,u.*A.*C,DAE.m,DAE.n); % df4/dv1
DAE.Gx = DAE.Gx + sparse(p.Vs,p.v2,u.*B.*C,DAE.m,DAE.n); % df4/dv2
DAE.Gx = DAE.Gx + sparse(p.Vs,p.v3,u.*D,DAE.m,DAE.n);    % df4/dv3

K1 = Kw./Tw;
K2 = Kw./T2;
K3 = Kw.*A./T4;

SIv  = find(p.type == 1); % V
SIPs = find(p.type == 2); % Pij
SIPr = find(p.type == 3); % Pji
SIIs = find(p.type == 4); % Iij
SIIr = find(p.type == 5); % Iji
SIQs = find(p.type == 6); % Qij
SIQr = find(p.type == 7); % Qji
S = find(p.type > 1);

if SIPs, JPs = pjflows(Line,1,p.idx(SIPs),2); end
if SIPr, JPr = pjflows(Line,2,p.idx(SIPr),2); end
if SIIs, JIs = pjflows(Line,3,p.idx(SIIs),2); end
if SIIr, JIr = pjflows(Line,4,p.idx(SIIr),2); end
if SIQs, JQs = pjflows(Line,5,p.idx(SIQs),2); end
if SIQr, JQr = pjflows(Line,6,p.idx(SIQr),2); end

if SIv
  DAE.Fy = DAE.Fy + sparse(p.v1(SIv),p.idx(SIv),K1(SIv),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(p.v2(SIv),p.idx(SIv),K2(SIv),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(p.v3(SIv),p.idx(SIv),K3(SIv),DAE.n,DAE.m);
end

if S

  L = p.idx(S);
  J = zeros(p.n,4);

  if SIPs, J(SIPs,:) = JPs; end
  if SIPr, J(SIPr,:) = JPr; end
  if SIQs, J(SIQs,:) = JQs; end
  if SIQr, J(SIQr,:) = JQr; end
  if SIIs, J(SIIs,:) = JIs; end
  if SIIr, J(SIIr,:) = JIr; end
  
  DAE.Fy = DAE.Fy + sparse(p.v1(S),Line.fr(L),K1(S).*J(S,1),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(p.v1(S),Line.vfr(L),K1(S).*J(S,2),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(p.v1(S),Line.to(L),K1(S).*J(S,3),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(p.v1(S),Line.vto(L),K1(S).*J(S,4),DAE.n,DAE.m);
  
  DAE.Fy = DAE.Fy + sparse(p.v2(S),Line.fr(L),K2(S).*J(S,1),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(p.v2(S),Line.vfr(L),K2(S).*J(S,2),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(p.v2(S),Line.to(L),K2(S).*J(S,3),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(p.v2(S),Line.vto(L),K2(S).*J(S,4),DAE.n,DAE.m);
  
  DAE.Fy = DAE.Fy + sparse(p.v3(S),Line.fr(L),K3(S).*J(S,1),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(p.v3(S),Line.vfr(L),K3(S).*J(S,2),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(p.v3(S),Line.to(L),K3(S).*J(S,3),DAE.n,DAE.m);
  DAE.Fy = DAE.Fy + sparse(p.v3(S),Line.vto(L),K3(S).*J(S,4),DAE.n,DAE.m);
  
end
