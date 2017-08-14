function a = subsasgn(a,index,val)

switch index(1).type
 case '.'
  switch index(1).subs
   case 'con'
    if length(index) == 2
      a.con(index(2).subs{:}) = val;
    else
      a.con = val;
    end
   case 'store'
    if length(index) == 2
      a.store(index(2).subs{:}) = val;
    else
      a.store = val;
    end
   case 'u'
    if length(index) == 2
      a.u(index(2).subs{:}) = val;
    else
      a.u = val;
    end
   case 't1'
    if length(index) == 2
      a.t1(index(2).subs{:}) = val;
    else
      a.t1 = val;
    end
   case 't2'
    if length(index) == 2
      a.t2(index(2).subs{:}) = val;
    else
      a.t2 = val;
    end
  end
end
