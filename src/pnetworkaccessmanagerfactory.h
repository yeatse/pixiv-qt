#ifndef PNETWORKACCESSMANAGERFACTORY_H
#define PNETWORKACCESSMANAGERFACTORY_H

#include <QtDeclarative>
#include <QtNetwork>

class PNetworkAccessManagerFactory : public QDeclarativeNetworkAccessManagerFactory
{
public:
    explicit PNetworkAccessManagerFactory();
    virtual QNetworkAccessManager* create(QObject *parent);
};

class PNetworkAccessManager : public QNetworkAccessManager
{
    Q_OBJECT
public:
    explicit PNetworkAccessManager(QObject *parent=0);
protected:
    QNetworkReply *createRequest(Operation op, const QNetworkRequest &request, QIODevice *outgoingData);
};

#endif // PNETWORKACCESSMANAGERFACTORY_H
