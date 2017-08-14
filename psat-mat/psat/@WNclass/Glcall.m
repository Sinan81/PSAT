function Glcall(a)

global DAE

if ~a.n, return, end

DAE.Gl = DAE.Gl + sparse(a.ws,1,wspeed(a),DAE.m,1);
