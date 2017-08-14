function b = subsref(a,index)
% returns device properties
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
   case 'n'
    b = a.n;
   case 'syn'
    b = a.syn;
   case 'pm'
    b = a.pm;
   case 'wref'
    if length(index) == 2
      b = a.wref(index(2).subs{:});
    else
      b = a.wref;
    end
   case 'tg'
    b = a.tg;
   case 'tg1'
    b = a.tg1;
   case 'tg2'
    b = a.tg2;
   case 'tg3'
    b = a.tg3;
   case 'tg4'
    b = a.tg4;
    case 'tg5'
    b = a.tg5;
   case 'ncol'
    b = a.ncol;
   case 'format'
    b = a.format;
   case 'dat1'
    if length(index) == 2
      b = a.dat1(index(2).subs{:});
    else
      b = a.dat1;
    end
   case 'dat2'
    if length(index) == 2
      b = a.dat2(index(2).subs{:});
    else
      b = a.dat2;
    end
   case 'dat3'
    if length(index) == 2
      b = a.dat3(index(2).subs{:});
    else
      b = a.dat3;
    end
   case 'dat4'
    if length(index) == 2
      b = a.dat4(index(2).subs{:});
    else
      b = a.dat4;
    end
   case 'dat5'
    if length(index) == 2
      b = a.dat5(index(2).subs{:});
    else
      b = a.dat5;
    end
   case 'dat6'
    if length(index) == 2
      b = a.dat6(index(2).subs{:});
    else
      b = a.dat6;
    end  
   case 'store'
    if length(index) == 2
      b = a.store(index(2).subs{:});
    else
      b = a.store;
    end
  end
end
