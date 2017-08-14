$title GAMS/PSAT interface for solving the electricty market problem
* ==============================================================================
$onempty
$offlisting
$offupper

* ==============================================================================
* include data created with the PSAT-GAMS Interface
$if exist psatglobs.gms $include psatglobs.gms
* ==============================================================================

sets B     index of buses       /1*%nBus%/,
     L     index of lines       /1*%nLine%/,
     G     index of suppliers   /1*%nPs%/,
     C     index of consumers   /1*%nPd%/,
     SW    index of slack buses /1*%nSW%/,
     PV    index of pv buses    /1*%nPV%/,
     H     index of hours       /H0*%nH%/,
     Day   index of days        /D1*D7/,
     Week  index of weeks       /W1*W52/,
     Br(B) reference bus index  /%nBusref%/;

sets supply /Ps0, Psmax, Psmin, Cs, suc,
	    mut, mdt, rut, rdt, u0, y0, z0/,
     demand /Pd0, Pdmax, Pdmin, tgphi, Cd/,
     data   /V0, t0, Pg0, Qg0, Pl0, Ql0,
	     Qgmax, Qgmin, Vmax, Vmin, ksw, kpv/,
     lines  /g, b, g0, b0, Pijmax, Pjimax/,
     days   /wwkdy, wwknd, swkdy, swknd, sfwkdy, sfwknd/,
     vsc    /lmin, lmax, omega, line/;

alias (B,BB);
alias (H,HH);
alias (G,GG);

parameters S(G,supply)    supply data //,
	   D(C,demand)    demand data //,
	   X(B,data)      network data //,
	   N(L,lines)     line data //,
	   lambda(vsc)    loading paramter //,
	   Ps_idx(B,G)    supply incidence matrix //,
	   Pd_idx(B,C)    demand incidence matrix //,
	   SW_idx(B,SW)   slack bus incidence matrix //,
	   PV_idx(B,PV)   PV bus incidence matrix //,
	   Ch(H)          charge profile //,
	   Li(L,B)        node-to-branch (ij) incidence matrix //,
	   Lj(L,B)        node-to-branch (ji) incidence matrix //,
	   Gh(B,BB)       conductance matrix //,
	   Bh(B,BB)       admittance matrix //,
	   Ghc(B,BB)      conductance matrix (critical system) //,
	   Bhc(B,BB)      admittance matrix (critical system) //;

scalars MLC   maximum loading condition /0/,
	pi    /3.1416/
	T     /0/;

* ==============================================================================
* include data created with the PSAT-GAMS Interface
$if exist psatdata.gms $include psatdata.gms
* ==============================================================================

T = card(H)-1;

* ==============================================================================
* ==================== C O M M O N    V A R I A B L E S ========================
* ==============================================================================

variables obj value to be minimized,
	  Pij(H,L) flows from bus i to bus j,
	  Pji(H,L) flows from bus j to bus i,
	  V(H,B) bus voltage magnitudes,
	  a(H,B) bus voltage phases,
	  Ps(H,G) power supply bids,
	  Pd(H,C) power demand bids,
	  Qg(H,B) generator reactive powers,
	  u(H,G)  1 if gen. G is committed in hour H,
	  y(H,G)  1 if gen. G is started-up at the beginning of hour H,
	  z(H,G)  1 if gen. G is shut-down at the beginning of hour H;

positive variables z(H,G);

binary variables u(H,G),
		 y(H,G);

* ------------------------------------------------------------------------------
* initial values
* ------------------------------------------------------------------------------

Qg.l(H,B) = X(B,'Qg0');
V.l(H,B) = X(B,'V0');
a.l(H,B) = X(B,'t0');
Ps.l(H,G) = 0.5*(S(G,'Psmax')-S(G,'Psmin'));
Pd.l(H,C) = Ch(H)*0.5*(D(C,'Pdmax')-D(C,'Pdmin'));

* ------------------------------------------------------------------------------
* zero-one variable initialization
* ------------------------------------------------------------------------------

z.up(H,G) = 1;
u.up(H,G) = 1;
y.up(H,G) = 1;
z.lo(H,G) = 0;
u.lo(H,G) = 0;
y.lo(H,G) = 0;
S(G,'u0') = 0$(S(G,'y0')<=0)+1$(S(G,'y0')>=1);
S(G,'z0') = S(G,'mdt')+1;

* ------------------------------------------------------------------------------
* limits
* ------------------------------------------------------------------------------

* Bid Blocks
Pd.up(H,C) = Ch(H)*D(C,'Pdmax');
Pd.lo(H,C) = Ch(H)*D(C,'Pdmin');

* Voltages & Voltage Limits
V.up(H,B) = X(B,'Vmax');
V.lo(H,B) = X(B,'Vmin');
a.up(H,B) = pi;
a.lo(H,B) = -pi;

