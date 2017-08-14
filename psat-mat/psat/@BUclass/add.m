function [a,newbus] = add(a,data,name,idx,str)

global DAE

if isempty(data), return, end

[nrow,ncol] = size(data);
busmax = length(a.int);
nb = [1:nrow]';
data(:,1) = busmax + nb;
newbus = data(:,1);
a.int = [a.int; a.n + nb];

DAE.y(2*a.n + nrow + nb) = data(:,3);
DAE.y(a.n + nb) = data(:,4);

a.n = a.n + nrow;
DAE.m = DAE.m + 2*nrow;
a.con = [a.con; data];
a.a = [1:a.n]';
a.v = a.a + a.n;

% update algebraic variables
DAE.y = zeros(DAE.m,1);
DAE.g = zeros(DAE.m,1);
DAE.Gy = sparse(DAE.m,DAE.m);
DAE.y(a.a) = a.con(:,4);
DAE.y(a.v) = a.con(:,3);

if ~isempty(a.names)
  if isempty(name)
    for i = 1:nrow
      a.names{end+1,1} = [a.names{a.int(idx(i))},str];
    end
  else
    for i = 1:nrow
      a.names{end+1,1} = name{i};
    end    
  end
end

a.Pl = [a.Pl; zeros(nrow,1)];
a.Ql = [a.Ql; zeros(nrow,1)];
a.Pg = [a.Pg; zeros(nrow,1)];
a.Qg = [a.Qg; zeros(nrow,1)];
