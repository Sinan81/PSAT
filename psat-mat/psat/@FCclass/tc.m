function T = tc(a,T,T0,Tn)

idx = find(T == 0);
if idx
  T(idx) = T0;
  warn(a,idx, ['Time constant ', Tn, ...
               ' cannot be zero. ', ...
               Tn, ' = ', num2str(T0), ...
               ' s will be used.'])
end
