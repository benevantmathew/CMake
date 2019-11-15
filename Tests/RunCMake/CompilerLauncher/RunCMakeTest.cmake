include(RunCMake)

function(run_compiler_launcher lang)
  # Use a single build tree for tests without cleaning.
  set(RunCMake_TEST_BINARY_DIR ${RunCMake_BINARY_DIR}/${lang}-build)
  set(RunCMake_TEST_NO_CLEAN 1)
  file(REMOVE_RECURSE "${RunCMake_TEST_BINARY_DIR}")
  file(MAKE_DIRECTORY "${RunCMake_TEST_BINARY_DIR}")
  run_cmake(${lang})

  set(RunCMake_TEST_OUTPUT_MERGE 1)
  if("${RunCMake_GENERATOR}" MATCHES "Ninja")
    set(verbose_args -- -v)
  endif()
  run_cmake_command(${lang}-Build ${CMAKE_COMMAND} --build . ${verbose_args})
endfunction()

function(run_compiler_launcher_env lang)
  string(REGEX REPLACE "-.*" "" core_lang "${lang}")
  set(ENV{CMAKE_${core_lang}_COMPILER_LAUNCHER} "${CMAKE_COMMAND};-E;env;USED_LAUNCHER=1")
  run_compiler_launcher(${lang})
  unset(ENV{CMAKE_${core_lang}_COMPILER_LAUNCHER})
endfunction()

set(langs C CXX)
if(CMake_TEST_CUDA)
  list(APPEND langs CUDA)
endif()
if(CMake_TEST_Fortran)
  list(APPEND langs Fortran)
endif()

foreach(lang ${langs})
  run_compiler_launcher(${lang})
  run_compiler_launcher_env(${lang}-env)
  if (NOT RunCMake_GENERATOR STREQUAL "Watcom WMake")
    run_compiler_launcher(${lang}-launch)
    run_compiler_launcher_env(${lang}-launch-env)
  endif()
endforeach()
