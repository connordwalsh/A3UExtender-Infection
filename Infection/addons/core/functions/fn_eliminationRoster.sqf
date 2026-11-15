// [optional approved primary class] -> [primary, basic roles, minor specials].
// Start with 4-8 basics plus 1-2 minor specials; 6-11 actors including the target.
params [["_primary","",[""]]];
if (!isServer || {isRemoteExecuted} || {!([west] call A3I_fnc_isActive)}
    || {isNil "tierWar"} || {!(tierWar isEqualType 0)} || {!finite tierWar}) exitWith {[]};
private _specials = call A3I_fnc_eliminationClasses;
if (_specials isEqualTo []) exitWith {[]};
if (_primary == "") then {_primary = selectRandom _specials};
if !(_primary in _specials) exitWith {[]};
private _minorChoices = _specials - [_primary];
if (_minorChoices isEqualTo []) exitWith {[]};
private _choices = [A3A_faction_occ,"groupsTierSquads"] call SCRT_fnc_unit_flattenTier;
private _definitions = A3A_faction_occ get "loadouts";
_choices = _choices select {_x isEqualType [] && {_x isNotEqualTo []}
    && {(_x findIf {!(_x isEqualType "") || {_x find "loadouts_occ_" != 0}
        || {!((_x select [13]) in _definitions)}}) == -1}};
if (_choices isEqualTo []) exitWith {[]};
private _war = (tierWar max 0) min 10;
private _count = (4+floor (_war/2)) min 8;
private _basics = [];
while {count _basics < _count} do {_basics append selectRandom _choices};
_basics resize _count;
private _minor = [selectRandom _minorChoices];
if (_war >= 7) then {_minor pushBack selectRandom _minorChoices};
[_primary,_basics,_minor]
