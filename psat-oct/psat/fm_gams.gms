$title GAMS/PSAT interface for solving the electricty market problem
$onempty
$offlisting
$offupper

$if exist psatglobs.gms $include psatglobs.gms

set B /1*%nBus%/,
    L /1*%nLine%/,
    G /1*%nPs%/,
    C /1*%nPd%/,
    W /1*%nSW%/,
    U /1*%nPV%/,
    busref(B) /%nBusref%/;

set supply /Ps0, Psmax, Psmin, Csa, Csb, Csc, Dsa, Dsb, Dsc, ksu/,
    demand /Pd0, Pdmax, Pdmin, tgphi, Cda, Cdb, Cdc, Dda, Ddb, Ddc/,
    data   /V0, t0, Pg0, Qg0, Pl0, Ql0, Qgmax, Qgmin, Vmax, Vmin, ksw, kpv/,
    lines  /g, b, g0, b0, Pijmax, Pjimax/,
    vsc    /lmin, lmax, omega, line/;
  
alias (BB,B);

parameter S(G,supply)  //,
	  D(C,demand)  //,
	  X(B,data)    //,
	  N(L,lines)   //,
	  lambda(vsc)  //,
          Ps_idx(B,G) //,
          Pd_idx(B,C) //,
          SW_idx(B,W) //,
          PV_idx(B,U) //,
	  Li(L,B)  //,
	  Lj(L,B)  //,
	  Gh(B,BB) //,
	  Bh(B,BB) //,
	  Ghc(B,BB) //,
	  Bhc(B,BB) //;

scalar MLC   /0/,
       pi    /3.1416/; 

$if exist psatdata.gms $include psatdata.gms

* =========================================================================
* ==================== C O M M O N    V A R I A B L E S ===================
* =========================================================================

variables obj,
	  Pij(L),
	  Pji(L),
	  V(B),
	  a(B),
	  Ps(G),
	  Pd(C),
	  Qg(B);

* -------------------------------------------------------------------------
* initial values
* -------------------------------------------------------------------------

Qg.l(B) = X(B,'Qg0');
V.l(B)  = X(B,'V0');
a.l(B)  = X(B,'t0');
Ps.l(G) = S(G,'Psmin');
Pd.l(C) = D(C,'Pdmin');

* -------------------------------------------------------------------------
* limits
* -------------------------------------------------------------------------

* Bid Blocks
Ps.up(G) = S(G,'Psmax');
Pd.up(C) = D(C,'Pdmax');
Ps.lo(G) = S(G,'Psmin');
Pd.lo(C) = D(C,'Pdmin');

* Voltages & Voltage Limits
V.up(B) = X(B,'Vmax');
V.lo(B) = X(B,'Vmin');
a.up(B) = pi;
a.lo(B) = -pi;

* Generator Reactive Power Limits
Qg.up(B) = X(B,'Qgmax');
Qg.lo(B) = X(B,'Qgmin');

* Flow limits on transmission lines
Pij.up(L) =  N(L,'Pijmax');
Pij.lo(L) = -N(L,'Pijmax');
Pji.up(L) =  N(L,'Pijmax');
Pji.lo(L) = -N(L,'Pijmax');

* -------------------------------------------------------------------------
* define equations
* -------------------------------------------------------------------------

equation cost;

$if %control% == 1 $goto jfloweq

equation Peq(B);

$if %control% == 2 $goto jfloweq

equations Qeq(B),
	  Thetaref(B);

$if %flow% == 0 $goto jfloweq

equations Pijeq(L),
	  Pjieq(L);

$label jfloweq

* =========================================================================
* -------------------------------------------------------------------------
* ============================ M E T H O D S ==============================
* -------------------------------------------------------------------------
* =========================================================================

* check method
$if %control% == 1 $goto auction
$if %control% == 2 $goto mcm
$if %control% == 3 $goto opf
$if %control% == 4 $goto vscopf
$if %control% == 5 $goto mlcopf
$if %control% == 6 $goto vscopf

* =========================================================================
* ====================== S I M P L E    A U C T I O N  ====================
* =========================================================================

$label auction

* -------------------------------------------------------------------------
* objective function
cost.. obj =e= sum(G,Ps(G)*S(G,'Csb')) - sum(C,Pd(C)*D(C,'Cdb'));
* -------------------------------------------------------------------------

