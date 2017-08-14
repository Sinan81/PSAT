$offlisting

* PSATOUT.GMS - PSAT-GAMS interface library.
*               Create PSATSOL.M file for output variables
*
*Author:    Federico Milano
*Date:      27-Apr-2003
*
*E-mail:    fmilano@thunderbox.uwaterloo.ca
*Web-site:  http://thunderbox.uwaterloo.ca/~fmilano
*
* ----------------------------------------------------------------

*       Skip compilation is there is a pre-existing program error:

$if not errorfree $exit

*	Do nothing if no input arguments

$if '%1' == '' $exit

$if declared psatsol $goto psatsoldec
file psatsol /psatsol.m/;
psatsol.ap = 0;
scalar psatsolcnt /0/;

$goto printit

$label psatsoldec
psatsol.ap = 1;

$label printit
psatsol.nr = 0;
psatsol.nz = 0;
$if not setglobal psatsollw $setglobal psatsollw '12' 
psatsol.lw = %psatsollw%;
put psatsol;

$if declared %1  $goto declared
$error Error in psatout: identfier %1 is undeclared.
$exit

$label declared
$if defined %1     $goto defined
$error Error in psatout: identfier %1 is undefined.
$exit

$label defined
$if partype %1 $goto decpar
$if vartype %1 $goto decpar
$if equtype %1 $goto decpar
$error Error in psatout: identfier %1 is not a parameter, variable or equation.
$exit

$label decpar
put 'nout = nout + 1;'/;
$if dimension 0 %1 $goto scalar 
$if a%2 == a    $goto badargs
$if not settype %2 $goto notsetarg
$if dimension 1 %1 $goto dim1
$if a%3 == a    $goto badargs
$if not settype %3 $goto notsetarg
$if dimension 2 %1 $goto dim2
$if a%4 == a    $goto badargs
$if not settype %4 $goto notsetarg
$if dimension 3 %1 $goto dim3
$if a%5 == a    $goto badargs
$if not settype %5 $goto notsetarg
$if dimension 4 %1 $goto dim4
$if a%6 == a    $goto badargs
$if not settype %6 $goto notsetarg
$if dimension 5 %1 $goto dim5
$if a%7 == a    $goto badargs
$if not settype %7 $goto notsetarg
$if dimension 6 %1 $goto dim6
$if a%8 == a    $goto badargs
$if not settype %8 $goto notsetarg
$if dimension 7 %1 $goto dim7
$if a%9 == a    $goto badargs
$if not settype %9 $goto notsetarg
$if dimension 8 %1 $goto dim8
$if a%10 == a    $goto badargs
$if not settype %10 $goto notsetarg
$if dimension 9 %1 $goto dim9
$if a%11 == a    $goto badargs
$if not settype %11 $goto notsetarg
$if dimension 10 %1 $goto dim10

$error Error in psatout: too many dimensions on parameter
$exit;

$label scalar
psatsol.nr=2; 
put 'varargout{nout} = '%1:22:13';'/; 
psatsol.nr=0;
$goto endprint

$label dim1
put 'varargout{nout} = zeros('card(%2):0:0',1);'/;
loop(%2$%1(%2), 
 put 'varargout{nout}('ord(%2):0:0') = '; 
 psatsol.nr=2; put %1(%2):22:13';'/; psatsol.nr=0);
$goto endprint

$label dim2
put 'varargout{nout} = zeros('card(%2):0:0','card(%3):0:0');'/;
$set rr '%2,%3';
loop((%rr%)$%1(%rr%), 
 put 'varargout{nout}('ord(%2):0:0','ord(%3):0:0') = '; 
 psatsol.nr=2; put %1(%rr%):22:13';'/; psatsol.nr=0);
$goto endprint

$label dim3
put 'varargout{nout} = zeros('card(%2):0:0','card(%3):0:0','card(%4):0:0');'/;
$set rr '%2,%3,%4';
loop((%rr%)$%1(%rr%), 
 put 'varargout{nout}('ord(%2):0:0','ord(%3):0:0','ord(%4):0:0') = '; 
 psatsol.nr=2; put %1(%rr%):22:13';'/; psatsol.nr=0);
$goto endprint

$label dim4
put 'varargout{nout} = zeros('card(%2):0:0','card(%3):0:0','card(%4):0:0
    ','card(%5):0:0');'/;
$set rr '%2,%3,%4,%5';
loop((%rr%)$%1(%rr%), 
 put 'varargout{nout}('ord(%2):0:0','ord(%3):0:0','ord(%4):0:0
     ','ord(%5):0:0') = ';
 psatsol.nr=2; put %1(%rr%):22:13';'/; psatsol.nr=0);
