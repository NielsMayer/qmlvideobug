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

#include "utils.h"
#include <QSslSocket>       //for Utils::supportsSSL()
#include <QCoreApplication> //for Utils::argv()
#include <QUrl>             //for Utils::argv()
#include <QDir>             //for Utils::argv()
#include <QDebug>           //for Utils::argv()
#include <QLocale>

//#if (QT_VERSION < QT_VERSION_CHECK(6, 0, 0))
//#include <QtMultimedia/QAudio>
//#endif

#ifdef Q_OS_ANDROID
#if (QT_VERSION < QT_VERSION_CHECK(6, 0, 0))    //Qt5
#include <QtAndroidExtras> //for checkAndroidStoragePermissions()
#elif (QT_VERSION < QT_VERSION_CHECK(6, 2, 0))
//Qt6.0, 6.1 are unsupported...
#elif (QT_VERSION >= QT_VERSION_CHECK(6, 2, 0)) //Qt6.2
//already in header #include <QCoreApplication>    //Qt>=6.2 QAndroidJniEnvironment and QAndroidJniObject in QCore
//already in header #include <QJniObject>
#include <QJniEnvironment>
#endif /* (QT_VERSION < QT_VERSION_CHECK(6, 0, 0)) */
#endif /* Q_OS_ANDROID */


QString Utils::toHtmlEscaped(const QString str) const {
    return (str.toHtmlEscaped());
}

///
/// \brief supportsSSL
/// \return
///
bool Utils::supportsSSL() const {
#ifdef QT_NO_SSL //disable for webassembly b/c
    qWarning() << "supportsSSL(): returning false b/c QT_NO_SSL set at compile time.";
    return (false);
#else
    return (QSslSocket::supportsSsl());
#endif
}

///
/// \brief Utils::argv
/// \return
///
QList<QUrl> Utils::argv() const
{
    QList<QUrl> result;
    QStringList args = QCoreApplication::instance()->arguments();
    args.takeFirst();     // skip the first argument, which is the executable name
    if (args.isEmpty())
        return result;

    for (const QString &arg : qAsConst(args)) {
        const QString fp = arg.toLocal8Bit();
        if (QFile::exists(fp))
            result.append(QUrl::fromLocalFile((fp[0] == QDir::separator())
                                              ? fp
                                              : QDir::currentPath() + QDir::separator() + fp));
        else
            qWarning() << "argv(): skipping nonexistant file argument:" << fp;
    }
    return (result);
}

#if (QT_VERSION >= QT_VERSION_CHECK(5, 10, 0))
///
/// \brief Utils::formattedDataSize
/// \param sizeValue
/// \param precision
/// \return
///
QString Utils::formattedDataSize(const qint64 sizeValue, const int precision) const {
    return (QLocale::system().formattedDataSize(sizeValue,
                                                precision,
                                                QLocale::DataSizeTraditionalFormat)); //use regular stuff not default 'DataSizeelecFormat' bullshit that prints KiB MiB etc.
}
#endif /* end: QT_VERSION... */

///
/// \brief Utils::formatDuration
/// \param duration
/// \return
///
QString Utils::formatDuration(const double duration /*, bool milliminutesP */ ) const {
    long hours{}, minutes{}, seconds{};
    //  if (!milliminutesP && (duration < 3600000)) {    // --> MM'SS"
    if (duration <= 3600000.0) {                     //less than 60 minutes --> MM:SS
        hours   = 0l;
        minutes = (long) (duration / 60000.0);
        seconds = (long) ((duration - (((double) minutes * 60000.0))) / 1000.0);

        if (seconds == 60l) { //bugfix against 00:60 --> 01:00
            minutes++;
            seconds = 0l;
        }
        if (minutes == 60l) { //bugfix against 1:60:00 --> 2:00:00
            hours++;
            minutes = 0l;
        }

        if (hours == 0l)
            return (QString::number(minutes)             //      return (QString::number(minutes) + ((seconds < 10) ? "'0" : "'") + QString::number(seconds)) + '"';
                    + ((seconds < 10l)
                           ? ":0"
                           : ":")
                    + QString::number(seconds));
    }
    else {
        hours   = (long) (duration / (60.0*60000.0));      //more than 60 mins --> HH:MM:SS
        minutes = (long) ((duration - ((double) hours * 60.0 * 60000.0))/60000.0);
        seconds = (long) ((duration - (((double) minutes * 60000.0))
                               - ((double) hours * 60.0 * 60000.0)) / 1000.0);

        if (seconds == 60l) { //bugfix against 00:60 --> 01:00
            minutes++;
            seconds = 0l;
        }
        if (minutes == 60l) { //bugfix against 1:60:00 --> 2:00:00
            hours++;
            minutes = 0l;
        }
    }

    return (QString::number(hours)
            + ((minutes < 10l)
                   ? ":0"
                   : ":")
            + QString::number(minutes)
            + ((seconds < 10l)
                   ? ":0"
                   : ":")
            + QString::number(seconds));
}