equation Pbalance;
Pbalance.. sum(G,Ps(G)) + sum(B,X(B,'Pg0')) -
	   sum(C,Pd(C)) - sum(B,X(B,'Pl0')) =e= 0;

$goto solvestat

* =========================================================================
* =========== M A R K E T   C L E A R I N G   M E C H A N I S M ===========
* =========================================================================

$label mcm

* -------------------------------------------------------------------------
* objective function
cost.. obj =e= sum(G,Ps(G)*S(G,'Csb')) - sum(C,Pd(C)*D(C,'Cdb'));
* -------------------------------------------------------------------------

equations Thetaref(B);
Thetaref(B)$busref(B).. a(B) =e= 0;

Peq(B).. sum(G,Ps_idx(B,G)*Ps(G)) + X(B,'Pg0') -
	 sum(C,Pd_idx(B,C)*Pd(C)) - X(B,'Pl0') -
	 sum(BB,Bh(B,BB)*a(BB)) =e= 0;

equation Pijeq(L);
Pijeq(L).. Pij(L) =e= sum(B,Li(L,B)*a(B))-sum(B,Lj(L,B)*a(B));


$goto solvestat

* =========================================================================
* ================== O P T I M A L   P O W E R   F L O W  =================
* =========================================================================

$label opf

* -------------------------------------------------------------------------
* objective function
cost.. obj =e= sum(G,S(G,'Csa')) + sum(G,Ps(G)*S(G,'Csb'))
       + sum(G,sqr(Ps(G))*S(G,'Csc'))
       + sum(G,S(G,'Dsa'))
       + sum(B,Qg(B)*sum(G,Ps_idx(B,G)*S(G,'Dsb')))
       + sum(B,sqr(Qg(B))*sum(G,Ps_idx(B,G)*S(G,'Dsc')))
       - sum(C,D(C,'Cda')) - sum(C,Pd(C)*D(C,'Cdb'))
       - sum(C,sqr(Pd(C))*D(C,'Cdc'))
       - sum(C,D(C,'Dda'))
       - sum(C,(D(C,'tgphi')*Pd(C))*D(C,'Ddb'))
       - sum(C,sqr(D(C,'tgphi')*Pd(C))*D(C,'Ddc'));
* -------------------------------------------------------------------------

Peq(B).. sum(G,Ps_idx(B,G)*Ps(G)) -
	 sum(C,Pd_idx(B,C)*Pd(C)) + X(B,'Pg0') - X(B,'Pl0') -
	 V(B)*sum(BB,V(BB)*(Gh(B,BB)*cos(a(B)-a(BB)) +
	 Bh(B,BB)*sin(a(B)-a(BB)))) =e= 0;

Qeq(B).. Qg(B) - X(B,'Ql0') - sum(C,Pd_idx(B,C)*(D(C,'tgphi')*Pd(C))) -
	 V(B)*sum(BB,V(BB)*(Gh(B,BB)*sin(a(B)-a(BB)) -
	 Bh(B,BB)*cos(a(B)-a(BB)))) =e= 0;

Thetaref(B)$busref(B).. a(B) =e= 0;

$goto floweq

* =========================================================================
* ====== V O L T A G E    S T A B I L I T Y   C O N S T R A I N E D  ======
* ================== O P T I M A L   P O W E R   F L O W  =================
* =========================================================================

$label vscopf

* -------------------------------------------------------------------------
* local variables
* -------------------------------------------------------------------------

variables Pijc(L),
	  Pjic(L),
	  Vc(B),
	  ac(B),
	  Qgc(B),
	  kg,
	  lambdac;

* -------------------------------------------------------------------------
* initial values
* -------------------------------------------------------------------------

Qgc.l(B) = X(B,'Qg0');
Vc.l(B)  = X(B,'V0');
ac.l(B)  = X(B,'t0');
kg.l = 0;

* -------------------------------------------------------------------------
* limits
* -------------------------------------------------------------------------

* Voltages & Voltage Limits
Vc.up(B) = X(B,'Vmax');
Vc.lo(B) = X(B,'Vmin');
ac.up(B) =  pi;
ac.lo(B) = -pi;
kg.lo = -1;
kg.up =  1;

