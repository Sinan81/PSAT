function [Cda,Cdb,Cdc,Dda,Ddb,Ddc] = costs(a)

global Settings

Cda = a.u.*a.con(:,8)/Settings.mva;
Cdb = a.u.*a.con(:,9);
Cdc = Settings.mva*a.u.*a.con(:,10);

Dda = a.u.*a.con(:,11)/Settings.mva;
Ddb = a.u.*a.con(:,12);
Ddc = Settings.mva*a.u.*a.con(:,13);
