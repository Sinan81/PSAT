% This program forms the complex bus impedance matrix by the method
% of building algorithm.  Bus zero is taken as reference.
% This program is compatible with power flow data.
%  Copyright (C) 1998  by H. Saadat.

function [Zbus, linedata] = zbuildpi(linedata, gendata, yload)

% gendata generator data syn.con
ng = length(gendata(:,1));
nlg = gendata(:,1);
nrg = zeros(size(gendata(:,1)));
zg = gendata(:,7) + j*gendata(:,6);

nl = linedata(:,1); 
nr = linedata(:,2); 

R = linedata(:,8);
X = linedata(:,9);
ZB = R + j*X;

nbr = length(linedata(:,1)); 
nbus = max(max(nl), max(nr));
nc = length(linedata(1,:));

BC = 0.5*linedata(:,10);
yc = zeros(nbus,1);
nlc = zeros(nbus,1);
nrc = zeros(nbus,1);

for n = 1:nbus
  yc(n) = 0;
  nlc(n) = 0; 
  nrc(n) = n;
  for k = 1:nbr
    if nl(k) == n || nr(k) == n
      yc(n) = yc(n) + j*BC(k);
    end
  end
end

if exist('yload') == 1
  yload = yload.';
  yc = yc + yload;
end

m = 0;
havecc = 0; % have cc ? 

for n = 1:nbus
  if abs(yc(n)) ~=0
    m = m + 1;
    nlcc(m) = nlc(n);
    nrcc(m) = nrc(n);
    zc(m) = 1/yc(n);
    havecc = 1;
  end
end

if havecc == 1 
  nlcc = nlcc'; 
  nrcc = nrcc'; 
  zc = zc.';
  nl = [nlg; nlcc; nl];
  nr = [nrg; nrcc; nr];
  ZB = [zg; zc; ZB];
else
  nl = [nlg; nl];
  nr = [nrg; nr];
  ZB = [zg; ZB];    
end    

% standard line data consist of line generator capacitor of line model and load
linedata = [nl nr real(ZB) imag(ZB)]; 
nbr = length(nl);
Zbus = zeros(nbus, nbus);
tree = 0;  %%%%new

% Adding a branch from a new bus to reference bus 0
for I = 1:nbr
  ntree(I) = 1;
  if nl(I) == 0 || nr(I) == 0
    if nl(I) == 0
      n = nr(I);
    elseif nr(I) == 0
      n = nl(I);
    end
    if abs(Zbus(n, n)) == 0 
      Zbus(n,n) = ZB(I);
      tree = tree+1; %%new
    else 
      Zbus(n,n) = Zbus(n,n)*ZB(I)/(Zbus(n,n) + ZB(I));
    end
    ntree(I) = 2;
  end
end

% Adding a branch from new bus to an existing bus
while tree < nbus  %%% new

  for n = 1:nbus
    nadd = 1;
    if abs(Zbus(n,n)) == 0
      for I = 1:nbr
        if nadd == 1
          if nl(I) == n || nr(I) == n
            if nl(I) == n
              k = nr(I);
            elseif nr(I) == n
              k = nl(I);
            end
            if abs(Zbus(k,k)) ~= 0
              for m = 1:nbus
                if m ~= n
                  Zbus(m,n) = Zbus(m,k);
                  Zbus(n,m) = Zbus(m,k);
                end
              end
              Zbus(n,n) = Zbus(k,k) + ZB(I); 
              tree=tree+1; %%new
              nadd = 2; 
              ntree(I) = 2;
            end
          end
        end
      end
    end
  end
end  %%%%%%new

% Adding a link between two old buses
for n = 1:nbus
  for I = 1:nbr
    if ntree(I) == 1
      if nl(I) == n || nr(I) == n
        if nl(I) == n
          k = nr(I);
        elseif nr(I) == n 
          k = nl(I);
        end
        DM = Zbus(n,n) + Zbus(k,k) + ZB(I) - 2*Zbus(n,k);
        for jj = 1:nbus
          AP = Zbus(jj,n) - Zbus(jj,k);
          for kk = 1:nbus
            AT = Zbus(n,kk) - Zbus(k, kk);
            DELZ(jj,kk) = AP*AT/DM;
          end
        end
        Zbus = Zbus - DELZ;
        ntree(I) = 2;
      end
    end
  end
end

disp('end of zbus build')
