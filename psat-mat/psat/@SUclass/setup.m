function a = setup(a)

global Bus

if isempty(a.con)
  a.store = [];
  return
end

a.n = length(a.con(:,1));
a.bus = getint(Bus,a.con(:,1));

nsup = length(a.con(1,:));
if nsup < 14,
  a.con = [a.con, zeros(a.n,14-nsup)];
end

switch length(a.con(1,:))
 case a.ncol
  % All OK!
 case 14
  a.con = [a.con,ones(a.n,1),zeros(a.n,2),a.con(:,8),a.con(:,8),ones(a.n,1)];    
 case 15
  a.con = [a.con,zeros(a.n,2),a.con(:,8),a.con(:,8),ones(a.n,1)]; 
 case 16
  a.con = [a.con,zeros(a.n,1),a.con(:,8),a.con(:,8),ones(a.n,1)]; 
 case 17
  a.con = [a.con,a.con(:,8),a.con(:,8),ones(a.n,1)]; 
 case 18
  a.con = [a.con,a.con(:,8),ones(a.n,1)];
 case 19
  a.con = [a.con,ones(a.n,1)];  
end

a.u = a.con(:,a.ncol);
a.store = a.con;
