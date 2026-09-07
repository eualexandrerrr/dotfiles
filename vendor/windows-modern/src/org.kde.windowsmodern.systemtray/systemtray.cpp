/*
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include <optional>

#include "debug.h"
#include "systemtray.h"

#include "plasmoidregistry.h"
#include "sortedsystemtraymodel.h"
#include "statusnotifieritemhost.h"
#include "statusnotifieritemsource.h"
#include "systemtraymodel.h"
#include "systemtraysettings.h"

#include <QGuiApplication>
#include <QMenu>
#include <QMetaMethod>
#include <QMetaObject>
#include <QQueue>
#include <QQuickItem>
#include <QQuickWindow>
#include <QScreen>
#include <QTimer>

#include <Plasma/Applet>
#include <Plasma/Corona>
#include <Plasma/PluginLoader>

#include <KAcceleratorManager>
#include <KActionCollection>
#include <KSharedConfig>
#include <KWindowSystem>

using namespace Qt::StringLiterals;

SystemTray::SystemTray(QObject *parent, const KPluginMetaData &data, const QVariantList &args)
    : Plasma::Containment(parent, data, args)
{
    setHasConfigurationInterface(true);
    setContainmentDisplayHints(Plasma::Types::ContainmentDrawsPlasmoidHeading | Plasma::Types::ContainmentForcesSquarePlasmoids);
}

SystemTray::~SystemTray()
{
    delete m_settings;
}

void SystemTray::init()
{
    migrateFromSystrayContainer();

    Containment::init();

    initSettingsAndRegistry();

    connect(this, &Containment::appletAdded, this, [this](Plasma::Applet *applet) {
        disconnect(applet, &Applet::activated, this, &Applet::activated);
    });

    if (KWindowSystem::isPlatformWayland()) {
        auto config = KSharedConfig::openConfig(QStringLiteral("kdeglobals"), KConfig::NoGlobals);
        KConfigGroup kscreenGroup = config->group(QStringLiteral("KScreen"));
        m_xwaylandClientsScale = kscreenGroup.readEntry("XwaylandClientsScale", true);

        m_configWatcher = KConfigWatcher::create(config);
        connect(m_configWatcher.data(), &KConfigWatcher::configChanged, this, [this](const KConfigGroup &group, const QByteArrayList &names) {
            if (group.name() == u"KScreen" && names.contains(QByteArrayLiteral("XwaylandClientsScale"))) {
                m_xwaylandClientsScale = group.readEntry("XwaylandClientsScale", true);
            }
        });
    }
}

void SystemTray::initSettingsAndRegistry()
{
    if (!m_settings) {
        m_settings = new SystemTraySettings(configScheme(), this);
        connect(m_settings, &SystemTraySettings::enabledPluginsChanged, this, &SystemTray::onEnabledAppletsChanged);
    }

    if (!m_plasmoidRegistry) {
        m_plasmoidRegistry = new PlasmoidRegistry(m_settings, this);
        connect(m_plasmoidRegistry, &PlasmoidRegistry::plasmoidEnabled, this, &SystemTray::startApplet);
        connect(m_plasmoidRegistry, &PlasmoidRegistry::plasmoidStopped, this, &SystemTray::stopApplet);
    }
}

void SystemTray::migrateFromSystrayContainer()
{
    KConfigGroup rootCg(corona()->config(), QStringLiteral("Containments"));
    KConfigGroup ownCg = KConfigGroup(config());
    KConfigGroup oldAppletCg(&ownCg, QStringLiteral("Configuration"));
    const uint oldSystrayId = oldAppletCg.readEntry(QStringLiteral("SystrayContainmentId"), 0);

    if (oldSystrayId == 0) {
        return;
    }

    KConfigGroup oldContCg = KConfigGroup(&rootCg, QString::number(oldSystrayId));

    QQueue<QPair<KConfigGroup, KConfigGroup>> queue;
    queue.enqueue(qMakePair(oldContCg, ownCg));
    while (!queue.isEmpty()) {
        QPair<KConfigGroup, KConfigGroup> current = queue.dequeue();
        const KConfigGroup &currentSource = current.first;
        KConfigGroup &currentDest = current.second;

        const QMap<QString, QString> entries = currentSource.entryMap();
        for (auto it = entries.constBegin(); it != entries.constEnd(); ++it) {
            currentDest.writeEntry(it.key(), currentSource.readEntry(it.key(), QString()));
        }

        const QStringList groups = currentSource.groupList();
        for (const QString &group : groups) {
            KConfigGroup sourceSubGroup = currentSource.group(group);
            KConfigGroup destSubGroup = currentDest.group(group);
            queue.enqueue(qMakePair(sourceSubGroup, destSubGroup));
        }
    }

    for (Plasma::Containment *cont : corona()->containments()) {
        if (cont->id() == oldSystrayId) {
            delete cont;
            break;
        }
    }
    rootCg.deleteGroup(QString::number(oldSystrayId));

    oldAppletCg.deleteEntry(QStringLiteral("SystrayContainmentId"));

    for (Applet *a : applets()) {
        a->configChanged();
    }
}

void SystemTray::restoreContents(KConfigGroup &group)
{
    if (!isContainment()) {
        qCWarning(SYSTEM_TRAY) << "Loaded as an applet, this shouldn't have happened";
        return;
    }

    KConfigGroup shortcutConfig(&group, u"Shortcuts"_s);
    QString shortcutText = shortcutConfig.readEntryUntranslated("global", QString());
    if (!shortcutText.isEmpty()) {
        setGlobalShortcut(QKeySequence(shortcutText));
    }

    KConfigGroup cg = group.group(u"Applets"_s);
    for (const QString &group : cg.groupList()) {
        KConfigGroup appletConfig(&cg, group);
        QString plugin = appletConfig.readEntry("plugin");
        if (!plugin.isEmpty()) {
            m_configGroupIds[plugin] = group.toInt();
        }
    }

    initSettingsAndRegistry();
    m_plasmoidRegistry->init();
}

void SystemTray::showPlasmoidMenu(QQuickItem *appletInterface, int x, int y)
{
    if (!appletInterface) {
        return;
    }

    auto *applet = appletInterface->property("_plasma_applet").value<Plasma::Applet *>();

    QPointF pos = appletInterface->mapToScene(QPointF(x, y));

    if (appletInterface->window() && appletInterface->window()->screen()) {
        pos = appletInterface->window()->mapToGlobal(pos.toPoint());
    } else {
        pos = QPoint();
    }

    auto *desktopMenu = new QMenu;
    desktopMenu->setAttribute(Qt::WA_TranslucentBackground);
    connect(this, &QObject::destroyed, desktopMenu, &QMenu::close);
    desktopMenu->setAttribute(Qt::WA_DeleteOnClose);

    auto ungrabMouseHack = [appletInterface]() {
        if (appletInterface->window() && appletInterface->window()->mouseGrabberItem()) {
            appletInterface->window()->mouseGrabberItem()->ungrabMouse();
        }
    };

    QTimer::singleShot(0, appletInterface, ungrabMouseHack);

    Q_EMIT applet->contextualActionsAboutToShow();
    const auto contextActions = applet->contextualActions();
    for (QAction *action : contextActions) {
        if (action) {
            desktopMenu->addAction(action);
        }
    }

    if (applet->internalAction(QStringLiteral("configure"))) {
        desktopMenu->addAction(applet->internalAction(QStringLiteral("configure")));
    }

    if (desktopMenu->isEmpty()) {
        delete desktopMenu;
        return;
    }

    KAcceleratorManager::manage(desktopMenu);

    desktopMenu->winId();
    desktopMenu->windowHandle()->setTransientParent(appletInterface->window());
    desktopMenu->popup(pos.toPoint());
}

QPointF SystemTray::popupPosition(QQuickItem *visualParent, int x, int y)
{
    if (!visualParent) {
        return {0, 0};
    }

    QPointF pos = visualParent->mapToScene(QPointF(x, y));

    QQuickWindow *const window = visualParent->window();
    if (window && window->screen()) {
        pos = window->mapToGlobal(pos.toPoint());
    }

    return pos;
}

bool SystemTray::isSystemTrayApplet(const QString &appletId)
{
    if (m_plasmoidRegistry) {
        return m_plasmoidRegistry->isSystemTrayApplet(appletId);
    }
    return false;
}

QQuickItem *SystemTray::appletForPluginId(const QString &pluginId)
{
    if (!m_plasmoidModel || pluginId.isEmpty()) {
        return nullptr;
    }
    const auto roles = m_plasmoidModel->roleNames();
    int itemIdRole = -1, appletRole = -1;
    for (auto it = roles.constBegin(); it != roles.constEnd(); ++it) {
        if (it.value() == QByteArrayLiteral("itemId")) {
            itemIdRole = it.key();
        } else if (it.value() == QByteArrayLiteral("applet")) {
            appletRole = it.key();
        }
    }
    if (itemIdRole < 0 || appletRole < 0) {
        return nullptr;
    }
    for (int i = 0; i < m_plasmoidModel->rowCount(); ++i) {
        const QModelIndex idx = m_plasmoidModel->index(i, 0);
        if (m_plasmoidModel->data(idx, itemIdRole).toString() == pluginId) {
            return m_plasmoidModel->data(idx, appletRole).value<QQuickItem *>();
        }
    }
    return nullptr;
}

SystemTrayModel *SystemTray::systemTrayModel()
{
    if (!m_systemTrayModel) {
        m_systemTrayModel = new SystemTrayModel(this);

        m_plasmoidModel = new PlasmoidModel(m_settings, m_plasmoidRegistry, m_systemTrayModel);
        connect(this, &SystemTray::appletAdded, m_plasmoidModel, &PlasmoidModel::addApplet);
        connect(this, &SystemTray::appletRemoved, m_plasmoidModel, &PlasmoidModel::removeApplet);
        for (auto applet : applets()) {
            m_plasmoidModel->addApplet(applet);
        }

        m_statusNotifierModel = new StatusNotifierModel(m_settings, m_systemTrayModel);

        m_systemTrayModel->addSourceModel(m_plasmoidModel);
        m_systemTrayModel->addSourceModel(m_statusNotifierModel);
        m_systemTrayModel->addSourceModel(new BackgroundAppsFilteredModel(new BackgroundAppsModel(m_settings, m_systemTrayModel), m_systemTrayModel));
    }

    return m_systemTrayModel;
}

QAbstractItemModel *SystemTray::sortedSystemTrayModel()
{
    if (!m_sortedSystemTrayModel) {
        m_sortedSystemTrayModel = new SortedSystemTrayModel(SortedSystemTrayModel::SortingType::SystemTray, this);
        m_sortedSystemTrayModel->setSourceModel(systemTrayModel());
    }
    return m_sortedSystemTrayModel;
}

QAbstractItemModel *SystemTray::configSystemTrayModel()
{
    if (!m_configSystemTrayModel) {
        m_configSystemTrayModel = new SortedSystemTrayModel(SortedSystemTrayModel::SortingType::ConfigurationPage, this);
        m_configSystemTrayModel->setSourceModel(systemTrayModel());
    }
    return m_configSystemTrayModel;
}

void SystemTray::onEnabledAppletsChanged()
{
    const auto appletsList = applets();
    for (Plasma::Applet *applet : appletsList) {
        if (!applet->pluginMetaData().isValid()) {
            applet->config().parent().deleteGroup();
            delete applet;
        } else {
            const QString task = applet->pluginMetaData().pluginId();
            if (!m_settings->isEnabledPlugin(task)) {
                applet->config().parent().deleteGroup();
                delete applet;
                m_configGroupIds.remove(task);
            }
        }
    }
}

void SystemTray::startApplet(const QString &pluginId)
{
    const auto appletsList = applets();
    for (Plasma::Applet *applet : appletsList) {
        if (!applet->pluginMetaData().isValid()) {
            continue;
        }

        if (pluginId == applet->pluginMetaData().pluginId()) {
            if (!applet->destroyed()) {
                return;
            }
        }
    }

    qCDebug(SYSTEM_TRAY) << "Adding applet:" << pluginId;

    if (m_configGroupIds.contains(pluginId)) {
        Applet *applet = Plasma::PluginLoader::self()->loadApplet(pluginId, m_configGroupIds.value(pluginId), QVariantList());
        if (!applet) {
            qCWarning(SYSTEM_TRAY) << "Unable to find applet" << pluginId;
            return;
        }
        applet->setProperty("org.kde.plasma:force-create", true);
        addApplet(applet);
    } else {
        Applet *applet = createApplet(pluginId, QVariantList() << u"org.kde.plasma:force-create"_s);
        if (applet) {
            m_configGroupIds[pluginId] = applet->id();
        }
    }
}

void SystemTray::stopApplet(const QString &pluginId)
{
    const auto appletsList = applets();
    for (Plasma::Applet *applet : appletsList) {
        if (applet->pluginMetaData().isValid() && pluginId == applet->pluginMetaData().pluginId()) {
            delete applet;
        }
    }
}

void SystemTray::stackItemBefore(QQuickItem *newItem, QQuickItem *beforeItem)
{
    if (!newItem || !beforeItem) {
        return;
    }
    newItem->stackBefore(beforeItem);
}

void SystemTray::stackItemAfter(QQuickItem *newItem, QQuickItem *afterItem)
{
    if (!newItem || !afterItem) {
        return;
    }
    newItem->stackAfter(afterItem);
}

void SystemTray::activate(const QString &service, QPoint pos, QQuickItem *statusNotifierIcon)
{
    const auto source = StatusNotifierItemHost::self()->itemForService(service);

    if (!source) {
        qCWarning(SYSTEM_TRAY) << "activate: Could not find item for service" << service;
        return;
    }

    connect(
        source,
        &StatusNotifierItemSource::activateResult,
        this,
        [this, service, pos, statusNotifierIcon](bool res) {
            if (!res) {
                openContextMenu(service, pos, statusNotifierIcon);
            }
        },
        Qt::SingleShotConnection);

    source->activate(pos.x(), pos.y());
}

void SystemTray::secondaryActivate(const QString &service, QPoint pos)
{
    const auto source = StatusNotifierItemHost::self()->itemForService(service);

    if (!source) {
        qCWarning(SYSTEM_TRAY) << "secondaryActivate: Could not find item for service" << service;
        return;
    }

    source->secondaryActivate(pos.x(), pos.y());
}

void SystemTray::openContextMenu(const QString &service, QPoint pos, QQuickItem *statusNotifierIcon)
{
    const auto source = StatusNotifierItemHost::self()->itemForService(service);

    if (!source) {
        qCWarning(SYSTEM_TRAY) << "openContextMenu: Could not find item for service" << service;
        return;
    }

    connect(
        source,
        &StatusNotifierItemSource::contextMenuReady,
        this,
        [this, statusNotifierIcon, pos](QMenu *menu) {
            if (menu && !menu->isEmpty()) {
                KAcceleratorManager::manage(menu);

                menu->winId();
                menu->windowHandle()->setTransientParent(statusNotifierIcon->window());
                menu->popup(pos);

                if (auto item = statusNotifierIcon->window()->mouseGrabberItem()) {
                    item->ungrabMouse();
                }
            }
        },
        Qt::SingleShotConnection);

    source->contextMenu(pos.x(), pos.y());
}

void SystemTray::scroll(const QString &service, int delta, const QString &direction)
{
    const auto source = StatusNotifierItemHost::self()->itemForService(service);

    if (!source) {
        qCWarning(SYSTEM_TRAY) << "scroll: Could not find item for service" << service;
        return;
    }

    source->scroll(delta, direction);
}

K_PLUGIN_CLASS_WITH_JSON(SystemTray, "metadata.json")

#include "systemtray.moc"

#include "moc_systemtray.cpp"
