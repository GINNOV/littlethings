
file (
  COPY ${PROJECT_SOURCE_DIR}/tests/examples
  DESTINATION ${PROJECT_BINARY_DIR}/tests/
)

message( STATUS "Enable tests in tests/examples/" )
add_test( test_examples_basic.sh ${BASH_PROGRAM}
          test_examples_basic.sh ../../examples )
add_test( test_unadf.sh ${BASH_PROGRAM}
          test_unadf.sh )
