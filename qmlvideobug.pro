QT += quick quickcontrols2 multimedia


equals(QT_MAJOR_VERSION, 5):android {
    QT += androidextras
}


CONFIG += c++11
DEFINES += QT_DEPRECATED_WARNINGS
SOURCES += main.cpp utils.cpp
HEADERS += utils.h
RESOURCES += qml.qrc

equals(QT_MAJOR_VERSION, 6) { ## for Qt6 use MediaPlayer6.qml
    RESOURCES += qml6.qrc
}
else {                        ## for Qt5 use MediaPlayer5.qml
    RESOURCES += qml5.qrc
}
# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
