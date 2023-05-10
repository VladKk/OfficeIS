find_package(Qt6 6.2 COMPONENTS Core REQUIRED)

qt_add_qml_module(filehandler
    URI "filehandler"
    VERSION
        1.0
    SOURCES
        ${CMAKE_CURRENT_LIST_DIR}/filehandler.cpp
        ${CMAKE_CURRENT_LIST_DIR}/filehandler.h
        ${CMAKE_CURRENT_LIST_DIR}/qmldir
    PLUGIN_TARGET filehandler
)

target_link_libraries(filehandler PRIVATE Qt6::Core)
include_directories(${CMAKE_SOURCE_DIR} ${CMAKE_CURRENT_LIST_DIR})

install(TARGETS filehandler LIBRARY DESTINATION ${OFFICEIS_INSTALL_QML_PATH}/filehandler)
install(FILES ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/filehandler/qmldir DESTINATION ${OFFICEIS_INSTALL_QML_PATH}/filehandler)
