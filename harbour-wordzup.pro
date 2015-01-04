# The name of your application
TARGET = harbour-wordzup

CONFIG += sailfishapp

SOURCES += src/harbour-wordzup.cpp

OTHER_FILES += qml/harbour-wordzup.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/GamePage.qml \
    qml/pages/ScorePage.qml \
    qml/pages/DataUpdatePage.qml \
    qml/pages/controls/CountDownClock.qml \
    qml/pages/controls/FlippingText.qml \
    qml/pages/controls/MessagePopup.qml \
    qml/pages/utils/FirstLoad.qml \
    qml/pages/utils/Persistence.js \
    rpm/harbour-wordzup.spec \
    rpm/harbour-wordzup.yaml \
    translations/*.ts \
    harbour-wordzup.desktop \
    rpm/harbour-wordzup.changes

RESOURCES += \
    gamedata.qrc

# to disable building translations every time, comment out the
# following CONFIG line
#CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-wordzup-pt.ts

