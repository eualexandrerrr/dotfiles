cmake_minimum_required(VERSION 3.20)

project(windowsmodern-systemtray)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(ECM REQUIRED 5.240.0)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})
include(ECMQtDeclareLoggingCategory)

find_package(Qt6 REQUIRED COMPONENTS DBus Gui Quick Qml QuickControls2)
find_package(KF6 REQUIRED COMPONENTS
    Config
    IconThemes
    I18n
    KIO
    JobWidgets
    Service
    ItemModels
    WindowSystem
    XmlGui
    Package
)
find_package(Plasma REQUIRED)
find_package(PlasmaQuick REQUIRED)

add_definitions(-DTRANSLATION_DOMAIN=\"plasma_applet_org.kde.windowsmodern.systemtray\")

set(CMAKE_INCLUDE_CURRENT_DIR ON)
include_directories(${CMAKE_CURRENT_BINARY_DIR})

# Ensure plugin builds to the build directory, not the install prefix
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)

# Generate DBus interfaces
qt_add_dbus_interface(DBUS_SRCS
    "${CMAKE_CURRENT_SOURCE_DIR}/kf6_org.kde.StatusNotifierWatcher.xml"
    statusnotifierwatcher_interface
)
qt_add_dbus_interface(DBUS_SRCS
    "${CMAKE_CURRENT_SOURCE_DIR}/org.freedesktop.DBus.Properties.xml"
    dbusproperties
)

set(SNI_XML "${CMAKE_CURRENT_SOURCE_DIR}/kf6_org.kde.StatusNotifierItem.xml")
set_source_files_properties(${SNI_XML} PROPERTIES
   NO_NAMESPACE false
   INCLUDE "systemtraytypes.h"
   CLASSNAME OrgKdeStatusNotifierItem
)
qt_add_dbus_interface(DBUS_SRCS ${SNI_XML} statusnotifieritem_interface)

# DBusMenu (copied from plasma-workspace/libdbusmenuqt)
set_source_files_properties(com.canonical.dbusmenu.xml PROPERTIES
   NO_NAMESPACE true
   INCLUDE "dbusmenutypes_p.h"
   CLASSNAME DBusMenuInterface
)
qt_add_dbus_interface(DBUS_SRCS com.canonical.dbusmenu.xml dbusmenu_interface)

# Logging category — system tray
ecm_qt_declare_logging_category(SRC_LOGGING HEADER debug.h
    IDENTIFIER SYSTEM_TRAY
    CATEGORY_NAME kde.systemtray
    DEFAULT_SEVERITY Info
    DESCRIPTION "plasma applet systemtray"
)
# Logging category — dbusmenu (embedded from plasma-workspace/libdbusmenuqt)
ecm_qt_declare_logging_category(SRC_LOGGING HEADER debug_dbusmenu.h
    IDENTIFIER DBUSMENUQT
    CATEGORY_NAME org.kde.libdbusmenuqt
    DEFAULT_SEVERITY Info
    DESCRIPTION "libdbusmenu debug"
)

set(SRCS
    ${DBUS_SRCS}
    ${SRC_LOGGING}
    systemtray.cpp systemtray.h
    systemtraymodel.cpp systemtraymodel.h
    systemtraysettings.cpp systemtraysettings.h
    plasmoidregistry.cpp plasmoidregistry.h
    dbusserviceobserver.cpp dbusserviceobserver.h
    statusnotifieritemhost.cpp statusnotifieritemhost.h
    statusnotifieritemsource.cpp statusnotifieritemsource.h
    sortedsystemtraymodel.cpp sortedsystemtraymodel.h
    systemtraytypes.cpp systemtraytypes.h
    systemtraytypedefs.h
    dbusmenuimporter.h dbusmenuimporter.cpp
    dbusmenushortcut_p.h dbusmenushortcut_p.cpp
    dbusmenutypes_p.h dbusmenutypes_p.cpp
    utils_p.h utils.cpp
)

# Static library for shared code
add_library(systemtray_static STATIC ${SRCS})
set_property(TARGET systemtray_static PROPERTY POSITION_INDEPENDENT_CODE ON)

target_link_libraries(systemtray_static
    PUBLIC
        Qt6::DBus
        Qt6::Gui
        Qt6::Widgets
        Qt6::Quick
        KF6::ConfigCore
        KF6::IconThemes
        KF6::I18n
        KF6::KIOCore
        KF6::KIOGui
        KF6::JobWidgets
        KF6::Service
        KF6::ItemModels
        KF6::WindowSystem
        KF6::XmlGui
        Plasma::Plasma
        Plasma::PlasmaQuick
)

# Main applet plugin
plasma_add_applet(org.kde.windowsmodern.systemtray
    CPP_SOURCES
        systemtray.cpp
    RESOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/config/main.xml
)

target_link_libraries(org.kde.windowsmodern.systemtray PRIVATE systemtray_static)
target_include_directories(org.kde.windowsmodern.systemtray PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

# Register QML sources with preserved subdirectory layout so relative imports
# (import "lib", import "../js/funcs.js", etc.) resolve inside the qrc.
# plasma_add_applet flattens everything to the module root, so we add QML
# sources ourselves via ecm_target_qml_sources with PATH prefixes.
ecm_target_qml_sources(org.kde.windowsmodern.systemtray
    SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/main.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/AbstractItem.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/BackgroundAppItem.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/CompactApplet.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/ConfigGeneral.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/config.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/CurrentItemHighLight.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/ExpanderArrow.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/ExpandedRepresentation.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/HiddenItemsView.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/ItemLoader.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/PlasmoidItem.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/PlasmoidPopupsContainer.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/PulseAnimation.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/StatusNotifierItem.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/SystemTrayState.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/ActionPanel.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/FlyoutRouter.qml
)
ecm_target_qml_sources(org.kde.windowsmodern.systemtray
    PATH lib
    SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/lib/Tile.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/lib/SplitTile.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/lib/Slider.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/lib/SectionHeader.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/lib/PageHeader.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/lib/Page.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/lib/MoreSettingsLink.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/lib/ListRow.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/lib/FooterButton.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/lib/DetailPage.qml
)
ecm_target_qml_sources(org.kde.windowsmodern.systemtray
    PATH js
    SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/js/funcs.js
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/js/colorType.js
)
ecm_target_qml_sources(org.kde.windowsmodern.systemtray
    PATH components
    SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/NetworkPage.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/NetworkToggle.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/BluetoothPage.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/BluetoothToggle.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/VolumePage.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/VolumeSlider.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/BatteryPage.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/Battery.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/BrightnessPage.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/BrightnessSlider.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/PowerProfilePage.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/PowerButton.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/AirplaneToggle.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/BatterySaverToggle.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/NightLightToggle.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/DndToggle.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/ColorSchemeToggle.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/MicMuteToggle.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/HotspotToggle.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/CastInvertToggle.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/InhibitSleepToggle.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/TouchpadToggle.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/KeyboardBrightnessSlider.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/Footer.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/ClipboardPage.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/NotificationsPage.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/DeviceNotifierPage.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/MediaControllerPage.qml
)
ecm_target_qml_sources(org.kde.windowsmodern.systemtray
    PATH components/volume
    SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/volume/VolumeModels.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/volume/OutputDeviceSection.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/volume/InputDeviceSection.qml
        ${CMAKE_CURRENT_SOURCE_DIR}/contents/ui/components/volume/VolumeMixerSection.qml
)
