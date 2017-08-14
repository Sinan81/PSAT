function [Csa,Csb,Csc,Dsa,Dsb,Dsc] = costs(a)

global Settings

MVA = Settings.mva;

Csa = a.u.*a.con(:,7)/MVA;
Csb = a.u.*a.con(:,8);
Csc = MVA*a.u.*a.con(:,9);

Dsa = a.u.*a.con(:,10)/MVA;
Dsb = a.u.*a.con(:,11);
% the coefficient 1e-4 is added to avoid "indifferent" Qg
% injections for multiple Supplies at the same bus. 
% it is equivalent to Ps and Pd tiebreaking.
deltaQ = abs(a.con(:,16)-a.con(:,17)).^2;
deltaQ(find(~deltaQ)) = 1;
Dsc = a.u.*(MVA*a.con(:,12)+1e-4./deltaQ);
