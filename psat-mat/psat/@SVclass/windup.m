function windup(a)

if ~a.n, return, end

if a.ty1, fm_windup(a.bcv,a.con(a.ty1,9),a.con(a.ty1,10),'td'), end
if a.ty2, fm_windup(a.alpha,a.con(a.ty2,9),a.con(a.ty2,10),'td'), end
