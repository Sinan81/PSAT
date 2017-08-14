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
   case {'gen','g'}
    bus = a.bus(find(a.u & a.gen));
   otherwise
    bus = [];
  end

else

  bus = [];

end
