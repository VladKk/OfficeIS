include(CMakeParseArguments)

### Find the qmlplugindump paths
### Requires that 'qmake' is listed in the PATHs
function(FindQmlPluginPath)
    execute_process(
        COMMAND qmake -query QT_INSTALL_BINS
        OUTPUT_VARIABLE QT_BIN_DIR
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    set(QMLPLUGINDUMP_BIN ${QT_BIN_DIR}/qmlplugindump PARENT_SCOPE)
endfunction()

function(add_qt_packages PACKAGES)

endfunction(add_qt_packages)

function(add_qmlplugin TARGET)
    set(options "")
    set(oneValueArgs URI VERSION RESOURCE BINARY_DIR)
    set(multiValueArgs SOURCES QT_LIBS)

    cmake_parse_arguments(QMLPLUGIN
        "${options}"
        "${oneValueArgs}"
        "${multiValueArgs}"
        ${ARGN}
    )

    if(NOT QMLPLUGIN_URI OR NOT QMLPLUGIN_VERSION)
        message(WARNING "TARGET, URI and VERSION must be set, no files generated")
        return()
    endif()

    if(NOT QMLPLUGIN_BINARY_DIR)
        set(QMLPLUGIN_BINARY_DIR ${PLUGINS_OUTPUT_PATH}/${TARGET})
    endif()

    if(QMLPLUGIN_RESOURCE)
        qt_add_resources(PLUGIN_RESOURCES ${QMLPLUGIN_RESOURCE})
    endif()

    add_library(${TARGET}
        SHARED
            ${PLUGIN_RESOURCES}
            ${QMLPLUGIN_SOURCES}
    )

    set_target_properties(${TARGET}
        PROPERTIES
        LIBRARY_OUTPUT_DIRECTORY
            ${QMLPLUGIN_BINARY_DIR}
    )

    add_custom_command(
        TARGET
            ${TARGET}
        POST_BUILD
        COMMAND
            ${CMAKE_COMMAND} -E copy
            ${CMAKE_CURRENT_LIST_DIR}/qmldir
            $<TARGET_FILE_DIR:${TARGET}>/qmldir
        COMMENT
            "Copying qmldir to binary directory"
    )
endfunction()

macro(init_qt)
    set(CMAKE_AUTOMOC ON)
    set(CMAKE_AUTORCC ON)
    set(CMAKE_AUTOUIC ON)
endmacro()

init_qt()
