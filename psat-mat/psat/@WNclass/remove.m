function a = remove(a,idx)

if ~a.n, return, end
if isempty(idx), return, end

a.con(idx,:) = [];
a.n = a.n - length(idx);
a.speed(idx).vw = [];
a.speed(idx).time = [];
a.vwa(idx) = [];
a.vw(idx) = [];
a.ws(idx) = [];
