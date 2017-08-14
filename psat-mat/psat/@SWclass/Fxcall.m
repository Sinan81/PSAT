function Fxcall(p,varargin)

global DAE

if ~p.n, return, end

if nargin == 1
  type = 'all';
else
  type = varargin{1};
end

idx = p.vbus(find(p.u));

if isempty(idx),return, end

DAE.Fy(:,idx) = 0;
DAE.Gx(idx,:) = 0;

if strcmp(type,'onlyq'), return, end

idx = p.bus(find(p.u));
DAE.Fy(:,idx) = 0;
DAE.Gx(idx,:) = 0;

