function bus = getbus(a,varargin)

bus = [];

if ~a.n, return, end

if nargin > 1
  idx = varargin{1};
  if isempty(idx), return, end
  bus = a.bus(idx);
else
  bus = a.bus(find(a.u));
end
