// Nearby, ready walking origins for the infected participant in a conquest race.
params [["_target","",[""]]];
if (!isServer || {!canSuspend} || {!([west] call A3I_fnc_isActive)}
    || {missionNamespace getVariable ["areOccupantsDefeated",false]}
    || {missionNamespace getVariable ["bigAttackInProgress",false]}
    || {!isNil "A3I_majorGlobalOwner"} || {!(_target in allMapMarkers)}
    || {sidesX getVariable [_target,sideUnknown] != Invaders}
    || {!(_target in (airportsX + milbases + outposts + seaports + factories + resourcesX))}
    || {_target in forcedSpawn}) exitWith {[]};
private _origins = airportsX + outposts + milbases + seaports + factories + resourcesX + citiesX
    + (missionNamespace getVariable ["milAdministrationsX",[]]);
_origins = _origins arrayIntersect _origins;
[getMarkerPos _target,_origins,{_this call A3I_fnc_majorSourceEligible}] call A3I_fnc_tacticalSources
