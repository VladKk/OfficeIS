cmake_minimum_required(VERSION 3.16)

enable_testing()
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
set(PLUGINS_OUTPUT_PATH ${CMAKE_BINARY_DIR}/plugins)
set(SCRIPTS_OUTPUT_PATH ${CMAKE_BINARY_DIR}/scripts)
set(OFFICEIS_NAMESPACE "OfficeIS")
set(OFFICEIS_INSTALL_PATH ${CMAKE_BINARY_DIR}/install)
set(OFFICEIS_INSTALL_PLUGINS_PATH ${OFFICEIS_INSTALL_PATH}/plugins)
set(OFFICEIS_INSTALL_QML_PATH ${OFFICEIS_INSTALL_PATH}/qml)

set(QML_IMPORT_PATH "./qml" CACHE STRING "" FORCE)
set(QML2_IMPORT_PATH "./qml" CACHE STRING "" FORCE)

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    option(DEBUG "Set debug build definition" ON)
else()
    option(DEBUG "Set debug build definition" OFF)
endif()

configure_file(config.h.in ${CMAKE_CURRENT_SOURCE_DIR}/config.h)

set(PROJECT "officeis" CACHE STRING "Office Information System" FORCE)

project(${PROJECT})

find_package(Qt6 6.2 COMPONENTS Qml Core Quick Widgets Sql REQUIRED)

qt_add_executable(${PROJECT} main.cpp)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

target_compile_options(${PROJECT} PRIVATE
    -Wcast-align -Wchar-subscripts -Wpointer-arith
    -Wwrite-strings -Wpacked -Wformat-security -Wmissing-format-attribute
    -Wold-style-cast -Woverloaded-virtual -Wnon-virtual-dtor  -Wall -Wextra
    -Wformat=2 -Wundef -Wstack-protector -Wmissing-include-dirs
    -Winit-self -Wunsafe-loop-optimizations -fno-inline
)

include(QtCommon)

target_include_directories(${PROJECT} PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}
    ${Qt6Qml_INCLUDE_DIRS}
    ${Qt6Core_INCLUDE_DIRS}
    ${Qt6Quick_INCLUDE_DIRS}
    ${Qt6Widgets_INCLUDE_DIRS}
    ${Qt6Sql_INCLUDE_DIRS})

target_compile_definitions(${PROJECT} PRIVATE
    ${Qt6Qml_DEFINITIONS}
    ${Qt6Core_DEFINITIONS}
    ${Qt6Quick_DEFINITIONS}
    ${Qt6Widgets_DEFINITIONS}
    ${Qt6Sql_DEFINITIONS}
    $<$<BOOL:${DEBUG}>:DEBUG>)

target_link_libraries(${PROJECT} PRIVATE Qt6::Core Qt6::Qml Qt6::Quick Qt6::Widgets Qt6::Sql gui)

add_subdirectory(common)
add_subdirectory(filteringmodel)
add_subdirectory(gui)

install(TARGETS ${PROJECT} RUNTIME DESTINATION ${OFFICEIS_INSTALL_PATH})
