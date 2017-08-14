function F = pjflows(a,type,pfl,flag)
% PJFLOWS computes currents and powers in transmission lines
%         and the associated Jacobian matrices
%
% NOTE: Flows are Jacobians computed by this function are valid
%       only for transmsmission lines whith tap ratio = 1.
%
% pfl = index of lines
% nsl = length(pfl)
%
% Fij -> column vector (nsl,1) of flows from bus i to bus j
% Jij -> Jacobian matrix (nsl,4) of flows from bus i to bus j
%
% Fji -> column vector (nsl,1) of  flows from bus j to bus i
% Jji -> Jacobian matrix (nsl,4) of flows from bus j to bus i

global DAE

% line flows
V1 = DAE.y(a.vfr(pfl));
V2 = DAE.y(a.vto(pfl));
theta1 = DAE.y(a.fr(pfl));
theta2 = DAE.y(a.to(pfl));
rl = a.con(pfl,8);
xl = a.con(pfl,9);
bl = a.u(pfl).*a.con(pfl,10);
z = rl + i*xl;
y = a.u(pfl)./z;
g12 = real(y);
b12 = imag(y);
bl0 = 0.5*bl;

switch flag
 case 1, F = zeros(length(pfl),1);
 case 2, F = zeros(length(pfl),4);
end

