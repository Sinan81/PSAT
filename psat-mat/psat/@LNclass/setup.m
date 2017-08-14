function a = setup(a,varargin)

global Settings

switch nargin
 case 2
  Bus = varargin{1};
 otherwise
  global Bus
end

if isempty(a.con)
  a.store = [];
  return
end

% set the store data as the original input data
a.store = a.con;

[a.n,ncol] = size(a.con);
[a.fr,a.vfr] = getbus(Bus,a.con(:,1));
[a.to,a.vto] = getbus(Bus,a.con(:,2));

a.p = getzeros(Bus);
a.q = getzeros(Bus);

% size control
if ncol < a.ncol
  a.con = [a.con, zeros(a.n,a.ncol-ncol)];
elseif ncol > a.ncol
  a.con = a.con(:,[1:a.ncol]);
end

% status control
if ncol < a.nu
  a.con(:,a.nu) = ones(a.n,1);
end

% set line status
a.u = a.con(:,a.nu); 

% adjust tap ratio
a.con(find(abs(a.con(:,11))==0),11) = 1;

% set parameters in p.u. (if the length is > 0, unit is km)
idx = find(a.con(:,6));
if ~isempty(idx)
  XB = a.con(idx,4).*a.con(idx,4)./a.con(idx,3);
  a.con(idx,8)  = a.con(idx,6).*a.con(idx,8)./XB;
  a.con(idx,9)  = a.con(idx,6).*a.con(idx,9)./XB*(2*pi*Settings.freq);
  a.con(idx,10) = a.con(idx,6).*a.con(idx,10).*XB*(2*pi*Settings.freq);
  bidx = find(a.con(idx,10) > 10);
  if ~isempty(bidx)
    fm_disp('Warning: Some line susceptances are too high...')
    fm_disp(['         microFarad are assumed for those susceptance' ...
             ' values'])
    a.con(idx(bidx),10) = a.con(idx(bidx),10)/1e6;
  end
end

% check for parameter consistency (zero series impedance is not allowed)
idx = find(a.con(:,8) == 0 & a.con(:,9) == 0);
if ~isempty(idx)
  a.con(idx,9) = 1e-5;
end

% The user can also define directly the admittance matrix
% --------------------------------------------------------------------
% Important notes:
%
% a) It is admitted also the sole superior triangular part.
%
% b) Observe that Line.con containing the from bus and to bus
%    information MUST be defined in the data file.
%
% c) This input method is not reccomended as several features of the
%    Line class will not work properly.
% --------------------------------------------------------------------
if ~isempty(a.Y)

  a.no_build_y = 1;
  
  % assign the full admittance matrix
  ytriu = triu(full(a.Y));
  y0 = diag(ytriu);
  ytril = ytriu - diag(y0);
  ybus = ytriu + ytril.';
  a.Y = ybus;
  
  % approximate series impedances
  yij = zeros(a.n,1);
  for i = 1:a.n, yij(i) = ybus(a.fr(i),a.to(i)); end
  zij = -1./yij;
  a.con(:,8) = real(zij);
  a.con(:,9) = imag(zij);
  
  % approximate shunts
  % the resulting system is typicall under-determined
  nb = length(a.p);
  incmat = zeros(nb,a.n);
  for i = 1:nb
    idx_h = find(a.fr == i);
    idx_k = find(a.to == i);
    if ~isempty(idx_h), incmat(i,idx_h) = 1; end
    if ~isempty(idx_k), incmat(i,idx_k) = 1; end    
  end
  %a.con(:,10) = 2*(incmat\imag(y0));
end
% --------------------------------------------------------------------

Settings.nseries = Settings.nseries + a.n;
