if(NOT CLANG_FORMAT_BIN)
    find_program(CLANG_FORMAT_BIN
        NAMES clang-format)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    ClangFormat
    REQUIRED_VARS CLANG_FORMAT_BIN
    VERSION_VAR ClangFormat_VERSION)

mark_as_advanced(
    CLANG_FORMAT_BIN
    CLANG_FORMAT_VERSION_OUTPUT)

if (CLANGFORMAT_FOUND)
    # Find all source files
    set(CLANG_FORMAT_CXX_FILE_EXTENSIONS *.c *.h)
    file(GLOB_RECURSE ALL_SOURCE_FILES ${CLANG_FORMAT_CXX_FILE_EXTENSIONS})

    # Don't include some common build folders
    set(CLANG_FORMAT_EXCLUDE_PATTERNS
        ${CLANG_FORMAT_EXCLUDE_PATTERNS}
        "/build/" "/CMakeFiles/" "/src/Drivers/" "cmake" "/test/")

    # Get all project files file
    foreach (SOURCE_FILE ${ALL_SOURCE_FILES})
        foreach (EXCLUDE_PATTERN ${CLANG_FORMAT_EXCLUDE_PATTERNS})
            string(FIND ${SOURCE_FILE} ${EXCLUDE_PATTERN} EXCLUDE_FOUND)
            if (NOT ${EXCLUDE_FOUND} EQUAL -1)
                list(REMOVE_ITEM ALL_SOURCE_FILES ${SOURCE_FILE})
            endif ()
        endforeach ()
    endforeach ()

    add_custom_target(codeformat
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
        COMMENT "Running clang-format to change files"
        VERBATIM
        COMMAND ${CLANG_FORMAT_BIN}
        -style=file
        -i
        ${ALL_SOURCE_FILES})

    add_custom_target(formatcheck
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
        COMMENT "Running clang-format to check files"
        VERBATIM
        COMMAND ${CLANG_FORMAT_BIN}
        -style=file
        --dry-run
        --Werror
        -i
        ${ALL_SOURCE_FILES})
endif()
