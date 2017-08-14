function a = setdat(a)

global Bus Settings

Wn = 2*pi*Settings.freq;

a.dat = ones(a.n,11);

% torque coefficient: A + B*slip + C*slip^2
a.dat(:,1) =  a.con(:,15) + a.con(:,16) + a.con(:,17);
a.dat(:,2) = -a.con(:,16) - 2*a.con(:,17);
a.dat(:,3) =  a.con(:,17);

% 1/(2*Hm)
a.dat(:,4) = 1./(2*a.con(:,14));

% x0 x' x"
a.dat(:,5) =  a.con(:,8) + a.con(:,13);
a.dat(:,6) =  a.con(:,8) + a.con(:,10).*a.con(:,13)./ ...
    (a.con(:,10)+a.con(:,13));
a.dat(:,7) =  a.con(:,8) + a.con(:,10).*a.con(:,12).* ...
    a.con(:,13)./(a.con(:,10).*a.con(:,13) + a.con(:,12).* ...
                    a.con(:,13)+a.con(:,10).*a.con(:,12));

% T'0  T"0
a.con(find(a.con(:,9) == 0),9) = 1;
a.con(find(a.con(:,11) == 0),11) = 1;
a.dat(:,8) = (a.con(:,10)+a.con(:,13))./a.con(:,9)/Wn;
a.dat(:,9) = (a.con(:,12) + a.con(:,10).*a.con(:,13)./ ...
                (a.con(:,10)+a.con(:,13)))./a.con(:,11)/Wn;

% 1/xm    x's = xs + xr1
noxm = find(a.con(:,13) == 0);
for i = 1:length(noxm)
  if ord(noxm(i)) == 1
    fm_disp(['Zero magnetising reactance found for induction motor #',
             num2str(noxm(i)),' at Bus ',Bus.names{noxm(i)}],2)
  end
  a.con(noxm(i),13) = 1;
end
a.dat(:,10) = 1./a.con(:,13);
a.dat(:,11) = a.con(:,8)+a.con(:,10);