* Generator Reactive Power Limits
Qg.up(H,B) = X(B,'Qgmax');
Qg.lo(H,B) = X(B,'Qgmin');

* Flow limits on transmission lines
Pij.up(H,L) =  N(L,'Pijmax');
Pij.lo(H,L) = -N(L,'Pijmax');
Pji.up(H,L) =  N(L,'Pijmax');
Pji.lo(H,L) = -N(L,'Pijmax');

* ------------------------------------------------------------------------------
* define equations
* ------------------------------------------------------------------------------

equation cost            objective function,
         pmaxlim(H,G)    maximum power supply output,
	 pminlim(H,G)    minimum power supply output,
	 logicupdn1(H,G) start-up and shut-down and running logic 1,
	 logicupdn2(H,G) start-up and shut-down and running logic 2,
	 rampdown(H,G)   maximum ramp down rate limit,
	 rampup(H,G)     maximum ramp up rate limit,
	 uptime1(G)      mimimum up time logic 1,
	 uptime2(H,G)    mimimum up time logic 2,
	 uptime3(H,G)    mimimum up time logic 3,
	 dwntime1(G)     mimimum down time logic 1,
	 dwntime2(H,G)   mimimum down time logic 2,
	 dwntime3(H,G)   mimimum down time logic 3;	 

* ------------------------------------------------------------------------------
* maximum and minimum power supply output constraints
* ------------------------------------------------------------------------------
pmaxlim(H,G)$(S(G,'Psmax') and (ord(H) gt 1)).. Ps(H,G) =l= S(G,'Psmax')*u(H,G);
pminlim(H,G)$(S(G,'Psmin') and (ord(H) gt 1)).. Ps(H,G) =g= S(G,'Psmin')*u(H,G);

* ------------------------------------------------------------------------------
* logic up and logic down
* ------------------------------------------------------------------------------
logicupdn1(H,G)$(ord(H) gt 1).. y(H,G)-z(H,G) =e= u(H,G)-u(H-1,G);
logicupdn2(H,G)$(ord(H) gt 1).. y(H,G)+z(H,G) =l= 1;

* ------------------------------------------------------------------------------
* ramp up and ramp down
* ------------------------------------------------------------------------------
rampdown(H,G)$(S(G,'rdt') and (ord(H) gt 1)).. Ps(H-1,G)-Ps(H,G) =l=
					       S(G,'rdt')*(1-z(H,G))+
					       S(G,'rdt')*z(H,G);

rampup(H,G)$(S(G,'rut') and (ord(H) gt 1)).. Ps(H,G)-Ps(H-1,G) =l=
					     S(G,'rut')*(1-y(H,G))+
					     S(G,'rut')*y(H,G);

* ------------------------------------------------------------------------------
* up time constraints
* ------------------------------------------------------------------------------
uptime1(G).. sum(H$((ord(H) gt 1) and (ord(H) le
	     min(T,(S(G,'mut')-S(G,'y0'))*S(G,'u0'))+1)),1-u(H,G))=e=0;

uptime2(H,G)$((ord(H) gt (min(T,(S(G,'mut')-S(G,'y0'))*S(G,'u0'))+1)) and
	(ord(H) le T-S(G,'mut')+1+1))..
	sum(HH$((ord(HH) ge ord(H)) and (ord(HH) le
	ord(H)+S(G,'mut')-1)),u(HH,G))=g=S(G,'mut')*y(H,G);

uptime3(H,G)$((ord(H) gt T-S(G,'mut')+2) and (ord(H) le T+1))..
	sum(HH$((ord(HH) ge ord(H)) and	(ord(HH) le T+1)),u(HH,G)-y(H,G))=g=0;

* ------------------------------------------------------------------------------
* down time constraints
* ------------------------------------------------------------------------------
dwntime1(G).. sum(H$((ord(H) gt 1) and (ord(H) le
	      min(T,(S(G,'mdt')-S(G,'z0'))*(1-S(G,'u0')))+1)),u(H,G))=e=0;

dwntime2(H,G)$((ord(H) gt min(T,(S(G,'mdt')-S(G,'z0'))*(1-S(G,'u0')))+1)
	and (ord(H) le T-S(G,'mdt')+1+1))..
	sum(HH$((ord(HH) ge ord(H)) and (ord(HH) le
	ord(H)+S(G,'mdt')-1)),1-u(HH,G))=g=S(G,'mdt')*z(H,G);

dwntime3(H,G)$((ord(H) gt T-S(G,'mdt')+2) and (ord(H) le T+1))..
	sum(HH$((ord(HH) ge ord(H)) and	(ord(HH) le T+1)),1-u(HH,G)-z(H,G))=g=0;

* ------------------------------------------------------------------------------

$if %control% == 1 $goto jfloweq

