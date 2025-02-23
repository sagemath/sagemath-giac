project('sagemath-giac', 'cpp', 'cython',
  default_options: ['warning_level=3', 'cpp_std=c++11']
)

## Python
py_module = import('python')

# Ask explicitly for 'python' so we get the venv python and
# not the one used to run meson.
py = py_module.find_installation('python', pure: false)
py_dep = py.dependency()

## Compilers
cxx = meson.get_compiler('cpp')

subdir('src/sagemath_giac')

pytest = py_module.find_installation(modules: ['pytest'], required: false)
if pytest.found()
  test('pytest',
       pytest,
       args: ['-m', 'pytest'],
       workdir: meson.current_source_dir(),
       timeout: 600)
else
  message('pytest not found, skipping tests')
endif
