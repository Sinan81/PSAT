function fm_setgy(varargin)

global DAE

switch nargin
  case 1
    idx = varargin{1};
    type = 1;
  case 2
    idx = varargin{1};
    type = varargin{2};
end

if isempty(idx), return, end

switch type
  case 1
    DAE.Gy(idx,:) = 0;
    DAE.Gy(:,idx) = 0;
    DAE.Gy = DAE.Gy + sparse(idx,idx,1,DAE.m,DAE.m);
  case 2
    DAE.Gy(idx,:) = 0;
    DAE.Gy(:,idx) = 0;
    DAE.Gy = DAE.Gy + sparse(idx,idx,1,DAE.m,DAE.m);
    DAE.Fy(:,idx) = 0;
    DAE.Gx(idx,:) = 0;
end
