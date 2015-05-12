#include "pnetworkaccessmanagerfactory.h"

PNetworkAccessManagerFactory::PNetworkAccessManagerFactory() :
    QDeclarativeNetworkAccessManagerFactory()
{
}

QNetworkAccessManager* PNetworkAccessManagerFactory::create(QObject *parent)
{
    QNetworkAccessManager* manager = new PNetworkAccessManager(parent);
    return manager;
}

PNetworkAccessManager::PNetworkAccessManager(QObject *parent) :
    QNetworkAccessManager(parent)
{
}

QNetworkReply *PNetworkAccessManager::createRequest(Operation op, const QNetworkRequest &request, QIODevice *outgoingData)
{
    QNetworkRequest req(request);
    if (!request.hasRawHeader("Referer")){
        req.setRawHeader("Referer", "http://spapi.pixiv.net/");
    }
    req.setRawHeader("User-Agent", "pixiv-android-app (ver 3.2.2)");
    QNetworkReply *reply = QNetworkAccessManager::createRequest(op, req, outgoingData);
    return reply;
}
