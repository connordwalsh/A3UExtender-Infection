# Elimination scene factory

This internal increment uses the owner's infected-held towns/permanent-sites and
mixed basic/minor-special escort decisions. It does not install public missions.

Target selection keeps Ultimate's AS distance and inactive-site restrictions.
The existing validated town/permanent-site list includes live administration
strongholds, excludes road controls/HQ, and requires infected ownership. Unlike
Liquidation, this objective does not capture its location, so its source list
does not apply Liquidation's war-level restriction on capturing bases/airfields.

The initial escort is four to eight basic infected plus one or two minor specials,
scaled by war level. Including the target, this is six to eleven actors. The
special pool is the approved Screamer, Boomer and Leaper 2 set. Basic roles use
Ultimate's current-tier faction squads and the existing prepared basic classes.
The roster can be tuned later; it is not a performance or gameplay acceptance claim.

The factory searches bounded, hidden, dry, unobstructed locations within the
target boundary. Escorts are within 25 metres of the primary spawn position.
All positions are rechecked against current observers and ownership before
creation. A full shared-budget reservation is required: insufficient capacity
creates no partial group. The target and escorts use a separate mission context,
never permanent garrison roster entries. Failed creation rolls back its actors.

Only explicit factory-created approved specials receive the private management
tag allowing Infection's existing budget and native-compatible combat bookkeeping.
Unowned specials and ordinary human soldiers do not acquire this behavior by
being on WEST. The prepared native AI and damage handlers remain installed;
Infection adds its existing observation/kill/deletion handlers and disables the
human incapacitation flow. Each scene returns its actor/group/ticket references
to the eventual controller, which will own lifecycle and safe cleanup.

## Validation status

The initial run passed all 33 assertions but is retained as rejected because
the fixture omitted Ultimate's plusGarrison setting before invoking its real
tier selector. The corrected fixture initializes that setting and adds an actual
high-war eleven-actor scene. Production source is unchanged by this correction.
The repeat passes all 34 checks without engine/SQF errors. Actual
missing-dependency checks also pass all 11 cases. Basic formation regression and
final integration are running or pending. Actual connected combat, terrain and
campaign behavior remain open.
