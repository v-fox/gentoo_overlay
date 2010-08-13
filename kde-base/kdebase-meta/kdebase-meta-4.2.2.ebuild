# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/kdebase-meta/kdebase-meta-4.2.2.ebuild,v 1.1 2009/04/11 22:33:43 alexxy Exp $

EAPI="2"

inherit kde4-functions

DESCRIPTION="Merge this to pull in all kdebase-derived packages"
HOMEPAGE="http://www.kde.org/"

LICENSE="GPL-2"
SLOT="4.2"
KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc64 ~x86"
IUSE="semantic-desktop"

RDEPEND="
	!kde-base/kdebase-runtime-meta
	!kde-base/kdebase-workspace-meta
	>=kde-base/dolphin-${PV}
	>=kde-base/drkonqi-${PV}
	>=kde-base/kappfinder-${PV}
	>=kde-base/kcheckpass-${PV}
	>=kde-base/kcminit-${PV}
	>=kde-base/kcmshell-${PV}
	>=kde-base/kcontrol-${PV}
	>=kde-base/kde-menu-${PV}
	>=kde-base/kde-menu-icons-${PV}
	>=kde-base/kde-wallpapers-${PV}
	>=kde-base/kdebase-cursors-${PV}
	>=kde-base/kdebase-data-${PV}
	>=kde-base/kdebase-desktoptheme-${PV}
	>=kde-base/kdebase-kioslaves-${PV}
	>=kde-base/kdebase-startkde-${PV}
	>=kde-base/kdebugdialog-${PV}
	>=kde-base/kdedglobalaccel-${PV}
	>=kde-base/kdepasswd-${PV}
	>=kde-base/kdesu-${PV}
	>=kde-base/kdialog-${PV}
	>=kde-base/kdm-${PV}
	>=kde-base/keditbookmarks-${PV}
	>=kde-base/kephal-${PV}
	>=kde-base/kfile-${PV}
	>=kde-base/kfind-${PV}
	>=kde-base/khelpcenter-${PV}
	>=kde-base/khotkeys-${PV}
	>=kde-base/kiconfinder-${PV}
	>=kde-base/kinfocenter-${PV}
	>=kde-base/kioclient-${PV}
	>=kde-base/klipper-${PV}
	>=kde-base/kmenuedit-${PV}
	>=kde-base/kmimetypefinder-${PV}
	>=kde-base/knetattach-${PV}
	>=kde-base/knewstuff-${PV}
	>=kde-base/konqueror-${PV}
	>=kde-base/konsole-${PV}
	>=kde-base/kpasswdserver-${PV}
	>=kde-base/kquitapp-${PV}
	>=kde-base/kscreensaver-${PV}
	>=kde-base/ksmserver-${PV}
	>=kde-base/ksplash-${PV}
	>=kde-base/kstart-${PV}
	>=kde-base/kstartupconfig-${PV}
	>=kde-base/kstyles-${PV}
	>=kde-base/ksysguard-${PV}
	>=kde-base/ksystraycmd-${PV}
	>=kde-base/ktimezoned-${PV}
	>=kde-base/ktraderclient-${PV}
	>=kde-base/kuiserver-${PV}
	>=kde-base/kurifilter-plugins-${PV}
	>=kde-base/kwalletd-${PV}
	>=kde-base/kwin-${PV}
	>=kde-base/kwrite-${PV}
	>=kde-base/kwrited-${PV}
	>=kde-base/libkonq-${PV}
	>=kde-base/libkworkspace-${PV}
	>=kde-base/libplasmaclock-${PV}
	>=kde-base/libtaskmanager-${PV}
	>=kde-base/nsplugins-${PV}
	>=kde-base/phonon-kde-${PV}
	>=kde-base/plasma-apps-${PV}
	>=kde-base/plasma-workspace-${PV}
	>=kde-base/powerdevil-${PV}
	>=kde-base/renamedlg-plugins-${PV}
	>=kde-base/solid-${PV}
	>=kde-base/solid-hardware-${PV}
	>=kde-base/soliduiserver-${PV}
	>=kde-base/systemsettings-${PV}
	semantic-desktop? ( >=kde-base/nepomuk-${PV} )
"
