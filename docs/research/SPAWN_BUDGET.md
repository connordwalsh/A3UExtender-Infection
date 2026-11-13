# Server spawn budget component

The S5-1 budget component is implemented early as a dependency of S2 site
spawning. The persistent-site increment now connects it to six site types; see
[site spawning](SITE_SPAWNING.md). Mission/response and other spawn callers remain
unconverted. This is not a claim that the whole campaign obeys a global cap.

The server owns transient reservations, assigned units and allocation sequence
numbers. Every budget operation runs unscheduled through CBA's direct-call
helper when necessary, so competing scheduled requests cannot both spend the
same free capacity. Direct calls from clients or remote calls whose origin is
not the server are rejected. Only server-local registered basic infected can be
bound. Headless transfer and client-origin behavior still require live tests.

## Settings and behavior

CBA registers three server-controlled settings. The active limit defaults to
40, configurable from 1 to 48. The limit shared by groups from one location or
event defaults to 12, configurable from 1 to 24. Diagnostic logging defaults off.
These values are conservative development limits, not a completed performance
benchmark. No additional mod dependency is introduced beyond the required CBA.

An accepted request reserves capacity before creation. Binding an actor converts
one pending slot into one live slot. Multiple requests with the same context
share a ceiling; a later request cannot raise the ceiling of an existing one.
Partial grants are returned explicitly. Repeated binding cannot consume another
slot or transfer an actor to another reservation.

Closing releases unused slots and retains live actors. Cancelling closes the
reservation and deletes its bound live actors. Real Killed and Deleted handlers
release the binding; arbitrary release of a living unit is rejected. Empty
records are removed. Every operation reconciles dead/null bindings, and a
reservation's unfilled portion expires after 30 seconds without a successful
bind. Expiry retains actors already created. A failed or terminated spawn script
therefore cannot permanently reserve unused capacity.

Lower limits take effect at the next budget operation. Unfilled slots are trimmed
in allocation order, preserving older reservations first. Living units remain;
if their number already exceeds the reduced limit, no new capacity is granted
until sufficient units leave. Diagnostics expose living and pending counts
separately, including this temporary condition after an administrator lowers a limit.

## Internal API

Call `[operation, arguments] call A3I_fnc_budget` on the server. Every response is
`[success, payload, reason]`; unsuccessful results include a specific reason.

| Operation | Arguments | Successful payload |
| --- | --- | --- |
| `reserve` | `[context, requested, localLimit]`, local limit defaults to 12 | `[ticket, grantedCount]` |
| `remaining` | `[ticket]`, reconciles expiry and lowered limits first | Number of still-unbound slots; an expired/closed ticket is rejected |
| `bind` | `[ticket, unit]` | `1`, or `0` for an already-bound actor |
| `close` | `[ticket]` | Number of unused slots released |
| `cancel` | `[ticket]` | Number of bound living actors deleted |
| `release` | `[unit]`, normally called by the engine event handlers | Number of bindings released |
| `stats` | `[]` | `[limit, living, pending, ticketCount, [[context, occupied], ...]]` |

Spawners must reserve before creation, check each bind result, delete a
new actor if binding fails, and close unused slots on every exit. They must
handle a partial grant, expired ticket, reduced capacity or ownership change.
These obligations will be checked in the actual site/response/mission callers.
Reservations are not save data; future save loading must rebuild transient state.

## Evidence and remaining work

The original API [build manifest](../../evidence/sprint-5/budget-build.json) identifies
that tested addon. Its [140-check report](../../evidence/sprint-5/budget-contract.json)
includes 20 budget checks plus the 120 template/garrison/combat regressions on
Ultimate 12.4.2. Twenty scheduled requests competed for eight slots and exactly
eight succeeded with unique tickets. Real prepared units exercised binding,
combat death, live deletion, cancellation and cleanup alongside the combat
adapter. Raw records were checked before reconciliation to prove that Deleted
handlers released capacity. The lease test waited 31 real seconds, preserved a
bound unit and rejected a late bind. No fixture entities/groups or reservations
remained, and server setting changes were not persisted.

The [missing-dependency run](../../evidence/sprint-5/budget-dependencies-absent.json)
passed 11 checks without WebKnight/IMS. Both reports contain no recorded engine
or SQF errors, while preserving existing startup warnings. The first budget
attempt had passing assertions but produced SQF parameter errors because a
guard inherited the caller's arguments. Its report failed; the guard now receives
an explicit WEST argument. It is not included as accepted evidence.

The later site increment adds production callers, bounded placement, HQ/player
exclusions, per-site tracking and batch pacing for six persistent site types.
Still open: remaining spawn routes, specials and their extra entities, debug UI,
persistence acceptance, headless/JIP and the representative performance soak.
Only bound actors and their reservations are controlled by this component;
unrelated or unconverted spawn routes are outside this evidence.
