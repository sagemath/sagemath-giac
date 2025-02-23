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

# Cython gets its path (for pxd files) from python's sys.path, but
# when the system cython is used from within a venv, the shebang on
# e.g.  /use/bin/cython can break out of the venv. Here we run
# "python" from the venv and dump its sys.path as --include-dir
# arguments we can pass to cython. Note: meson automatically quotes
# compiler args with spaces in them, so you shouldn't try to quote the
# paths here. Instead we split the --include-dir and path arguments
# into separate elements so that auto-quoting the path does the right
# thing.
cython_include_args = run_command(
  py,
  [
    '-c',
    '''
import sys
for p in sys.path:
    if p:
        print("--include-dir")
        print(p)
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

