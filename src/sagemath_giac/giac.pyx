r"""
Interface to the c++ giac library.

Giac is a general purpose Computer algebra system by Bernard Parisse
released under GPLv3.

- http://www-fourier.ujf-grenoble.fr/~parisse/giac.html
- It is build on C and C++ libraries: NTL (arithmetic), GSL (numerics), GMP
  (big integers), MPFR (bigfloats)
- It  provides fast  algorithms  for multivariate polynomial operations
  (product, GCD, factorisation) and
- symbolic  computations: solver, simplifications, limits/series, integration,
  summation...
- Linear Algebra with numerical or symbolic coefficients.

AUTHORS:

- Frederic Han (2013-09-23): initial version
- Vincent Delecroix (2020-09-02): move inside Sage source code

EXAMPLES:

The class Pygen is the main tool to interact from python/sage with the c++
library giac via cython.  The initialisation of a Pygen just create an object
in giac, but the mathematical computation  is not done. This class is mainly
for cython users.  Here A is a Pygen element, and it is ready for any giac
function.::

    >>> from sagemath_giac.giac import *
    >>> A = Pygen('2+2')
    >>> A
    2+2
    >>> A.eval()
    4

In general, you may prefer to directly create a Pygen and execute the
evaluation in giac. This is exactly the meaning of the :func:`libgiac`
function.::

    >>> a = libgiac('2+2')
    >>> a
    4
    >>> isinstance(a, Pygen)
    True

Most common usage of this package in sage will be with the libgiac() function.
This function is just the composition of the Pygen initialisation and the
evaluation of this object in giac.::

    >>> x,y,z = libgiac('x,y,z')  # add some giac objects
    >>> f = (x+y*3)/(x+z+1)**2 - (x+z+1)**2 / (x+y*3)
    >>> f.factor()
    (3*y-x^2-2*x*z-x-z^2-2*z-1)*(3*y+x^2+2*x*z+3*x+z^2+2*z+1)/((x+z+1)^2*(3*y+x))
    >>> f.normal()
    (-x^4-4*x^3*z-4*x^3-6*x^2*z^2-12*x^2*z-5*x^2+6*x*y-4*x*z^3-12*x*z^2-12*x*z-4*x+9*y^2-z^4-4*z^3-6*z^2-4*z-1)/(x^3+3*x^2*y+2*x^2*z+2*x^2+6*x*y*z+6*x*y+x*z^2+2*x*z+x+3*y*z^2+6*y*z+3*y)

Some settings of giac are available via the ``giacsettings``
element. (Ex: maximal number of threads in computations, allowing
probabilistic algorithms or not...::

    >>> from sage.rings.polynomial.polynomial_ring_constructor import PolynomialRing
    >>> from sage.rings.rational_field import QQ
    >>> from sage.rings.ideal import Katsura as KatsuraIdeal
    >>> R = PolynomialRing(QQ,8,'x')
    >>> I = KatsuraIdeal(R,8)
    >>> giacsettings.proba_epsilon = 1e-15  # faster, but can fail
    >>> Igiac = libgiac(I.gens());
    >>> Bgiac = Igiac.gbasis([R.gens()],'revlex')
    >>> len(Bgiac)
    74
    >>> giacsettings.proba_epsilon = 0  # slower, but more reliable
    >>> Igiac = libgiac(I.gens())
    >>> Bgiac = Igiac.gbasis([R.gens()],'revlex')
    >>> len(Bgiac)
    74
    >>> giacsettings.proba_epsilon = 1e-15

  ::

    >>> x = libgiac('x')
    >>> f = libgiac(1) / (libgiac.sin(x*5)+2)
    >>> f.int()
    2/5/sqrt(3)*(atan((-sqrt(3)*sin(5*x)+cos(5*x)+2*sin(5*x)+1)/(sqrt(3)*cos(5*x)+sqrt(3)-2*cos(5*x)+sin(5*x)+2))+5*x/2)
    >>> f.series(x,0,3)
    1/2-5/4*x+25/8*x^2-125/48*x^3+x^4*order_size(x)
    >>> (libgiac.sqrt(5)+libgiac.pi).approx(100)
    5.377660631089582934871817052010779119637787758986631545245841837718337331924013898042449233720899343

TESTS::

    >>> from sagemath_giac.giac import libgiac
    >>> libgiac(3**100)
    515377520732011331036461129765621272702107522001
    >>> libgiac(-3**100)
    -515377520732011331036461129765621272702107522001
    >>> libgiac(-11**1000)
    -2469932918005826334124088385085221477709733385238396234869182951830739390375433175367866116456946191973803561189036523363533798726571008961243792655536655282201820357872673322901148243453211756020067624545609411212063417307681204817377763465511222635167942816318177424600927358163388910854695041070577642045540560963004207926938348086979035423732739933235077042750354729095729602516751896320598857608367865475244863114521391548985943858154775884418927768284663678512441565517194156946312753546771163991252528017732162399536497445066348868438762510366191040118080751580689254476068034620047646422315123643119627205531371694188794408120267120500325775293645416335230014278578281272863450085145349124727476223298887655183167465713337723258182649072572861625150703747030550736347589416285606367521524529665763903537989935510874657420361426804068643262800901916285076966174176854351055183740078763891951775452021781225066361670593917001215032839838911476044840388663443684517735022039957481918726697789827894303408292584258328090724141496484460001

Ensure that signed infinities get converted correctly::

    >>> from sage.rings.infinity import Infinity
    >>> libgiac(+Infinity)
    +infinity
    >>> libgiac(-Infinity)
    -infinity

.. SEEALSO::

    ``libgiac``, ``giacsettings``, ``Pygen``,``loadgiacgen``


GETTING HELP:

- To obtain some help on a giac keyword use the help() method. In sage the
  htmlhelp() method for Pygen element is disabled. Just use the ? or .help()
  method.

- You can find full html documentation about the **giac** functions  at:

      - https://www-fourier.ujf-grenoble.fr/~parisse/giac/doc/en/cascmd_en/

      - https://www-fourier.ujf-grenoble.fr/~parisse/giac/doc/fr/cascmd_fr/

      - https://www-fourier.ujf-grenoble.fr/~parisse/giac/doc/el/cascmd_el/

"""
# ****************************************************************************
#       Copyright (C) 2012, Frederic Han <frederic.han@imj-prg.fr>
#                     2020, Vincent Delecroix <20100.delecroix@gmail.com>
#
#  Distributed under the terms of the GNU General Public License (GPL)
#  as published by the Free Software Foundation; either version 2 of
#  the License, or (at your option) any later version.
#                  https://www.gnu.org/licenses/
#*****************************************************************************

from cysignals.signals cimport *
from gmpy2 cimport import_gmpy2, mpz_set
from sys import maxsize as Pymaxint, version_info as Pyversioninfo
import os
import math

# sage includes
from sage.ext.stdsage cimport PY_NEW
from sage.rings.integer_ring import ZZ
from sage.rings.rational_field import QQ
from sage.rings.finite_rings.integer_mod_ring import IntegerModRing
from sage.rings.integer cimport Integer
from sage.rings.infinity import AnInfinity
from sage.rings.rational cimport Rational
from sage.structure.element cimport Matrix

from sage.symbolic.expression import symbol_table
from sage.calculus.calculus import symbolic_expression_from_string, SR_parser_giac
from sage.symbolic.ring import SR
from sage.symbolic.expression import Expression
from sage.symbolic.expression_conversions import InterfaceInit
from sage.interfaces.giac import giac


# initialize the gmpy2 C-API
import_gmpy2()


# Python3 compatibility ############################
def encstring23(s):
    return bytes(s, 'UTF-8')
# End of Python3 compatibility #####################


########################################################
# A global context pointer. One by giac session.
########################################################
cdef context * context_ptr = new context()

# Some global variables for optimisation
GIACNULL = Pygen('NULL')

# Create a giac setting instance
giacsettings = GiacSetting()
Pygen('I:=sqrt(-1)').eval()   # WTF?

# A function to convert SR Expression with defined giac conversion to a string
# for giac/libgiac.
# NB: We want to do this without starting an external giac program and
# self._giac_() does.
SRexpressiontoGiac = InterfaceInit(giac)


