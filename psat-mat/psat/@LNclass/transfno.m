function n = transfno(a)

n = 0;

if ~a.n, return, end

n = length(find(a.con(:,7) ~= 0));

