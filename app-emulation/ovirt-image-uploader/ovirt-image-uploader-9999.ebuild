# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python2_7 )

inherit user python-r1
inherit autotools git-2

DESCRIPTION="Upload images to Open Virtualization Manager"
HOMEPAGE="http://gerrit.ovirt.org"
EGIT_REPO_URI="git://gerrit.ovirt.org/${PN}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="${PYTHON_DEPS}
	>=dev-python/python-exec-0.3
	app-emulation/ovirt-engine-sdk-python"
DEPEND="${RDEPEND}
	sys-devel/gettext"

pkg_setup() {
	enewgroup kvm 36
	enewuser vdsm 36 -1 -1 kvm
}

src_prepare() {
	eautoreconf
	python_copy_sources
}

src_configure() {
	# temporary
	conf() {
		econf --disable-python-syntax-check
	}
	python_foreach_impl run_in_build_dir conf
}

src_compile() {
	python_foreach_impl run_in_build_dir default
}

src_install() {
	inst() {
		emake install DESTDIR="${ED}" am__py_compile=true
		python_export ${EPYTHON} PYTHON_SITEDIR
		python_replicate_script "${ED}${PYTHON_SITEDIR}/ovirt_image_uploader/__main__.py"
		python_optimize
	}
	python_foreach_impl run_in_build_dir inst
}

run_in_build_dir() {
	pushd "${BUILD_DIR}" > /dev/null
	"$@"
	popd > /dev/null
}
