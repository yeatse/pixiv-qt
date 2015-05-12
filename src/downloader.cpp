#include "downloader.h"

Downloader::Downloader(QObject *parent) :
    QObject(parent),
    dl(0),
    thread(0),
    mState(0),
    mProgress(0)
{
}

Downloader::~Downloader()
{
    if (thread){
        thread->terminate();
        thread->wait();
        dl->deleteLater();
    }
}

int Downloader::state() const
{
    return mState;
}
void Downloader::setState(int state)
{
    if (mState != state){
        mState = state;
        emit stateChanged();
    }
}

qreal Downloader::progress() const
{
    return mProgress;
}
void Downloader::setProgress(qreal progress)
{
    if (mProgress != progress){
        mProgress = progress;
        emit progressChanged();
    }
}

int Downloader::error() const
{
    return mError;
}
void Downloader::setError(int error)
{
    mError = error;
}

QString Downloader::currentFile() const
{
    return mCurrentFile;
}
QString Downloader::currentRequest() const
{
    return mCurrentRequest;
}

QString Downloader::saveFileName(const QString &oriName)
{
    QFileInfo info(oriName);
    QString path = info.absolutePath();
    QString basename = info.completeBaseName();
    QString suffix = info.suffix();

    QDir dir;
    if (!dir.exists(path))
        dir.mkpath(path);
    if (basename.isEmpty())
        basename = "download";
    if (suffix.isEmpty())
        suffix = "dl";

    if (QFile::exists(path+"/"+basename+"."+suffix)){
        int i = 1;
        while (QFile::exists(path+"/"+basename+QString::number(i)+"."+suffix))
            i++;
        basename += QString::number(i);
    }
    return path+'/'+basename+"."+suffix;
}

void Downloader::appendDownload(const QString &url, const QString &filename)
{
    qDebug() << url << filename;
    if (downloadQueue.isEmpty() && (mState == 0||mState == 4))
        QTimer::singleShot(0, this, SLOT(startNextDownload()));

    downloadQueue.enqueue(QUrl::fromEncoded(url.toLocal8Bit()));
    fileNameQueue.enqueue(filename);
}

void Downloader::abortDownload(const bool isAll)
{
    if (isAll){
        fileNameQueue.clear();
        downloadQueue.clear();
    }
    emit abort();
}

bool Downloader::existsRequest(const QString &url)
{
    return downloadQueue.contains(QUrl::fromEncoded(url.toLocal8Bit()));
}

void Downloader::removeRequest(const QString &url, const QString &filename)
{
    fileNameQueue.removeOne(filename);
    downloadQueue.removeOne(url);
}

void Downloader::startNextDownload()
{
    if (!thread){
        thread = new QThread(this);
        dl = new DownloadHelper;
        dl->moveToThread(thread);
        connect(this, SIGNAL(start(QUrl,QString)), dl, SLOT(start(QUrl,QString)));
        connect(this, SIGNAL(abort()), dl, SLOT(abort()));
        connect(dl, SIGNAL(error(int)), this, SLOT(setError(int)));
        connect(dl, SIGNAL(progressChanged(qreal)), this, SLOT(setProgress(qreal)));
        connect(dl, SIGNAL(stateChanged(int)), this, SLOT(setState(int)));
        connect(dl, SIGNAL(finished()), this, SLOT(startNextDownload()));
        thread->start();
    }
    if (downloadQueue.isEmpty()){
        mCurrentRequest.clear();
        emit currentRequestChanged();
        setState(4);
    } else {
        QUrl url = downloadQueue.dequeue();
        QString filename = saveFileName(fileNameQueue.dequeue());
        mCurrentFile = filename;
        mCurrentRequest = url.toString();
        emit currentFileChanged();
        emit currentRequestChanged();
        emit start(url, filename);
    }
}


DownloadHelper::DownloadHelper(QObject *parent) :
    QObject(parent),
    manager(0),
    currentDownload(0),
    output(0)
{
}

DownloadHelper::~DownloadHelper()
{
    abort();
}

void DownloadHelper::start(QUrl source, QString target)
{
    if (!manager) manager = new QNetworkAccessManager(this);
    if (!output) output = new QFile(this);

    output->setFileName(target+".tmp");
    if (!output->open(QIODevice::WriteOnly)){
        emit error(-1);
        emit stateChanged(3);
        emit finished();
    } else {
        emit error(0);
        emit stateChanged(1);
        emit progressChanged(0);

        QNetworkRequest req(source);

        req.setRawHeader("Referer", "http://www.pixiv.net");

        currentDownload = manager->get(req);
        emit stateChanged(2);
        connect(currentDownload, SIGNAL(downloadProgress(qint64,qint64)), SLOT(downloadProgress(qint64,qint64)));
        connect(currentDownload, SIGNAL(finished()), SLOT(downloadFinished()));
        connect(currentDownload, SIGNAL(readyRead()), SLOT(downloadReadyRead()));
    }
}

void DownloadHelper::downloadFinished()
{
    currentDownload->deleteLater();
    output->close();
    if (currentDownload->error()){
        output->remove();
    } else {
        QString fileName = output->fileName();
        int idx = fileName.lastIndexOf(".tmp");
        fileName = fileName.left(idx);
        output->rename(fileName);
    }
    emit error(currentDownload->error());
    emit stateChanged(3);
    emit finished();
}

void DownloadHelper::downloadReadyRead()
{
    output->write(currentDownload->readAll());
}

void DownloadHelper::downloadProgress(qint64 bytesReceived, qint64 bytesTotal)
{
    emit progressChanged(qreal(bytesReceived)/qreal(bytesTotal));
}

void DownloadHelper::abort()
{
    if (!currentDownload.isNull() && currentDownload->isRunning()){
        currentDownload->abort();
    }
}
