target_sources(${CMAKE_PROJECT_NAME} PUBLIC
    "main.cpp"
    "PlcModbusClient.cpp"
    "PlcModbusClient.h"
    "TagRegistry.cpp"
    "TagRegistry.h"
    "ScadaEngine.cpp"
    "ScadaEngine.h"
)

target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Gui
    Qt${QT_VERSION_MAJOR}::Widgets
    Qt${QT_VERSION_MAJOR}::Quick
    Qt${QT_VERSION_MAJOR}::Qml
    Qt${QT_VERSION_MAJOR}::SerialBus
    Qt${QT_VERSION_MAJOR}::Sql)

target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}"
    "${CMAKE_CURRENT_SOURCE_DIR}/autogen"
)