#######################################################
# The wrapper to eval with giac
#######################################################
# in sage we don't export the giac function. We replace it by libgiac
def _giac(s):
    """
    This function evaluate a python/sage object with the giac
    library. It creates in python/sage a Pygen element and evaluate it
    with giac:

    EXAMPLES::

        >>> from sagemath_giac.giac import libgiac
        >>> x,y = libgiac('x,y')
        >>> (x + y*2).cos().texpand()
        cos(x)*(2*cos(y)^2-1)-sin(x)*2*cos(y)*sin(y)

    Coercion, Pygen and internal giac variables: The most useful
    objects will be the Python object of type Pygen::

        >>> x,y,z = libgiac('x,y,z')
        >>> f = sum([x[i] for i in range(5)], libgiac(0))**15/(y+z)
        >>> f.coeff(x[0],12)
        (455*(x[1])^3+1365*(x[1])^2*x[2]+1365*(x[1])^2*x[3]+1365*(x[1])^2*x[4]+1365*x[1]*(x[2])^2+2730*x[1]*x[2]*x[3]+2730*x[1]*x[2]*x[4]+1365*x[1]*(x[3])^2+2730*x[1]*x[3]*x[4]+1365*x[1]*(x[4])^2+455*(x[2])^3+1365*(x[2])^2*x[3]+1365*(x[2])^2*x[4]+1365*x[2]*(x[3])^2+2730*x[2]*x[3]*x[4]+1365*x[2]*(x[4])^2+455*(x[3])^3+1365*(x[3])^2*x[4]+1365*x[3]*(x[4])^2+455*(x[4])^3)/(y+z)

    Warning: The complex number sqrt(-1) is available in SageMath as
    ``I``, but it may appears as ``i``::

        >>> from sage.rings.imaginary_unit import I
        >>> libgiac((libgiac.sqrt(3)*I + 1)**3).normal()
        -8
        >>> libgiac(1+I)
        1+i

    Python integers and reals can be directly converted to giac.::

        >>> libgiac(2**1024).nextprime()
        179769313486231590772930519078902473361797697894230657273430081157732675805500963132708477322407536021120113879871393357658789768814416622492847430639474124377767893424865485276302219601246094119453082952085005768838150682342462881473913110540827237163350510684586298239947245938479716304835356329624224137859
        >>> libgiac(1.234567).erf().approx(10)
        0.9191788641

    The Python object ``y`` defined above is of type Pygen. It is not
    an internal giac variable. (Most of the time you won't need to use
    internal giac variables)::

        >>> libgiac('y:=1'); y
        1
        y
        >>> libgiac.purge('y')
        1
        >>> libgiac('y')
        y

    There are some natural coercion to Pygen elements::

        >>> libgiac.pi > 3.14
        True
        >>> libgiac.pi > 3.15
        False
        >>> libgiac(3) == 3
        True

    Linear Algebra. In Giac/Xcas vectors are just lists and matrices
    are lists of list::

        >>> x,y = libgiac('x,y')
        >>> A = libgiac([[1,2],[3,4]])  # giac matrix
        >>> v = libgiac([x,y]); v  # giac vector
        [x,y]
        >>> A*v  # matrix-vector product
        [x+2*y,3*x+4*y]
        >>> v*v  # dot product
        x*x+y*y

    Remark that ``w=giac([[x],[y]])`` is a matrix of 1 column and 2
    rows. It is not a vector so w*w doesn't make sense.::

        >>> w = libgiac([[x],[y]])
        >>> w.transpose()*w
        matrix[[x*x+y*y]]

    In sage, changing an entry doesn't create a new matrix (see also
    the doc of ``Pygen.__setitem__``)::

        >>> B1 = A
        >>> B1[0,0]=43; B1 # in place affectation changes both B1 and A
        [[43,2],[3,4]]
        >>> A
        [[43,2],[3,4]]
        >>> A[0][0]=A[0][0]+1; A  # similar as A[0,0]=A[0,0]+1
        [[44,2],[3,4]]
        >>> A.pcar(x)  # compute the characteristic polynomial of A
        x^2-48*x+170
        >>> B2=A.copy() # use copy to create another object
        >>> B2[0,0]=55; B2  # here A is not modified
        [[55,2],[3,4]]
        >>> A
        [[44,2],[3,4]]

    Sparse Matrices are available via the table function::

        >>> A = libgiac.table(()); A  # create an empty giac table
        table(
        )
        >>> A[2,3] = 33; A[0,2] = '2/7' # set nonzero entries of the sparse matrix
        >>> A*A  # basic matrix operation are supported with sparse matrices
        table(
        (0,3) = 66/7
        )
        >>> D = libgiac.diag([22,3,'1/7']); D  # some diagonal matrix
        [[22,0,0],[0,3,0],[0,0,1/7]]
        >>> libgiac.table(D)    # to create a sparse matrix from an ordinary one
        table(
        (0,0) = 22,
        (1,1) = 3,
        (2,2) = 1/7
        )

    But many matrix functions apply only with ordinary matrices so
    need conversions::

        >>> B1 = A.matrix(); B1 # convert the sparse matrix to a matrix, but the size is minimal
        [[0,0,2/7,0],[0,0,0,0],[0,0,0,33]]
        >>> B2 = B1.redim(4,4) # so we may need to resize B1
        >>> B2.pmin(x)
        x^3

    Lists of Pygen and Giac lists. Here l1 is a giac list and l2 is a
    python list of Pygen type objects::

        >>> l1 = libgiac(range(10))
        >>> l2 = [libgiac(1)/(i**2+1) for i in l1]
        >>> sum(l2, libgiac(0))
        33054527/16762850

    So l1+l1 is done in giac and means a vector addition. But l2+l2 is
    done in Python so it is the list concatenation::

        >>> l1+l1
        [0,2,4,6,8,10,12,14,16,18]
        >>> l2+l2
        [1, 1/2, 1/5, 1/10, 1/17, 1/26, 1/37, 1/50, 1/65, 1/82, 1, 1/2, 1/5, 1/10, 1/17, 1/26, 1/37, 1/50, 1/65, 1/82]

    Here V is not a Pygen element. We need to push it to giac to use a
    giac method like dim, or we need to use an imported function::

        >>> V = [ [x[i]**j for i in range(8)] for j in range(8)]
        >>> libgiac(V).dim()
        [8,8]
        >>> libgiac.det_minor(V).factor()
        (x[6]-(x[7]))*(x[5]-(x[7]))*(x[5]-(x[6]))*(x[4]-(x[7]))*(x[4]-(x[6]))*(x[4]-(x[5]))*(x[3]-(x[7]))*(x[3]-(x[6]))*(x[3]-(x[5]))*(x[3]-(x[4]))*(x[2]-(x[7]))*(x[2]-(x[6]))*(x[2]-(x[5]))*(x[2]-(x[4]))*(x[2]-(x[3]))*(x[1]-(x[7]))*(x[1]-(x[6]))*(x[1]-(x[5]))*(x[1]-(x[4]))*(x[1]-(x[3]))*(x[1]-(x[2]))*(x[0]-(x[7]))*(x[0]-(x[6]))*(x[0]-(x[5]))*(x[0]-(x[4]))*(x[0]-(x[3]))*(x[0]-(x[2]))*(x[0]-(x[1]))

    Modular objects with ``%``::

        >>> V = libgiac.ranm(5,6) % 2
        >>> V.ker().rowdim()+V.rank()
        6
        >>> a = libgiac(7)%3
        >>> a
        1 % 3
        >>> a % 0
        1
        >>> 7 % 3
        1

    Do not confuse with the python integers::

        >>> type(7 % 3) == type(a)
        False
        >>> type(a) == type(7 % 3)
        False

    Syntax with reserved or unknown Python/sage symbols. In general
    equations needs symbols such as ``=``, ``<`` or ``>`` that have
    another meaning in Python or Sage. So those objects must be
    quoted::

        >>> x = libgiac('x')
        >>> (libgiac.sin(x*3)*2 + 1).solve(x).simplify()
        list[-pi/18,7*pi/18]

        >>> libgiac.solve('x^3-x>x',x)
        list[((x>(-sqrt(2))) and (x<0)),x>(sqrt(2))]

    You can also add some hypothesis to a giac symbol::

        >>> libgiac.assume('x>-pi && x<pi')
        x
        >>> libgiac.solve('sin(3*x)>2*sin(x)',x)
        list[((x>(-5*pi/6)) and (x<(-pi/6))),((x>0) and (x<(pi/6))),((x>(5*pi/6)) and (x<pi))]

    To remove those hypothesis use the giac function ``purge``::

        >>> libgiac.purge('x')
        assume[[],[line[-pi,pi]],[-pi,pi]]
        >>> libgiac.solve('x>0')
        list[x>0]

    Same problems with the ``..``::

        >>> x = libgiac('x')
        >>> f = libgiac(1)/(libgiac.cos(x*4)+5)
        >>> f.int()
        1/2/(2*sqrt(6))*(atan((-sqrt(6)*sin(4*x)+2*sin(4*x))/(sqrt(6)*cos(4*x)+sqrt(6)-2*cos(4*x)+2))+4*x/2)
        >>> libgiac.fMax(f,'x=-0..pi').simplify()
        pi/4,3*pi/4
        >>> libgiac.sum(libgiac(1)/(x**2+1),'x=0..infinity').simplify()
        (pi*exp(pi)^2+pi+exp(pi)^2-1)/(2*exp(pi)^2-2)

    From giac to sage. One can convert a Pygen element to sage with
    the ``sage`` method::

        >>> L = libgiac('[1,sqrt(5),[1.3,x]]')
        >>> L.sage()       # All entries are converted recursively
        [1, sqrt(5), [1.30000000000000, x]]

        >>> from sage.symbolic.ring import SR
        >>> from sage.matrix.constructor import matrix
        >>> n = SR.symbol('n')
        >>> A = matrix([[1,2],[-1,1]])
        >>> B = libgiac(A).matpow(n)    # We compute the symbolic power on A via libgiac
        >>> C = matrix(SR,B); C         # We convert B to sage
        [                     1/2*(I*sqrt(2) + 1)^n + 1/2*(-I*sqrt(2) + 1)^n -1/2*I*sqrt(2)*(I*sqrt(2) + 1)^n + 1/2*I*sqrt(2)*(-I*sqrt(2) + 1)^n]
        [ 1/4*I*sqrt(2)*(I*sqrt(2) + 1)^n - 1/4*I*sqrt(2)*(-I*sqrt(2) + 1)^n                      1/2*(I*sqrt(2) + 1)^n + 1/2*(-I*sqrt(2) + 1)^n]
        >>> (C.subs(n=3)-A**3).expand()
        [0 0]
        [0 0]


   **MEMENTO of usual GIAC functions**:

   - *Expand with simplification*

         * ``ratnormal``, ``normal``, ``simplify``   (from the fastest to the most sophisticated)

         *  NB: ``expand`` function doesn't regroup nor cancel terms, so it could be slow. (pedagogical purpose only?)

   - *Factor/Regroup*

         * ``factor``, ``factors``, ``regroup``, ``cfactor``, ``ifactor``

   - *Misc*

         * ``unapply``, ``op``, ``subst``

   - *Polynomials/Fractions*

         * ``coeff``,  ``gbasis``, ``greduce``, ``lcoeff``, ``pcoeff``, ``canonical_form``,

         * ``proot``,  ``poly2symb``,  ``symb2poly``, ``posubLMQ``, ``poslbdLMQ``, ``VAS``, ``tcoeff``,  ``valuation``

         * ``gcd``, ``egcd``, ``lcm``, ``quo``, ``rem``, ``quorem``, ``abcuv``, ``chinrem``,

         * ``peval``, ``horner``, ``lagrange``, ``ptayl``, ``spline``,  ``sturm``,  ``sturmab``

         * ``partfrac``, ``cpartfrac``

   - *Memory/Variables*

         * ``assume``, ``about``, ``purge``, ``ans``

   - *Calculus/Exact*

         * ``linsolve``,  ``solve``,  ``csolve``,  ``desolve``,  ``seqsolve``, ``reverse_rsolve``, ``matpow``

         * ``limit``, ``series``, ``sum``, ``diff``, ``fMax``, ``fMin``,

         * ``integrate``, ``subst``, ``ibpdv``, ``ibpu``, ``preval``

   - *Calculus/Exp, Log, powers*

         * ``exp2pow``, ``hyp2exp``, ``expexpand``, ``lin``, ``lncollect``, ``lnexpand``, ``powexpand``, ``pow2exp``

   - *Trigo*

         * ``trigexpand``, ``tsimplify``, ``tlin``, ``tcollect``,

         * ``halftan``, ``cos2sintan``, ``sin2costan``, ``tan2sincos``, ``tan2cossin2``, ``tan2sincos2``, ``trigcos``, ``trigsin``, ``trigtan``, ``shift_phase``

         * ``exp2trig``, ``trig2exp``

         * ``atrig2ln``, ``acos2asin``, ``acos2atan``, ``asin2acos``, ``asin2atan``, ``atan2acos``, ``atan2asin``

   - *Linear Algebra*

         * ``identity``, ``matrix``, ``makemat``, ``syst2mat``, ``matpow``, ``table``, ``redim``

         * ``det``,  ``det_minor``, ``rank``, ``ker``, ``image``, ``rref``, ``simplex_reduce``,

         * ``egv``, ``egvl``,  ``eigenvalues``, ``pcar``, ``pcar_hessenberg``, ``pmin``,

         * ``jordan``, ``adjoint_matrix``, ``companion``, ``hessenberg``, ``transpose``,

         * ``cholesky``, ``lll``,  ``lu``, ``qr``, ``svd``, ``a2q``, ``gauss``, ``gramschmidt``,
           ``q2a``, ``isom``, ``mkisom``


   - *Finite Fields*

         * ``%``, ``% 0``, ``mod``, ``GF``, ``powmod``


   - *Integers*

         * ``gcd``, ``iabcuv``, ``ichinrem``, ``idivis``, ``iegcd``,

         * ``ifactor``, ``ifactors``, ``iquo``, ``iquorem``, ``irem``,

         * ``is_prime, is_pseudoprime``, ``lcm``, ``mod``, ``nextprime``, ``pa2b2``, ``prevprime``,
           ``smod``, ``euler``, ``fracmod``

   - *List*

         * ``append``, ``accumulate_head_tail``, ``concat``, ``head``, ``makelist``, ``member``, ``mid``, ``revlist``, ``rotate``, ``shift``, ``size``, ``sizes``, ``sort``, ``suppress``, ``tail``

   - *Set*

         * ``intersect``, ``minus``, ``union``, ``is_element``, ``is_included``
    """
    return Pygen(s).eval()


