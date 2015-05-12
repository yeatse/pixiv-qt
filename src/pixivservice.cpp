#include "pixivservice.h"

#include <QRegExp>

#include "qjson.h"
#include "utility.h"

PixivService::PixivService(QObject *parent) :
    QObject(parent)
{
}

PixivService::~PixivService()
{
    if (loginReply && loginReply->isRunning())
        loginReply->abort();
}

void PixivService::classBegin()
{
    QDeclarativeEngine* engine = qmlEngine(this);
    if (QDeclarativeNetworkAccessManagerFactory* factory = engine->networkAccessManagerFactory()){
        manager = factory->create(this);
    } else {
        manager = engine->networkAccessManager();
    }
}

void PixivService::componentComplete()
{
}

void PixivService::login(QString username, QString password)
{
    if (loginReply && loginReply->isRunning())
        loginReply->abort();

    QString pending;
    pending.append("client_id=");
    pending.append(CLIENT_ID);
    pending.append("&client_secret=");
    pending.append(CLIENT_SECRET);
    pending.append("&grant_type=password");
    pending.append("&username="+QUrl::toPercentEncoding(username));
    pending.append("&password="+password);

    QNetworkRequest req(QUrl(AUTH_URL));
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    req.setHeader(QNetworkRequest::ContentLengthHeader, pending.toAscii().length());
    loginReply = manager->post(req, pending.toAscii());
    loginReply->ignoreSslErrors();

    connect(loginReply, SIGNAL(finished()), this, SLOT(slotLoginFinished()));
}

void PixivService::slotLoginFinished()
{
    loginReply->deleteLater();

    if (loginReply->error() != QNetworkReply::NoError){
        emit loginFailed();
        return;
    }

    QByteArray reply = loginReply->readAll();
    QJson json;
    bool ok;
    QVariantMap map = json.parse(reply, &ok).toMap();

    if (!ok || map.contains("has_error")){
        emit loginFailed();
        return;
    }

    QVariant variantCookies = loginReply->header(QNetworkRequest::SetCookieHeader);
    QList<QNetworkCookie> cookies = qvariant_cast<QList<QNetworkCookie> >(variantCookies);
    foreach (QNetworkCookie cookie, cookies) {
        if (cookie.name() == "PHPSESSID"){
            mPhpsessid = QString(cookie.value());
            emit phpsessidChanged();
            break;
        }
    }

    mUserData = map.value("response").toMap().value("user").toMap();
    emit userDataChanged();

    emit loginFinished();
}
