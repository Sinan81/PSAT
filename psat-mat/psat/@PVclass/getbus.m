function bus = getbus(a,varargin)

if a.n

  if nargin > 1
    type = varargin{1};
  else
    type = 'angle';
  end
  
  switch type
   case {'voltage','v'}
    bus = a.vbus(find(a.u));
   case {'angle','a'}
    bus = a.bus(find(a.u));
   otherwise
    bus = [];
  end

else

  bus = [];

end