#######################################
# A class to adjust giac configuration
#######################################
cdef class GiacSetting(Pygen):
    """
    A class to customise the Computer Algebra System settings.

    EXAMPLES::

        >>> from sagemath_giac.giac import giacsettings, libgiac

    ``threads`` (maximal number of allowed theads in giac)::

        >>> import os
        >>> try:
        ...     ncpu = int(os.environ['SAGE_NUM_THREADS'])
        ... except KeyError:
        ...     ncpu =1
        >>> giacsettings.threads == ncpu
        True

    ``digits`` (default digit number used for approximations)::

        >>> giacsettings.digits = 20
        >>> libgiac.approx('1/7')
        0.14285714285714285714
        >>> giacsettings.digits = 50
        >>> libgiac.approx('1/7')
        0.14285714285714285714285714285714285714285714285714
        >>> giacsettings.digits = 12

    ``sqrtflag`` (flag to allow sqrt extractions during solve and
    factorizations)::

        >>> giacsettings.sqrtflag = False
        >>> libgiac('x**2-2').factor()
        x^2-2
        >>> giacsettings.sqrtflag = True
        >>> libgiac('x**2-2').factor()
        (x-sqrt(2))*(x+sqrt(2))

    ``complexflag`` (flag to allow complex number in solving equations
    or factorizations)::

        >>> giacsettings.complexflag = False; giacsettings.complexflag
        False
        >>> libgiac('x**2+4').factor()
        x^2+4
        >>> giacsettings.complexflag = True
        >>> libgiac('x**2+4').factor()
        (x+2*i)*(x-2*i)

    ``eval_level`` (recursive level of substitution of variables
    during an evaluation)::

        >>> giacsettings.eval_level = 1
        >>> libgiac("purge(a):;b:=a;a:=1;b")
        "Done",a,1,a
        >>> giacsettings.eval_level=25; giacsettings.eval_level
        25
        >>> libgiac("purge(a):;b:=a;a:=1;b")
        "Done",a,1,1

    ``proba_epsilon`` (maximum probability of a wrong answer with a
    probabilistic algorithm). Set this number to 0 to disable
    probabilistic algorithms (slower)::

        >>> giacsettings.proba_epsilon = 0
        >>> libgiac('proba_epsilon')
        0.0
        >>> giacsettings.proba_epsilon = 10**(-13)
        >>> libgiac('proba_epsilon') < 10**(-14)
        False

    ``epsilon`` (value used by the ``epsilon2zero`` function)::

        >>> giacsettings.epsilon = 1e-10
        >>> P = libgiac('1e-11+x+5')
        >>> P == x+5
        False
        >>> (P.epsilon2zero()).simplify()
        x+5

    """
    def __repr__(self):
        return "Giac Settings"

    def _sage_doc_(self):
        return GiacSetting.__doc__

    property digits:
        r"""
        Default digits number used for approximations.

        EXAMPLES::

            >>> from sagemath_giac.giac import giacsettings, libgiac
            >>> giacsettings.digits = 20
            >>> giacsettings.digits
            20
            >>> libgiac.approx('1/7')
            0.14285714285714285714
            >>> giacsettings.digits=12

        """
        def __get__(self):
            return (self.cas_setup()[6])._val

        def __set__(self, value):
            l = Pygen('cas_setup()').eval()
            pl = [ i for i in l ]
            pl[6] = value
            Pygen('cas_setup(%s)' % pl).eval()

    property sqrtflag:
        r"""
        Flag to allow square roots in solving equations or
        factorizations.
        """
        def __get__(self):
            return (self.cas_setup()[9])._val == 1

        def __set__(self, value):
            l = Pygen('cas_setup()').eval()
            pl = [ i for i in l ]
            if value:
                pl[9]=1
            else:
                pl[9]=0
            Pygen('cas_setup(%s)' % pl).eval()

    property complexflag:
        r"""
        Flag to allow complex number in solving equations or
        factorizations.

        EXAMPLES::

            >>> from sagemath_giac.giac import libgiac, giacsettings
            >>> giacsettings.complexflag = False
            >>> giacsettings.complexflag
            False
            >>> libgiac('x**2+4').factor()
            x^2+4
            >>> giacsettings.complexflag=True;
            >>> libgiac('x**2+4').factor()
            (x+2*i)*(x-2*i)

        """
        def __get__(self):
            return (self.cas_setup()[2])._val == 1

        def __set__(self, value):
            l = Pygen('cas_setup()').eval()
            pl = [ i for i in l ]
            if value:
                pl[2] = 1
            else:
                pl[2] = 0
            Pygen('cas_setup(%s)' % pl).eval()

    property eval_level:
        r"""
        Recursive level of substitution of variables during an evaluation.

        EXAMPLES::

            >>> from sagemath_giac.giac import giacsettings, libgiac
            >>> giacsettings.eval_level=1
            >>> libgiac("purge(a):;b:=a;a:=1;b")
            "Done",a,1,a
            >>> giacsettings.eval_level = 25
            >>> giacsettings.eval_level
            25
            >>> libgiac("purge(a):;b:=a;a:=1;b")
            "Done",a,1,1
            >>> libgiac.purge('a,b')
            1,a

        """
        def __get__(self):
            return (self.cas_setup()[7][3])._val

        def __set__(self, value):
            l = Pygen('cas_setup()').eval()
            pl = [ i for i in l ]
            pl[7] = [l[7][0],l[7][1],l[7][2], value]
            Pygen('cas_setup(%s)' % pl).eval()

    property proba_epsilon:
        r"""
        Maximum probability of a wrong answer with a probabilistic
        algorithm.

        Set this number to 0 to disable probabilistic algorithms
        (this makes the computation slower).

        EXAMPLES::

            >>> from sagemath_giac.giac import giacsettings,libgiac
            >>> giacsettings.proba_epsilon = 0
            >>> libgiac('proba_epsilon')
            0.0
            >>> giacsettings.proba_epsilon = 10**(-13)
            >>> libgiac('proba_epsilon') < 10**(-14)
            False

        """
        def __get__(self):
            return (self.cas_setup()[5][1])._double

        def __set__(self, value):
            l = Pygen('cas_setup()').eval()
            pl = [ i for i in l ]
            pl[5] = [l[5][0],value]
            Pygen('cas_setup(%s)' % pl).eval()

    property epsilon:
        r"""
        Value used by the ``epsilon2zero`` function.

        EXAMPLES::

            >>> from sagemath_giac.giac import giacsettings, libgiac
            >>> giacsettings.epsilon = 1e-10
            >>> P = libgiac('1e-11+x+5')
            >>> P == x+5
            False
            >>> (P.epsilon2zero()).simplify()
            x+5

        """
        def __get__(self):
            return (self.cas_setup()[5][0])._double

        def __set__(self, value):
            l = Pygen('cas_setup()').eval()
            pl = [ i for i in l ]
            pl[5] = [value,l[5][1]]
            Pygen('cas_setup(%s)' % pl).eval()

    property threads:
        r"""
        Maximal number of allowed theads in giac.
        """
        def __get__(self):
            return (self.cas_setup()[7][0])._val

        def __set__(self, value):
            Pygen('threads:=%s' % str(value)).eval()

