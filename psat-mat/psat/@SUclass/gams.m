function [n,idx,data] = gams(a,type)

global Bus GAMS Rmpg

n = int2str(a.n);
idx = sparse(a.bus,[1:a.n],1,Bus.n,a.n);

data = [];

if ~a.n, return, end

[Csa,Csb,Csc,Dsa,Dsb,Dsc] = costs(a);
[Psmax,Psmin] = plim(a);

if GAMS.loaddir
  Ps0 = a.u.*a.con(:,3);
else
  Ps0 = a.u.*a.con(:,6);
end

ksu = a.u.*a.con(:,15);

if GAMS.method < 7
  data.val = [Ps0,Psmax,Psmin,Csa,Csb,Csc,Dsa,Dsb,Dsc,ksu];
else
  Rgup = a.u.*a.con(:,18);
  Rgdw = a.u.*a.con(:,19);
  data.val = [Ps0,Psmax,Psmin,Csa,Csb,Csc,Dsa,Dsb,Dsc,ksu,Rgup,Rgdw];
end

if type == 2 || type == 4
  data.val = [data.val, zeros(a.n,8)];
  data.val = gams(Rmpg,data.val,[5:9,11,12]);
  data.val(:,4) = Csb;
  data.val(:,10) = a.con(:,13);
  data.labels = {cellstr(num2str([1:a.n]')), ...
              {'Ps0','Psmax','Psmin','Cs', ...
               'suc','mut','mdt','rut','rdt','u0','y0','z0'}};
else
  if GAMS.method < 7
    data.labels = {cellstr(num2str([1:a.n]')), ...
                {'Ps0','Psmax','Psmin','Csa','Csb', ...
                 'Csc','Dsa','Dsb','Dsc','ksu'}};
  else
    data.labels = {cellstr(num2str([1:a.n]')), ...
                {'Ps0','Psmax','Psmin','Csa','Csb', ...
                 'Csc','Dsa','Dsb','Dsc','ksu','RGup','RGdw'}};
  end
end

data.name = 'S';
