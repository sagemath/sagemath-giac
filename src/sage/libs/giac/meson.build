giac = cxx.find_library('giac', required: true)
gmpxx = cxx.find_library('gmpxx', required: true)

# Big hoops to get the include directory for cysignals and
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

py.install_sources('__init__.py', 'giac.pxd', 'misc.h', subdir: 'sage/libs/giac')
py.extension_module(
  'giac',
  sources: files('giac.pyx'),
  subdir: 'sage/libs/giac',
  install: true,
  override_options: ['cython_language=cpp'],
  dependencies: [cpython, cysignals, giac, gmpxx, py.dependency()],
)

