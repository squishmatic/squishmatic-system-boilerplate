#!/bin/sh
#
#  Copyright (C) Squishmatic project team <project@squishmatic.com>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, see <http://www.gnu.org/licenses>.
#

_RELOAD=0
_HARD=0
_VERBOSE=0
_PRINT_HELP=0

for _SRG in "$@"
do
    case "$_SRG" in
        -r|--reload)
            _RELOAD=1
            ;;
        -H|--hard)
            _HARD=1
            ;;
        -V|--verbose)
            _VERBOSE=1
            ;;
        -h|--help)
            _PRINT_HELP=1
            ;;
    esac
done

if [[ _PRINT_HELP -eq 1 ]]; then
    printf '\t%s\n' ""
    printf '\t%s\n\n' "(Re)configure to default settings"
    printf '\t%s\n\n' "Usage: reconfigure.sh [-R|--reload] [-H|--hard] [-V|--verbose] [-h|--help]"
    printf '\t\t%s\n' "-r, --reload       Try to reload default settings."
    printf '\t\t%s\n' "-H, --hard         Remove user personalizations."
    printf '\t\t%s\n' "-V, --verbose      Output more information."
    printf '\t\t%s\n' "-h, --help         Display this help and exit."
    printf '\t%s\n' ""

    exit 0
fi


# backup current xconf configuration files
if [[ _VERBOSE -eq 1 ]]; then
    echo -e 'backup current configuration files.\n'
fi
sudo cp /etc/xdg/xfce4/panel/default.xml /etc/xdg/xfce4/panel/default.bak.xml
sudo cp /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.bak.xml
sudo cp /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.bak.xml


# symbolic link default configuration files
if [[ _VERBOSE -eq 1 ]]; then
    echo -e 'symbolic link default configuration files.\n'
fi
sudo ln -s /usr/share/squishmatic/xfce-perchannel-xml/panel/xfce4-panel.xml /etc/xdg/xfce4/panel/default.xml
sudo ln -s /usr/share/squishmatic/xfce-perchannel-xml/xfconf/xfce4-session.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml
sudo ln -s /usr/share/squishmatic/xfce-perchannel-xml/xfconf/xsettings.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml


# reset user personalizations
if [[ _HARD -eq 1 ]]; then
    if [[ _VERBOSE -eq 1 ]]; then
        echo -e '\nreset user personalizations.\n'
    fi

    # backup
    if [[ _VERBOSE -eq 1 ]]; then
        echo -e 'backup user personalizations.\n'
    fi
    cp $HOME/.config/xfce4/xfce-perchannel-xml/squishmatic_xfce4-panel.xml $HOME/.config/xfce4/xfce-perchannel-xml/squishmatic_xfce4-panel.bak.xml
    cp $HOME/.config/xfce4/xfce-perchannel-xml/xfce4-session.xml $HOME/.config/xfce4/xfce-perchannel-xml/xfce4-session.bak.xml
    cp $HOME/.config/xfce4/xfce-perchannel-xml/xsettings.xml $HOME/.config/xfce4/xfce-perchannel-xml/xsettings.bak.xml

    # remove
    if [[ _VERBOSE -eq 1 ]]; then
        echo -e 'remove user personalizations.\n'
    fi
    rm $HOME/.config/xfce4/xfce-perchannel-xml/squishmatic_xfce4-panel.xml
    rm $HOME/.config/xfce4/xfce-perchannel-xml/xfce4-session.xml
    rm $HOME/.config/xfce4/xfce-perchannel-xml/xsettings.xml
fi


# try to reload configurations
if [[ _RELOAD -eq 1 ]]; then
    if [[ _VERBOSE -eq 1 ]]; then
        echo -e '\ntry to reload default configurations.\n'
    fi

    killall -HUP xfsettingsd
    xfsettingsd --no-daemon >/dev/null 2>&1
fi