* Generator Reactive Power Limits
Qgc.up(B) = X(B,'Qgmax');
Qgc.lo(B) = X(B,'Qgmin');

* Flow limits on transmission lines
Pijc.up(L) =  N(L,'Pijmax');
Pijc.lo(L) = -N(L,'Pijmax');
Pjic.up(L) =  N(L,'Pijmax');
Pjic.lo(L) = -N(L,'Pijmax');

lambdac.up = lambda('lmax');
lambdac.lo = lambda('lmin');

* -------------------------------------------------------------------------
* objective function
cost.. obj =e= (1-lambda('omega'))*
       (sum(G,S(G,'Csa')) + sum(G,Ps(G)*S(G,'Csb'))
       + sum(G,sqr(Ps(G))*S(G,'Csc'))
       + sum(G,S(G,'Dsa'))
       + sum(B,Qg(B)*sum(G,Ps_idx(B,G)*S(G,'Dsb')))
       + sum(B,sqr(Qg(B))*sum(G,Ps_idx(B,G)*S(G,'Dsc')))
       - sum(C,D(C,'Cda')) - sum(C,Pd(C)*D(C,'Cdb'))
       - sum(C,sqr(Pd(C))*D(C,'Cdc'))
       - sum(C,D(C,'Dda'))
       - sum(C,(D(C,'tgphi')*Pd(C))*D(C,'Ddb'))
       - sum(C,sqr(D(C,'tgphi')*Pd(C))*D(C,'Ddc')))
       - lambda('omega')*lambdac;
* -------------------------------------------------------------------------

equations Pceq(B),
	  Qceq(B),
	  Thetacref(B);	  
* ------------------------------------
* equation lambdaeq;
* lambdaeq.. lambdac-lambda('lmin') =e= 0;
* ------------------------------------

$if %flow% == 0 $goto jfloweqc

equations Pijceq(L),
	  Pjiceq(L);

$label jfloweqc

Peq(B).. sum(G,Ps_idx(B,G)*Ps(G)) -
	 sum(C,Pd_idx(B,C)*Pd(C)) + X(B,'Pg0') - X(B,'Pl0') -
	 V(B)*sum(BB,V(BB)*(Gh(B,BB)*cos(a(B)-a(BB)) +
	 Bh(B,BB)*sin(a(B)-a(BB)))) =e= 0;

Qeq(B).. Qg(B) - X(B,'Ql0') - sum(C,Pd_idx(B,C)*(D(C,'tgphi')*Pd(C))) -
	 V(B)*sum(BB,V(BB)*(Gh(B,BB)*sin(a(B)-a(BB)) -
	 Bh(B,BB)*cos(a(B)-a(BB)))) =e= 0;

Thetaref(B)$busref(B).. a(B) =e= 0;

*sum(G,Ps_idx(B,G)*(S(G,'ksu')*Ps(G))) +
*          sum(W,SW_idx(B,W)*(X(B,'ksw')*X(B,'Pg0'))) +
*          sum(U,PV_idx(B,U)*(X(B,'kpv')*X(B,'Pg0')))

Pceq(B).. (1+lambdac+kg)*(sum(G,Ps_idx(B,G)*Ps(G)) + X(B,'Pg0')) -
          (1+lambdac)*(sum(C,Pd_idx(B,C)*Pd(C)) + X(B,'Pl0')) -
          Vc(B)*sum(BB,Vc(BB)*(Ghc(B,BB)*cos(ac(B)-ac(BB)) +
          Bhc(B,BB)*sin(ac(B)-ac(BB)))) =e= 0;

Qceq(B).. Qgc(B) - (1+lambdac)*(X(B,'Ql0') +
	  sum(C,Pd_idx(B,C)*(D(C,'tgphi')*Pd(C)))) -
	  Vc(B)*sum(BB,Vc(BB)*(Ghc(B,BB)*sin(ac(B)-ac(BB)) -
	  Bhc(B,BB)*cos(ac(B)-ac(BB)))) =e= 0;

Thetacref(B)$busref(B).. ac(B) =e= 0;

$goto floweq

* =========================================================================
* =========== M A X I M U M   L O A D I N G   C O N D I T I O N ===========
* =========================================================================