equation Peq(H,B),
	 Thetaref(H,B);

$if %control% == 2 $goto jfloweq

equations Qeq(H,B);

$if %flow% == 0 $goto jfloweq

equations Pijeq(H,L),
	  Pjieq(H,L);

$label jfloweq

* ==============================================================================
* ------------------------------------------------------------------------------
* ============================ M E T H O D S ===================================
* ------------------------------------------------------------------------------
* ==============================================================================

* check method
$if %control% == 1 $goto auction
$if %control% == 2 $goto mcm
$if %control% == 3 $goto opf
$if %control% == 4 $goto vscopf
$if %control% == 5 $goto mlcopf

* ==============================================================================
* ====================== S I M P L E    A U C T I O N  =========================
* ==============================================================================

$label auction

* ------------------------------------------------------------------------------
* objective function
cost.. obj =e= sum(H$(ord(H) gt 1),
       sum(G,Ps(H,G)*S(G,'Cs')) - sum(C,Pd(H,C)*D(C,'Cd'))) +
       sum(H$(ord(H) gt 1),sum(G,y(H,G)*S(G,'suc')));
* ------------------------------------------------------------------------------

equation Pbalance(H);
Pbalance(H).. sum(G,Ps(H,G)) - sum(C,Pd(H,C)) =e= 0;

$goto solvestat

* ==============================================================================
* =========== M A R K E T   C L E A R I N G   M E C H A N I S M ================
* ==============================================================================

$label mcm

* ------------------------------------------------------------------------------
* objective function
cost.. obj =e= sum(H$(ord(H) gt 1),
       sum(G,Ps(H,G)*S(G,'Cs')) - sum(C,Pd(H,C)*D(C,'Cd'))) +
       sum(H$(ord(H) gt 1),sum(G,y(H,G)*S(G,'suc')));
* ------------------------------------------------------------------------------

Peq(H,B).. sum(G,Ps_idx(B,G)*Ps(H,G)) + Ch(H)*X(B,'Pg0') -
	   sum(C,Pd_idx(B,C)*Pd(H,C)) - Ch(H)*X(B,'Pl0') -
	   sum(BB,Bh(B,BB)*a(H,BB)) =e= 0;

equation Pijeq(H,L);
Pijeq(H,L).. Pij(H,L) =e= sum(B,Li(L,B)*a(H,B))-sum(B,Lj(L,B)*a(H,B));

Thetaref(H,B)$Br(B).. a(H,B) =e= 0;

$goto solvestat

* ==============================================================================
* ================== O P T I M A L   P O W E R   F L O W  ======================
* ==============================================================================

$label opf

* ------------------------------------------------------------------------------
* objective function
cost.. obj =e= sum(H,sum(G,Ps(H,G)*S(G,'Cs')) - sum(C,Pd(H,C)*D(C,'Cd'))) +
       sum(H$(ord(H) gt 1),sum(G,y(H,G)*S(G,'suc')));
* ------------------------------------------------------------------------------

Peq(H,B).. sum(G,Ps_idx(B,G)*Ps(H,G)) - sum(C,Pd_idx(B,C)*Pd(H,C)) +
	   Ch(H)*X(B,'Pg0') - Ch(H)*X(B,'Pl0') -
	   V(H,B)*sum(BB,V(H,BB)*(Gh(B,BB)*cos(a(H,B)-a(H,BB)) +
	   Bh(B,BB)*sin(a(H,B)-a(H,BB)))) =e= 0;

Qeq(H,B).. Qg(H,B) - Ch(H)*X(B,'Ql0') -
	   sum(C,Pd_idx(B,C)*(D(C,'tgphi')*Pd(H,C)))
	   - V(H,B)*sum(BB,V(H,BB)*(Gh(B,BB)*sin(a(H,B)-a(H,BB)) -
	   Bh(B,BB)*cos(a(H,B)-a(H,BB)))) =e= 0;

Thetaref(H,B)$Br(B).. a(H,B) =e= 0;

*MLCeq.. MLC0 - (1+lambda)*(sum(C,Pd(C))+sum(B,X(B,'Pl0'))) =g= 0;

$goto floweq

* ==============================================================================
* ====== V O L T A G E    S T A B I L I T Y   C O N S T R A I N E D  ===========
* ================== O P T I M A L   P O W E R   F L O W  ======================
* ==============================================================================

$label vscopf

* ------------------------------------------------------------------------------
* local variables
* ------------------------------------------------------------------------------

variables Pijc(H,L),
	  Pjic(H,L),
	  Vc(H,B),
	  ac(H,B),
	  Qgc(H,B),
	  kg(H),
	  lambdac(H);

* ------------------------------------------------------------------------------
* initial values
* ------------------------------------------------------------------------------

