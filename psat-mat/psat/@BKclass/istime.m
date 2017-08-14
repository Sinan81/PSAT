function u = istime(a,t)

u = 0;

if ~a.n, return, end 
if isempty(t), return, end

u = ~isempty(find([a.t1; a.t2] == t(1)));