$label mlcopf

* -------------------------------------------------------------------------
* local variables
* -------------------------------------------------------------------------

variables kg,
	  lambdac;

* -------------------------------------------------------------------------
* initial values
* -------------------------------------------------------------------------

kg.l = 0;
lambdac.l = 1;

* -------------------------------------------------------------------------
* limits
* -------------------------------------------------------------------------

* Bid Blocks
Ps.up(G) = S(G,'Ps0');
Pd.up(C) = D(C,'Pd0');
Ps.lo(G) = S(G,'Ps0');
Pd.lo(C) = D(C,'Pd0');
* Loading Parameter
kg.lo = -1;
kg.up =  1;
lambdac.lo = 0;

* -------------------------------------------------------------------------
* objective function
cost.. obj =e= -lambdac;
* -------------------------------------------------------------------------

Peq(B).. (lambdac+kg)*(sum(G,Ps_idx(B,G)*Ps(G)) + X(B,'Pg0')) -
	 lambdac*(sum(C,Pd_idx(B,C)*Pd(C)) + X(B,'Pl0')) -
	 V(B)*sum(BB,V(BB)*(Gh(B,BB)*cos(a(B)-a(BB)) +
	 Bh(B,BB)*sin(a(B)-a(BB)))) =e= 0;

Qeq(B).. Qg(B) - lambdac*(X(B,'Ql0') +
	 sum(C,Pd_idx(B,C)*(D(C,'tgphi')*Pd(C)))) -
	 V(B)*sum(BB,V(BB)*(Gh(B,BB)*sin(a(B)-a(BB)) -
	 Bh(B,BB)*cos(a(B)-a(BB)))) =e= 0;

Thetaref(B)$busref(B).. a(B) =e= 0;

* -------------------------------------------------------------------------
* flow limit equations
* -------------------------------------------------------------------------

$label floweq

$if %flow% == 0 $goto solvestat
$if %flow% == 1 $goto iflows
$if %flow% == 2 $goto pflows
$if %flow% == 3 $goto sflows

$label pflows
Pijeq(L).. Pij(L) =e= N(L,'g0')*sum(B,Li(L,B)*V(B)*V(B)) -
	   N(L,'b')*sum(B,Li(L,B)*V(B)*sin(a(B)))*
	   sum(B,Lj(L,B)*V(B)*cos(a(B))) +
	   N(L,'b')*sum(B,Li(L,B)*V(B)*cos(a(B)))*
	   sum(B,Lj(L,B)*V(B)*sin(a(B))) -
	   N(L,'g')*sum(B,Li(L,B)*V(B)*cos(a(B)))*
	   sum(B,Lj(L,B)*V(B)*cos(a(B))) -
	   N(L,'g')*sum(B,Li(L,B)*V(B)*sin(a(B)))*
	   sum(B,Lj(L,B)*V(B)*sin(a(B)));

Pjieq(L).. Pji(L) =e= N(L,'g0')*sum(B,Lj(L,B)*V(B)*V(B)) -
	   N(L,'b')*sum(B,Lj(L,B)*V(B)*sin(a(B)))*
	   sum(B,Li(L,B)*V(B)*cos(a(B))) +
	   N(L,'b')*sum(B,Lj(L,B)*V(B)*cos(a(B)))*
	   sum(B,Li(L,B)*V(B)*sin(a(B))) -
	   N(L,'g')*sum(B,Lj(L,B)*V(B)*cos(a(B)))*
	   sum(B,Li(L,B)*V(B)*cos(a(B))) -
	   N(L,'g')*sum(B,Lj(L,B)*V(B)*sin(a(B)))*
	   sum(B,Li(L,B)*V(B)*sin(a(B)));

$if %control% == 3 $goto solvestat 
$if %control% == 5 $goto solvestat 

N(L,'b')$(ord(L) eq lambda('line')) = -1E-6;
N(L,'g')$(ord(L) eq lambda('line')) = 0;
N(L,'b0')$(ord(L) eq lambda('line')) = 0;
N(L,'g0')$(ord(L) eq lambda('line')) = 0;

