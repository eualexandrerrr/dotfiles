/*
    SPDX-FileCopyrightText: 2009 Marco Martin <notmart@gmail.com>
    SPDX-FileCopyrightText: 2009 Matthieu Gallien <matthieu_gallien@yahoo.fr>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "statusnotifieritemsource.h"
#include "systemtraytypes.h"

#include "debug.h"

#include <KIconColors>
#include <KIconEngine>
#include <KIconLoader>
#include <KWindowSystem>

#include <QApplication>
#include <QDBusConnectionInterface>
#include <QDBusMessage>
#include <QDBusPendingCall>
#include <QDBusPendingReply>
#include <QDBusReply>
#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QIcon>
#include <QImage>
#include <QSettings>
#include <QPainter>
#include <QPixmap>
#include <QSysInfo>
#include <QVariantMap>

#include <netinet/in.h>

#include <dbusmenuimporter.h>

using namespace Qt::StringLiterals;

class PlasmaDBusMenuImporter : public DBusMenuImporter
{
public:
    PlasmaDBusMenuImporter(const QString &service, const QString &path, KIconLoader *iconLoader, StatusNotifierItemSource *source)
        : DBusMenuImporter(service, path, nullptr)
        , m_iconLoader(iconLoader)
        , m_source(source)
    {
    }

protected:
    QIcon iconForName(const QString &name) override
    {
        return QIcon(new KIconEngine(name, m_iconLoader));
    }

    void actionActivated(int id) override
    {
        if (KWindowSystem::isPlatformX11() || !menu()->window() || !menu()->window()->windowHandle()) {
            sendClickedEvent(id);
            return;
        }
        // In standalone build without KWaylandExtras, we just send the event
        sendClickedEvent(id);
    }

private:
    KIconLoader *m_iconLoader;
    StatusNotifierItemSource *const m_source;
};

StatusNotifierItemSource::StatusNotifierItemSource(const QString &notifierItemId, QObject *parent)
    : QObject(parent)
    , m_customIconLoader(nullptr)
    , m_refreshing(false)
    , m_needsReRefreshing(false)
    , m_processNameResolved(false)
{
    setObjectName(notifierItemId);
    qDBusRegisterMetaType<KDbusImageStruct>();
    qDBusRegisterMetaType<KDbusImageVector>();
    qDBusRegisterMetaType<KDbusToolTipStruct>();

    m_servicename = notifierItemId;

    int slash = notifierItemId.indexOf(u'/');
    if (slash == -1) {
        qCWarning(SYSTEM_TRAY) << "Invalid notifierItemId:" << notifierItemId;
        m_valid = false;
        return;
    }
    QString service = notifierItemId.left(slash);
    QString path = notifierItemId.mid(slash);

    m_statusNotifierItemInterface = std::make_unique<org::kde::StatusNotifierItem>(service, path, QDBusConnection::sessionBus(), this);

    m_refreshTimer.setSingleShot(true);
    m_refreshTimer.setInterval(10);
    connect(&m_refreshTimer, &QTimer::timeout, this, &StatusNotifierItemSource::performRefresh);

    m_valid = !service.isEmpty() && m_statusNotifierItemInterface->isValid();
    if (m_valid) {
        connect(m_statusNotifierItemInterface.get(), &OrgKdeStatusNotifierItem::NewTitle, this, &StatusNotifierItemSource::refresh);
        connect(m_statusNotifierItemInterface.get(), &OrgKdeStatusNotifierItem::NewIcon, this, &StatusNotifierItemSource::refresh);
        connect(m_statusNotifierItemInterface.get(), &OrgKdeStatusNotifierItem::NewAttentionIcon, this, &StatusNotifierItemSource::refresh);
        connect(m_statusNotifierItemInterface.get(), &OrgKdeStatusNotifierItem::NewOverlayIcon, this, &StatusNotifierItemSource::refresh);
        connect(m_statusNotifierItemInterface.get(), &OrgKdeStatusNotifierItem::NewToolTip, this, &StatusNotifierItemSource::refresh);
        connect(m_statusNotifierItemInterface.get(), &OrgKdeStatusNotifierItem::NewStatus, this, &StatusNotifierItemSource::syncStatus);
        connect(m_statusNotifierItemInterface.get(), &OrgKdeStatusNotifierItem::NewMenu, this, &StatusNotifierItemSource::refreshMenu);
        refresh();
    }

    auto pid = QDBusConnection::sessionBus().interface()->servicePid(service);
    if (pid.isValid()) {
        const QString flatpakInfoPath = u"/proc/"_s + QString::number(pid.value()) + u"/root/.flatpak-info"_s;
        const QSettings flatpakInfo(flatpakInfoPath, QSettings::IniFormat);
        const auto instance = flatpakInfo.value(u"Instance/instance-id"_s).toString();
        m_flatpakInstance = instance;
        if (!instance.isEmpty()) {
            qCDebug(SYSTEM_TRAY) << "StatusNotifierItem" << notifierItemId << "is a flatpak" << instance;
        }
    }
}

StatusNotifierItemSource::~StatusNotifierItemSource()
{
}

KIconLoader *StatusNotifierItemSource::iconLoader() const
{
    return m_customIconLoader ? m_customIconLoader : KIconLoader::global();
}

QIcon StatusNotifierItemSource::attentionIcon() const
{
    return m_attentionIcon;
}

QString StatusNotifierItemSource::attentionIconName() const
{
    return m_attentionIconName;
}

QString StatusNotifierItemSource::attentionMovieName() const
{
    return m_attentionMovieName;
}

QString StatusNotifierItemSource::category() const
{
    return m_category;
}

QIcon StatusNotifierItemSource::icon() const
{
    return m_icon;
}

QString StatusNotifierItemSource::iconName() const
{
    return m_iconName;
}

QString StatusNotifierItemSource::iconThemePath() const
{
    return m_iconThemePath;
}

QString StatusNotifierItemSource::id() const
{
    return m_id;
}

QString StatusNotifierItemSource::processName()
{
    if (!m_processNameResolved) {
        resolveProcessName();
    }
    return m_processName;
}

void StatusNotifierItemSource::resolveProcessName()
{
    m_processNameResolved = true;

    int slash = m_servicename.indexOf(u'/');
    if (slash == -1) {
        return;
    }
    const QString service = m_servicename.left(slash);

    const QDBusReply<uint> pidReply = QDBusConnection::sessionBus().interface()->servicePid(service);
    if (!pidReply.isValid()) {
        return;
    }

    const uint pid = pidReply.value();
    const QString procBase = QStringLiteral("/proc/%1/").arg(pid);

    QFile cmdlineFile(procBase + QStringLiteral("cmdline"));
    if (cmdlineFile.open(QIODevice::ReadOnly)) {
        const QByteArray cmdlineData = cmdlineFile.readAll();
        const QList<QByteArray> args = cmdlineData.split('\0');
        const auto it = std::find_if(args.cbegin(), args.cend(), [](const QByteArray &arg) {
            return arg.endsWith(".asar");
        });
        if (it != args.cend()) {
            const QFileInfo asarInfo(QString::fromUtf8(*it));
            m_processName = QFileInfo(asarInfo.path()).fileName();
            return;
        }
    }

    QFile commFile(procBase + QStringLiteral("comm"));
    if (commFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        m_processName = QString::fromUtf8(commFile.readAll()).trimmed();
    }
}

bool StatusNotifierItemSource::itemIsMenu() const
{
    return m_itemIsMenu;
}

QString StatusNotifierItemSource::overlayIconName() const
{
    return m_overlayIconName;
}

QString StatusNotifierItemSource::status() const
{
    return m_status;
}

QString StatusNotifierItemSource::title() const
{
    return m_title;
}

QString StatusNotifierItemSource::toolTipSubTitle() const
{
    return m_toolTipSubTitle;
}

QString StatusNotifierItemSource::toolTipTitle() const
{
    return m_toolTipTitle;
}

QString StatusNotifierItemSource::windowId() const
{
    return m_windowId;
}

void StatusNotifierItemSource::syncStatus(const QString &status)
{
    m_status = status;
    Q_EMIT dataUpdated();
}

void StatusNotifierItemSource::refreshMenu()
{
    m_menuImporter.reset();
    refresh();
}

void StatusNotifierItemSource::refresh()
{
    if (!m_refreshTimer.isActive()) {
        m_refreshTimer.start();
    }
}

void StatusNotifierItemSource::performRefresh()
{
    if (m_refreshing) {
        m_needsReRefreshing = true;
        return;
    }

    m_refreshing = true;
    QDBusMessage message = QDBusMessage::createMethodCall(m_statusNotifierItemInterface->service(),
                                                          m_statusNotifierItemInterface->path(),
                                                          QStringLiteral("org.freedesktop.DBus.Properties"),
                                                          QStringLiteral("GetAll"));

    message << m_statusNotifierItemInterface->interface();
    QDBusPendingCall call = m_statusNotifierItemInterface->connection().asyncCall(message);
    auto *watcher = new QDBusPendingCallWatcher(call, this);
    connect(watcher, &QDBusPendingCallWatcher::finished, this, &StatusNotifierItemSource::refreshCallback);
}

void StatusNotifierItemSource::refreshCallback(QDBusPendingCallWatcher *call)
{
    m_refreshing = false;
    if (m_needsReRefreshing) {
        m_needsReRefreshing = false;
        performRefresh();
        call->deleteLater();
        return;
    }

    QDBusPendingReply<QVariantMap> reply = *call;
    if (reply.isError()) {
        m_valid = false;
    } else {
        QVariantMap properties = reply.argumentAt<0>();
        QString path = properties[QStringLiteral("IconThemePath")].toString();

        if (!path.isEmpty() && path != m_iconThemePath) {
            if (!m_customIconLoader) {
                m_customIconLoader = new KIconLoader(QString(), QStringList(), this);
            }
            QString appName;
            auto tokens = QStringView(path).split(u'/', Qt::SkipEmptyParts);
            if (tokens.length() >= 3 && tokens.takeLast() == QLatin1String("icons"))
                appName = tokens.takeLast().toString();

            m_customIconLoader->reconfigure(appName, QStringList(path));
            m_customIconLoader->addAppDir(appName.size() ? appName : QStringLiteral("unused"), path);

            connect(m_customIconLoader, &KIconLoader::iconChanged, this, [=, this] {
                m_customIconLoader->reconfigure(appName, QStringList(path));
                m_customIconLoader->addAppDir(appName.size() ? appName : QStringLiteral("unused"), path);
            });
        }
        m_iconThemePath = path;

        m_category = properties[QStringLiteral("Category")].toString();
        m_status = properties[QStringLiteral("Status")].toString();
        m_title = properties[QStringLiteral("Title")].toString();
        m_id = properties[QStringLiteral("Id")].toString();
        m_windowId = properties[QStringLiteral("WindowId")].toString();
        m_itemIsMenu = properties[QStringLiteral("ItemIsMenu")].toBool();

        m_attentionMovieName = properties[QStringLiteral("AttentionMovieName")].toString();

        QIcon overlay;

        {
            m_overlayIconName = QString();

            const QString iconName = properties[QStringLiteral("OverlayIconName")].toString();
            if (!iconName.isEmpty()) {
                overlay = QIcon(new KIconEngine(iconName, KIconColors(QPalette()), iconLoader()));
                if (!overlay.isNull()) {
                    m_overlayIconName = iconName;
                }
            }
            if (overlay.isNull()) {
                KDbusImageVector image;
                properties[QStringLiteral("OverlayIconPixmap")].value<QDBusArgument>() >> image;
                if (!image.isEmpty()) {
                    overlay = imageVectorToPixmap(image);
                }
            }
        }

        auto loadIcon = [this, &properties, &overlay](const QString &iconKey, const QString &pixmapKey) -> std::tuple<QIcon, QString> {
            if (QString iconName = properties[iconKey].toString(); !iconName.isEmpty()) {
                QIcon icon = QIcon(new KIconEngine(iconName, KIconColors(QPalette()), iconLoader(), {m_overlayIconName}));
                if (!icon.isNull()) {
                    if (!overlay.isNull() && m_overlayIconName.isEmpty()) {
                        overlayIcon(&icon, &overlay);
                    }
                    return {icon, iconName};
                }
            }
            KDbusImageVector image;
            properties[pixmapKey].value<QDBusArgument>() >> image;
            if (!image.isEmpty()) {
                QIcon icon = imageVectorToPixmap(image);
                if (!icon.isNull() && !overlay.isNull()) {
                    overlayIcon(&icon, &overlay);
                }
                return {icon, QString()};
            }
            return {};
        };

        std::tie(m_icon, m_iconName) = loadIcon(QStringLiteral("IconName"), QStringLiteral("IconPixmap"));
        std::tie(m_attentionIcon, m_attentionIconName) = loadIcon(QStringLiteral("AttentionIconName"), QStringLiteral("AttentionIconPixmap"));

        {
            KDbusToolTipStruct toolTip;
            properties[QStringLiteral("ToolTip")].value<QDBusArgument>() >> toolTip;
            if (toolTip.title.isEmpty()) {
                m_toolTipTitle = QString();
                m_toolTipSubTitle = QString();
            } else {
                m_toolTipTitle = toolTip.title;
                m_toolTipSubTitle = toolTip.subTitle;
            }

            if (m_title.isEmpty() && !m_toolTipTitle.isEmpty()) {
                m_title = m_toolTipTitle;
            }
        }

        if (qobject_cast<QApplication *>(QCoreApplication::instance()) && !m_menuImporter) {
            QString menuObjectPath = properties[QStringLiteral("Menu")].value<QDBusObjectPath>().path();
            if (!menuObjectPath.isEmpty()) {
                if (menuObjectPath == QLatin1String("/NO_DBUSMENU")) {
                    qCWarning(SYSTEM_TRAY) << "DBusMenu disabled for this application";
                } else {
                    m_menuImporter = std::make_unique<PlasmaDBusMenuImporter>(m_statusNotifierItemInterface->service(), menuObjectPath, iconLoader(), this);
                    connect(m_menuImporter.get(), &PlasmaDBusMenuImporter::menuUpdated, this, [this](QMenu *menu) {
                        if (menu == m_menuImporter->menu()) {
                            Q_EMIT contextMenuReady(m_menuImporter->menu());
                        }
                    });
                }
            }
        }
    }

    Q_EMIT dataUpdated();
    call->deleteLater();
}

void StatusNotifierItemSource::reloadIcon()
{
    if (!m_iconName.isEmpty()) {
        m_icon = QIcon(new KIconEngine(m_iconName, KIconColors(QPalette()), iconLoader(), {m_overlayIconName}));
    }

    if (!m_attentionIconName.isEmpty()) {
        m_attentionIcon = QIcon(new KIconEngine(m_attentionIconName, KIconColors(QPalette()), iconLoader(), {m_overlayIconName}));
    }

    Q_EMIT dataUpdated();
}

QPixmap StatusNotifierItemSource::KDbusImageStructToPixmap(const KDbusImageStruct &image) const
{
    if (QSysInfo::ByteOrder == QSysInfo::LittleEndian) {
        uint *uintBuf = (uint *)image.data.data();
        for (uint i = 0; i < image.data.size() / sizeof(uint); ++i) {
            *uintBuf = ntohl(*uintBuf);
            ++uintBuf;
        }
    }
    if (image.width == 0 || image.height == 0) {
        return {};
    }

    auto dataRef = new QByteArray(image.data);

    QImage iconImage(
        reinterpret_cast<const uchar *>(dataRef->data()),
        image.width,
        image.height,
        QImage::Format_ARGB32,
        [](void *ptr) {
            delete static_cast<QByteArray *>(ptr);
        },
        dataRef);
    return QPixmap::fromImage(std::move(iconImage));
}

QIcon StatusNotifierItemSource::imageVectorToPixmap(const KDbusImageVector &vector) const
{
    QIcon icon;

    for (int i = 0; i < vector.size(); ++i) {
        icon.addPixmap(KDbusImageStructToPixmap(vector[i]));
    }

    return icon;
}

void StatusNotifierItemSource::overlayIcon(QIcon *icon, QIcon *overlay)
{
    QIcon tmp;
    QPixmap m_iconPixmap = icon->pixmap(KIconLoader::SizeSmall, KIconLoader::SizeSmall);

    QPainter p(&m_iconPixmap);

    const int size = KIconLoader::SizeSmall / 2;
    p.drawPixmap(QRect(size, size, size, size), overlay->pixmap(size, size), QRect(0, 0, size, size));
    p.end();
    tmp.addPixmap(m_iconPixmap);

    m_iconPixmap = icon->pixmap(KIconLoader::SizeSmallMedium, KIconLoader::SizeSmallMedium);
    if (m_iconPixmap.width() == KIconLoader::SizeSmallMedium) {
        const int size = KIconLoader::SizeSmall / 2;
        QPainter p(&m_iconPixmap);
        p.drawPixmap(QRect(m_iconPixmap.width() - size, m_iconPixmap.height() - size, size, size), overlay->pixmap(size, size), QRect(0, 0, size, size));
        p.end();
        tmp.addPixmap(m_iconPixmap);
    }

    *icon = tmp;
}

void StatusNotifierItemSource::activate(int x, int y)
{
    if (m_statusNotifierItemInterface && m_statusNotifierItemInterface->isValid()) {
        QDBusMessage message = QDBusMessage::createMethodCall(m_statusNotifierItemInterface->service(),
                                                              m_statusNotifierItemInterface->path(),
                                                              m_statusNotifierItemInterface->interface(),
                                                              QStringLiteral("Activate"));

        message << x << y;
        QDBusPendingCall call = m_statusNotifierItemInterface->connection().asyncCall(message);
        auto *watcher = new QDBusPendingCallWatcher(call, this);
        connect(watcher, &QDBusPendingCallWatcher::finished, this, &StatusNotifierItemSource::activateCallback);
    }
}

void StatusNotifierItemSource::activateCallback(QDBusPendingCallWatcher *call)
{
    QDBusPendingReply<void> reply = *call;
    Q_EMIT activateResult(!reply.isError());
    call->deleteLater();
}

void StatusNotifierItemSource::secondaryActivate(int x, int y)
{
    if (m_statusNotifierItemInterface && m_statusNotifierItemInterface->isValid()) {
        m_statusNotifierItemInterface->call(QDBus::NoBlock, QStringLiteral("SecondaryActivate"), x, y);
    }
}

void StatusNotifierItemSource::scroll(int delta, const QString &direction)
{
    if (m_statusNotifierItemInterface && m_statusNotifierItemInterface->isValid()) {
        m_statusNotifierItemInterface->call(QDBus::NoBlock, QStringLiteral("Scroll"), delta, direction);
    }
}

void StatusNotifierItemSource::contextMenu(int x, int y)
{
    if (m_menuImporter) {
        m_menuImporter->updateMenu();
    } else {
        qCWarning(SYSTEM_TRAY) << "Could not find DBusMenu interface, falling back to calling ContextMenu()";
        if (m_statusNotifierItemInterface && m_statusNotifierItemInterface->isValid()) {
            m_statusNotifierItemInterface->call(QDBus::NoBlock, QStringLiteral("ContextMenu"), x, y);
        }
    }
}

void StatusNotifierItemSource::provideXdgActivationToken(const QString &token)
{
    if (m_statusNotifierItemInterface && m_statusNotifierItemInterface->isValid()) {
        m_statusNotifierItemInterface->ProvideXdgActivationToken(token);
    }
}

QString StatusNotifierItemSource::flatpakInstance() const
{
    return m_flatpakInstance;
}

#include "moc_statusnotifieritemsource.cpp"
