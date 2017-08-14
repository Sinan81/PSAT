$offlisting

* MATOUT.GMS - Matlab-GAMS interface library.
*              Create MATSOL.GMS file for output variables
*              to be read by the GAMS.M function.
*
*Author:    Michael C. Ferris
*Date:      10-Aug-1999
*
*E-mail:    ferris@cs.wisc.edu
*Web-site:  http://www.cs.wisc.edu/math-prog/matlab.html
*
* ------------------------------------------------------------
*
*Update:    01-Mar-2003
*Author:    Federico Milano/ Michael C. Ferris
*Version:   1.0.1
*
*       Skip compilation is there is a pre-existing program error:

$if not errorfree $exit

*	Do nothing if no input arguments

$if '%1' == '' $exit

$if declared matsol $goto matsoldec
file matsol /matsol.gms/;
matsol.ap = 0;
scalar matsolcnt /0/;
$goto printit

$label matsoldec
matsol.ap = 1;

$label printit
matsol.nr = 0;
matsol.nz = 0;
$if not setglobal matsollw $setglobal matsollw '12' 
matsol.lw = %matsollw%;
put matsol;

$if %1 == matstr $goto stringout
$if %1 == matlbl $goto labelout
$if declared %1  $goto declared
$error Error in matout: identfier %1 is undeclared.
$exit

$label declared
$if defined %1     $goto defined
$error Error in matout: identfier %1 is undefined.
$exit

$label defined
$if partype %1 $goto decpar
$if vartype %1 $goto decpar
$if equtype %1 $goto decpar
$if settype %1 $goto decset
$error Error in matout: identfier %1 is not a parameter, set, variable or equation.
$exit

*       Set up temporary sets for processing:
$label decset
put '::%1'/;
$if dimension 1 %1 $goto sdim1
* remainder does sparse multi-d sets
$if a%2 == a    $goto badargs
$if not settype %2 $goto notsetarg
$if a%3 == a    $goto badargs
$if not settype %3 $goto notsetarg
$if dimension 2 %1 $goto sdim2
$if a%4 == a    $goto badargs
$if not settype %4 $goto notsetarg
$if dimension 3 %1 $goto sdim3
$error Error in matout: too many dimensions on set
$exit


$label decpar
put '::%1'/;
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

$error Error in matout: too many dimensions on parameter
$exit;

$label scalar
put 'd 1 1'/;
matsol.nr=2; put '1 '%1:22:13/; matsol.nr=0;
$goto endprint

$label dim1
put 'd 1 'card(%2):0:0/;
loop(%2$%1(%2), put ord(%2):0:0' '; matsol.nr=2; put %1(%2):22:13/; matsol.nr=0);
$goto endprint

$label sdim1
$if not a%3 == a	$goto badargs
$set rr 'tl';
$if a%2 == ate	$set rr 'te(%1)';
put 'c 1 'card(%1):0:0/;
loop(%1, put ord(%1):0:0' '%1.%rr%/);
$goto endprint

$label dim2
put 'd 2 'card(%2):0:0' 'card(%3):0:0/;
$set rr '%2,%3';
loop((%rr%)$%1(%rr%), put ord(%2):0:0'.'ord(%3):0:0' '; matsol.nr=2; put %1(%rr%):22:13/; matsol.nr=0);
$goto endprint

$label sdim2
put 'd 2 'card(%1):0:0' 2'/;
$set rr '%2,%3';
matsolcnt = 0;
loop((%rr%)$%1(%rr%), matsolcnt = matsolcnt+1; put matsolcnt:0:0'.1 'ord(%2):0:0/matsolcnt:0:0'.2 'ord(%3):0:0/;);
$goto endprint

$label dim3
put 'd 3 'card(%2):0:0' 'card(%3):0:0' 'card(%4):0:0/;
$set rr '%2,%3,%4';
loop((%rr%)$%1(%rr%), put ord(%2):0:0'.'ord(%3):0:0'.'ord(%4):0:0' '; matsol.nr=2; put %1(%rr%):22:13/; matsol.nr=0);
$goto endprint

$label sdim3
put 'd 2 'card(%1):0:0' 3'/;
$set rr '%2,%3,%4';
matsolcnt = 0;
loop((%rr%)$%1(%rr%), matsolcnt = matsolcnt+1; put matsolcnt:0:0'.1 'ord(%2):0:0/matsolcnt:0:0'.2 'ord(%3):0:0/matsolcnt:0:0'.3 'ord(%4):0:0/;);
$goto endprint

$label dim4
put 'd 4 'card(%2):0:0' 'card(%3):0:0' 'card(%4):0:0' 'card(%5):0:0/;
$set rr '%2,%3,%4,%5';
loop((%rr%)$%1(%rr%), 
 put ord(%2):0:0'.'ord(%3):0:0'.'ord(%4):0:0'.'ord(%5):0:0' ';
 matsol.nr=2; put %1(%rr%):22:13/; matsol.nr=0);
