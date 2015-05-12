#include <QtDeclarative>
#include "qmlapplicationviewer.h"
#include "pixivservice.h"
#include "utility.h"
#include "downloader.h"
#include "pnetworkaccessmanagerfactory.h"
#include <QtWebKit/QWebSettings>

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));

#if defined(Q_OS_SYMBIAN) || defined(Q_WS_SIMULATOR)
    // Show splash screen on symbian
    QPixmap p("qml/gfx/splash.jpg");
    QSplashScreen* splash = new QSplashScreen(p);
    splash->show();
    splash->raise();
#endif

    app->setApplicationName("pixiv");
    app->setOrganizationName("Yeatse");
#ifdef Q_OS_S60V5
    const QString appVersion = "1.3.0";
#else
    const QString appVersion = VER;
#endif
    app->setApplicationVersion(appVersion);

    // Install translator for qt
    QString locale = QLocale::system().name();
    QTranslator qtTranslator;
    if (qtTranslator.load("qt_"+locale, QLibraryInfo::location(QLibraryInfo::TranslationsPath)))
        app->installTranslator(&qtTranslator);
    QTranslator translator;
    if (translator.load(app->applicationName()+"_"+locale, ":/i18n/"))
        app->installTranslator(&translator);

    QWebSettings::globalSettings()->setUserStyleSheetUrl(QUrl::fromLocalFile("qml/js/default_theme.css"));
    qmlRegisterType<PixivService>("com.yeatse.pixiv", 1, 0, "PixivService");

    // For fiddler network debugging
#ifdef Q_WS_SIMULATOR
    QNetworkProxy proxy;
    proxy.setType(QNetworkProxy::HttpProxy);
    proxy.setHostName("localhost");
    proxy.setPort(8888);
    QNetworkProxy::setApplicationProxy(proxy);
#endif

    QmlApplicationViewer viewer;
    PNetworkAccessManagerFactory factory;
    Downloader downloader;

    viewer.engine()->setNetworkAccessManagerFactory(&factory);
    viewer.rootContext()->setContextProperty("utility", Utility::Instance());
    viewer.rootContext()->setContextProperty("downloader", &downloader);
    viewer.rootContext()->setContextProperty("appVersion", appVersion);

    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationLockPortrait);

#ifdef Q_OS_S60V5
    viewer.setMainQmlFile(QLatin1String("qml/s60v5/main.qml"));
#elif defined(Q_OS_SYMBIAN)
    viewer.setMainQmlFile(QLatin1String("qml/pixiv/main.qml"));
#elif defined(Q_OS_HARMATTAN)
    viewer.setMainQmlFile(QLatin1String("qml/meego/main.qml"));
#else
    viewer.setMainQmlFile(QLatin1String("qml/pixiv/main.qml"));
#endif
    viewer.showExpanded();

#if defined(Q_OS_SYMBIAN) || defined(Q_WS_SIMULATOR)
    splash->finish(&viewer);
    splash->deleteLater();
#endif

    return app->exec();
}
