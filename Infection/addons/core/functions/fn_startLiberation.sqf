// Local server entry. An empty result never applies a political ownership flip;
// the campaign caller's no-nearby-origin policy remains a separate decision.
params [["_town","",[""]],["_source","",[""]]];
if (!isServer || {!canSuspend} || {isRemoteExecuted}) exitWith {[false,"server_local_scheduled"]};
private _routes = [_town] call A3I_fnc_liberationSources;
if (_source != "") then {_routes = _routes select {_x # 0 == _source}};
if (_routes isEqualTo []) exitWith {[false,"source"]};
_source = (selectRandom _routes) # 0;
private _data = (missionNamespace getVariable ["A3A_townData",createHashMap]) getOrDefault [_town,[]];
private _population = _data param [0,-1];
if !(_population isEqualType 0 && {finite _population} && {_population >= 0})
    exitWith {[false,"population"]};
private _result = [false,"race"];
isNil {
    if ("townBattle" in (missionNamespace getVariable ["A3A_activeTasks",[]])
        || {((values (missionNamespace getVariable ["A3I_liberations",createHashMap]))
            findIf {!(_x getOrDefault ["settled",false])}) != -1}) exitWith {_result = [false,"task_pending"]};
    if (!([west] call A3I_fnc_isActive) || {sidesX getVariable [_town,sideUnknown] != west}
        || {_town in townSkirmishes} || {_town in forcedSpawn}
        || {!([_source] call A3I_fnc_majorSourceEligible)}) exitWith {};
    if (isNil "A3I_liberations") then {A3I_liberations = createHashMap; A3I_liberationSerial = 0};
    if (isNil "A3I_liberationSkirmishClaims") then {A3I_liberationSkirmishClaims = createHashMap};
    A3I_liberationSerial = (missionNamespace getVariable ["A3I_liberationSerial",0]) + 1;
    private _name = "A3I_LIB_" + str A3I_liberationSerial;
    private _claims = [_town];
    if (milAdministrationsX isNotEqualTo []) then {
        private _admin = [milAdministrationsX,getMarkerPos _town] call BIS_fnc_nearestPosition;
        if (_admin isEqualType "" && {_admin in allMapMarkers}) then {_claims pushBackUnique _admin};
    };
    private _record = createHashMapFromArray [["name",_name],["town",_town],["source",_source],
        ["position",getMarkerPos _town],["population",_population],["phase","setup"],
        ["expiresAt",time + 2400],["outcome","pending"],["settled",false],["recruited",false],
        ["taskRegistered",false],["taskDeleted",false],["claims",_claims],["claimsReleased",false]];
    A3I_liberations set [_name,_record];
    {
        private _claim = A3I_liberationSkirmishClaims getOrDefault [_x,[_x in townSkirmishes,[]]];
        (_claim # 1) pushBack _name;
        A3I_liberationSkirmishClaims set [_x,_claim];
        townSkirmishes pushBackUnique _x;
    } forEach _claims;
    _record set ["script",[_record] spawn A3I_fnc_runLiberation];
    if (isNil "A3I_liberationWatchdogHandle") then {
        A3I_liberationWatchdogHandle = [A3I_fnc_liberationWatchdog,1] call CBA_fnc_addPerFrameHandler;
    };
    _result = [true,_name];
};
_result
