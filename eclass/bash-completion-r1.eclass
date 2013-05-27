# Copyright owners: Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: bash-completion-r1.eclass
# @MAINTAINER:
# mgorny@gentoo.org
# @BLURB: A few quick functions to install bash-completion files
# @EXAMPLE:
#
# @CODE
# EAPI=4
#
# src_install() {
# 	default
#
# 	newbashcomp contrib/${PN}.bash-completion ${PN}
# }
# @CODE

case ${EAPI:-0} in
	0|1|2|3|4|4-python|5|5-progress) ;;
	*) die "EAPI ${EAPI} unsupported (yet)."
esac

# @FUNCTION: dobashcomp
# @USAGE: file [...]
# @DESCRIPTION:
# Install bash-completion files passed as args. Has EAPI-dependant failure
# behavior (like doins).
dobashcomp() {
	debug-print-function ${FUNCNAME} "${@}"

	(
		insinto /usr/share/bash-completion
		doins "${@}"
	)
}

# @FUNCTION: newbashcomp
# @USAGE: file newname
# @DESCRIPTION:
# Install bash-completion file under a new name. Has EAPI-dependant failure
# behavior (like newins).
newbashcomp() {
	debug-print-function ${FUNCNAME} "${@}"

	(
		insinto /usr/share/bash-completion
		newins "${@}"
	)
}
