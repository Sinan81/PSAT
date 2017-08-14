function swsum_supply(a,k)

global SW

if ~a.n, return, end

for i = 1:a.n
  idx = findbus_sw(SW,a.bus(i));
  SW = swsum_sw(SW,idx,k*a.con(i,6)*a.u(i));
end
        