Qgc.l(H,B) = X(B,'Qg0');
Vc.l(H,B)  = X(B,'V0');
ac.l(H,B)  = X(B,'t0');
kg.l(H) = 0;

* ------------------------------------------------------------------------------
* limits
* ------------------------------------------------------------------------------

* Voltages & Voltage Limits
Vc.up(H,B) = X(B,'Vmax');
Vc.lo(H,B) = X(B,'Vmin');
ac.up(H,B) =  pi;
ac.lo(H,B) = -pi;
kg.lo(H) = -1;
kg.up(H) =  1;

* Generator Reactive Power Limits
Qgc.up(H,B) = X(B,'Qgmax');
Qgc.lo(H,B) = X(B,'Qgmin');

* Flow limits on transmission lines
Pijc.up(H,L) =  N(L,'Pijmax');
Pijc.lo(H,L) = -N(L,'Pijmax');
Pjic.up(H,L) =  N(L,'Pijmax');
Pjic.lo(H,L) = -N(L,'Pijmax');

lambdac.up(H) = lambda('lmax');
lambdac.lo(H) = lambda('lmin');

* ------------------------------------------------------------------------------
* objective function
cost.. obj =e= (1-lambda('omega'))*sum(H,sum(G,Ps(H,G)*S(G,'Cs')) -
       sum(C,Pd(H,C)*D(C,'Cd'))) +
       (1-lambda('omega'))*sum(H$(ord(H) gt 1),sum(G,y(H,G)*S(G,'suc'))) - 
       sum(H,lambda('omega')*lambdac(H));
* ------------------------------------------------------------------------------

equations Pceq(H,B),
	  Qceq(H,B),
	  Thetacref(H,B);	  

$if %flow% == 0 $goto jfloweqc

equations Pijceq(H,L),
	  Pjiceq(H,L);

$label jfloweqc

Peq(H,B).. sum(G,Ps_idx(B,G)*Ps(H,G)) -
	   sum(C,Pd_idx(B,C)*Pd(H,C)) +
	   Ch(H)*X(B,'Pg0') - Ch(H)*X(B,'Pl0') -
	   V(H,B)*sum(BB,V(H,BB)*(Gh(B,BB)*cos(a(H,B)-a(H,BB)) +
	   Bh(B,BB)*sin(a(H,B)-a(H,BB)))) =e= 0;

Qeq(H,B).. Qg(H,B) - Ch(H)*X(B,'Ql0') -
	   sum(C,Pd_idx(B,C)*(D(C,'tgphi')*Pd(H,C)))
	   - V(H,B)*sum(BB,V(H,BB)*(Gh(B,BB)*sin(a(H,B)-a(H,BB)) -
	   Bh(B,BB)*cos(a(H,B)-a(H,BB)))) =e= 0;

Thetaref(H,B)$Br(B).. a(H,B) =e= 0;

Pceq(H,B).. (1+lambdac(H)+kg(H))*(sum(G,Ps_idx(B,G)*Ps(H,G)) +
	    Ch(H)*X(B,'Pg0')) 
	    - (1+lambdac(H))*(sum(C,Pd_idx(B,C)*Pd(H,C)) +
	    Ch(H)*X(B,'Pl0'))
	    - Vc(H,B)*sum(BB,Vc(H,BB)*(Ghc(B,BB)*cos(ac(H,B)-ac(H,BB)) +
	    Bhc(B,BB)*sin(ac(H,B)-ac(H,BB)))) =e= 0;

Qceq(H,B).. Qgc(H,B) - (1+lambdac(H))*(Ch(H)*X(B,'Ql0') +
	    sum(C,Pd_idx(B,C)*(D(C,'tgphi')*Pd(H,C)))) -
	    Vc(H,B)*sum(BB,Vc(H,BB)*(Ghc(B,BB)*sin(ac(H,B)-ac(H,BB)) -
	    Bhc(B,BB)*cos(ac(H,B)-ac(H,BB)))) =e= 0;

Thetacref(H,B)$Br(B).. ac(H,B) =e= 0;

$goto floweq

* ==============================================================================
* =========== M A X I M U M   L O A D I N G   C O N D I T I O N ================
* ==============================================================================

$label mlcopf

* ------------------------------------------------------------------------------
* local variables
* ------------------------------------------------------------------------------

variables kg(H),
	  lambdac(H);

* ------------------------------------------------------------------------------
* initial values
* ------------------------------------------------------------------------------

kg.l(H) = 0;
lambdac.l(H) = 1;

* ------------------------------------------------------------------------------
* limits
* ------------------------------------------------------------------------------

* Bid Blocks
Ps.up(H,G) = S(G,'Ps0');
Pd.up(H,C) = Ch(H)*D(C,'Pd0');
Ps.lo(H,G) = S(G,'Ps0');
Pd.lo(H,C) = Ch(H)*D(C,'Pd0');
* Loading Parameter
kg.lo(H) = -1;
kg.up(H) =  1;
lambdac.lo(H) = 0;

