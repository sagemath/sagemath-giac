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

py.install_sources('context.py', 'gb.py', 'giac.pxd', 'misc.h', subdir: 'sagemath_giac')
py.extension_module(
  'giac',
  sources: files('giac.pyx'),
  subdir: 'sagemath_giac',
  install: true,
  override_options: ['cython_language=cpp'],
  dependencies: [cpython, cysignals, giac, gmpy2, gmpxx, py.dependency()],
)

