#include "utility.h"

Utility::Utility(QObject *parent) :
    QObject(parent),
    settings(0)
{
    settings = new QSettings(this);
}

Utility::~Utility()
{
}

Utility* Utility::Instance()
{
    static Utility u;
    return &u;
}

QVariant Utility::getValue(const QString &key, const QVariant &defaultValue)
{
    if (map.contains(key)){
        return map.value(key);
    } else {
        return settings->value(key, defaultValue);
    }
}

void Utility::setValue(const QString &key, const QVariant &value)
{
    if (map.value(key) != value){
        map.insert(key, value);
        settings->setValue(key, value);
    }
}

int Utility::daysTo(int fy, int fm, int fd, int ty, int tm, int td)
{
    QDate fromDate(fy, fm, fd);
    QDate toDate(ty, tm, td);
    return fromDate.daysTo(toDate);
}

QDate Utility::addDays(int y, int m, int d, int ndays)
{
    QDate date(y, m, d);
    return date.addDays(ndays);
}
