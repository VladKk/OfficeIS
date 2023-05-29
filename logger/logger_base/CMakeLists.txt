find_package(Qt6 6.2 COMPONENTS Core REQUIRED)

set(SOURCES
    ${CMAKE_CURRENT_LIST_DIR}/loggerbase.cpp
)

set(HEADERS
    ${CMAKE_CURRENT_LIST_DIR}/loggerbase.h
)

add_library(logger_base ${SOURCES} ${HEADERS})

target_include_directories(logger_base PUBLIC ${CMAKE_SOURCE_DIR} ${CMAKE_CURRENT_LIST_DIR})
target_link_libraries(logger_base PRIVATE Qt6::Core)
