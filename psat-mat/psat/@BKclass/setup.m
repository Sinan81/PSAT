function a = setup(a)

global Bus Line

if isempty(a.con)
  a.store = [];
  return
end

if ~isempty(a.con)
  a.line = a.con(:,1);
  a.bus = getint(Bus,a.con(:,2));
  a.n = length(a.con(:,1));
  a.u = a.con(:,6);

  % finding breakers that are initially open
  idx = find(~a.u);
  Line.u(a.line(idx)) = 0;
  % swap intervention times so that first
  % intervention will close the breaker
  %if ~isempty(idx)
  %  a.con(idx,[7 8]) = a.con(idx,[8 7]);
  %end
  
  % check data consistency
  ncol = size(a.con,2);
  switch ncol
   case 8, a.con = [a.con, ones(a.n,2)];
   case 9, a.con = [a.con, ones(a.n,1)];
   case 10, % everything ok!
   otherwise
    fm_disp('* * * Error: Breaker data are not complete!')
    a.con = [a.con, zeros(a.n, a.ncol-ncol)];
  end
  
  % set intervention times
  a.t1 = a.con(find(a.con(:,9)),7);
  a.t2 = a.con(find(a.con(:,10)),8);
  
  % intervention times t = 0 are not allowed
  idx = find(a.con(:,7) == 0 & a.con(:,9));
  if ~isempty(idx)
    a.con(idx,7) = 1e-6;
    a.con(idx,8) = a.con(idx,8)+1e-6;
  end
  idx = find(a.con(:,8) == 0 & a.con(:,10));
  if ~isempty(idx)
    a.con(idx,8) = 1e-6;
    a.con(idx,7) = a.con(idx,7)+1e-6;
  end
end

a.store = a.con;
