#ifndef UTILITY_H
#define UTILITY_H

#include <QtDeclarative>

class Utility : public QObject
{
    Q_OBJECT
public:
    static Utility* Instance();
    ~Utility();

    Q_INVOKABLE QVariant getValue(const QString &key, const QVariant &defaultValue = QVariant());
    Q_INVOKABLE void setValue(const QString &key, const QVariant &value);

    // Date helper
    Q_INVOKABLE int daysTo(int fy, int fm, int fd, int ty, int tm, int td);
    Q_INVOKABLE QDate addDays(int y, int m, int d, int ndays);

private:
    explicit Utility(QObject *parent = 0);

    QSettings* settings;
    QMap<QString, QVariant> map;
};

#endif // UTILITY_H
