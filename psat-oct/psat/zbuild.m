% This program forms the complex bus impedance matrix by the method
% of building algorithm.  Bus zero is taken as reference.
%  Copyright (c) 1998  by H. Saadat
%

% Update By s.m. Shariatzadeh For Psat Data Format 

function [Zbus] = zbuild(linedata)

nl = linedata(:,1); 
nr = linedata(:,2); 

R = linedata(:,8);
X = linedata(:,9);

nbr = length(linedata(:,1)); 
nbus = max(max(nl), max(nr));

for k=1:nbr
  if R(k) == inf || X(k) == inf
    R(k) = 99999999; 
    X(k) = 99999999;
  end
end

ZB = R + j*X;
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
      tree = tree + 1; %%new
    else 
      Zbus(n,n) = Zbus(n,n)*ZB(I)/(Zbus(n,n) + ZB(I));
    end
    ntree(I) = 2;
  end
end

Zbus

% Adding a branch from new bus to an existing bus
while tree < nbus  %%% new

  for n = 1:nbus
    nadd = 1;
    if abs(Zbus(n,n)) == 0
      for I = 1:nbr
        if nadd == 1;
          if nl(I) == n || nr(I) == n
            if nl(I) == n
              k = nr(I);
            elseif nr(I) == n
              k = nl(I);
            end
            %if abs(Zbus(k,k)) ~= 0
            for m = 1:nbus
              if m ~= n
                Zbus(m,n) = Zbus(m,k);
                Zbus(n,m) = Zbus(m,k);
              end
            end
            Zbus(n,n) = Zbus(k,k) + ZB(I); tree=tree+1; %%new
            nadd = 2;  ntree(I) = 2;
            %else, end
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
