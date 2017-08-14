function b = subsref(a,index)

switch index(1).type
 case '.'
  switch index(1).subs
   case 'n'
    b = a.n;
   case 'con'
    if length(index) == 2
      b = a.con(index(2).subs{:});
    else
      b = a.con;
    end
   case 'int'
    if length(index) == 2
      b = a.int(index(2).subs{:});
    else
      b = a.int;
    end
   case 'a'
    if length(index) == 2
      b = a.a(index(2).subs{:});
    else
      b = a.a;
    end
   case 'v'
    if length(index) == 2
      b = a.v(index(2).subs{:});
    else
      b = a.v;
    end
   case 'names'
    if length(index) == 2
      switch index(2).type
       case '{}'
        b = a.names{index(2).subs{:}};
       case '()'
        b = a.names(index(2).subs{:});
      end
    else
      b = a.names;
    end
   case 'Pg'
    if length(index) == 2
      b = a.Pg(index(2).subs{:});
    else
      b = a.Pg;
    end
   case 'Pl'
    if length(index) == 2
      b = a.Pl(index(2).subs{:});
    else
      b = a.Pl;
    end
   case 'Qg'
    if length(index) == 2
      b = a.Qg(index(2).subs{:});
    else
      b = a.Qg;
    end
   case 'Ql'
    if length(index) == 2
      b = a.Ql(index(2).subs{:});
    else
      b = a.Ql;
    end
   case 'island'
    if length(index) == 2
      b = a.island(index(2).subs{:});
    else
      b = a.island;
    end
   case 'store'
    if length(index) == 2
      b = a.store(index(2).subs{:});
    else
      b = a.store;
    end
   case 'ncol'
    b = a.ncol;
   case 'format'
    b = a.format;
  end
end
