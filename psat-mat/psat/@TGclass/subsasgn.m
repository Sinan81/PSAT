function a = subsasgn(a,index,val)
% assigns device properties. properties that are not listed in this
% function cannot be assigned from outside of the class
switch index(1).type
 case '.'
  switch index(1).subs
   case 'con'
    if length(index) == 2
      a.con(index(2).subs{:}) = val;
    else
      a.con = val;
    end
   case 'u'
    if length(index) == 2
      a.u(index(2).subs{:}) = val;
    else
      a.u = val;
    end
   case 'bus'
    a.bus = val;
   case 'syn'
    a.syn = val;
   case 'pm'
    a.pm = val;
   case 'wref'
    if length(index) == 2
      a.wref(index(2).subs{:}) = val;
    else
      a.wref = val;
    end
   case 'n'
    a.n = val;
   case 'store'
    if length(index) == 2
      a.store(index(2).subs{:}) = val;
    else
      a.store = val;
    end
   case 'dat1'
    if length(index) == 2
      a.dat1(index(2).subs{:}) = val;
    else
      a.dat1 = val;
    end
   case 'dat2'
    if length(index) == 2
      a.dat2(index(2).subs{:}) = val;
    else
      a.dat2 = val;
    end
   case 'dat3'
    if length(index) == 2
      a.dat3(index(2).subs{:}) = val;
    else
      a.dat3 = val;
    end
   case 'dat4'
    if length(index) == 2
      a.dat4(index(2).subs{:}) = val;
    else
      a.dat4 = val;
    end
   case 'dat5'
    if length(index) == 2
      a.dat5(index(2).subs{:}) = val;
    else
      a.dat5 = val;
    end
   case 'dat6'
    if length(index) == 2
      a.dat6(index(2).subs{:}) = val;
    else
      a.dat6 = val;
    end
  end
end
