function a = restore_pq(a,varargin)

global PQgen

if isempty(a.store)
  a = init_pq(a);
  return
end

a.con = a.store;
a = setup_pq(a);

switch nargin
 case 2
  addpqgen = varargin{1};
 otherwise
  addpqgen = 1;
end

if PQgen.n && addpqgen
  a = addgen_pq(a,PQgen);
end
