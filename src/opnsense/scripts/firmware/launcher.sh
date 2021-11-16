#!/bin/sh

# Copyright (C) 2016-2021 Franco Fichtner <franco@opnsense.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

BASEDIR="/usr/local/opnsense/scripts/firmware"
LOCKFILE="/tmp/pkg_upgrade.progress"
FLOCK="/usr/local/bin/flock -n -o"
COMMANDS="
check
connection
health
install
lock
reinstall
remove
resync
security
sync
unlock
update
upgrade
"

DO_RANDOM=
DO_SCRIPT=

while getopts r:s: OPT; do
	case ${OPT} in
	r)
		DO_RANDOM="-r $(jot -r 1 1 ${OPTARG})"
		;;
	s)
		# make sure the script exists
		if [ ! -f "${OPTARG}" ]; then
			exit 1
		fi
		DO_SCRIPT="-s ${OPTARG}"
		;;
	*)
		# ignore unknown
		;;
	esac
done

shift $((${OPTIND} - 1))

if [ -n "${DO_SCRIPT}" ]; then
	SELECTED=${DO_SCRIPT#"-s "}
else
	SELECTED=${1}
	shift
fi

if [ -n "${DO_RANDOM}" ]; then
	sleep ${DO_RANDOM#"-r "}
fi

if [ -f "${SELECTED}" ]; then
	${FLOCK} ${LOCKFILE} ${SELECTED} "${@}"
	exit ${?}
fi

for COMMAND in ${COMMANDS}; do
	if [ "${SELECTED}" != ${COMMAND} ]; then
		continue
	fi

	${FLOCK} ${LOCKFILE} ${BASEDIR}/${COMMAND}.sh "${@}"
done
