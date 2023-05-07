find_package(Qt6 6.2 COMPONENTS Qml Core Quick REQUIRED)

qt_add_qml_module(filteringmodel
    URI "filteringmodel"
    VERSION
        1.0
    SOURCES
        ${CMAKE_CURRENT_LIST_DIR}/node.h
        ${CMAKE_CURRENT_LIST_DIR}/modelattached.cpp
        ${CMAKE_CURRENT_LIST_DIR}/modelattached.h
        ${CMAKE_CURRENT_LIST_DIR}/filteringmodel.cpp
        ${CMAKE_CURRENT_LIST_DIR}/filteringmodel.h
        ${CMAKE_CURRENT_LIST_DIR}/qmldir
    PLUGIN_TARGET filteringmodel
)

target_link_libraries(filteringmodel PRIVATE Qt6::Qml Qt6::Core Qt6::Quick)
include_directories(${CMAKE_SOURCE_DIR} ${CMAKE_CURRENT_LIST_DIR} ${Qt6QmlModels_PRIVATE_INCLUDE_DIRS})

install(TARGETS filteringmodel LIBRARY DESTINATION ${OFFICEIS_INSTALL_QML_PATH}/filteringmodel)
install(FILES ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/filteringmodel/qmldir DESTINATION ${OFFICEIS_INSTALL_QML_PATH}/filteringmodel)
