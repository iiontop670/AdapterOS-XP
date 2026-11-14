cmake_minimum_required(VERSION 3.21)
project(AdapterDesktop VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Core Gui Qml Quick)

qt_add_executable(adapter-desktop
    src/main.cpp
    resources.qrc
)

target_link_libraries(adapter-desktop PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
)

install(TARGETS adapter-desktop
    RUNTIME DESTINATION bin
)