########################################################
#                                                      #
#    The python class that points to a cpp giac gen    #
#                                                      #
########################################################
include 'auto-methods.pxi'

cdef class Pygen(GiacMethods_base):

    cdef gen * gptr   #pointer to the corresponding C++ element of type giac::gen

    def __cinit__(self, s=None):

        #NB: the  != here gives problems with  the __richcmp__ function
        #if (s!=None):
        # so it's better to use isinstance
        if (isinstance(s, None.__class__)):
            # Do NOT replace with: self=GIACNULL  (cf the doctest in __repr__
            sig_on()
            self.gptr = new gen ((<Pygen>GIACNULL).gptr[0])
            sig_off()
            return

        if isinstance(s, int):
            # This looks 100 faster than the str initialisation
            if s.bit_length() < Pymaxint.bit_length():
                sig_on()
                self.gptr = new gen(<long long>s)
                sig_off()
            else:
                sig_on()
                self.gptr = new gen(pylongtogen(s))
                sig_off()

        elif isinstance(s, Integer):       # for sage int (gmp)
            sig_on()
            if (abs(s)>Pymaxint):
                self.gptr = new gen((<Integer>s).value)
            else:
                self.gptr = new gen(<long long>s)   # important for pow to have a int
            sig_off()

        elif isinstance(s, Rational):       # for sage rat (gmp)
            #self.gptr = new gen((<Pygen>(Pygen(s.numerator())/Pygen(s.denominator()))).gptr[0])
            # FIXME: it's slow
            sig_on()
            self.gptr = new gen(GIAC_rdiv(gen((<Integer>(s.numerator())).value),gen((<Integer>(s.denominator())).value)))
            sig_off()

        elif isinstance(s, Matrix):
            s = Pygen(s.list()).list2mat(s.ncols())
            sig_on()
            self.gptr = new gen((<Pygen>s).gptr[0])
            sig_off()

        elif isinstance(s, float):
            sig_on()
            self.gptr = new gen(<double>s)
            sig_off()

        elif isinstance(s, Pygen):
            # in the test: x,y=Pygen('x,y');((x+2*y).sin()).texpand()
            # the y are lost without this case.
            sig_on()
            self.gptr = new gen((<Pygen>s).gptr[0])
            sig_off()

        elif isinstance(s, (list, range)):
            sig_on()
            self.gptr = new gen(_wrap_pylist(<list>s),<short int>0)
            sig_off()

        elif isinstance(s, tuple):
            sig_on()
            self.gptr = new gen(_wrap_pylist(<tuple>s),<short int>1)
            sig_off()

        # Other types are converted with strings.
        else:
            if isinstance(s, Expression):
                # take account of conversions with key giac in the sage symbol dict
                try:
                    s = s._giac_init_()
                except AttributeError:
                    s = SRexpressiontoGiac(s)
            elif isinstance(s, AnInfinity):
                s = s._giac_init_()
            if not isinstance(s, str):
                s = s.__str__()
            sig_on()
            self.gptr = new gen(<string>encstring23(s),context_ptr)
            sig_off()

    def __dealloc__(self):
        del self.gptr

    def __repr__(self):
        # fast evaluation of the complexity of the gen. (it's not the number of char )
        sig_on()
        t=GIAC_taille(self.gptr[0], 6000)
        sig_off()
        if t < 6000:
            sig_on()
            result = GIAC_print(self.gptr[0], context_ptr).c_str().decode()
            sig_off()
            return result
        else:
            sig_on()
            result = str(self.type) + "\nResult is too big for Display. If you really want to see it use print"
            sig_off()
            return result

    def __str__(self):
        #if self.gptr == NULL:
        #  return ''
        sig_on()
        result = GIAC_print(self.gptr[0], context_ptr).c_str().decode()
        sig_off()
        return result

    def __len__(self):
        """
        TESTS::

           >>> from sagemath_giac.giac import libgiac
           >>> l=libgiac("seq[]"); len(l) # 29552 comment28
           0

        """
        if (self._type == 7):
            sig_on()
            rep=(self.gptr.ref_VECTptr()).size()
            sig_off()
            return rep
        else:
            sig_on()
            rep=GIAC_size(self.gptr[0],context_ptr).val
            sig_off()
            #GIAC_size return a gen. we take the int: val
            return rep

    def __getitem__(self, i):  #TODO?: add gen support for indexes
        """
        Lists of 10**6 integers should be translated to giac easily

        TESTS::

           >>> from sagemath_giac.giac import libgiac
           >>> l = libgiac(list(range(10**6))); l[5]
           5
           >>> l[35:50:7]
           [35,42,49]
           >>> l[-10**6]
           0
           >>> t = libgiac(tuple(range(10)))
           >>> t[:4:-1]
           9,8,7,6,5
           >>> x = libgiac('x')
           >>> sum([ x[i] for i in range(5) ], libgiac(0))**3
           (x[0]+x[1]+x[2]+x[3]+x[4])^3
           >>> A = libgiac.ranm(5,10)
           >>> A[3,7]-A[3][7]
           0
           >>> A.transpose()[8,2]-A[2][8]
           0

        Crash test::

           >>> from sagemath_giac.giac import Pygen
           >>> l = Pygen()
           >>> l[0]
           Traceback (most recent call last):
           ...
           IndexError: list index 0 out of range

        """
        cdef gen result

        if(self._type == 7) or (self._type == 12):   #if self is a list or a string
            if isinstance(i, (int, Integer)):
                n=len(self)
                if(i<n)and(-i<=n):
                    if(i<0):
                        i=i+n
                    sig_on()
                    result = self.gptr[0][<int>i]
                    sig_off()
                    return _wrap_gen(result)
                else:
                    raise IndexError('list index %s out of range' % i)
            else:
                if isinstance(i, slice):
                    sig_on()
                    result = gen(_getgiacslice(self,i),<short int>self._subtype)
                    sig_off()
                    return _wrap_gen(result)
                # add support for multi indexes
                elif isinstance(i, tuple):
                    if(len(i)==2):
                        return self[i[0]][i[1]]
                    elif(len(i)==1):
                        # in case of a tuple like this: (3,)
                        return self[i[0]]
                    else:
                        return self[i[0],i[1]][tuple(i[2:])]
                else:
                    raise TypeError('gen indexes are not yet implemented')
        # Here we add support to formal variable indexes:
        else:
            cmd = '%s[%s]' % (self, i)
            ans = Pygen(cmd).eval()
            # if the answer is a string, it must be an error message because self is not a list or a string
            if (ans._type == 12):
                raise TypeError("Error executing code in Giac\nCODE:\n\t%s\nGiac ERROR:\n\t%s" % (cmd, ans))
            return ans

    def __setitem__(self, key, value):
        """
        Set the value of a coefficient of a giac vector or matrix or list.

        Warning: It is an in place affectation.

        TESTS::

            >>> from sagemath_giac.giac import libgiac
            >>> from sage.rings.rational_field import QQ
            >>> A = libgiac([ [ libgiac(j)+libgiac(i)*2 for i in range(3)] for j in range(3)]); A
            [[0,2,4],[1,3,5],[2,4,6]]
            >>> A[1,2] = 44; A
            [[0,2,4],[1,3,44],[2,4,6]]
            >>> A[2][2] = QQ(1)/QQ(3); A
            [[0,2,4],[1,3,44],[2,4,1/3]]
            >>> x = libgiac('x')
            >>> A[0,0] = x + libgiac(1)/x; A
            [[x+1/x,2,4],[1,3,44],[2,4,1/3]]
            >>> A[0] = [-1,-2,-3]; A
            [[-1,-2,-3],[1,3,44],[2,4,1/3]]
            >>> B = A; A[2,2]
            1/3
            >>> B[2,2] = 6    # in place assignment
            >>> A[2,2]        # so A is also modified
            6
            >>> A.pcar(x)
            x^3-8*x^2-159*x

        NB: For Large matrix it seems that the syntax ``A[i][j]=`` is
        faster that ``A[i,j]=``.
        """
        cdef gen v
        sig_on()
        cdef gen g = gen(<string>encstring23('GIACPY_TMP_NAME050268070969290100291003'),context_ptr)
        GIAC_sto((<Pygen>self).gptr[0],g,1,context_ptr)
        g = gen(<string>encstring23('GIACPY_TMP_NAME050268070969290100291003[%s]' % str(key)), context_ptr)
        v=(<Pygen>(Pygen(value).eval())).gptr[0]
        GIAC_sto(v, g, 1, context_ptr)
        Pygen('purge(GIACPY_TMP_NAME050268070969290100291003):;').eval()
        sig_off()
        return

    def __iter__(self):
        """
        Pygen lists of 10**6 elements should be yield.

        TESTS::

            >>> from sagemath_giac.giac import libgiac
            >>> l = libgiac(range(10**6))
            >>> [ i for i in l ] == list(range(10**6))
            True

        Check for SageMath issue 18841::

            >>> L = libgiac(range(10))
            >>> next(iter(L))
            0

        """
        cdef int i
        for i in range(len(self)):
            yield self[i]

    def eval(self):
        cdef gen result
        sig_on()
        result = GIAC_protecteval(self.gptr[0],giacsettings.eval_level,context_ptr)
        sig_off()
        return _wrap_gen(result)

    def __add__(self, right):
        cdef gen result
        if not isinstance(right, Pygen):
            right=Pygen(right)
        # Curiously this case is important:
        # otherwise: f=1/(2+sin(5*x)) crash
        if not isinstance(self, Pygen):
            self=Pygen(self)
        sig_on()
        result = (<Pygen>self).gptr[0] + (<Pygen>right).gptr[0]
        sig_off()
        return _wrap_gen(result)

    def __call__(self, *args):
        cdef gen result
        cdef Pygen pari_unlock = Pygen('pari_unlock()')
        cdef gen pari_unlock_result
        cdef Pygen right
        n = len(args)
        if n > 1:
            # FIXME? improve with a vector, or improve Pygen(list)
            right = Pygen(args).eval()
        elif n == 1:
            right = Pygen(args[0])
        else:
            right = GIACNULL
        if not isinstance(self, Pygen):
            self = Pygen(self)
        # Some giac errors such as pari_locked are caught by the try
        # so we can't put the sig_on() in the try.
        # But now a keyboard interrupt fall back to this sig_on so
        # it may have left the giac pari locked.
        sig_on()
        try:
            result = self.gptr[0](right.gptr[0], context_ptr)
        except RuntimeError:
            # The previous computation might have failed due to a pari_lock
            # So we will not raise an exception yet.
            pari_unlock_result = GIAC_eval(pari_unlock.gptr[0], <int> 1, context_ptr)
            tmp = _wrap_gen(result)
            # if pari was not locked in giac, we have locked it, so unlock it.
            if tmp == 0:
                pari_unlock_result = GIAC_eval(pari_unlock.gptr[0], <int> 1, context_ptr)
                tmp = _wrap_gen(result)
                raise
            else:
                result = GIAC_eval(right.gptr[0], <int> 1, context_ptr)
                result = self.gptr[0](result, context_ptr)
        finally:
            sig_off()
        return _wrap_gen(result)

    def __sub__(self, right):
        cdef gen result
        if not isinstance(right, Pygen):
            right=Pygen(right)
        if not isinstance(self, Pygen):
            self=Pygen(self)
        sig_on()
        result = (<Pygen>self).gptr[0] - (<Pygen>right).gptr[0]
        sig_off()
        return _wrap_gen(result)

    def __mul__(self, right):
        """
        TESTS::

            >>> from sagemath_giac.giac import libgiac
            >>> (libgiac.sqrt(5)*libgiac('x')).factor()
            sqrt(5)*x
            >>> (libgiac('x')*libgiac.sqrt(5)).factor()
            sqrt(5)*x

        """
        cdef gen result
        if not isinstance(right, Pygen):
            right = Pygen(right)
        if not isinstance(self, Pygen):
            self = Pygen(self)
        #result = (<Pygen>self).gptr[0] * (<Pygen>right).gptr[0]
        #NB: with the natural previous method, the following error generated by
        #giac causes python to quit instead of an error message.
        #l=Pygen([1,2]);l.transpose()*l;
        sig_on()
        result = GIAC_giacmul((<Pygen>self).gptr[0], (<Pygen>right).gptr[0],context_ptr)
        sig_off()
        return _wrap_gen(result)

    # PB / in python3 is truediv
    def __div__(self, right):
        """
        TESTS::

            >>> from sagemath_giac.giac import libgiac
            >>> (libgiac.sqrt(3)/libgiac('x')).factor()
            sqrt(3)/x
            >>> (libgiac('x')/libgiac.sqrt(3)).factor()
            sqrt(3)*x/3

        """
        cdef gen result
        if not isinstance(right, Pygen):
            right = Pygen(right)
        if not isinstance(self, Pygen):
            self = Pygen(self)
        sig_on()
        result = GIAC_giacdiv((<Pygen>self).gptr[0], (<Pygen>right).gptr[0],context_ptr)
        sig_off()
        return _wrap_gen(result)

    def __truediv__(self, right):
        cdef gen result
        if not isinstance(right, Pygen):
            right = Pygen(right)
        if not isinstance(self, Pygen):
            self = Pygen(self)
        sig_on()
        result = (<Pygen>self).gptr[0] / (<Pygen>right).gptr[0]
        sig_off()
        return _wrap_gen(result)

    def __pow__(self, right, ignored):
        cdef gen result
        if not isinstance(right, Pygen):
            right = Pygen(right)
        if not isinstance(self, Pygen):
            self = Pygen(self)
        sig_on()
        result = GIAC_pow((<Pygen>self).gptr[0], (<Pygen>right).gptr[0], context_ptr )
        sig_off()
        return _wrap_gen(result)

    def __mod__(self, right):
        cdef gen result
        if not isinstance(right, Pygen):
            right = Pygen(right)
        if not isinstance(self, Pygen):
            self = Pygen(self)
        #result = gen(GIAC_makenewvecteur((<Pygen>self).gptr[0],(<Pygen>right).gptr[0]),<short int>1)
        #to have an integer output:
        #result = GIAC_smod(result,context_ptr)
        #we give a modular output:
        sig_on()
        result = GIAC_giacmod((<Pygen>self).gptr[0], (<Pygen>right).gptr[0],context_ptr)
        sig_off()
        return _wrap_gen(result)

    def __neg__(self):
        cdef gen result
        if not isinstance(self, Pygen):
            self = Pygen(self)
        sig_on()
        result = GIAC_neg((<Pygen>self).gptr[0])
        sig_off()
        return _wrap_gen(result)

    def __pos__(self):
        return self

    # To be able to use the eval function before the GiacMethods initialisation
    def cas_setup(self, *args):
        return Pygen('cas_setup')(self, *args)

    def savegen(self, str filename):
        """
        Archive a Pygen element to a file in giac compressed format.

        Use the loadgiacgen command to get back the Pygen from the file.
        In C++ these files can be opened with ``giac::unarchive``.

        EXAMPLES::

            >>> from sagemath_giac.giac import *
            >>> f = libgiac('(x+y+z+2)**10')
            >>> g = f.normal()
            >>> from tempfile import NamedTemporaryFile
            >>> F = NamedTemporaryFile()  # choose a temporary file for a test
            >>> g.savegen(F.name)
            >>> a = loadgiacgen(F.name)
            >>> a.factor()
            (x+y+z+2)^10
            >>> F.close()

        """
        sig_on()
        GIAC_archive( <string>encstring23(filename), (<Pygen>self).gptr[0], context_ptr)
        sig_off()


    def redim(self, a, b=None):
        """
        Increase the size of a matrix when possible, otherwise return ``self``.

        EXAMPLES::

            >>> from sagemath_giac.giac import libgiac
            >>> C = libgiac([[1,2]])
            >>> C.redim(2,3)
            [[1,2,0],[0,0,0]]
            >>> C.redim(2,1)
            [[1,2]]

        """
        d = self.dim()
        if d.type() == 7:
            if(a > d[0] and b >= d[1]):
                a = Pygen(a)
                A = self.semi_augment(Pygen((a-d[0],d[1])).matrix())
                if(b > d[1]):
                    b = Pygen(b)
                    A = A.augment(Pygen((a,b-d[1])).matrix())
                return A
            elif(b > d[1] and a == d[0]):
                b = Pygen(b)
                return self.augment(Pygen((d[0],b-d[1])).matrix())
            else:
                return self
        else:
            raise TypeError("self is not a giac List")

    def _help(self):
        return self.findhelp().__str__()

    def _sage_doc_(self):
        return self._help()

    def __doc__(self):
        return self._help()

    # # # # # # # # # # # # # # # # #
    # sage addons
    # # # # # # # # # # # # # # # # #
    def _latex_(self):
        r"""
        You can output Giac expressions in latex.

        EXAMPLES::

            >>> from sagemath_giac.giac import libgiac
            >>> from sage.misc.latex import latex
            >>> gf = libgiac('(x^4 - y)/(y^2-3*x)')
            >>> latex(gf)
            \frac{x^{4}-y}{y^{2}-3 x}

        """
        sig_on()
        result = GIAC_gen2tex(self.gptr[0], context_ptr).c_str().decode()
        sig_off()
        return result

    def _integer_(self, Z=None):
        """
        Convert giac integers or modular integers to sage Integers
        (via gmp).

        EXAMPLES::

            >>> from sagemath_giac.giac import *
            >>> from sage.arith.misc import next_prime
            >>> from sage.rings.integer_ring import ZZ
            >>> from sage.rings.finite_rings.integer_mod import Mod
            >>> a = libgiac('10')
            >>> b = libgiac('2**300')
            >>> a
            10
            >>> type(ZZ(a))
            <class 'sage.rings.integer.Integer'>
            >>> next_prime(b)
            2037035976334486086268445688409378161051468393665936250636140449354381299763336706183397533
            >>> c = libgiac('2 % nextprime(2**40)')
            >>> ZZ(c**1000)
            -233775163595
            >>> Mod(2,next_prime(2**40))**1000 - ZZ(c**1000)
            0
            >>> 2**320-(c**320).sage()
            0

        """
        cdef Integer n = PY_NEW(Integer)
        typ = self._type

        if(typ == 0):
            # giac _INT_  i.e int
            return Integer(self._val)

        elif(typ == 2):
            # giac _ZINT  i.e mpz_t
            sig_on()
            mpz_set(n.value,(self.gptr.ref_ZINTptr())[0])
            sig_off()
            return n

        elif(typ == 15):
            # self is a giac modulo
            sig_on()
            a = _wrap_gen( (self.gptr.ref_MODptr())[0])
            # It is useless to get the modulus here
            # because the result will be lift to ZZ.
            result = ZZ(a)
            sig_off()
            return result

        else:
            raise TypeError("cannot convert non giac integers to Integer")

    def _rational_(self, Z=None):
        """
        Convert giac rationals to sage rationals.

        EXAMPLES::

           >>> from sagemath_giac.giac import libgiac
           >>> from sage.rings.rational_field import QQ
           >>> a = libgiac('103993/33102')
           >>> b = QQ(a); b
           103993/33102
           >>> b == a.sage()
           True

        """
        typ = self._type
        # _INT_ or _ZINT
        if typ == 0 or typ == 2:
            return QQ(ZZ(self))
        # _FRAC_
        elif typ == 10:
            # giac _RAT_
            return ZZ(self.numer()) / ZZ(self.denom())
        else:
            raise TypeError("cannot convert non giac _FRAC_ to QQ")

    def sage(self):
        r"""
        Convert a libgiac expression back to a Sage
        expression. (could be slow)

        This currently does not implement a parser for the Giac output
        language, therefore only very simple expressions will convert
        successfully.

        Lists are converted recursively to sage.

        CURRENT STATUS:

            ZZ, QQ, ZZ/nZZ, strings, are supported, other type are sent
            to the symbolic ring via strings. In particular symbolic
            expressions modulo n should be lift to ZZ before (with % 0).

        EXAMPLES::

            >>> from sagemath_giac.giac import libgiac
            >>> m = libgiac('x^2 + 5*y')
            >>> m.sage()
            x^2 + 5*y

        ::

            >>> m = libgiac('sin(2*sqrt(1-x^2)) * (1 - cos(1/x))^2')
            >>> m.trigexpand().sage()
            2*cos(sqrt(-x^2 + 1))*cos(1/x)^2*sin(sqrt(-x^2 + 1)) - 4*cos(sqrt(-x^2 + 1))*cos(1/x)*sin(sqrt(-x^2 + 1)) + 2*cos(sqrt(-x^2 + 1))*sin(sqrt(-x^2 + 1))

        ::

            >>> a = libgiac(' 2 % 7')
            >>> (a.sage())**6
            1
            >>> a=libgiac('"une chaine"')
            >>> b=a.sage(); b + b
            'une chaineune chaine'
            >>> isinstance(b,str)
            True

        The giac entries in the pynac conversion dictionary are used::

            >>> from sage.symbolic.ring import SR
            >>> x = SR.symbol('x')
            >>> f = libgiac.Gamma
            >>> f(4)
            6
            >>> f(x)
            Gamma(sageVARx)
            >>> (f(x)).sage()
            gamma(x)

        Converting a custom name by adding a new entry to the
        ``symbols_table``::

            >>> from sage.symbolic.expression import register_symbol
            >>> from sage.functions.trig import sin
            >>> ex = libgiac('myFun(x)')
            >>> register_symbol(sin, {'giac':'myFun'})
            >>> ex.sage()
            sin(x)

        """
        typ = self._type

        if typ != 7:
            # self is not a list
            if typ == 0 or typ == 2:
                return ZZ(self)

            elif typ == 10:
                return QQ(self)

            elif typ == 15:
                # modular integer
                sig_on()
                a = _wrap_gen( (self.gptr.ref_MODptr())[0])
                b = _wrap_gen( (self.gptr.ref_MODptr())[1])
                result = IntegerModRing(ZZ(b))(ZZ(a))
                sig_off()
                return result

            elif typ == 12:
                # string
                sig_on()
                result = eval(self.__str__())
                sig_off()
                return result

            else:
                return SR(self)

        else:
            # self is a list
            sig_on()
            result = [entry.sage() for entry in self]
            sig_off()
            return result

    def _symbolic_(self, R):
        r"""
        Convert ``self`` object to the ring R via a basic string evaluation. (slow)

        EXAMPLES::

            >>> from sagemath_giac.giac import libgiac
            >>> from sage.symbolic.ring import SR
            >>> from sage.functions.trig import sin
            >>> u, v = SR.var('u,v')
            >>> a = libgiac('cos(u+v)').texpand()
            >>> (SR(a)+sin(u)*sin(v)).simplify()
            cos(u)*cos(v)

        TESTS:

        Check that variables and constants are not mixed up
        (SageMath issue 30133)::

            >>> from sage.symbolic.constants import e, I, pi
            >>> ee, ii, pp = SR.var('e,i,pi')
            >>> from sage.functions.trig import cos
            >>> libgiac(ee * ii * pp).sage().variables()
            (e, i, pi)
            >>> libgiac(e * I * pi).sage().variables()
            ()
            >>> libgiac.integrate(ee**x, x).sage()
            e^x/log(e)
            >>> y = SR.var('π')
            >>> libgiac.integrate(cos(y), y).sage()
            sin(π)

        """
        if isinstance(R, SR.__class__):
            # Try to convert some functions names to the symbolic ring
            lsymbols = symbol_table['giac'].copy()
            try:
                result = symbolic_expression_from_string(self.__str__(), lsymbols,
                                                         accept_sequence=True,
                                                         parser=SR_parser_giac)
                return result

            except Exception:
                raise NotImplementedError("Unable to parse Giac output: %s" % self.__repr__())
        else:
            try:
                result = R(self.__str__())
                return result

            except Exception:
                raise NotImplementedError("Unable to parse Giac output: %s" % self.__repr__())

    def _matrix_(self, R=ZZ):
        r"""
        Return matrix over the (Sage) ring R  where self
        should be a  Giac matrix. The default ring is ZZ.

        EXAMPLES::

            >>> from sagemath_giac.giac import *
            >>> from sage.rings.polynomial.polynomial_ring_constructor import PolynomialRing
            >>> from sage.rings.rational_field import QQ
            >>> from sage.matrix.constructor import matrix
            >>> M = libgiac('matrix(4,4,(k,l)->(x^k-y^l))')
            >>> M
            matrix[[0,1-y,1-y^2,1-y^3],[x-1,x-y,x-y^2,x-y^3],[x^2-1,x^2-y,x^2-y^2,x^2-y^3],[x^3-1,x^3-y,x^3-y^2,x^3-y^3]]
            >>> len(M.eigenvals())
            4
            >>> R = PolynomialRing(QQ,'x,y')
            >>> Z = matrix(R,M); Z
            [         0     -y + 1   -y^2 + 1   -y^3 + 1]
            [     x - 1      x - y   -y^2 + x   -y^3 + x]
            [   x^2 - 1    x^2 - y  x^2 - y^2 -y^3 + x^2]
            [   x^3 - 1    x^3 - y  x^3 - y^2  x^3 - y^3]
            >>> Z.parent()
            Full MatrixSpace of 4 by 4 dense matrices over Multivariate Polynomial Ring in x, y over Rational Field

        """
        cdef int c
        cdef int r
        v = self.dim()
        n = (v[0])._val
        m = (v[1])._val
        from sage.matrix.matrix_space import MatrixSpace
        M = MatrixSpace(R, n, m)
        sig_on()
        entries = [[R((self[r])[c]) for c in range(m)] for r in range(n)]
        sig_off()
        return M(entries)

    def _vector_(self, R=None):
        r"""
        Return vector over the (Sage) ring R where self
        should be a  Giac matrix. The default ring is ZZ.

        EXAMPLES::

            >>> from sagemath_giac.giac import libgiac
            >>> from sage.rings.rational_field import QQ
            >>> from sage.modules.free_module_element import vector
            >>> v = libgiac(range(10))
            >>> vector(v+v)
            (0, 2, 4, 6, 8, 10, 12, 14, 16, 18)
            >>> vector(v + v/3, QQ)
            (0, 4/3, 8/3, 4, 16/3, 20/3, 8, 28/3, 32/3, 12)

        """
        if isinstance(R, None.__class__):
            R=ZZ

        v = self.dim()
        try:
            n = v._val
        except AttributeError:
            raise TypeError("Entry is not a giac vector")
        from sage.modules.free_module_element import vector
        sig_on()
        entries = [R(self[c]) for c in range(n)]
        sig_off()
        return vector(R,entries)

    # # # # # # # # # # # # # # #

    def mplot(self):
        """
        Basic export of some 2D plots to sage. Only generic plots
        are supported.  lines, circles, ... are not implemented
        """
        from sage.plot.line import line
        from sage.plot.scatter_plot import scatter_plot

        xyscat = []
        xyplot = []
        plotdata = self
        if not plotdata.type() == 'DOM_LIST':
            plotdata = [plotdata]

        sig_on()
        for G in plotdata:
            if G.dim() > 2:  # it is not a pnt. Ex: scatterplot
                for g in G:
                    xyscat=xyscat+[[(g.real())._double,(g.im())._double]]

            else:
                if G[1].type()=='DOM_LIST':
                    l=G[1].op()
                else:
                    l=G[1][2].op()
                xyplot=[[(u.real())._double,(u.im())._double] for u in l]

        if xyscat:
            result = scatter_plot(xyscat)

        else:
            result = line(xyplot)
        sig_off()

        return result

    # # # # # # # # # # # # # # # # # # # # # # # # #
    #           WARNING:
    #
    # Do not use things like != in  Pygen's __cinit__
    # with this __richcmp__ enabled
    # The methods will bug: a=Pygen(2); a.sin()
    #
    # # # # # # # # # # # # # # # # # # # # # # # # #

    def __richcmp__(self, other, op):
        if not isinstance(other, Pygen):
            other = Pygen(other)
        if not isinstance(self, Pygen):
            self = Pygen(self)
        sig_on()
        result = giacgenrichcmp((<Pygen>self).gptr[0],(<Pygen>other).gptr[0], op, context_ptr )
        sig_off()
        return result == 1

    #
    # Some attributes of the gen class:
    #

    property _type:
        def __get__(self):
            sig_on()
            result = self.gptr.type
            sig_off()
            return result

    property _subtype:
        def __get__(self):
            sig_on()
            result = self.gptr.subtype
            sig_off()
            return result

    property _val:  # immediate int (type _INT_)
        """
        immediate int value of an _INT_ type gen.
        """
        def __get__(self):
            if self._type == 0:
                sig_on()
                result = self.gptr.val
                sig_off()
                return result
            else:
                raise TypeError("cannot convert non _INT_ giac gen")

    property _double:  # immediate double (type _DOUBLE_)
        """
        immediate conversion to float for a gen of _DOUBLE_ type.
        """
        def __get__(self):
            if self._type == 1:
                sig_on()
                result = self.gptr._DOUBLE_val
                sig_off()
                return result
            else:
                raise TypeError("cannot convert non _DOUBLE_ giac gen")

    property help:
        def __get__(self):
            return self._help()

    ###################################################
    # Add the others methods
    ###################################################
    #
    #  NB: with __getattr__ this is about 10 times slower: [a.normal() for i in range(10**4)]
    #      than [GiacMethods["normal"](a) for i in range(10**4)]
    #
    #     def __getattr__(self, name):
    #       return GiacMethods[str(name)](self)

    # test

    def giacAiry_Ai(self, *args):
        cdef gen result = GIAC_Airy_Ai(self.gptr[0], context_ptr)
        return _wrap_gen(result)

    def giacifactor(self, *args):
        cdef gen result
        sig_on()
        result = GIAC_eval(self.gptr[0], <int>1, context_ptr)
        result = GIAC_ifactor(result, context_ptr)
        sig_off()
        return _wrap_gen(result)


