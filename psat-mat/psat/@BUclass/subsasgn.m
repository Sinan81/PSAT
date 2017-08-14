function a = subsasgn(a,index,val)

switch index(1).type
 case '.'
  switch index(1).subs
   case 'n'
    a.n = val;
   case 'con'
    if length(index) == 2
      a.con(index(2).subs{:}) = val;
    else
      a.con = val;
    end
   case 'int'
    if length(index) == 2
      a.int(index(2).subs{:}) = val;
    else
      a.int = val;
    end
   case 'names'
    if length(index) == 2
      a.names(index(2).subs{:}) = val;
    else
      a.names = val;
    end
   case 'Pg'
    if length(index) == 2
      a.Pg(index(2).subs{:}) = val;
    else
      a.Pg = val;
    end
   case 'Pl'
    if length(index) == 2
      a.Pl(index(2).subs{:}) = val;
    else
      a.Pl = val;
    end
   case 'Qg'
    if length(index) == 2
      a.Qg(index(2).subs{:}) = val;
    else
      a.Qg = val;
    end
   case 'Ql'
    if length(index) == 2
      a.Ql(index(2).subs{:}) = val;
    else
      a.Ql = val;
    end
   case 'a'
    if length(index) == 2
      a.a(index(2).subs{:}) = val;
    else
      a.a = val;
    end
   case 'v'
    if length(index) == 2
      a.v(index(2).subs{:}) = val;
    else
      a.v = val;
    end
   case 'island'
    if length(index) == 2
      a.island(index(2).subs{:}) = val;
    else
      a.island = val;
    end
   case 'store'
    if length(index) == 2
      a.store(index(2).subs{:}) = val;
    else
      a.store = val;
    end
  end
end