Pijceq(L).. Pijc(L) =e= N(L,'g0')*sum(B,Li(L,B)*Vc(B)*Vc(B)) -
	    N(L,'b')*sum(B,Li(L,B)*Vc(B)*sin(ac(B)))*
	    sum(B,Lj(L,B)*Vc(B)*cos(ac(B))) +
	    N(L,'b')*sum(B,Li(L,B)*Vc(B)*cos(ac(B)))*
	    sum(B,Lj(L,B)*Vc(B)*sin(ac(B))) -
	    N(L,'g')*sum(B,Li(L,B)*Vc(B)*cos(ac(B)))*
	    sum(B,Lj(L,B)*Vc(B)*cos(ac(B))) -
	    N(L,'g')*sum(B,Li(L,B)*Vc(B)*sin(ac(B)))*
	    sum(B,Lj(L,B)*Vc(B)*sin(ac(B)));

Pjiceq(L).. Pjic(L) =e= N(L,'g0')*sum(B,Lj(L,B)*Vc(B)*Vc(B)) -
	    N(L,'b')*sum(B,Lj(L,B)*Vc(B)*sin(ac(B)))*
	    sum(B,Li(L,B)*Vc(B)*cos(ac(B))) +
	    N(L,'b')*sum(B,Lj(L,B)*Vc(B)*cos(ac(B)))*
	    sum(B,Li(L,B)*Vc(B)*sin(ac(B))) -
	    N(L,'g')*sum(B,Lj(L,B)*Vc(B)*cos(ac(B)))*
	    sum(B,Li(L,B)*Vc(B)*cos(ac(B))) -
	    N(L,'g')*sum(B,Lj(L,B)*Vc(B)*sin(ac(B)))*
	    sum(B,Li(L,B)*Vc(B)*sin(ac(B)));

$goto solvestat

$label iflows

Pijeq(L).. Pij(L) =e= sqrt(
	   sqr(N(L,'g')*sum(B,Li(L,B)*V(B)*cos(a(B)))-
	       N(L,'g')*sum(B,Lj(L,B)*V(B)*cos(a(B)))-
	       N(L,'b')*sum(B,Li(L,B)*V(B)*sin(a(B)))+
	       N(L,'b')*sum(B,Lj(L,B)*V(B)*sin(a(B)))-
	       N(L,'b0')*sum(B,Li(L,B)*V(B)*sin(a(B))))+
	   sqr(N(L,'b')*sum(B,Li(L,B)*V(B)*cos(a(B)))-
	       N(L,'b')*sum(B,Lj(L,B)*V(B)*cos(a(B)))+
	       N(L,'g')*sum(B,Li(L,B)*V(B)*sin(a(B)))-
	       N(L,'g')*sum(B,Lj(L,B)*V(B)*sin(a(B)))+
	       N(L,'b0')*sum(B,Li(L,B)*V(B)*cos(a(B)))));

Pjieq(L).. Pji(L) =e= sqrt(
	   sqr(N(L,'g')*sum(B,Lj(L,B)*V(B)*cos(a(B)))-
	       N(L,'g')*sum(B,Li(L,B)*V(B)*cos(a(B)))-
	       N(L,'b')*sum(B,Lj(L,B)*V(B)*sin(a(B)))+
	       N(L,'b')*sum(B,Li(L,B)*V(B)*sin(a(B)))-
	       N(L,'b0')*sum(B,Lj(L,B)*V(B)*sin(a(B))))+
	   sqr(N(L,'b')*sum(B,Lj(L,B)*V(B)*cos(a(B)))-
	       N(L,'b')*sum(B,Li(L,B)*V(B)*cos(a(B)))+
	       N(L,'g')*sum(B,Lj(L,B)*V(B)*sin(a(B)))-
	       N(L,'g')*sum(B,Li(L,B)*V(B)*sin(a(B)))+
	       N(L,'b0')*sum(B,Lj(L,B)*V(B)*cos(a(B)))));

$if %control% == 3 $goto solvestat 
$if %control% == 5 $goto solvestat 

N(L,'b')$(ord(L) eq lambda('line')) = -1E-6;
N(L,'g')$(ord(L) eq lambda('line')) = 0;
N(L,'b0')$(ord(L) eq lambda('line')) = 0;
N(L,'g0')$(ord(L) eq lambda('line')) = 0;

