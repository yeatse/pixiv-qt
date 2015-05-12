TEMPLATE = app
TARGET = pixiv

VERSION = 1.3.0
DEFINES += VER=\\\"$$VERSION\\\"

QT += network webkit

HEADERS += \
    src/pixivservice.h \
    src/utility.h \
    src/pnetworkaccessmanagerfactory.h \
    src/downloader.h

SOURCES += main.cpp \
    src/pixivservice.cpp \
    src/utility.cpp \
    src/pnetworkaccessmanagerfactory.cpp \
    src/downloader.cpp \
#    qml/pixiv/*.qml \
#    qml/pixiv/Component/*.qml \
#    qml/pixiv/Illustration/*.qml \
#    qml/pixiv/Bookmark/*.qml \
#    qml/pixiv/Novel/*.qml \
#    qml/pixiv/User/*.qml \
#    qml/pixiv/Search/*.qml


RESOURCES += pixiv-res.qrc

INCLUDEPATH += src
TRANSLATIONS += i18n/pixiv_zh.ts

folder_symbian3.source = qml/pixiv
folder_symbian3.target = qml

folder_harmattan.source = qml/meego
folder_harmattan.target = qml

folder_s60v5.source = qml/s60v5
folder_s60v5.target = qml

folder_js.source = qml/js
folder_js.target = qml

folder_gfx.source = qml/gfx
folder_gfx.target = qml

DEPLOYMENTFOLDERS = folder_js folder_gfx

simulator {
    DEPLOYMENTFOLDERS += folder_symbian3 folder_harmattan folder_s60v5
}

contains(MEEGO_EDITION,harmattan){
    DEFINES += Q_OS_HARMATTAN
    DEPLOYMENTFOLDERS += folder_harmattan
    CONFIG += qdeclarative-boostable
}

symbian {
    contains(S60_VERSION, 5.0){
        DEFINES += Q_OS_S60V5
        INCLUDEPATH += $$[QT_INSTALL_PREFIX]/epoc32/include/middleware
        INCLUDEPATH += $$[QT_INSTALL_PREFIX]/include/Qt
        DEPLOYMENTFOLDERS += folder_s60v5
    } else {
        CONFIG += qt-components
        DEPLOYMENTFOLDERS += folder_symbian3
        MMP_RULES += "OPTION gcce -march=armv6 -mfpu=vfp -mfloat-abi=softfp -marm"
    }

    CONFIG += localize_deployment

    TARGET.UID3 = 0xA00168FC
    TARGET.CAPABILITY *= NetworkServices ReadUserData WriteUserData
    TARGET.EPOCHEAPSIZE = 0x40000 0x4000000

    vendorinfo = "%{\"Yeatse\"}" ":\"Yeatse\""
    my_deployment.pkg_prerules += vendorinfo
    DEPLOYMENT += my_deployment

    # Symbian have a different syntax
    DEFINES -= VER=\\\"$$VERSION\\\"
    DEFINES += VER=\"$$VERSION\"
}

OTHER_FILES += \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/README \
    qtc_packaging/debian_harmattan/manifest.aegis \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog

include(QJson/json.pri)
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()
