function a = base(a)

global Settings

if ~a.n, return, end

a.con(:,4) = a.con(:,3).*a.con(:,4)/Settings.mva;
a.con(:,5) = a.con(:,3).*a.con(:,5)/Settings.mva;
a.con(:,7) = a.con(:,3).*a.con(:,7)/Settings.mva;
a.con(:,8) = a.con(:,3).*a.con(:,8)/Settings.mva;

