function b = subsref(a,index)

switch index(1).type
 case '.'
  switch index(1).subs
   case 'con'
    if length(index) == 2
      b = a.con(index(2).subs{:});
    else
      b = a.con;
    end
   case 'u'
    if length(index) == 2
      b = a.u(index(2).subs{:});
    else
      b = a.u;
    end
   case 'bus'
    b = a.bus;
   case 'gen'
    b = a.gen;
   case 'freq'
    b = a.freq;
   case 'n'
    b = a.n;
   case 'dat'
    b = a.dat;
   case 'store'
    b = a.store;
   case 'Dfm'
    b = a.Dfm;
   case 'x'
    b = a.x;
   case 'csi'
    b = a.csi;
   case 'pfw'
    b = a.pfw;
   case 'pwa'
    b = a.pwa;
   case 'pf1'
    b = a.pf1;
   case 'pout'
    b = a.pout;
   case 'we'
    b = a.we;
   case 'ncol'
    b = a.ncol;
   case 'format'
    b = a.format;
  end
end