* ------------------------------------------------------------------------------
* objective function
cost.. obj =e= sum(H,-lambdac(H));
* ------------------------------------------------------------------------------

Peq(H,B).. (lambdac(H)+kg(H))*(sum(G,Ps_idx(B,G)*Ps(H,G)) +
	   Ch(H)*X(B,'Pg0')) -
	   lambdac(H)*(sum(C,Pd_idx(B,C)*Pd(H,C)) + Ch(H)*X(B,'Pl0')) -
	   V(H,B)*sum(BB,V(H,BB)*(Gh(B,BB)*cos(a(H,B)-a(H,BB)) +
	   Bh(B,BB)*sin(a(H,B)-a(H,BB)))) =e= 0;

Qeq(H,B).. Qg(H,B) - lambdac(H)*(Ch(H)*X(B,'Ql0') +
	   sum(C,Pd_idx(B,C)*(D(C,'tgphi')*Pd(H,C)))) -
	   V(H,B)*sum(BB,V(H,BB)*(Gh(B,BB)*sin(a(H,B)-a(H,BB)) -
	   Bh(B,BB)*cos(a(H,B)-a(H,BB)))) =e= 0;

Thetaref(H,B)$Br(B).. a(H,B) =e= 0;

* ------------------------------------------------------------------------------
* flow limit equations
* ------------------------------------------------------------------------------

$label floweq

$if %flow% == 0 $goto solvestat
$if %flow% == 1 $goto iflows
$if %flow% == 2 $goto pflows
$if %flow% == 3 $goto sflows

$label pflows

Pijeq(H,L).. Pij(H,L) =e= N(L,'g0')*sum(B,Li(L,B)*V(H,B)*V(H,B)) -
	     N(L,'b')*sum(B,Li(L,B)*V(H,B)*sin(a(H,B)))*
	     sum(B,Lj(L,B)*V(H,B)*cos(a(H,B))) +
	     N(L,'b')*sum(B,Li(L,B)*V(H,B)*cos(a(H,B)))*
	     sum(B,Lj(L,B)*V(H,B)*sin(a(H,B))) -
	     N(L,'g')*sum(B,Li(L,B)*V(H,B)*cos(a(H,B)))*
	     sum(B,Lj(L,B)*V(H,B)*cos(a(H,B))) -
	     N(L,'g')*sum(B,Li(L,B)*V(H,B)*sin(a(H,B)))*
	     sum(B,Lj(L,B)*V(H,B)*sin(a(H,B)));

Pjieq(H,L).. Pji(H,L) =e= N(L,'g0')*sum(B,Lj(L,B)*V(H,B)*V(H,B)) -
	     N(L,'b')*sum(B,Lj(L,B)*V(H,B)*sin(a(H,B)))*
	     sum(B,Li(L,B)*V(H,B)*cos(a(H,B))) +
	     N(L,'b')*sum(B,Lj(L,B)*V(H,B)*cos(a(H,B)))*
	     sum(B,Li(L,B)*V(H,B)*sin(a(H,B))) -
	     N(L,'g')*sum(B,Lj(L,B)*V(H,B)*cos(a(H,B)))*
	     sum(B,Li(L,B)*V(H,B)*cos(a(H,B))) -
	     N(L,'g')*sum(B,Lj(L,B)*V(H,B)*sin(a(H,B)))*
	     sum(B,Li(L,B)*V(H,B)*sin(a(H,B)));

$if %control% == 3 $goto solvestat 
$if %control% == 5 $goto solvestat 

N(L,'b')$(ord(L) eq lambda('line')) = -1E-6;
N(L,'g')$(ord(L) eq lambda('line')) = 0;
N(L,'b0')$(ord(L) eq lambda('line')) = 0;
N(L,'g0')$(ord(L) eq lambda('line')) = 0;

Pijceq(H,L).. Pijc(H,L) =e= N(L,'g0')*sum(B,Li(L,B)*Vc(H,B)*Vc(H,B)) -
	      N(L,'b')*sum(B,Li(L,B)*Vc(H,B)*sin(ac(H,B)))*
	      sum(B,Lj(L,B)*Vc(H,B)*cos(ac(H,B))) +
	      N(L,'b')*sum(B,Li(L,B)*Vc(H,B)*cos(ac(H,B)))*
	      sum(B,Lj(L,B)*Vc(H,B)*sin(ac(H,B))) -
	      N(L,'g')*sum(B,Li(L,B)*Vc(H,B)*cos(ac(H,B)))*
	      sum(B,Lj(L,B)*Vc(H,B)*cos(ac(H,B))) -
	      N(L,'g')*sum(B,Li(L,B)*Vc(H,B)*sin(ac(H,B)))*
	      sum(B,Lj(L,B)*Vc(H,B)*sin(ac(H,B)));