switch type
 case 1  % P12

  cc = cos(theta1-theta2);
  ss = sin(theta1-theta2);
  if flag == 2
    F(:,1) = -V1.*V2.*(-g12.*ss+b12.*cc);      % dP12/d(theta1)
    F(:,2) = 2.*V1.*g12-V2.*(g12.*cc+b12.*ss); % dP12/dV1
    F(:,3) = -V1.*V2.*(g12.*ss-b12.*cc);       % dP12/d(theta2)
    F(:,4) = -V1.*(g12.*cc+b12.*ss);           % dP12/dV2
  else
    F = V1.^2.*g12 - V1.*V2.*(g12.*cc+b12.*ss);
  end

 case 2  % P21

  cc = cos(theta1-theta2);
  ss = sin(theta1-theta2);
  if flag == 2
    F(:,1) = -V1.*V2.*(-g12.*ss-b12.*cc);     % dP21/d(theta1)
    F(:,2) = -V2.*(g12.*cc-b12.*ss);          % dP21/dV1
    F(:,3) = -V1.*V2.*(g12.*ss+b12.*cc);      % dP21/d(theta2)
    F(:,4) = 2*V2.*g12-V1.*(g12.*cc-b12.*ss); % dP21/dV2
  else
    F = V2.^2.*g12 - V1.*V2.*(g12.*cc-b12.*ss);
  end

 case 3  % I12

  V11 = V1.*exp(i*theta1);
  V22 = V2.*exp(i*theta2);
  I12 = (V11-V22).*y + i*V11.*bl0;  % Is
  Ir12 = real(I12);
  Im12 = imag(I12);
  if flag == 2
    aI12 = abs(I12);
    cs1 = cos(theta1);
    cs2 = cos(theta2);
    sn1 = sin(theta1);
    sn2 = sin(theta2);
    JIr12_1=g12.*cs1-b12.*sn1-bl0.*sn1;              % dIr12/dV1
    JIr12_2=-V1.*g12.*sn1-V1.*b12.*cs1-V1.*bl0.*cs1; % dIr12/theta1
    JIr12_3=-g12.*cs2+b12.*sn2;                      % dIr12/dV2
    JIr12_4=V2.*g12.*sn2+V2.*b12.*cs2;               % dIr12/theta2
    JIm12_1=b12.*cs1+g12.*sn1+bl0.*cs1;              % dIm12/dV1
    JIm12_2=-V1.*b12.*sn1+V1.*g12.*cs1-V1.*bl0.*sn1; % dIm12/theta1
    JIm12_3=-b12.*cs2-g12.*sn2;                      % dIm12/dV2
    JIm12_4=V2.*b12.*sn2-V2.*g12.*cs2;               % dIm12/theta2
    F(:,1) = (Ir12.*JIr12_2+Im12.*JIm12_2)./aI12; % dI12/theta1
    F(:,2) = (Ir12.*JIr12_1+Im12.*JIm12_1)./aI12; % dI12/dV1
    F(:,3) = (Ir12.*JIr12_4+Im12.*JIm12_4)./aI12; % dI12/theta2
    F(:,4) = (Ir12.*JIr12_3+Im12.*JIm12_3)./aI12; % dI12/dV2
  else
    F = abs(I12);
  end

 case 4  % I21

  V11 = V1.*exp(i*theta1);
  V22 = V2.*exp(i*theta2);
  I21 = (V22-V11).*y + i*V22.*bl0;  % Ir
  Ir21 = real(I21);
  Im21 = imag(I21);
  if flag == 2
    aI21 = abs(I21);
    cs1 = cos(theta1);
    cs2 = cos(theta2);
    sn1 = sin(theta1);
    sn2 = sin(theta2);
    JIr21_1 = -g12.*cs1+b12.*sn1;                      % dIr21/dV1
    JIr21_2 = V1.*b12.*cs1+V1.*g12.*sn1;               % dIr21/theta1
    JIr21_3 = g12.*cs2-b12.*sn2-bl0.*sn2;              % dIr21/dV2
    JIr21_4 = -V2.*g12.*sn2-V2.*b12.*cs2-V2.*bl0.*cs2; % dIr21/theta2
    JIm21_1 = -b12.*cs1-g12.*sn1;                      % dIm21/dV1
    JIm21_2 = V1.*b12.*sn1-V1.*g12.*cs1;               % dIm21/theta1
    JIm21_3 = g12.*sn2+b12.*cs2+bl0.*cs2;              % dIm21/dV2
    JIm21_4 = V2.*g12.*cs2-V2.*b12.*sn2-V2.*bl0.*sn2;  % dIm21/theta2
    F(:,1) = (Ir21.*JIr21_2+Im21.*JIm21_2)./aI21; % dI21/theta1
    F(:,2) = (Ir21.*JIr21_1+Im21.*JIm21_1)./aI21; % dI21/dV1
    F(:,3) = (Ir21.*JIr21_4+Im21.*JIm21_4)./aI21; % dI21/theta2
    F(:,4) = (Ir21.*JIr21_3+Im21.*JIm21_3)./aI21; % dI21/dV2
  else
    F = abs(I21);    
  end

 case 5  % Q12

  cc = cos(theta1-theta2);
  ss = sin(theta1-theta2);
  if flag == 2
    F(:,1) = -V1.*V2.*(g12.*cc+b12.*ss);              % dQ12/d(theta1)
    F(:,2) = -2.*V1.*(b12+bl0)-V2.*(g12.*ss-b12.*cc); % dQ12/dV1
    F(:,3) = -V1.*V2.*(-g12.*cc-b12.*ss);             % dQ12/d(theta2)
    F(:,4) = -V1.*(g12.*ss-b12.*cc);                  % dQ12/dV2
  else
    F = -V1.^2.*(b12+bl0)-V1.*V2.*(g12.*ss-b12.*cc);    
  end

 case 6  % Q21

  cc = cos(theta1-theta2);
  ss = sin(theta1-theta2);
  if flag == 2
    F(:,1) = V1.*V2.*(g12.*cc-b12.*ss);             % dQ12/d(theta1)
    F(:,2) = V2.*(g12.*ss+b12.*cc);                 % dQ12/dV1
    F(:,3) = V1.*V2.*(-g12.*cc+b12.*ss);            % dQ12/d(theta2)
    F(:,4) = -2*V2.*(b12+bl0)+V1.*(g12*ss+b12.*cc); % dQ12/dV2
  else
    F = -V2.^2.*(b12+bl0)+V1.*V2.*(g12.*ss+b12.*cc);    
  end

end

