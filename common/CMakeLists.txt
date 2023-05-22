find_package(Qt6 6.2 COMPONENTS Core Sql REQUIRED)

qt_add_qml_module(common
    URI "common"
    SHARED
    VERSION 1.0
    SOURCES
        utils.h
        utils.cpp
        dbmanager.h
        dbmanager.cpp
        equipmentmodel.h
        equipmentmodel.cpp
        qmldir
    RESOURCES
        sql/Users.sql
        sql/Tasks.sql
        sql/Projects.sql
        sql/Equipment.sql
    PLUGIN_TARGET common
)

target_link_libraries(common PRIVATE Qt6::Core Qt6::Sql)
include_directories(${CMAKE_SOURCE_DIR})

install(TARGETS common LIBRARY DESTINATION ${OFFICEIS_INSTALL_QML_PATH}/common)
install(FILES ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/common/qmldir DESTINATION ${OFFICEIS_INSTALL_QML_PATH}/common)