Pjiceq(H,L).. Pjic(H,L) =e= N(L,'g0')*sum(B,Lj(L,B)*Vc(H,B)*Vc(H,B)) -
	      N(L,'b')*sum(B,Lj(L,B)*Vc(H,B)*sin(ac(H,B)))*
	      sum(B,Li(L,B)*Vc(H,B)*cos(ac(H,B))) +
	      N(L,'b')*sum(B,Lj(L,B)*Vc(H,B)*cos(ac(H,B)))*
	      sum(B,Li(L,B)*Vc(H,B)*sin(ac(H,B))) -
	      N(L,'g')*sum(B,Lj(L,B)*Vc(H,B)*cos(ac(H,B)))*
	      sum(B,Li(L,B)*Vc(H,B)*cos(ac(H,B))) -
	      N(L,'g')*sum(B,Lj(L,B)*Vc(H,B)*sin(ac(H,B)))*
	      sum(B,Li(L,B)*Vc(H,B)*sin(ac(H,B)));

$goto solvestat

$label iflows

Pijeq(H,L).. Pij(H,L) =e= sqrt(
	     sqr(N(L,'g')*sum(B,Li(L,B)*V(H,B)*cos(a(H,B)))-
	     N(L,'g')*sum(B,Lj(L,B)*V(H,B)*cos(a(H,B)))-
	     N(L,'b')*sum(B,Li(L,B)*V(H,B)*sin(a(H,B)))+
	     N(L,'b')*sum(B,Lj(L,B)*V(H,B)*sin(a(H,B)))-
	     N(L,'b0')*sum(B,Li(L,B)*V(H,B)*sin(a(H,B))))+
	     sqr(N(L,'b')*sum(B,Li(L,B)*V(H,B)*cos(a(H,B)))-
	     N(L,'b')*sum(B,Lj(L,B)*V(H,B)*cos(a(H,B)))+
	     N(L,'g')*sum(B,Li(L,B)*V(H,B)*sin(a(H,B)))-
	     N(L,'g')*sum(B,Lj(L,B)*V(H,B)*sin(a(H,B)))+
	     N(L,'b0')*sum(B,Li(L,B)*V(H,B)*cos(a(H,B)))));

Pjieq(H,L).. Pji(H,L) =e= sqrt(
	     sqr(N(L,'g')*sum(B,Lj(L,B)*V(H,B)*cos(a(H,B)))-
	     N(L,'g')*sum(B,Li(L,B)*V(H,B)*cos(a(H,B)))-
	     N(L,'b')*sum(B,Lj(L,B)*V(H,B)*sin(a(H,B)))+
	     N(L,'b')*sum(B,Li(L,B)*V(H,B)*sin(a(H,B)))-
	     N(L,'b0')*sum(B,Lj(L,B)*V(H,B)*sin(a(H,B))))+
	     sqr(N(L,'b')*sum(B,Lj(L,B)*V(H,B)*cos(a(H,B)))-
	     N(L,'b')*sum(B,Li(L,B)*V(H,B)*cos(a(H,B)))+
	     N(L,'g')*sum(B,Lj(L,B)*V(H,B)*sin(a(H,B)))-
	     N(L,'g')*sum(B,Li(L,B)*V(H,B)*sin(a(H,B)))+
	     N(L,'b0')*sum(B,Lj(L,B)*V(H,B)*cos(a(H,B)))));

$if %control% == 3 $goto solvestat 
$if %control% == 5 $goto solvestat 

N(L,'b')$(ord(L) eq lambda('line')) = -1E-6;
N(L,'g')$(ord(L) eq lambda('line')) = 0;
N(L,'b0')$(ord(L) eq lambda('line')) = 0;
N(L,'g0')$(ord(L) eq lambda('line')) = 0;

Pijceq(H,L).. Pijc(H,L) =e= sqrt(
	      sqr(N(L,'g')*sum(B,Li(L,B)*Vc(H,B)*cos(ac(H,B)))-
	      N(L,'g')*sum(B,Lj(L,B)*Vc(H,B)*cos(ac(H,B)))-
	      N(L,'b')*sum(B,Li(L,B)*Vc(H,B)*sin(ac(H,B)))+
	      N(L,'b')*sum(B,Lj(L,B)*Vc(H,B)*sin(ac(H,B)))-
	      N(L,'b0')*sum(B,Li(L,B)*Vc(H,B)*sin(ac(H,B))))+
	      sqr(N(L,'b')*sum(B,Li(L,B)*Vc(H,B)*cos(ac(H,B)))-
	      N(L,'b')*sum(B,Lj(L,B)*Vc(H,B)*cos(ac(H,B)))+
	      N(L,'g')*sum(B,Li(L,B)*Vc(H,B)*sin(ac(H,B)))-
	      N(L,'g')*sum(B,Lj(L,B)*Vc(H,B)*sin(ac(H,B)))+
	      N(L,'b0')*sum(B,Li(L,B)*Vc(H,B)*cos(ac(H,B)))));

