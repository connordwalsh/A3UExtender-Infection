// Server scheduled entry after mixed-faction source selection. Planning can
// yield; source ownership, cooldown and shared patrol count are committed once.
params [["_base","",[""]]];
if (!isServer || {!canSuspend} || {isRemoteExecuted && {remoteExecutedOwner != 2}})
    exitWith {false};
if !([_base] call A3I_fnc_roamingEligible) exitWith {false};
private _route = [_base] call A3I_fnc_roamingRoute;
if (_route isEqualTo []) exitWith {false};
private _choices = [A3A_faction_occ,"groupsTierSmall"] call SCRT_fnc_unit_flattenTier;
if (_choices isEqualTo []) exitWith {false};
private _roles = (selectRandom _choices) select [0,4];
if (_roles isEqualTo []) exitWith {false};
private _accepted = false;
isNil {
    if (!([_base] call A3I_fnc_roamingEligible)
        || {AAFpatrols >= round (3 * A3A_balancePlayerScale)}
        || {(_route findIf {!((_x # 0) in allMapMarkers) || {sidesX getVariable [_x # 0,sideUnknown] != west}}) != -1}) exitWith {};
    if (isNil "A3I_roamers") then {A3I_roamers = createHashMap; A3I_roamingSerial = 0};
    if (_base in A3I_roamers) exitWith {};
    A3I_roamingSerial = A3I_roamingSerial + 1;
    private _record = createHashMapFromArray [
        ["source",_base], ["context","roam:" + str A3I_roamingSerial], ["route",_route],
        ["queue",_roles], ["units",[]], ["groups",[]], ["counted",true], ["cleanupOrdered",false],
        ["spawnDeadline",time + 120], ["endTime",time + 1800], ["lastObserved",time]
    ];
    AAFpatrols = AAFpatrols + 1;
    A3I_roamers set [_base,_record];
    if (isNil "A3I_roamingCooldowns") then {A3I_roamingCooldowns = createHashMap};
    A3I_roamingCooldowns set [_base,time + 600];
    _record set ["script",[_record] spawn A3I_fnc_runRoaming];
    if (isNil "A3I_roamingWatchdogHandle") then {
        A3I_roamingWatchdogHandle = [A3I_fnc_roamingWatchdog,2] call CBA_fnc_addPerFrameHandler;
    };
    _accepted = true;
};
_accepted