Pijceq(L).. Pijc(L) =e= sqrt(
	    sqr(N(L,'g')*sum(B,Li(L,B)*Vc(B)*cos(ac(B)))-
	    N(L,'g')*sum(B,Lj(L,B)*Vc(B)*cos(ac(B)))-
	    N(L,'b')*sum(B,Li(L,B)*Vc(B)*sin(ac(B)))+
	    N(L,'b')*sum(B,Lj(L,B)*Vc(B)*sin(ac(B)))-
	    N(L,'b0')*sum(B,Li(L,B)*Vc(B)*sin(ac(B))))+
	    sqr(N(L,'b')*sum(B,Li(L,B)*Vc(B)*cos(ac(B)))-
	    N(L,'b')*sum(B,Lj(L,B)*Vc(B)*cos(ac(B)))+
	    N(L,'g')*sum(B,Li(L,B)*Vc(B)*sin(ac(B)))-
	    N(L,'g')*sum(B,Lj(L,B)*Vc(B)*sin(ac(B)))+
	    N(L,'b0')*sum(B,Li(L,B)*Vc(B)*cos(ac(B)))));

Pjiceq(L).. Pjic(L) =e= sqrt(
	    sqr(N(L,'g')*sum(B,Lj(L,B)*Vc(B)*cos(ac(B)))-
	    N(L,'g')*sum(B,Li(L,B)*Vc(B)*cos(ac(B)))-
	    N(L,'b')*sum(B,Lj(L,B)*Vc(B)*sin(ac(B)))+
	    N(L,'b')*sum(B,Li(L,B)*Vc(B)*sin(ac(B)))-
	    N(L,'b0')*sum(B,Lj(L,B)*Vc(B)*sin(ac(B))))+
	    sqr(N(L,'b')*sum(B,Lj(L,B)*Vc(B)*cos(ac(B)))-
	    N(L,'b')*sum(B,Li(L,B)*Vc(B)*cos(ac(B)))+
	    N(L,'g')*sum(B,Lj(L,B)*Vc(B)*sin(ac(B)))-
	    N(L,'g')*sum(B,Li(L,B)*Vc(B)*sin(ac(B)))+
	    N(L,'b0')*sum(B,Lj(L,B)*Vc(B)*cos(ac(B)))));

$goto solvestat

$label sflows

Pijeq(L).. Pij(L) =e= sum(B,Li(L,B)*V(B))*sqrt(
	   sqr(N(L,'g')*sum(B,Li(L,B)*V(B)*cos(a(B)))-
	   N(L,'g')*sum(B,Lj(L,B)*V(B)*cos(a(B)))-
	   N(L,'b')*sum(B,Li(L,B)*V(B)*sin(a(B)))+
	   N(L,'b')*sum(B,Lj(L,B)*V(B)*sin(a(B)))-
	   N(L,'b0')*sum(B,Li(L,B)*V(B)*sin(a(B))))+
	   sqr(N(L,'b')*sum(B,Li(L,B)*V(B)*cos(a(B)))-
	   N(L,'b')*sum(B,Lj(L,B)*V(B)*cos(a(B)))+
	   N(L,'g')*sum(B,Li(L,B)*V(B)*sin(a(B)))-
	   N(L,'g')*sum(B,Lj(L,B)*V(B)*sin(a(B)))+
	   N(L,'b0')*sum(B,Li(L,B)*V(B)*cos(a(B)))));

Pjieq(L).. Pji(L) =e= sum(B,Lj(L,B)*V(B))*sqrt(
	   sqr(N(L,'g')*sum(B,Lj(L,B)*V(B)*cos(a(B)))-
	   N(L,'g')*sum(B,Li(L,B)*V(B)*cos(a(B)))-
	   N(L,'b')*sum(B,Lj(L,B)*V(B)*sin(a(B)))+
	   N(L,'b')*sum(B,Li(L,B)*V(B)*sin(a(B)))-
	   N(L,'b0')*sum(B,Lj(L,B)*V(B)*sin(a(B))))+
	   sqr(N(L,'b')*sum(B,Lj(L,B)*V(B)*cos(a(B)))-
	   N(L,'b')*sum(B,Li(L,B)*V(B)*cos(a(B)))+
	   N(L,'g')*sum(B,Lj(L,B)*V(B)*sin(a(B)))-
	   N(L,'g')*sum(B,Li(L,B)*V(B)*sin(a(B)))+
	   N(L,'b0')*sum(B,Lj(L,B)*V(B)*cos(a(B)))));

