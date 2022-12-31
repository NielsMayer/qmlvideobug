// Copyright (C) 2022 Niels P. Mayer (http://nielsmayer.com)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

#ifndef UTILS_H
#define UTILS_H

#include <QObject>
#include <QUrl>             //for Utils::argv()
#include <qplatformdefs.h> // defines QT_VERSION, etc
#include <QDebug>

#ifdef Q_OS_ANDROID
#if (QT_VERSION < QT_VERSION_CHECK(6, 0, 0))    //Qt5
#include <QAndroidJniEnvironment>
#include <QAndroidJniObject>
#elif (QT_VERSION < QT_VERSION_CHECK(6, 2, 0))
//Qt6.0, 6.1 are unsupported...
#elif (QT_VERSION >= QT_VERSION_CHECK(6, 2, 0)) //Qt6.2
#include <QCoreApplication>    //Qt>=6.2 QAndroidJniEnvironment and QAndroidJniObject in QCore
#include <QJniObject>
#endif /* (QT_VERSION < QT_VERSION_CHECK(6, 0, 0)) */
#endif /* Q_OS_ANDROID */

#define UTILS_PROP(type,name) QNANO_PROPERTY(type, m_##name, name, set##name)

class Utils : public QObject
{
    Q_OBJECT

public:
    explicit Utils(QObject *parent = nullptr);
  
    //convenience for missing QML QAudio::convertVolume(linear_value, QAudio::LinearVolumeScale, QAudio::LogarithmicVolumeScale);
    Q_INVOKABLE qreal linearToLog(qreal linear_value) const;

    // access QOperatingSystemVersion class in QML
    Q_INVOKABLE int osMajorVersion() const;
    Q_INVOKABLE int osMinorVersion() const;
    Q_INVOKABLE int osMicroVersion() const;
    Q_INVOKABLE int osBinaryVersion() const;   // majorVersion * (1000 * 1000)) + (minorVersion * 1000) + microVersion
    Q_INVOKABLE QString osName() const;

    Q_INVOKABLE inline QString qtVersion() const //was:{"_QT_VERSION_STR_",   QVariant::fromValue(QStringLiteral(QT_VERSION_STR)) }, //was: engine.rootContext()->setContextProperty("_QT_VERSION_STR_", QString(QT_VERSION_STR));
    { return QStringLiteral(QT_VERSION_STR); }
    Q_INVOKABLE inline int qtVersionMajor() const //was:{"_QT_VERSION_MAJOR_", QVariant::fromValue(QT_VERSION_MAJOR)},         //was: engine.rootContext()->setContextProperty("_QT_VERSION_MAJOR_", QT_VERSION_MAJOR);
    {return QT_VERSION_MAJOR;}
    Q_INVOKABLE inline int qtVersionMinor() const //was: engine.rootContext()->setContextProperty("_QT_VERSION_MINOR_", QT_VERSION_MINOR);
    {return QT_VERSION_MINOR; }
    Q_INVOKABLE inline int qtVersionPatch() const //was: //{"_QT_VERSION_PATCH_", QVariant::fromValue(QT_VERSION_PATCH)}          //was: engine.rootContext()->setContextProperty("_QT_VERSION_PATCH_", QT_VERSION_PATCH);
    {return QT_VERSION_PATCH;}
  
    Q_INVOKABLE QString toHtmlEscaped(const QString str) const;
    Q_INVOKABLE bool supportsSSL() const;
    Q_INVOKABLE QList<QUrl> argv() const;
#if (QT_VERSION >= QT_VERSION_CHECK(5, 10, 0))
    Q_INVOKABLE QString formattedDataSize(const qint64 sizeValue,
                                          const int precision = 2) const;
#endif /* end: QT_VERSION... */

    Q_INVOKABLE QString formatDuration(const double duration /*, bool milliminutesP */) const;
    Q_INVOKABLE bool checkAndroidStoragePermissions() const;

#ifdef Q_OS_ANDROID
    Q_INVOKABLE void vibrate(const int milliseconds);
#endif /* Q_OS_ANDROID */

    Q_INVOKABLE void keepScreenOn(const bool on);

    Q_INVOKABLE void deleteFile(const QString &path);
    Q_INVOKABLE void touchFile(const QString &path);

    Q_INVOKABLE bool pathExists(const QString &path) const;
    Q_INVOKABLE bool fileExists(const QString &path) const;

private:
    bool              m_hasVibrator = false; //only set to true if android, VIBRATION permission set, and service started successfully in initializer.
#ifdef Q_OS_ANDROID
#if (QT_VERSION < QT_VERSION_CHECK(6, 0, 0))    //Qt5
    QAndroidJniObject
#elif (QT_VERSION >= QT_VERSION_CHECK(6, 2, 0)) //Qt6.2
    QJniObject
#endif /* QT_VERSION... */
        m_vibratorService; //initialized in Utils()
#endif /* Q_OS_ANDROID */

    
Q_SIGNALS:
    void alert(const QString &message);
};

extern QSharedPointer<Utils> _Utils;                       //global pointer to shared data

// used in main.cpp:main() as deleter for the global '_Utils' extern'd above
static void utilsDeleter(Utils* obj)
{
    Q_UNUSED(obj);
    qWarning() << Q_FUNC_INFO << "deleting Utils storage ...";
}

#endif // UTILS_H
