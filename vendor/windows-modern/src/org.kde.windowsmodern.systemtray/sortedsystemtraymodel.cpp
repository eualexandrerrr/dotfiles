/*
    SPDX-FileCopyrightText: 2019 Konrad Materka <materka@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/
#include "sortedsystemtraymodel.h"
#include "debug.h"
#include "systemtraymodel.h"
#include <QList>

static const QList<QString> s_categoryOrder = {
    QStringLiteral("UnknownCategory"),
    QStringLiteral("ApplicationStatus"),
    QStringLiteral("Communications"),
    QStringLiteral("SystemServices"),
    QStringLiteral("Hardware"),
};

SortedSystemTrayModel::SortedSystemTrayModel(SortingType sorting, QObject *parent)
    : QSortFilterProxyModel(parent), m_sorting(sorting) { setSortLocaleAware(true); sort(0); }

bool SortedSystemTrayModel::lessThan(const QModelIndex &left, const QModelIndex &right) const {
    switch (m_sorting) {
    case SortingType::ConfigurationPage: return lessThanConfigurationPage(left, right);
    case SortingType::SystemTray: return lessThanSystemTray(left, right);
    }
    return QSortFilterProxyModel::lessThan(left, right);
}

bool SortedSystemTrayModel::lessThanConfigurationPage(const QModelIndex &left, const QModelIndex &right) const {
    int cmp = compareCategoriesAlphabetically(left, right);
    return cmp == 0 ? QSortFilterProxyModel::lessThan(left, right) : cmp < 0;
}

bool SortedSystemTrayModel::lessThanSystemTray(const QModelIndex &left, const QModelIndex &right) const {
    QVariant lid = left.data(static_cast<int>(BaseModel::BaseRole::ItemId));
    QVariant rid = right.data(static_cast<int>(BaseModel::BaseRole::ItemId));
    if (rid.toString() == QLatin1String("org.kde.plasma.notifications")) return false;
    if (lid.toString() == QLatin1String("org.kde.plasma.notifications")) return true;
    int cmp = compareCategoriesOrderly(left, right);
    return cmp == 0 ? QSortFilterProxyModel::lessThan(left, right) : cmp < 0;
}

int SortedSystemTrayModel::compareCategoriesAlphabetically(const QModelIndex &left, const QModelIndex &right) const {
    QString lcat = left.data(static_cast<int>(BaseModel::BaseRole::Category)).toString();
    if (lcat.isEmpty()) lcat = QStringLiteral("UnknownCategory");
    QString rcat = right.data(static_cast<int>(BaseModel::BaseRole::Category)).toString();
    if (rcat.isEmpty()) rcat = QStringLiteral("UnknownCategory");
    return QString::localeAwareCompare(lcat, rcat);
}

int SortedSystemTrayModel::compareCategoriesOrderly(const QModelIndex &left, const QModelIndex &right) const {
    QString lcat = left.data(static_cast<int>(BaseModel::BaseRole::Category)).toString();
    if (lcat.isEmpty()) lcat = QStringLiteral("UnknownCategory");
    QString rcat = right.data(static_cast<int>(BaseModel::BaseRole::Category)).toString();
    if (rcat.isEmpty()) rcat = QStringLiteral("UnknownCategory");
    int li = s_categoryOrder.indexOf(lcat); if (li == -1) li = s_categoryOrder.indexOf(QStringLiteral("UnknownCategory"));
    int ri = s_categoryOrder.indexOf(rcat); if (ri == -1) ri = s_categoryOrder.indexOf(QStringLiteral("UnknownCategory"));
    return li - ri;
}

#include "moc_sortedsystemtraymodel.cpp"
