#!/bin/sh
set -eu

root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd -P)
mgr="$root/libraries/MagicalGlassRedux"
umr="$root/libraries/UndertaleMonstersRecreation"
i18n="$root/libraries/kristal-i18n"

for language in en zh_hans; do
    grep -F '"mgr_act_check"' "$mgr/lang/$language.json" >/dev/null
done

if grep -R -n -E '"mgr_|mgr_act_check' \
    "$root/lang" "$i18n/lang" "$umr/lang" "$umr/scripts"; then
    printf '%s\n' 'MGR localization keys must stay in MGR' >&2
    exit 1
fi

if grep -R -n -E 'i18n_refreshEnemy|i18n_localizeItemName' \
    "$mgr/lib.lua" "$mgr/scripts" "$umr/scripts" "$i18n/lib.lua" "$i18n/modules"; then
    printf '%s\n' 'legacy cross-library i18n API must stay removed' >&2
    exit 1
fi

test ! -e "$root/scripts/battle/randomencounters/thrash_light.lua"
if grep -R -n -F 'thrash_light' "$root/mod.lua" "$root/scripts" "$mgr" "$umr"; then
    printf '%s\n' 'thrash_light must not reappear outside its owning library' >&2
    exit 1
fi

if grep -E -q '"(magical-glass|undertale_monsters_recreation)"[[:space:]]*:[[:space:]]*\{' "$root/mod.json"; then
    printf '%s\n' 'optional libraries belong in optionalLibraries, not config enabled switches' >&2
    exit 1
fi
if grep -F -q '"enabled"' "$mgr/lib.json" "$umr/lib.json"; then
    printf '%s\n' 'MGR/UMR must not expose obsolete enabled switches' >&2
    exit 1
fi
if grep -R -n -F 'getLibConfig("magical-glass", "enabled")' "$mgr/lib.lua" "$mgr/scripts" "$umr/scripts" ||
    grep -R -n -F 'getLibConfig("undertale_monsters_recreation", "enabled")' "$mgr/lib.lua" "$mgr/scripts" "$umr/scripts"; then
    printf '%s\n' 'MGR/UMR must not retain obsolete enabled runtime guards' >&2
    exit 1
fi

printf '%s\n' 'refactor boundaries: PASS'
