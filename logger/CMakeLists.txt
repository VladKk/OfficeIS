add_subdirectory(logger_base)

find_package(Qt6 6.2 COMPONENTS Qml Core Gui Widgets REQUIRED)

qt_add_qml_module(logger
    URI "logger"
    VERSION
        1.0
    SOURCES
        ${CMAKE_CURRENT_LIST_DIR}/input_logger.cpp
        ${CMAKE_CURRENT_LIST_DIR}/input_logger.h
        ${CMAKE_CURRENT_LIST_DIR}/logger.cpp
        ${CMAKE_CURRENT_LIST_DIR}/logger.h
        ${CMAKE_CURRENT_LIST_DIR}/qmldir
    PLUGIN_TARGET logger
)

include_directories(${CMAKE_SOURCE_DIR})
target_link_libraries(logger PRIVATE Qt6::Qml Qt6::Core Qt6::Gui Qt6::Widgets logger_base)

install(TARGETS logger LIBRARY DESTINATION ${OFFIECEIS_INSTALL_QML_PATH}/logger)
install(FILES ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/logger/qmldir DESTINATION ${OFFICEIS_INSTALL_QML_PATH}/logger)
