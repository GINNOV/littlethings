add_test(
    NAME build_identity
    COMMAND "${Python3_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/test_build_contract.py"
            --case identity
            --binary "$<TARGET_FILE:send2adf>"
            --manifest "${SEND2ADF_ADFLIB_MANIFEST}"
)
add_test(
    NAME offline_rebuild
    COMMAND "${Python3_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/test_build_contract.py"
            --case offline-rebuild
            --source "${CMAKE_SOURCE_DIR}"
            --pristine "${SEND2ADF_ADFLIB_PRISTINE_ROOT}"
)
add_test(
    NAME dependency_literal_check
    COMMAND "${Python3_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/../build-support/adflib/check_dependency_literals.py"
            --root "${CMAKE_SOURCE_DIR}/../.."
)
add_test(
    NAME production_guards
    COMMAND "${Python3_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/test_build_contract.py"
            --case production-guards
            --source "${CMAKE_SOURCE_DIR}"
            --pristine "${SEND2ADF_ADFLIB_PRISTINE_ROOT}"
)
add_test(
    NAME warm_cache_provenance
    COMMAND "${Python3_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/test_build_contract.py"
            --case warm-cache-provenance
            --source "${CMAKE_SOURCE_DIR}"
            --binary "$<TARGET_FILE:send2adf>"
            --manifest "${SEND2ADF_ADFLIB_MANIFEST}"
)
add_test(
    NAME canonical_archive
    COMMAND "${Python3_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/../build-support/adflib/tests/test_canonical_archive.py"
)

add_test(
    NAME adf_cli_help
    COMMAND "${Python3_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/run_characterization.py"
            --case help
            --send2adf "$<TARGET_FILE:send2adf>"
)

add_executable(adf_inspect adf_inspect.c)
target_link_libraries(adf_inspect PRIVATE adf)
if(SEND2ADF_SANITIZERS)
    target_compile_options(adf_inspect PRIVATE "${_send2adf_sanitize_flag}" -fno-omit-frame-pointer)
    target_link_options(adf_inspect PRIVATE "${_send2adf_sanitize_flag}")
endif()
if(MSVC)
    target_compile_options(adf_inspect PRIVATE /W4)
else()
    target_compile_options(adf_inspect PRIVATE -Wall -Wextra -Wpedantic)
endif()

function(add_adf_content_test test_name case_name)
    add_test(
        NAME "${test_name}"
        COMMAND "${Python3_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/run_characterization.py"
                --case "${case_name}"
                --send2adf "$<TARGET_FILE:send2adf>"
                --inspector "$<TARGET_FILE:adf_inspect>"
                --fixtures "${CMAKE_CURRENT_SOURCE_DIR}/fixtures"
    )
endfunction()

add_adf_content_test(adf_content_file file)
add_adf_content_test(adf_content_nested nested)
add_adf_content_test(adf_content_empty empty)
add_adf_content_test(adf_content_multi multi)
add_adf_content_test(adf_content_boot_none boot_none)
add_adf_content_test(adf_content_boot_13 boot_13)
add_adf_content_test(adf_content_boot_20 boot_20)

foreach(_mutation content bootblock)
    add_test(
        NAME "adf_mutation_${_mutation}"
        COMMAND "${Python3_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/run_characterization.py"
                --case "mutation_${_mutation}"
                --send2adf "$<TARGET_FILE:send2adf>"
                --inspector "$<TARGET_FILE:adf_inspect>"
                --fixtures "${CMAKE_CURRENT_SOURCE_DIR}/fixtures"
                --mutator "${CMAKE_CURRENT_SOURCE_DIR}/mutate_adf.py"
    )
endforeach()

foreach(_error missing_input missing_required invalid_bootblock)
    add_test(
        NAME "adf_error_${_error}"
        COMMAND "${Python3_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/run_characterization.py"
                --case "error_${_error}"
                --send2adf "$<TARGET_FILE:send2adf>"
    )
endforeach()

add_test(
    NAME transaction_happy
    COMMAND "${Python3_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/transaction_cases.py"
            --case happy
            --send2adf "$<TARGET_FILE:send2adf>"
)

add_test(
    NAME transaction_deterministic_order
    COMMAND "${Python3_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/transaction_order.py"
            --send2adf "$<TARGET_FILE:send2adf>"
            --inspector "$<TARGET_FILE:adf_inspect>"
)

add_test(
    NAME transaction_repeated_bytes_distinct_inodes
    COMMAND "${Python3_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/transaction_hardlinks.py"
            --case repeated-bytes
            --send2adf "$<TARGET_FILE:send2adf>"
)

foreach(_case IN ITEMS hardlink-top hardlink-nested)
    string(REPLACE "-" "_" _test_suffix "${_case}")
    add_test(
        NAME "transaction_failure_${_test_suffix}"
        COMMAND "${Python3_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/transaction_hardlinks.py"
                --case "${_case}"
                --send2adf "$<TARGET_FILE:send2adf>"
    )
endforeach()

set(_transaction_failure_cases
    missing-input name-31 forbidden non-ascii case-collision duplicate-top
    symlink fifo hardlink-output same-input-output preexisting oversized low-nofile forced-write
    volume-0 volume-31 entry-limit depth-limit disk-full output-contained dot dotdot
    input-symlink-ancestor output-symlink-ancestor
    input-unlink input-symlink input-regular input-overwrite input-truncate-regrow
    temp-unlink temp-symlink temp-regular destination-race parent-swap
    sigint-after-temp sigterm-after-temp sigint-after-link sigterm-after-link
)
foreach(_case IN LISTS _transaction_failure_cases)
    string(REPLACE "-" "_" _test_suffix "${_case}")
    add_test(
        NAME "transaction_failure_${_test_suffix}"
        COMMAND "${Python3_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/transaction_cases.py"
                --case "${_case}"
                --send2adf "$<TARGET_FILE:send2adf>"
    )
endforeach()