################################################################
#   A wrapper from a cpp element of type giac gen to create    #
#   the Python object                                          #
################################################################
cdef inline _wrap_gen(gen  g)except +:

#   cdef Pygen pyg=Pygen('NULL')
# It is much faster with ''
#      [x-x for i in range(10**4)]
#      ('clock: ', 0.010000000000000009,
# than with 'NULL':
#      [x-x for i in range(10**4)]
#      ('clock: ', 1.1999999999999997,
#    #    #    #    #    #
# This is faster than with:
#    cdef Pygen pyg=Pygen('')
# ll=giac(range(10**6))
# ('clock: ', 0.40000000000000036, ' time: ', 0.40346789360046387)
# gg=[1 for i in ll]
# ('clock: ', 0.669999999999999, ' time: ', 0.650738000869751)
#
# But beware when changing the None case in  Pygen init.
#
    sig_on()
    cdef Pygen pyg=Pygen()
    del pyg.gptr # Pygen.__cinit__() always creates a gen. So we have to delete it here.
    pyg.gptr=new gen(g)
    sig_off()
    return pyg
#    if(pyg.gptr !=NULL):
#      return pyg
#    else:
#      raise MemoryError("empty gen")

################################################################
#    A wrapper from a python list to a vector of gen           #
################################################################