$if %control% == 3 $goto solvestat 
$if %control% == 5 $goto solvestat 

N(L,'b')$(ord(L) eq lambda('line')) = -1E-6;
N(L,'g')$(ord(L) eq lambda('line')) = 0;
N(L,'b0')$(ord(L) eq lambda('line')) = 0;
N(L,'g0')$(ord(L) eq lambda('line')) = 0;

Pijceq(L).. Pijc(L) =e= sum(B,Li(L,B)*Vc(B))*sqrt(
	    sqr(N(L,'g')*sum(B,Li(L,B)*Vc(B)*cos(ac(B)))-
	    N(L,'g')*sum(B,Lj(L,B)*Vc(B)*cos(ac(B)))-
	    N(L,'b')*sum(B,Li(L,B)*Vc(B)*sin(ac(B)))+
	    N(L,'b')*sum(B,Lj(L,B)*Vc(B)*sin(ac(B)))-
	    N(L,'b0')*sum(B,Li(L,B)*Vc(B)*sin(ac(B))))+
	    sqr(N(L,'b')*sum(B,Li(L,B)*Vc(B)*cos(ac(B)))-
	    N(L,'b')*sum(B,Lj(L,B)*Vc(B)*cos(ac(B)))+
	    N(L,'g')*sum(B,Li(L,B)*Vc(B)*sin(ac(B)))-
	    N(L,'g')*sum(B,Lj(L,B)*Vc(B)*sin(ac(B)))+
	    N(L,'b0')*sum(B,Li(L,B)*Vc(B)*cos(ac(B)))));

Pjiceq(L).. Pjic(L) =e= sum(B,Lj(L,B)*Vc(B))*sqrt(
	    sqr(N(L,'g')*sum(B,Lj(L,B)*Vc(B)*cos(ac(B)))-
	    N(L,'g')*sum(B,Li(L,B)*Vc(B)*cos(ac(B)))-
	    N(L,'b')*sum(B,Lj(L,B)*Vc(B)*sin(ac(B)))+
	    N(L,'b')*sum(B,Li(L,B)*Vc(B)*sin(ac(B)))-
	    N(L,'b0')*sum(B,Lj(L,B)*Vc(B)*sin(ac(B))))+
	    sqr(N(L,'b')*sum(B,Lj(L,B)*Vc(B)*cos(ac(B)))-
	    N(L,'b')*sum(B,Li(L,B)*Vc(B)*cos(ac(B)))+
	    N(L,'g')*sum(B,Lj(L,B)*Vc(B)*sin(ac(B)))-
	    N(L,'g')*sum(B,Li(L,B)*Vc(B)*sin(ac(B)))+
	    N(L,'b0')*sum(B,Lj(L,B)*Vc(B)*cos(ac(B)))));

$goto solvestat

* -------------------------------------------------------------------------
* Solve Market Problem
* -------------------------------------------------------------------------

$label solvestat
model market /all/;
scalar mstatus  /0/;
scalar sstatus  /0/;

option nlp = minos;
option iterlim = 50000;

$if %control% == 1 $goto linearmodel
$if %control% == 2 $goto linearmodel
$if %control% == 3 $goto nonlinearmodel
$if %control% == 4 $goto nonlinearmodel
$if %control% == 5 $goto nonlinearmodel
$if %control% == 6 $goto nonlinearmodel

$label linearmodel

* option lp = cplex;
solve market using lp minimizing obj;

if ((market.modelstat eq 1), mstatus = 1;);
if ((market.modelstat eq 2), mstatus = 2;);
if ((market.modelstat eq 3), mstatus = 3;);
if ((market.modelstat eq 4), mstatus = 4;);
if ((market.modelstat eq 5), mstatus = 5;);
if ((market.modelstat eq 6), mstatus = 6;);
if ((market.modelstat eq 7), mstatus = 7;);
if ((market.modelstat eq 8), mstatus = 8;);
if ((market.modelstat eq 9), mstatus = 9;);
if ((market.modelstat eq 10), mstatus = 10;);
if ((market.modelstat eq 11), mstatus = 11;);
if ((market.modelstat eq 12), mstatus = 12;);
if ((market.modelstat eq 13), mstatus = 13;);

