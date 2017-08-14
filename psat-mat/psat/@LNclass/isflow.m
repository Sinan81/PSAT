function out = isflow(a,out,k)

global DAE Bus Settings

if ~a.n, return, end

nb = DAE.n+DAE.m+2*Bus.n;
ns = Settings.nseries;

if k <= nb, return, end

% Pij and Pji
if k > nb && k < nb + a.n
  h = k - nb;
  if a.con(h,14)
    out = out/a.con(h,14);
  elseif a.con(h,15)
    out = out/a.con(h,15);
  end
elseif k > nb + ns && k < nb + ns + a.n
  h = k - nb - ns;
  if a.con(h,14)
    out = out/a.con(h,14);
  elseif a.con(h,15)
    out = out/a.con(h,15);
  end  
end

% Qij and Qji
if k > nb + 2*ns && k < nb + 2*ns + a.n
  h = k - nb - 2*ns;
  if a.con(h,15)
    out = out/a.con(h,15);
  end
elseif k > nb + 3*ns && k < nb + 3*ns + a.n
  h = k - nb - 3*ns;
  if a.con(h,15)
    out = out/a.con(h,15);
  end  
end

% Iij and Iji
if k > nb + 4*ns && k < nb + 4*ns + a.n
  h = k - nb - 4*ns;
  if a.con(h,13)
    out = out/a.con(h,13);
  end
elseif k > nb + 5*ns && k < nb + 5*ns + a.n
  h = k - nb - 5*ns;
  if a.con(h,13)
    out = out/a.con(h,13);
  end  
end

% Sij and Sji
if k > nb + 6*ns && k < nb + 6*ns + a.n
  h = k - nb - 6*ns;
  if a.con(h,15)
    out = out/a.con(h,15);
  end
elseif k > nb + 7*ns && k < nb + 7*ns + a.n
  h = k - nb - 7*ns;
  if a.con(h,15)
    out = out/a.con(h,15);
  end  
end

