function y = admittance(a)

r = a.con(:,11);
x = a.con(:,12);
z = r+i*x;
y = 1./z;
