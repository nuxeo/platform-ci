#!/bin/sh
# Post-renderer for the jenkins Helm release.
#
# The chart's generated apply_config.sh uses `yes n | cp -i` to copy plugins to
# the shared emptyDir volume. This pattern is non-idempotent: it works on the
# first init container run, but when the init container is restarted within the
# same pod lifetime (e.g. after the main container crashes), the destination
# already contains files. `cp -i` then prompts for each file, `yes n` answers
# "no", and cp exits 1. Combined with `set -e`, this aborts the script and puts
# the pod into CrashLoopBackOff.
#
# The fix: replace `yes n | cp -i` with `cp -f` (force-overwrite, no prompt,
# always exits 0), which is also consistent with `overwritePlugins: true`.
sed 's/yes n | cp -i/cp -f/g'
