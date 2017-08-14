function a = restore(a,varargin)

global PQgen

if isempty(a.store)
  a = init(a);
  return
end

a.con = a.store;
a = setup(a);

switch nargin
 case 2
  addpqgen = varargin{1};
 otherwise
  addpqgen = 1;
end

if PQgen.n && addpqgen
  a = addgen(a,PQgen);
end