$goto endprint

$label dim5
put 'varargout{nout} = zeros('card(%2):0:0','card(%3):0:0','card(%4):0:0
    ','card(%5):0:0','card(%6):0:0');'/;
$set rr '%2,%3,%4,%5,%6';
loop((%rr%)$%1(%rr%), 
 put 'varargout{nout}('ord(%2):0:0','ord(%3):0:0','ord(%4):0:0
     ','ord(%5):0:0','ord(%6):0:0') = ';
 psatsol.nr=2; put %1(%rr%):22:13';'/; psatsol.nr=0);
$goto endprint

$label dim6
put 'varargout{nout} = zeros('card(%2):0:0','card(%3):0:0','card(%4):0:0
    ','card(%5):0:0','card(%6):0:0','card(%7):0:0');'/;
$set rr '%2,%3,%4,%5,%6,%7';
loop((%rr%)$%1(%rr%), 
 put 'varargout{nout}('ord(%2):0:0','ord(%3):0:0','ord(%4):0:0
     ','ord(%5):0:0','ord(%6):0:0','ord(%7):0:0') = ';
 psatsol.nr=2; put %1(%rr%):22:13';'/; psatsol.nr=0);
$goto endprint

$label dim7
put 'varargout{nout} = zeros('card(%2):0:0','card(%3):0:0','card(%4):0:0
    ','card(%5):0:0','card(%6):0:0','card(%7):0:0','card(%8):0:0');'/;
$set rr '%2,%3,%4,%5,%6,%7,%8';
loop((%rr%)$%1(%rr%), 
 put 'varargout{nout}('ord(%2):0:0','ord(%3):0:0','ord(%4):0:0','ord(%5):0:0
     ','ord(%6):0:0','ord(%7):0:0','ord(%8):0:0') = ';
 psatsol.nr=2; put %1(%rr%):22:13';'/; psatsol.nr=0);
$goto endprint

$label dim8
put 'varargout{nout} = zeros('card(%2):0:0','card(%3):0:0','card(%4):0:0
    ','card(%5):0:0','card(%6):0:0','card(%7):0:0','card(%8):0:0','card(%9):0:0');'/;
$set rr '%2,%3,%4,%5,%6,%7,%8,%9';
loop((%rr%)$%1(%rr%), 
 put 'varargout{nout}('ord(%2):0:0','ord(%3):0:0','ord(%4):0:0','ord(%5):0:0
     ','ord(%6):0:0','ord(%7):0:0','ord(%8):0:0','ord(%9):0:0') = ';
 psatsol.nr=2; put %1(%rr%):22:13';'/; psatsol.nr=0);
$goto endprint

$label dim9
put 'varargout{nout} = zeros('card(%2):0:0','card(%3):0:0','card(%4):0:0
    ','card(%5):0:0','card(%6):0:0','card(%7):0:0','card(%8):0:0','card(%9):0:0
    ','card(%10):0:0');'/;
$set rr '%2,%3,%4,%5,%6,%7,%8,%9,%10';
loop((%rr%)$%1(%rr%), 
put 'varargout{nout}('ord(%2):0:0','ord(%3):0:0','ord(%4):0:0','ord(%5):0:0
    ','ord(%6):0:0','ord(%7):0:0','ord(%8):0:0','ord(%9):0:0','ord(%10):0:0') = ';
 psatsol.nr=2; put %1(%rr%):22:13';'/; psatsol.nr=0);
$goto endprint

$label dim10
put 'varargout{nout} = zeros('card(%2):0:0','card(%3):0:0','card(%4):0:0
    ','card(%5):0:0','card(%6):0:0','card(%7):0:0','card(%8):0:0','card(%9):0:0
    ','card(%10):0:0','card(%11):0:0');'/;
$set rr '%2,%3,%4,%5,%6,%7,%8,%9,%10,%11';
loop((%rr%)$%1(%rr%), 
put 'varargout{nout}('ord(%2):0:0','ord(%3):0:0','ord(%4):0:0','ord(%5):0:0
    ','ord(%6):0:0','ord(%7):0:0','ord(%8):0:0','ord(%9):0:0
    ','ord(%10):0:0','ord(%11):0:0') = ';
psatsol.nr=2; put %1(%rr%):22:13';'/; psatsol.nr=0);
$goto endprint

$label badargs
$error Error in psatout: wrong number of set arguments passed
$exit

$label notsetarg
$error Error in psatout: second to n args must be sets
$exit

$label badstring
$error Error in psatout: string returns need 2 arguments
$exit

$label endprint
putclose psatsol;
$exit

