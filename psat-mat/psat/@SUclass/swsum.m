function swsum(a,k)

global SW

if ~a.n, return, end

for i = 1:a.n
  idx = findbus(SW,a.bus(i));
  SW = swsum(SW,idx,k*a.con(i,6)*a.u(i));
end
        