///
/// \brief Utils::checkAndroidStoragePermissions
/// \return true if storage permissions granted by user. false if denied.
///
bool Utils::checkAndroidStoragePermissions() const {
#ifdef Q_OS_ANDROID
    const auto permissionsRequest = QStringList({ QString("android.permission.READ_EXTERNAL_STORAGE"),
                                                  QString("android.permission.WRITE_EXTERNAL_STORAGE")/*,
                                                  QString("android.permission.VIBRATE")*/
                                                });
#if (QT_VERSION < QT_VERSION_CHECK(6, 0, 0))    //Qt5
    if (   (QtAndroid::checkPermission(permissionsRequest[0])  == QtAndroid::PermissionResult::Denied)
        || (QtAndroid::checkPermission(permissionsRequest[1])) == QtAndroid::PermissionResult::Denied
        //      || (QtAndroid::checkPermission(permissionsRequest[2])) == QtAndroid::PermissionResult::Denied
        ) {
        auto permissionResults = QtAndroid::requestPermissionsSync(permissionsRequest);

        //        if (permissionResults[permissionsRequest[2]] == QtAndroid::PermissionResult::Denied)
        //            qWarning() << Q_FUNC_INFO << ": vibrator disabled by denial of permission 'android.permission.VIBRATE'";

        if (   (permissionResults[permissionsRequest[0]] == QtAndroid::PermissionResult::Denied)
            || (permissionResults[permissionsRequest[1]] == QtAndroid::PermissionResult::Denied))
            return (false);
    }
#elif (QT_VERSION < QT_VERSION_CHECK(6, 2, 0))
    return (false); //Qt6.0, 6.1 are unsupported...
#elif (QT_VERSION >= QT_VERSION_CHECK(6, 2, 0)) //Qt6.2
    return (true); //to allow QML code to not worry about platform, for other platforms, checkAndroidStoragePermissions() always returns true
#endif /* (QT_VERSION < QT_VERSION_CHECK(6, 0, 0)) */
#endif /* Q_OS_ANDROID */
    return (true); //to allow QML code to not worry about platform, for other platforms, checkAndroidStoragePermissions() always returns true
}

#ifdef Q_OS_ANDROID
///
/// \brief Utils::vibrate
/// \param milliseconds
///
/// from https://www.vladest.org/qttipsandtricks/how-to-vibrate-with-qtqml-on-android.html
/// usage:
///         if (!topwin.isDesktopApp)
///             utils.vibrate(500);
///
void Utils::vibrate(const int milliseconds)
{
    if (m_hasVibrator) {
        jlong ms = milliseconds;
        m_vibratorService.callMethod<void>("vibrate", "(J)V", ms);
    }
}
#endif /* Q_OS_ANDROID */

///
/// \brief Utils::keepScreenOn
/// \param on
///
void Utils::keepScreenOn(const bool on) {
    qWarning() << Q_FUNC_INFO
               << "screen on=" << on;
#ifdef Q_OS_ANDROID
#if (QT_VERSION < QT_VERSION_CHECK(6, 0, 0))    //Qt5
    /// FROM https://stackoverflow.com/questions/27758499/how-to-keep-the-screen-on-in-qt-for-android
    QtAndroid::runOnAndroidThread([on]{
        QAndroidJniObject activity = QtAndroid::androidActivity();
        if (activity.isValid()) {
            QAndroidJniObject window =
                activity.callObjectMethod("getWindow", "()Landroid/view/Window;");

            if (window.isValid()) {
                const int FLAG_KEEP_SCREEN_ON = 128;
                if (on) {
                    window.callMethod<void>("addFlags", "(I)V", FLAG_KEEP_SCREEN_ON);
                } else {
                    window.callMethod<void>("clearFlags", "(I)V", FLAG_KEEP_SCREEN_ON);
                }
            }
        }
        QAndroidJniEnvironment env;
        if (env->ExceptionCheck()) {
            env->ExceptionClear();
        }
    });
#elif (QT_VERSION < QT_VERSION_CHECK(6, 2, 0))
//Qt6.0, 6.1 are unsupported...
#elif (QT_VERSION >= QT_VERSION_CHECK(6, 2, 0)) //Qt6.2
    /// FROM https://stackoverflow.com/questions/27758499/how-to-keep-the-screen-on-in-qt-for-android
    QNativeInterface::QAndroidApplication::runOnAndroidMainThread([on]{
        QJniObject activity = QNativeInterface::QAndroidApplication::context();
        if (activity.isValid()) {
            QJniObject window =
                activity.callObjectMethod("getWindow", "()Landroid/view/Window;");

            if (window.isValid()) {
                const int FLAG_KEEP_SCREEN_ON = 128;
                if (on) {
                    window.callMethod<void>("addFlags", "(I)V", FLAG_KEEP_SCREEN_ON);
                } else {
                    window.callMethod<void>("clearFlags", "(I)V", FLAG_KEEP_SCREEN_ON);
                }
            }
        }
        QJniEnvironment env;
        if (env->ExceptionCheck()) {
            env->ExceptionClear();
        }
    });
#endif /* (QT_VERSION < QT_VERSION_CHECK(6, 0, 0)) */
#endif /* Q_OS_ANDROID */
}