cdef  vecteur _wrap_pylist(L) except +:
    cdef vecteur  * V
    cdef int i

    if isinstance(L, (tuple, list, range)):
        n = len(L)
        V = new vecteur()

        sig_on()
        for i in range(n):
            V.push_back((<Pygen>Pygen(L[i])).gptr[0])
        sig_off()
        return V[0]
    else:
        raise TypeError("argument must be a tuple or a list")


#################################
#  slice wrapper for a giac list
#################################
cdef  vecteur _getgiacslice(Pygen L, slice sl) except +:
    cdef vecteur  * V
    cdef int u

    if L.type()=="DOM_LIST":
        n=len(L)
        V=new vecteur()

        sig_on()
#      for u in range(n)[sl]:   #pb python3
        b, e, st = sl.indices(n)
        for u in range(b, e, st):
            V.push_back((L.gptr[0])[u])
        sig_off()
        return V[0]
    else:
        raise TypeError("argument must be a Pygen list and a slice")


cdef  gen pylongtogen(a) except +:
    #                                                                     #
    # basic conversion of Python long integers to gen via Horner's Method #
    #                                                                     #

    aneg=False
    cdef gen g=gen(<int>0)
    cdef gen M

    if (a<0):
        aneg=True
        a=-a
    if Pyversioninfo >= (2,7):
        size=a.bit_length()  # bit_length python >= 2.7 required.
        shift=Pymaxint.bit_length()-1
    else:
        size=math.trunc(math.log(a,2))+1
        shift=math.trunc(math.log(Pymaxint))
    M=gen(<long long>(1<<shift))

    while (size>=shift):
        size=size-shift
        i=int(a>>size)
        g=(g*M+gen(<long long>i))
        a=a-(i<<size)

    g=g*gen(<long long>(1<<size))+gen(<long long> a)
    if aneg:
        # when cythonizing with cython 0.24:
        # g=-g gives an Invalid operand type for '-' (gen)
        g=GIAC_neg(g)
    return g


