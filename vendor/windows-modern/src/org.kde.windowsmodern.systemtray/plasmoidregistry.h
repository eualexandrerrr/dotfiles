/*
    SPDX-FileCopyrightText: 2020 Konrad Materka <materka@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include <QMap>
#include <QObject>
#include <QPointer>

class DBusServiceObserver;
class KPluginMetaData;
class SystemTraySettings;

class PlasmoidRegistry : public QObject
{
    Q_OBJECT
public:
    explicit PlasmoidRegistry(QPointer<SystemTraySettings> settings, QObject *parent = nullptr);

    void init();

    virtual QMap<QString, KPluginMetaData> systemTrayApplets();
    bool isSystemTrayApplet(const QString &pluginId);

Q_SIGNALS:
    void pluginRegistered(const KPluginMetaData &pluginMetaData);
    void pluginUnregistered(const QString &pluginId);
    void plasmoidEnabled(const QString &pluginId);
    void plasmoidStopped(const QString &pluginId);
    void plasmoidDisabled(const QString &pluginId);

private Q_SLOTS:
    void onEnabledPluginsChanged(const QStringList &enabledPlugins, const QStringList &disabledPlugins);
    void packageInstalled(const QString &pluginId);
    void packageUninstalled(const QString &pluginId);

private:
    void registerPlugin(const KPluginMetaData &pluginMetaData);
    void unregisterPlugin(const QString &pluginId);
    void sanitizeSettings();

    QPointer<SystemTraySettings> m_settings;
    QPointer<DBusServiceObserver> m_dbusObserver;

    QMap<QString /*plugin id*/, KPluginMetaData> m_systrayApplets;
};
