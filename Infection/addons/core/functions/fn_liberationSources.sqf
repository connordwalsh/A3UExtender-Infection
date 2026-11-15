// Eligible origins for a survivor-defense skirmish in an infected-held town.
// An empty result is a selection result, not a political ownership decision.
params [["_town","",[""]]];
if (!isServer || {!canSuspend} || {isRemoteExecuted}
    || {!([west] call A3I_fnc_isActive)}
    || {missionNamespace getVariable ["areOccupantsDefeated",false]}
    || {isNil "sidesX"} || {isNil "spawner"}
    || {!(_town in (missionNamespace getVariable ["citiesX",[]]))}
    || {!(_town in allMapMarkers)} || {sidesX getVariable [_town,sideUnknown] != west}
    || {_town in (missionNamespace getVariable ["townSkirmishes",[]])}
    || {_town in (missionNamespace getVariable ["forcedSpawn",[]])}
    || {missionNamespace getVariable ["bigAttackInProgress",false]}
    || {!isNil "A3I_majorGlobalOwner"}) exitWith {[]};
private _position = getMarkerPos _town;
private _radius = 200 max ([_town] call A3A_fnc_sizeMarker);
// Preserve native refusal to create a new event around a player already there.
if (((call SCRT_fnc_misc_getRebelPlayers) findIf {alive _x && {_x distance2D _position < _radius}}) != -1)
    exitWith {[]};
private _origins = airportsX + outposts + milbases + seaports + factories + resourcesX + citiesX
    + (missionNamespace getVariable ["milAdministrationsX",[]]);
_origins = (_origins arrayIntersect _origins) - [_town];
if (_origins isEqualTo []) exitWith {[]};
[_position,_origins,{_this call A3I_fnc_majorSourceEligible}] call A3I_fnc_tacticalSources