#############################################################
# Examples of python functions directly implemented from giac
#############################################################
#def giaceval(Pygen self):
#    cdef gen result
#    try:
#      result = GIAC_protecteval(self.gptr[0],1,context_ptr)
#      return _wrap_gen(result)
#    except:
#      raise
#
#
#def giacfactor(Pygen self):
#
#    cdef gen result
#    try:
#      result = GIAC_factor(self.gptr[0],context_ptr)
#      return _wrap_gen(result)
#    except:
#      raise
#
#
#
#def giacfactors(Pygen self):
#    cdef gen result
#    try:
#      result = GIAC_factors(self.gptr[0],context_ptr)
#      return _wrap_gen(result)
#    except:
#      raise
#
#
#
#
#def giacnormal(Pygen self):
#    cdef gen result
#    try:
#      result = GIAC_normal(self.gptr[0],context_ptr)
#      return _wrap_gen(result)
#    except:
#      raise
#
#
#def giacgcd(Pygen a, Pygen b):
#    cdef gen result
#    try:
#      result = gen( GIAC_makenewvecteur(a.gptr[0],b.gptr[0]) ,<short int>1)
#      result = GIAC_gcd(result,context_ptr)
#      return _wrap_gen(result)
#    except:
#      raise


#############################################################
#  Most giac keywords
#############################################################
include 'keywords.pxi'
GiacMethods={}