if ((market.solvestat eq 1), sstatus = 1;);
if ((market.solvestat eq 2), sstatus = 2;);
if ((market.solvestat eq 3), sstatus = 3;);
if ((market.solvestat eq 4), sstatus = 4;);
if ((market.solvestat eq 5), sstatus = 5;);
if ((market.solvestat eq 6), sstatus = 6;);
if ((market.solvestat eq 7), sstatus = 7;);
if ((market.solvestat eq 8), sstatus = 8;);
if ((market.solvestat eq 9), sstatus = 9;);
if ((market.solvestat eq 10), sstatus = 10;);
if ((market.solvestat eq 11), sstatus = 11;);
if ((market.solvestat eq 12), sstatus = 12;);
if ((market.solvestat eq 13), sstatus = 13;);

$goto psatoutput

$label nonlinearmodel

solve market using nlp minimizing obj;

if ((market.modelstat eq 1), mstatus = 1;);
if ((market.modelstat eq 2), mstatus = 2;);
if ((market.modelstat eq 3), mstatus = 3;);
if ((market.modelstat eq 4), mstatus = 4;);
if ((market.modelstat eq 5), mstatus = 5;);
if ((market.modelstat eq 6), mstatus = 6;);
if ((market.modelstat eq 7), mstatus = 7;);
if ((market.modelstat eq 8), mstatus = 8;);
if ((market.modelstat eq 9), mstatus = 9;);
if ((market.modelstat eq 10), mstatus = 10;);
if ((market.modelstat eq 11), mstatus = 11;);
if ((market.modelstat eq 12), mstatus = 12;);
if ((market.modelstat eq 13), mstatus = 13;);

if ((market.solvestat eq 1), sstatus = 1;);
if ((market.solvestat eq 2), sstatus = 2;);
if ((market.solvestat eq 3), sstatus = 3;);
if ((market.solvestat eq 4), sstatus = 4;);
if ((market.solvestat eq 5), sstatus = 5;);
if ((market.solvestat eq 6), sstatus = 6;);
if ((market.solvestat eq 7), sstatus = 7;);
if ((market.solvestat eq 8), sstatus = 8;);
if ((market.solvestat eq 9), sstatus = 9;);
if ((market.solvestat eq 10), sstatus = 10;);
if ((market.solvestat eq 11), sstatus = 11;);
if ((market.solvestat eq 12), sstatus = 12;);
if ((market.solvestat eq 13), sstatus = 13;);

$if not %control% == 4 $goto psatoutput

lambdac.up = lambdac.l;
lambdac.lo = lambdac.l-1.0E-5;
lambda('omega') = 0;
option nlp = minos;
solve market using nlp minimizing obj;

$label psatoutput

$libinclude psatout Ps.l G
$libinclude psatout Pd.l C

$if %control% == 1 $libinclude psatout Pbalance.m
$if %control% == 1 $goto end_output

$if %control% == 2 $libinclude psatout Peq.m B
$if %control% == 2 $goto end_output

$libinclude psatout V.l B
$libinclude psatout a.l B
$libinclude psatout Qg.l B
$libinclude psatout Peq.m B
$libinclude psatout Pij.l L
$libinclude psatout Pji.l L

$if %control% == 5 $goto no_dual

$libinclude psatout V.m B
$libinclude psatout Pij.m L
$libinclude psatout Pji.m L

$label no_dual

$if %control% == 3 $goto end_output

$libinclude psatout lambdac.l
$libinclude psatout kg.l

$if %control% == 5 $goto end_output

$libinclude psatout Vc.l B
$libinclude psatout ac.l B
$libinclude psatout Qgc.l B
$libinclude psatout Pijc.l L
$libinclude psatout Pjic.l L

$libinclude psatout Pceq.m B

$if %control% == 4 $goto end_output

$libinclude psatout lambdac.m

$label end_output

$libinclude psatout mstatus
$libinclude psatout sstatus

