#ifndef PIXIVSERVICE_H
#define PIXIVSERVICE_H

#include <QObject>
#include <QtDeclarative>
#include <QtNetwork>
#include <QPointer>

#define CLIENT_ID "BVO2E8vAAikgUBW8FYpi6amXOjQj"
#define CLIENT_SECRET "LI1WsFUDrrquaINOdarrJclCrkTtc3eojCOswlog"
#define AUTH_URL "https://oauth.secure.pixiv.net/auth/token"
#define MEMBER_ILLUST_URL "http://www.pixiv.net/member_illust.php"

class PixivService : public QObject, public QDeclarativeParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QDeclarativeParserStatus)
    Q_PROPERTY(QString phpsessid READ phpsessid NOTIFY phpsessidChanged)
    Q_PROPERTY(QVariantMap userData READ userData NOTIFY userDataChanged)

public:
    explicit PixivService(QObject *parent = 0);
    ~PixivService();

    Q_INVOKABLE void login(QString username, QString password);

    QString phpsessid() const { return mPhpsessid; }
    QVariantMap userData() const { return mUserData; }

signals:
    void loginFinished();
    void loginFailed();

    void phpsessidChanged();
    void userDataChanged();

private slots:
    void slotLoginFinished();

private:
    virtual void classBegin();
    virtual void componentComplete();

    QPointer<QNetworkAccessManager> manager;
    QPointer<QNetworkReply> loginReply;

    QString mPhpsessid;
    QVariantMap mUserData;
};

#endif // PIXIVSERVICE_H