class GiacFunction(Pygen):
    """
    A Subclass of Pygen to create functions with evaluating all the args
    before call so that they are substituted by their value.

    EXAMPLES::

        >>> from sagemath_giac.giac import libgiac
        >>> from sage.rings.imaginary_unit import I
        >>> from sage.functions.log import exp
        >>> from sage.symbolic.constants import pi
        >>> libgiac.simplify(exp(I*pi))  # simplify is a GiacFunction
        -1
        >>> libgiac('a:=1')
        1
        >>> libgiac.purge('a')  # purge is not a GiacFunction
        1
        >>> libgiac('a')
        a

    """
    def __call__(self, *args):
        n = len(args)
        if n == 1:
            args = (Pygen(args[0]).eval(),)
        return Pygen.__call__(self, *args)


class GiacFunctionNoEV(Pygen):
    # a class to allow to write the __doc__ attribute.
    """
    A Subclass of Pygen to create functions

    EXAMPLES::

        >>> from sagemath_giac.giac import libgiac
        >>> libgiac('a:=1')
        1
        >>> libgiac.purge('a')  # purge is a GiacFunctionNoEV
        1
        >>> libgiac('a')
        a

    """


#############################################################
# Some convenient settings
############################################################
Pygen('printpow(1)').eval()  # default power is ^
# FIXME: print I for sqrt(-1) instead of i
# GIAC_try_parse_i(False,context_ptr); (does not work??)

NoEvArgsFunc=['purge','assume','quote']

for i in mostkeywords:
    if i in NoEvArgsFunc:
        # do not eval args before calling this function. Ex purge
        #tmp=Pygen(i)
        tmp = GiacFunctionNoEV(i)
    else:
        tmp = GiacFunction(i)
    # in the sage version we remove:    globals()[i]=tmp
    GiacMethods[i] = tmp

# We put the giac names that should not be exported to Python in moremethods.
for i in moremethods:
    tmp = GiacFunction(i)
    GiacMethods[i] = tmp

for i in mostkeywords+moremethods:
    GiacMethods[i].__doc__ = eval("Pygen." + i + ".__doc__")

# To avoid conflicts we export only these few ones.  Most giac keywords will be
# available through: libgiac.keywordname
__all__ = ['Pygen', 'giacsettings', 'libgiac', 'loadgiacgen', 'GiacFunction',
           'GiacMethods', 'GiacMethods_base']


def loadgiacgen(str filename):
    """
    Open a file in giac compressed format to create a Pygen element.

    Use the save method from Pygen elements to create such files.

    In C++ these files can be opened with giac::unarchive and created with
    ``giac::archive``.

    EXAMPLES::

        >>> from sagemath_giac.giac import *
        >>> g = libgiac.texpand('cos(10*a+5*b)')
        >>> from tempfile import NamedTemporaryFile
        >>> F = NamedTemporaryFile()   # choose a temporary file for a test
        >>> g.savegen(F.name)
        >>> a = loadgiacgen(F.name)
        >>> a.tcollect()
        cos(10*a+5*b)
        >>> F.close()

    """
    cdef gen result
    sig_on()
    result = GIAC_unarchive( <string>encstring23(filename), context_ptr)
    sig_off()
    return _wrap_gen(result)


class GiacInstance:
    """
    This class is used to create the giac interpreter object.

    EXAMPLES::

        >>> from sagemath_giac.giac import libgiac, GiacInstance
        >>> isinstance(libgiac, GiacInstance)
        True
        >>> libgiac.solve('2*exp(x)<(exp(x*2)-1),x')
        list[x>(ln(sqrt(2)+1))]

    """

    def __init__(self):
        self.__dict__.update(GiacMethods)

    def __call__(self, s):
        return _giac(s)

    def _sage_doc_(self):
        return _giac.__doc__

    def eval(self, code, strip=True, **kwds):

        if strip:
            code = code.replace("\n","").strip()
        return self(code)

    __doc__ = _giac.__doc__


libgiac = GiacInstance()

# Issue #23976 (bound threads with SAGE_NUM_THREADS)
import os
try:
    ncpus = int(os.environ['SAGE_NUM_THREADS'])
except KeyError:
    ncpus = 1

giacsettings.threads = ncpus