Pjiceq(H,L).. Pjic(H,L) =e= sqrt(
	      sqr(N(L,'g')*sum(B,Lj(L,B)*Vc(H,B)*cos(ac(H,B)))-
	      N(L,'g')*sum(B,Li(L,B)*Vc(H,B)*cos(ac(H,B)))-
	      N(L,'b')*sum(B,Lj(L,B)*Vc(H,B)*sin(ac(H,B)))+
	      N(L,'b')*sum(B,Li(L,B)*Vc(H,B)*sin(ac(H,B)))-
	      N(L,'b0')*sum(B,Lj(L,B)*Vc(H,B)*sin(ac(H,B))))+
	      sqr(N(L,'b')*sum(B,Lj(L,B)*Vc(H,B)*cos(ac(H,B)))-
	      N(L,'b')*sum(B,Li(L,B)*Vc(H,B)*cos(ac(H,B)))+
	      N(L,'g')*sum(B,Lj(L,B)*Vc(H,B)*sin(ac(H,B)))-
	      N(L,'g')*sum(B,Li(L,B)*Vc(H,B)*sin(ac(H,B)))+
	      N(L,'b0')*sum(B,Lj(L,B)*Vc(H,B)*cos(ac(H,B)))));

$goto solvestat

$label sflows

Pijeq(H,L).. Pij(H,L) =e= sum(B,Li(L,B)*V(H,B))*sqrt(
	     sqr(N(L,'g')*sum(B,Li(L,B)*V(H,B)*cos(a(H,B)))-
	     N(L,'g')*sum(B,Lj(L,B)*V(H,B)*cos(a(H,B)))-
	     N(L,'b')*sum(B,Li(L,B)*V(H,B)*sin(a(H,B)))+
	     N(L,'b')*sum(B,Lj(L,B)*V(H,B)*sin(a(H,B)))-
	     N(L,'b0')*sum(B,Li(L,B)*V(H,B)*sin(a(H,B))))+
	     sqr(N(L,'b')*sum(B,Li(L,B)*V(H,B)*cos(a(H,B)))-
	     N(L,'b')*sum(B,Lj(L,B)*V(H,B)*cos(a(H,B)))+
	     N(L,'g')*sum(B,Li(L,B)*V(H,B)*sin(a(H,B)))-
	     N(L,'g')*sum(B,Lj(L,B)*V(H,B)*sin(a(H,B)))+
	     N(L,'b0')*sum(B,Li(L,B)*V(H,B)*cos(a(H,B)))));

Pjieq(H,L).. Pji(H,L) =e= sum(B,Lj(L,B)*V(H,B))*sqrt(
	     sqr(N(L,'g')*sum(B,Lj(L,B)*V(H,B)*cos(a(H,B)))-
	     N(L,'g')*sum(B,Li(L,B)*V(H,B)*cos(a(H,B)))-
	     N(L,'b')*sum(B,Lj(L,B)*V(H,B)*sin(a(H,B)))+
	     N(L,'b')*sum(B,Li(L,B)*V(H,B)*sin(a(H,B)))-
	     N(L,'b0')*sum(B,Lj(L,B)*V(H,B)*sin(a(H,B))))+
	     sqr(N(L,'b')*sum(B,Lj(L,B)*V(H,B)*cos(a(H,B)))-
	     N(L,'b')*sum(B,Li(L,B)*V(H,B)*cos(a(H,B)))+
	     N(L,'g')*sum(B,Lj(L,B)*V(H,B)*sin(a(H,B)))-
	     N(L,'g')*sum(B,Li(L,B)*V(H,B)*sin(a(H,B)))+
	     N(L,'b0')*sum(B,Lj(L,B)*V(H,B)*cos(a(H,B)))));

$if %control% == 3 $goto solvestat 
$if %control% == 5 $goto solvestat 

N(L,'b')$(ord(L) eq lambda('line')) = -1E-6;
N(L,'g')$(ord(L) eq lambda('line')) = 0;
N(L,'b0')$(ord(L) eq lambda('line')) = 0;
N(L,'g0')$(ord(L) eq lambda('line')) = 0;

