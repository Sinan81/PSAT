function u = istime(a,t)

u = 0;

if ~a.n, return, end 
if isempty(t), return, end

u = ~isempty(find([a.con(:,5);a.con(:,6)] == t(1)));
