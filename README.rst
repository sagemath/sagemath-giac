Support for using Giac within SageMath

Introduction
============

Giac is a full-featured, open source mathematics library written by
Bernard Parisse:

* https://www-fourier.ujf-grenoble.fr/~parisse/giac.html

For many years, SageMath has included an interface to Giac based on
the GiacPy python interface by Frederic Han:

* https://pypi.org/project/giacpy/

This interface has now been split off into a separate package. The
main reason you would want to install it is to add Giac as a backend
for SageMath's ``integrate`` command. For example, without this
package, Sage cannot integrate the following example::

    >>> from sage.all import *
    >>> from sagemath_giac.giac import libgiac
    >>> x = SR.symbol("x", domain="real")
    >>> libgiac.integrate(2*min_symbolic(x,2*x),x).sage()
    -1/2*x^2*sgn(x) + 3/2*x^2

After installing sagemath-giac, Sage will automatically gain the
ability to do these integrals. Of course, you also gain access to the
rest of the Giac library, with easy conversions to and from Sage
objects.

Previously the contents of sagemath-giac were available (within
SageMath) in the ``sage.libs.giac`` module. In this package, we have
been forced to rename it to ``sagemath_giac`` due to some (hopefully
temporary) limitations of Cython in regard to namespace packages:

* https://github.com/cython/cython/issues/5237
* https://github.com/cython/cython/issues/5335
* https://github.com/cython/cython/issues/6287

If we had kept the old name, for example, you would not be able to
install sagemath-giac as a normal user for use with the system
installation of Sage. If sagemath-giac is installed, however, SageMath
will export its contents under the old name to avoid breaking
backwards compatibility. If/when Cython support for namespace packages
materializes, the contents of sagemath-giac can be moved back under
``sage.libs.giac``.

Building
========

It is possible to build the package directly through meson::

    $ meson setup --prefix=$HOME/.local build
    $ meson compile -C build

The prefix is not used until install-time, but eventually it tells
meson where to install the built files. The location ``$HOME/.local``
is most likely your personal python "user site" directory, where
python looks for packages installed with ``pip install --user``.

Of course, it is also possible to build a wheel the usual way, using::

    $ pip wheel --no-build-isolation --verbose .

or::

    $ python -m build --no-isolation .

If you installed SageMath using meson, the last method will only
work if you bypass the dependency check::

    $ python -m build --no-isolation --skip-dependency-check .

Otherwise, it will complain about a missing dependency on the
sagemath-standard distribution. (This is because ``meson install``
installs only the library and not the python packaging metadata.)

Testing
=======

A few doctests within the module ensure that everything is working. If
you have built the project using meson and a build directory named
``build``, you can run the tests with::

    $ PYTHONPATH=src:build/src python -m doctest \
        README.rst src/sagemath_giac/*.py* \
        2>/dev/null

We need to add both ``src`` and ``build/src`` (or whatever directory
you passed to meson as your build directory) to ``PYTHONPATH`` so that
python can find both our python modules and the compiled C extension
module. We have redirected stderr to ``/dev/null`` because, otherwise,
a mountain of debug output is printed to the console. A small amount
is still printed to stdout, but that is most likely a bug in libgiac.

Installation
============

After building/testing, you can install the package either using
meson::

    $ meson install -C build

or from the wheel that you generated earlier::

    $ pip install $(find ./ -type f -name 'sagemath_giac-*.whl')