Pijceq(H,L).. Pijc(H,L) =e= sum(B,Li(L,B)*Vc(H,B))*sqrt(
	      sqr(N(L,'g')*sum(B,Li(L,B)*Vc(H,B)*cos(ac(H,B)))-
	      N(L,'g')*sum(B,Lj(L,B)*Vc(H,B)*cos(ac(H,B)))-
	      N(L,'b')*sum(B,Li(L,B)*Vc(H,B)*sin(ac(H,B)))+
	      N(L,'b')*sum(B,Lj(L,B)*Vc(H,B)*sin(ac(H,B)))-
	      N(L,'b0')*sum(B,Li(L,B)*Vc(H,B)*sin(ac(H,B))))+
	      sqr(N(L,'b')*sum(B,Li(L,B)*Vc(H,B)*cos(ac(H,B)))-
	      N(L,'b')*sum(B,Lj(L,B)*Vc(H,B)*cos(ac(H,B)))+
	      N(L,'g')*sum(B,Li(L,B)*Vc(H,B)*sin(ac(H,B)))-
	      N(L,'g')*sum(B,Lj(L,B)*Vc(H,B)*sin(ac(H,B)))+
	      N(L,'b0')*sum(B,Li(L,B)*Vc(H,B)*cos(ac(H,B)))));

Pjiceq(H,L).. Pjic(H,L) =e= sum(B,Lj(L,B)*Vc(H,B))*sqrt(
	      sqr(N(L,'g')*sum(B,Lj(L,B)*Vc(H,B)*cos(ac(H,B)))-
	      N(L,'g')*sum(B,Li(L,B)*Vc(H,B)*cos(ac(H,B)))-
	      N(L,'b')*sum(B,Lj(L,B)*Vc(H,B)*sin(ac(H,B)))+
	      N(L,'b')*sum(B,Li(L,B)*Vc(H,B)*sin(ac(H,B)))-
	      N(L,'b0')*sum(B,Lj(L,B)*Vc(H,B)*sin(ac(H,B))))+
	      sqr(N(L,'b')*sum(B,Lj(L,B)*Vc(H,B)*cos(ac(H,B)))-
	      N(L,'b')*sum(B,Li(L,B)*Vc(H,B)*cos(ac(H,B)))+
	      N(L,'g')*sum(B,Lj(L,B)*Vc(H,B)*sin(ac(H,B)))-
	      N(L,'g')*sum(B,Li(L,B)*Vc(H,B)*sin(ac(H,B)))+
	      N(L,'b0')*sum(B,Lj(L,B)*Vc(H,B)*cos(ac(H,B)))));

$goto solvestat

* ------------------------------------------------------------------------------
* Solve Market Problem
* ------------------------------------------------------------------------------

$label solvestat
model market /all/;

option iterlim = 100000

$if %control% == 1 $goto linearmodel
$if %control% == 2 $goto linearmodel
$if %control% == 3 $goto nonlinearmodel
$if %control% == 4 $goto nonlinearmodel
$if %control% == 5 $goto nonlinearmodel
$if %control% == 6 $goto nonlinearmodel

$label linearmodel

solve market using mip minimizing obj;

parameters upar(H,G);

upar(H,G) = u.l(H,G);

equations cost2;

cost2.. obj =e= sum(H,sum(G,Ps(H,G)*S(G,'Cs')) - sum(C,Pd(H,C)*D(C,'Cd')));

Ps.up(H,G) = S(G,'Psmax')*upar(H,G);
Ps.lo(H,G) = S(G,'Psmin')*upar(H,G);

$if %control% == 1
model market2 /cost2,Pbalance/;

$if %control% == 2
model market2 /cost2,Peq,Pijeq,Thetaref/;

solve market2 using lp minimizing obj;

$goto psatoutput

$label nonlinearmodel

solve market using minlp minimizing obj;

$if not %control% == 4 $goto psatoutput

lambdac.up = lambdac.l;
lambdac.lo = lambdac.l-1.0E-5;
lambda('omega') = 0;

solve market using minlp minimizing obj;

$label psatoutput

$libinclude psatout Ps.l H G
$libinclude psatout Pd.l H C

$if %control% == 1 $libinclude psatout Pbalance.m H
$if %control% == 1 $goto end_output

$if %control% == 2 $libinclude psatout Peq.m H B
$if %control% == 2 $goto end_output

$libinclude psatout V.l H B
$libinclude psatout a.l H B
$libinclude psatout Qg.l H B
$libinclude psatout Peq.m H B
$libinclude psatout Pij.l H L
$libinclude psatout Pji.l H L

$if %control% == 5 $goto no_dual

$libinclude psatout V.m H B
$libinclude psatout Pij.m H L
$libinclude psatout Pji.m H L

$label no_dual

$if %control% == 3 $goto end_output

$libinclude psatout lambdac.l H 
$libinclude psatout kg.l H 

$if %control% == 5 $goto end_output

$libinclude psatout Vc.l H B
$libinclude psatout ac.l H B
$libinclude psatout Qgc.l H B
$libinclude psatout Pijc.l H L
$libinclude psatout Pjic.l H L

$label end_output

