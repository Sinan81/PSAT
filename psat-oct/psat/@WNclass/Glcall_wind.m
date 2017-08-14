function Glcall_wind(a)

global DAE

if ~a.n, return, end

DAE.Gl = DAE.Gl + sparse(a.ws,1,wspeed_wind(a),DAE.m,1);
