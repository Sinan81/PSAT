function t = fm_strjoin(varargin)
%FM_STRJOIN Concatenate strings.
%   same as STRCAT in Matlab. Used for compatibility with
%   GNU/Octave

if nargin < 1
  disp('Error in fm_strjoin: Not enough input arguments.');
  return
end

% Make sure everything is a cell array
maxsiz = [1 1];
emptyIdx = [];
siz = cell(1,nargin);
tf = zeros(1,nargin);
for i = 1:nargin
  if (isempty(varargin{i}))
    emptyIdx(i) = i;
  end
  if ischar(varargin{i}),
    varargin{i} = cellstr(varargin{i});
  end
  siz{i} = size(varargin{i});
  if prod(siz{i}) > prod(maxsiz),
    maxsiz = siz{i};
  end
  tf(i) = iscell(varargin{i});
end

if ~isempty(emptyIdx)
  emptyIdx = find(emptyIdx);
  varargin(emptyIdx) = [];
  tf(emptyIdx) = [];
  siz(emptyIdx) = [];
end

if ~all(tf)
  disp('Inputs must be cell arrays or strings.')
  return
end

% Scalar expansion
for i = 1:length(varargin)
  if prod(siz{i}) == 1
    varargin{i} = varargin{i}(ones(maxsiz));
    siz{i} = size(varargin{i});
  end
end

%if ((numel(siz) > 1) && ~isequal(siz{:}))
if ((prod(size(siz)) > 1) && ~isequal(siz{:}))
  disp('All the inputs must be the same size or scalars.')
  return
end

s = cell([length(varargin) maxsiz]);
for i = 1:length(varargin)
  s(i,:) = varargin{i}(:);
end

t = cell(maxsiz);
for i = 1:prod(maxsiz)
  t{i} = [s{:,i}];
end

