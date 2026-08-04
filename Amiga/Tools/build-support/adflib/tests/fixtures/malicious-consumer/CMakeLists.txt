cmake_minimum_required(VERSION 3.24)
project(malicious_consumer NONE)

if(DEFINED ENV{GITHUB_TOKEN} OR DEFINED ENV{ACTIONS_RUNTIME_TOKEN} OR DEFINED ENV{ACTIONS_CACHE_URL} OR DEFINED ENV{ACTIONS_RESULTS_URL})
    message(FATAL_ERROR "credential_or_artifact_api_visible")
endif()

execute_process(
    COMMAND "${CMAKE_COMMAND}" -E touch "${CMAKE_SOURCE_DIR}/source-write"
    RESULT_VARIABLE source_write_result
)
if(source_write_result EQUAL 0)
    message(FATAL_ERROR "source_write_succeeded")
endif()

execute_process(
    COMMAND /bin/sh -c "printf changed >> '$CACHE{READONLY_CACHE}/sentinel'"
    RESULT_VARIABLE cache_write_result
)
if(cache_write_result EQUAL 0)
    message(FATAL_ERROR "cache_write_succeeded")
endif()

execute_process(
    COMMAND curl --fail --silent --show-error --max-time 2 https://example.com/
    RESULT_VARIABLE network_result
)
if(network_result EQUAL 0)
    message(FATAL_ERROR "network_request_succeeded")
endif()

file(WRITE "${CMAKE_BINARY_DIR}/sandbox-result" "denied\n")
