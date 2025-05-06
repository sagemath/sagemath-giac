giac = cxx.find_library('giac', required: true)
gmpxx = cxx.find_library('gmpxx', required: true)

# Big hoops to get the include directory for cysignals, gmpy2, and
# sage.cpython.
inc_cysignals = run_command(
  py,
  [
    '-c',
    '''
import cysignals
print(cysignals.__file__.replace('__init__.py', ''))
    '''.strip(),
  ],
  check: true,
).stdout().strip()
cysignals = declare_dependency(include_directories: inc_cysignals)

inc_gmpy2 = run_command(
  py,
  [
    '-c',
    '''
import gmpy2
print(gmpy2.__file__.replace('__init__.py', ''))
    '''.strip(),
  ],
  check: true,
).stdout().strip()
gmpy2 = declare_dependency(include_directories: inc_gmpy2)

inc_cpython = run_command(
  py,
  [
    '-c',
    '''
import sage.cpython
print(sage.cpython.__file__.replace('__init__.py', ''))
    '''.strip(),
  ],
  check: true,
).stdout().strip()
cpython = declare_dependency(include_directories: inc_cpython)

# Cython gets its include path (for pxd files) from python's sys.path;
# the "include_directories" above are passed only to the C/CXX
# compiler. This leads to a problem: when the system cython is used
# from within a venv, the shebang on e.g. /usr/bin/cython can break
# out of the venv. In that case, as far as cython is concerned,
# sys.path won't contain sage. A similar problem arises when the sage
# library is installed with "--editable" and the build files are never
# actually installed to sys.path. Instead, a MesonpyMetaFinder object
# is appended to the user's sys.meta_path that allows python (but not
# cython!) to find sage.
#
# To work around these issues, we take whatever python we have handy
# (the venv python if we are in a venv, for example), and use it to
# find the __init__.py that corresponds to "import sage". From that
# we can find the appropriate include directory by going up two
# levels. This will find the sage source tree for editable installs,
# the venv sitedir for sage-the-distro, the user's sitedir for pip
# --user installs, etc. It would be better to have a general solution
# to this problem rather than a special case for each dependency that
# might be editable, but the sage library is the only dependency of
# ours that could reasonably be installed --editable, so I don't feel
# too bad about this.
#
# Note: meson automatically quotes compiler args with spaces in them,
# so you shouldn't try to quote the paths here. Instead we split the
# --include-dir and path arguments into separate elements so that
# auto-quoting the path does the right thing.
cython_include_args = run_command(
  py,
  [
    '-c',
    '''
import sage
from pathlib import Path
print("--include-dir")
print(Path(sage.__file__).parent.parent)
    '''.strip()
  ],
  check: true
).stdout().splitlines()

py.install_sources('context.py', 'gb.py', 'giac.pxd', 'misc.h', subdir: 'sagemath_giac')
py.extension_module(
  'giac',
  sources: files('giac.pyx'),
  subdir: 'sagemath_giac',
  install: true,
  override_options: ['cython_language=cpp'],
  cython_args : cython_include_args,
  dependencies: [cpython, cysignals, giac, gmpy2, gmpxx, py.dependency()],
)

