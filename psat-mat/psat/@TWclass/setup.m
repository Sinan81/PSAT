function a = setup(a,varargin)

switch nargin
 case 3
  Bus = varargin{1};
  Line = varargin{2};
 otherwise
  global Bus Line
end

if isempty(a.con)
  a.store = [];
  return
end

[nrows, ncols] = size(a.con);
if ncols < 14
  fm_disp(['Three-winding transformer data does not ', ...
           'seems in a valid format',2])
  return
elseif ncols < 15
  a.con = [a.con,ones(nrows,1),zeros(nrows,9),ones(nrows,1)];
elseif ncols < a.ncol
  a.con = [a.con,zeros(nrows,a.ncol-1-ncols),ones(nrows,1)];
end

% adding the ficticious bus of the equivalent star connection
data = zeros(nrows,6);
data(:,2) = a.con(:,6);
data(:,3) = ones(nrows,1);
data(:,4) = zeros(nrows,1);
data(:,[5 6]) = Bus.con(Bus.int(a.con(:,2)),[5 6]);
[Bus,twt_bus] = add(Bus,data,'',a.con(:,1),'(twt)');

% computing branch impedances
r12 = a.con(:,9);
r13 = a.con(:,10);
r23 = a.con(:,11);
r1 = 0.5*(r12+r13-r23);
r2 = 0.5*(r12+r23-r13);
r3 = 0.5*(r23+r13-r12);
x12 = a.con(:,12);
x13 = a.con(:,13);
x23 = a.con(:,14);
x1 = 0.5*(x12+x13-x23);
x2 = 0.5*(x12+x23-x13);
x3 = 0.5*(x23+x13-x12);

% checking for zero impedances in the equivalent star
idx = find(abs(x1) < 1e-5);
if ~isempty(idx), x1(idx) = 0.0001; end
idx = find(abs(x2) < 1e-5);
if ~isempty(idx), x2(idx) = 0.0001; end
idx = find(abs(x3) < 1e-5);
if ~isempty(idx), x3(idx) = 0.0001; end

% updating Line data
line1 = [a.con(:,1),twt_bus, a.con(:,[4,6,5]),zeros(nrows,1), ...
         ones(nrows,1),r1,x1,zeros(nrows,1), ...
         a.con(:,15), zeros(nrows,1),a.con(:,[16,19,22,25])];
line2 = [twt_bus,a.con(:,[2,4,6,5]),zeros(nrows,1), ...
         a.con(:,6)./a.con(:,7),r2,x2,zeros(nrows,1), ...
         ones(nrows,1),zeros(nrows,1),a.con(:,[17,20,23,25])];
line3 = [twt_bus,a.con(:,[3,4,6,5]),zeros(nrows,1), ...
         a.con(:,6)./a.con(:,8),r3,x3, zeros(nrows,1), ...
         ones(nrows,1), zeros(nrows,1),a.con(:,[18,21,24,25])];
if nargin == 3
  Line = add(Line,[line1; line2; line3],Bus);
else
  Line = add(Line,[line1; line2; line3]);
end

% clear data
a.store = a.con;
a.con = [];
