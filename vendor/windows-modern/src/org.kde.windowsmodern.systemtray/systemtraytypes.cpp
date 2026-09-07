/*
    SPDX-FileCopyrightText: 2009 Marco Martin <notmart@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "systemtraytypes.h"

#include <QDebug>

// Marshall the ImageStruct data into a D-BUS argument
const QDBusArgument &operator<<(QDBusArgument &argument, const KDbusImageStruct &icon)
{
    argument.beginStructure();
    argument << icon.width;
    argument << icon.height;
    argument << icon.data;
    argument.endStructure();
    return argument;
}

const QDBusArgument &operator>>(const QDBusArgument &argument, KDbusImageStruct &icon)
{
    qint32 width = 0;
    qint32 height = 0;
    QByteArray data;

    if (argument.currentType() == QDBusArgument::StructureType) {
        argument.beginStructure();
        argument >> width;
        argument >> height;
        argument >> data;
        argument.endStructure();
    }

    icon.width = width;
    icon.height = height;
    icon.data = data;

    return argument;
}

const QDBusArgument &operator<<(QDBusArgument &argument, const KDbusImageVector &iconVector)
{
    argument.beginArray(qMetaTypeId<KDbusImageStruct>());
    for (int i = 0; i < iconVector.size(); ++i) {
        argument << iconVector[i];
    }
    argument.endArray();
    return argument;
}

const QDBusArgument &operator>>(const QDBusArgument &argument, KDbusImageVector &iconVector)
{
    iconVector.clear();

    if (argument.currentType() == QDBusArgument::ArrayType) {
        argument.beginArray();

        while (!argument.atEnd()) {
            KDbusImageStruct element;
            argument >> element;
            iconVector.append(element);
        }

        argument.endArray();
    }

    return argument;
}

const QDBusArgument &operator<<(QDBusArgument &argument, const KDbusToolTipStruct &toolTip)
{
    argument.beginStructure();
    argument << toolTip.icon;
    argument << toolTip.image;
    argument << toolTip.title;
    argument << toolTip.subTitle;
    argument.endStructure();

    return argument;
}

const QDBusArgument &operator>>(const QDBusArgument &argument, KDbusToolTipStruct &toolTip)
{
    QString icon;
    KDbusImageVector image;
    QString title;
    QString subTitle;

    if (argument.currentType() == QDBusArgument::StructureType) {
        argument.beginStructure();
        argument >> icon;
        argument >> image;
        argument >> title;
        argument >> subTitle;
        argument.endStructure();
    }

    toolTip.icon = icon;
    toolTip.image = image;
    toolTip.title = title;
    toolTip.subTitle = subTitle;

    return argument;
}
