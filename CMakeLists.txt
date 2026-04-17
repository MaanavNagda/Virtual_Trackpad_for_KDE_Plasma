cmake_minimum_required(VERSION 3.16)

project(VirtualTrackpad VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick)

set(SOURCES
    uinput_cursor_controller.cpp
    main.cpp
)

set(HEADERS
    uinput_cursor_controller.h
)

add_executable(VirtualTrackpad
    ${SOURCES}
    ${HEADERS}
)

target_link_libraries(VirtualTrackpad
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
)

# Copy QML file to build directory
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/virtual_trackpad_app.qml ${CMAKE_CURRENT_BINARY_DIR}/virtual_trackpad_app.qml COPYONLY)
