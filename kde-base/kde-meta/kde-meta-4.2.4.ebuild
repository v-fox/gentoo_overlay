# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/kde-meta/kde-meta-4.2.1.ebuild,v 1.2 2009/03/12 11:25:45 scarabeus Exp $

EAPI="2"

DESCRIPTION="KDE - merge this to pull in all non-developer, split kde-base/* packages"
HOMEPAGE="http://www.kde.org/"
LICENSE="GPL-2"

KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
SLOT="4.2"
IUSE="accessibility +mysql nls"

# excluded: kdebindings, kdesdk, kdevelop, since these are developer-only
RDEPEND="
	>=kde-base/kate-${PV}
	>=kde-base/kdeadmin-meta-${PV}
	>=kde-base/kdeartwork-meta-${PV}
	>=kde-base/kdebase-meta-${PV}
	>=kde-base/kdegraphics-meta-${PV}
	>=kde-base/kdemultimedia-meta-${PV}
	>=kde-base/kdenetwork-meta-${PV}
	>=kde-base/kdeplasma-addons-${PV}
	>=kde-base/kdeutils-meta-${PV}
	accessibility? ( >=kde-base/kdeaccessibility-meta-${PV} )
	mysql? (
		>=kde-base/kdepim-meta-${PV}
		>=kde-base/kdewebdev-meta-${PV}
	)
	nls? ( >=kde-base/kde-l10n-${PV} )
"
# make kdepim-meta optional since it requires long hated mysql which people tend
# not to want in their system. But also enable it by default