$goto endprint

$label dim5
put 'd 5 'card(%2):0:0' 'card(%3):0:0' 'card(%4):0:0' 'card(%5):0:0' 'card(%6):0:0/;
$set rr '%2,%3,%4,%5,%6';
loop((%rr%)$%1(%rr%), 
 put ord(%2):0:0'.'ord(%3):0:0'.'ord(%4):0:0'.'ord(%5):0:0'.'ord(%6):0:0' ';
 matsol.nr=2; put %1(%rr%):22:13/; matsol.nr=0);
$goto endprint

$label dim6
put 'd 6 'card(%2):0:0' 'card(%3):0:0' 'card(%4):0:0' 'card(%5):0:0' '
    card(%6):0:0' 'card(%7):0:0/;
$set rr '%2,%3,%4,%5,%6,%7';
loop((%rr%)$%1(%rr%), 
	put ord(%2):0:0'.'ord(%3):0:0'.'ord(%4):0:0'.'ord(%5):0:0
	    '.'ord(%6):0:0'.'ord(%7):0:0' ';
	matsol.nr=2;
	put %1(%rr%):22:13/;
	matsol.nr=0);
$goto endprint

$label dim7
put 'd 7 'card(%2):0:0' 'card(%3):0:0' 'card(%4):0:0' 'card(%5):0:0' '
    card(%6):0:0' 'card(%7):0:0' 'card(%8):0:0/;
$set rr '%2,%3,%4,%5,%6,%7,%8';
loop((%rr%)$%1(%rr%), 
	put ord(%2):0:0'.'ord(%3):0:0'.'ord(%4):0:0'.'ord(%5):0:0
	    '.'ord(%6):0:0'.'ord(%7):0:0'.'ord(%8):0:0' ';
	matsol.nr=2;
	put %1(%rr%):22:13/;
	matsol.nr=0);
$goto endprint

$label dim8
put 'd 8 'card(%2):0:0' 'card(%3):0:0' 'card(%4):0:0' 'card(%5):0:0' '
    card(%6):0:0' 'card(%7):0:0' 'card(%8):0:0' 'card(%9):0:0/;
$set rr '%2,%3,%4,%5,%6,%7,%8,%9';
loop((%rr%)$%1(%rr%), 
	put ord(%2):0:0'.'ord(%3):0:0'.'ord(%4):0:0'.'ord(%5):0:0
	    '.'ord(%6):0:0'.'ord(%7):0:0'.'ord(%8):0:0'.'ord(%9):0:0' ';
	matsol.nr=2;
	put %1(%rr%):22:13/;
	matsol.nr=0);
$goto endprint

$label dim9
put 'd 9 'card(%2):0:0' 'card(%3):0:0' 'card(%4):0:0' 'card(%5):0:0' '
    card(%6):0:0' 'card(%7):0:0' 'card(%8):0:0' 'card(%9):0:0' 'card(%10):0:0/;
$set rr '%2,%3,%4,%5,%6,%7,%8,%9,%10';
loop((%rr%)$%1(%rr%), 
	put ord(%2):0:0'.'ord(%3):0:0'.'ord(%4):0:0'.'ord(%5):0:0
	    '.'ord(%6):0:0'.'ord(%7):0:0'.'ord(%8):0:0'.'ord(%9):0:0
	    '.'ord(%10):0:0' ';
	matsol.nr=2;
	put %1(%rr%):22:13/;
	matsol.nr=0);
$goto endprint

$label dim10
put 'd 10 'card(%2):0:0' 'card(%3):0:0' 'card(%4):0:0' 'card(%5):0:0' '
    card(%6):0:0' 'card(%7):0:0' 'card(%8):0:0' 'card(%9):0:0' '
    card(%10):0:0' 'card(%11):0:0/;
$set rr '%2,%3,%4,%5,%6,%7,%8,%9,%10,%11';
loop((%rr%)$%1(%rr%), 
	put ord(%2):0:0'.'ord(%3):0:0'.'ord(%4):0:0'.'ord(%5):0:0
	    '.'ord(%6):0:0'.'ord(%7):0:0'.'ord(%8):0:0'.'ord(%9):0:0
	    '.'ord(%10):0:0'.'ord(%11):0:0' ';
	matsol.nr=2;
	put %1(%rr%):22:13/;
	matsol.nr=0);
$goto endprint

$label badargs
$error Error in matout: wrong number of set arguments passed
$exit

$label notsetarg
$error Error in matout: second to n args must be sets
$exit

$label stringout
$if '%2' == '' $goto badstring
put '::string'/'c 1 1'/'1 %2'/;
$goto endprint

$label labelout
$if '%2' == '' $goto badstring
put '::%2'/'c 1 1'/'1 '%2/;
$goto endprint

$label badstring
$error Error in matout: string returns need 2 arguments
$exit

$label endprint
putclose matsol;
$exit