#include <qplatformdefs.h> // defines QT_VERSION, etc
#include <QDebug>
#include <QFile>
#include <QDir>
#include <QVariant>
#include <QString>
#include <QProcess>

Utils::Utils(QObject *parent)
    : QObject(parent)
{
    // per https://www.vladest.org/qttipsandtricks/how-to-vibrate-with-qtqml-on-android.html
    // init m_vibratorService
#ifdef Q_OS_ANDROID
#if (QT_VERSION < QT_VERSION_CHECK(6, 0, 0))    //Qt5
    QAndroidJniObject vibroString
        = QAndroidJniObject::fromString("vibrator");
    QAndroidJniObject activity
        = QAndroidJniObject::callStaticObjectMethod("org/qtproject/qt5/android/QtNative",
                                                    "activity",
                                                    "()Landroid/app/Activity;");
    QAndroidJniObject appctx
#elif (QT_VERSION < QT_VERSION_CHECK(6, 2, 0))
    m_hasVibrator = false;  //Qt6.0, 6.1 are unsupported...
#elif (QT_VERSION >= QT_VERSION_CHECK(6, 2, 0)) //Qt6.2
    QJniObject vibroString
        = QJniObject::fromString("vibrator");
    QJniObject activity
        = QJniObject::callStaticObjectMethod("org/qtproject/qt/android/QtNative",
                                                    "activity",
                                                    "()Landroid/app/Activity;");
    QJniObject appctx
#endif /* (QT_VERSION < QT_VERSION_CHECK(6, 0, 0)) */
    = activity.callObjectMethod("getApplicationContext",
                                "()Landroid/content/Context;");
    m_vibratorService
        = appctx.callObjectMethod("getSystemService",
                                  "(Ljava/lang/String;)Ljava/lang/Object;",
                                  vibroString.object<jstring>());
    if (m_vibratorService.isValid())
        m_hasVibrator = static_cast<bool>(m_vibratorService.callMethod<jboolean>("hasVibrator", "()Z"));
    else {
        qWarning() << Q_FUNC_INFO << ": Android vibrator service unavailable...";
        m_hasVibrator = false;
    }
#endif /* Q_OS_ANDROID */

    if (m_hasVibrator)
        qWarning() << Q_FUNC_INFO << ": vibrator available and initialized ...";
    else
        qWarning() << Q_FUNC_INFO << ": vibrator not available ...";

}

#include <cmath> //for std:exp, which ends up undefined in Qt5.15 but not 6.2...
#if (QT_VERSION < QT_VERSION_CHECK(6, 0, 0))
#include <QtMultimedia/QAudio>
#endif

qreal Utils::linearToLog(qreal linear_value) const
{
#if (QT_VERSION < QT_VERSION_CHECK(6, 0, 0))
    return (QAudio::convertVolume(linear_value, QAudio::LinearVolumeScale, QAudio::LogarithmicVolumeScale));
#else
    return (1.0 - std::exp(-(qMax(qreal(0), linear_value)) * 4.60517018599));
#endif
}

#include <QOperatingSystemVersion>

//NB: returns -1 for linux. Valid on Android.
int Utils::osMajorVersion() const
{
    return (QOperatingSystemVersion::current().majorVersion());
}

//NB: returns -1 for linux. Valid on Android.
int Utils::osMinorVersion() const
{
    return (QOperatingSystemVersion::current().minorVersion());
}

//NB: returns -1 for linux. valid on Android.
int Utils::osMicroVersion() const
{
    return (QOperatingSystemVersion::current().microVersion());
}

// majorVersion * (1000 * 1000)) + (minorVersion * 1000) + microVersion
// NB: due to priimitives returning -1 on Linux, returns -1001001 on Linux.
// returns valid value on Android.
int Utils::osBinaryVersion() const
{
    auto os = QOperatingSystemVersion::current();
    return (  (os.majorVersion() * (1000 * 1000))
            + (os.minorVersion() * 1000)
            + os.microVersion());
}

// NB: returns "" for Linux... "Android" for android, etc.
QString Utils::osName() const
{
    return (QOperatingSystemVersion::current().name());
}

void Utils::deleteFile(const QString &path) {
    if (QFile::exists(path)) {
        if (QFile::remove(path)) {
            Q_EMIT alert(tr("File(s) deleted from device"));
        }
        else {
            Q_EMIT alert(tr("Unable to delete file(s) from device"));
        }
    }
    else {
        Q_EMIT alert(tr("File not found"));
    }
}

void Utils::touchFile(const QString &path) {
        QFile qf(path);
        if (qf.open(QIODevice::Unbuffered|QIODevice::WriteOnly|QIODevice::Truncate)) {
            qf.close();
            qf.flush();
            Q_EMIT alert(tr("File(s) touched on device"));
        }
        else {
            Q_EMIT alert(tr("Unable to open file(s) from device"));
        }
}

bool Utils::pathExists(const QString &path) const {
    QDir dir(path);
    return dir.exists();
}

bool Utils::fileExists(const QString &file) const {
    return (QFile::exists(file));
}
