numjacs
fm_call('i')

disp(' ')

gerr = max(abs(DAE.g));
ferr = max(abs(DAE.f));

disp(['g max err = ',num2str(gerr)])
disp(['f max err = ',num2str(ferr)])

if ferr > Settings.dyntol
  disp('The following elements of the f vector are suspiciously high:')
  disp(' ')
  v = abs(DAE.f);
  i = find(v > Settings.dyntol);
  for h = 1:length(i)
    u = v(i(h));
    disp(['* ', Varname.uvars{i(h)}, ' -> ', num2str(u)])
  end
  disp(' ')
end

if gerr > Settings.dyntol
  disp('The following elements of the g vector are suspiciously high:')
  disp(' ')
  v = abs(DAE.g);
  i = find(v > Settings.dyntol);
  for h = 1:length(i)
    u = v(i(h));
    disp(['* ', Varname.uvars{i(h) + DAE.n}, ' -> ', num2str(u)])
  end
  disp(' ')
end

disp(' ')

disp(['Fx abs err = ',num2str(max(max(abs(DAE.Fx-Fx))))])
disp(['Fy abs err = ',num2str(max(max(abs(DAE.Fy-Fy))))])
disp(['Gx abs err = ',num2str(max(max(abs(DAE.Gx-Gx))))])
disp(['Gy abs err = ',num2str(max(max(abs(DAE.Gy-Gy))))])

disp(' ')

if DAE.n 
  [i,j] = find(abs(DAE.Fx) <= Settings.dyntol);
  Fxtmp = DAE.Fx + sparse(i,j,1,DAE.n,DAE.n);
  
  [i,j] = find(abs(DAE.Fy) <= Settings.dyntol);
  Fytmp = DAE.Fy + sparse(i,j,1,DAE.n,DAE.m);
  
  [i,j] = find(abs(DAE.Gx) <= Settings.dyntol);
  Gxtmp = DAE.Gx + sparse(i,j,1,DAE.m,DAE.n);
else
  Fxtmp = 1;
  Fytmp = ones(1,DAE.m);
  Gxtmp = ones(DAE.m,1);
end

[i,j] = find(abs(DAE.Gy) <= Settings.dyntol);
Gytmp = DAE.Gy + sparse(i,j,1,DAE.m,DAE.m);

Fxerr = max(max(abs((DAE.Fx-Fx)./Fxtmp)));
Fyerr = max(max(abs((DAE.Fy-Fy)./Fytmp)));
Gxerr = max(max(abs((DAE.Gx-Gx)./Gxtmp)));
Gyerr = max(max(abs((DAE.Gy-Gy)./Gytmp)));

disp(['Fx rel err = ',num2str(Fxerr)])
disp(['Fy rel err = ',num2str(Fyerr)])
disp(['Gx rel err = ',num2str(Gxerr)])
disp(['Gy rel err = ',num2str(Gyerr)])

disp(' ')

if Fxerr > Settings.dyntol
  disp('The following elements of the Fx matrix are suspiciously high:')
  disp(' ')
  v = abs((DAE.Fx-Fx)./Fxtmp);
  [i, j] = find(v > Settings.dyntol);
  for h = 1:length(i)
    u = v(i(h), j(h));
    disp(['* ', Varname.uvars{i(h)}, ' - ', Varname.uvars{j(h)}, ' -> ', num2str(u)])
  end
  disp(' ')
end

if Fyerr > Settings.dyntol
  disp('The following elements of the Fy matrix are suspiciously high:')
  disp(' ')
  v = abs((DAE.Fy-Fy)./Fytmp);
  [i, j] = find(v > Settings.dyntol);
  for h = 1:length(i)
    u = v(i(h), j(h));
    disp(['* ', Varname.uvars{i(h)}, ' - ', Varname.uvars{j(h)+DAE.n}, ' -> ', num2str(u)])
  end
  disp(' ')
end

if Gxerr > Settings.dyntol
  disp('The following elements of the Gx matrix are suspiciously high:')
  disp(' ')
  v = abs((DAE.Gx-Gx)./Gxtmp);
  [i, j] = find(v > Settings.dyntol);
  for h = 1:length(i)
    u = v(i(h), j(h));
    disp(['* ', Varname.uvars{i(h)+DAE.n}, ' - ', Varname.uvars{j(h)}, ' -> ', num2str(u)])
  end
  disp(' ')
end

if Gyerr > Settings.dyntol
  disp('The following elements of the Gy matrix are suspiciously high:')
  disp(' ')
  v = abs((DAE.Gy-Gy)./Gytmp);
  [i, j] = find(v > Settings.dyntol);
  for h = 1:length(i)
    u = v(i(h), j(h));
    disp(['* ', Varname.uvars{i(h)+DAE.n}, ' - ', Varname.uvars{j(h)+DAE.n}, ' -> ', num2str(u)])
  end
  disp(' ')
end
