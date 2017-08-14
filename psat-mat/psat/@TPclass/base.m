function a = base(a)

global Settings

if ~a.n, return, end

a.con(:,9) = a.con(:,9)./a.con(:,2)*Settings.mva;
a.con(:,10) = a.con(:,10)./a.con(:,2)*Settings.mva;

