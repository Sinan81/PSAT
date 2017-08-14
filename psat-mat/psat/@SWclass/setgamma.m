function a = setgamma(a)

z = a.con(:,12);
a.u = a.con(:,a.ncol);

a.con(find(z & a.u),11) = 1;
