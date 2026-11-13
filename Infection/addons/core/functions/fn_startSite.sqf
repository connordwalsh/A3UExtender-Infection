// Start one controller for a persistent occupied site. Duplicate requests share it.
params [["_marker","",[""]], ["_kind","",[""]]];
if (!isServer || {isRemoteExecuted && {remoteExecutedOwner != 2}}) exitWith {false};
if !(_kind in ["Resource","Outpost","Milbase","Airport"] && {_marker in allMapMarkers}
    && {!isNil "sidesX"} && {!isNil "spawner"} && {!isNil "garrison"}
    && {[sidesX getVariable [_marker,sideUnknown]] call A3I_fnc_isActive}
    && {spawner getVariable [_marker,2] != 2}) exitWith {false};
private _started = false;
isNil {
    if (isNil "A3I_sites") then {A3I_sites = createHashMap; A3I_siteSerial = 0};
    private _existing = A3I_sites getOrDefault [_marker,createHashMap];
    if (count _existing > 0) then {
        if (scriptDone (_existing get "script")) then {
            [_marker,_existing] call A3I_fnc_cleanupSite;
        };
    };
    if (_marker in A3I_sites) exitWith {};
    private _roster = garrison getVariable [_marker,[]];
    if !(_roster isEqualType []) exitWith {};
    A3I_siteSerial = A3I_siteSerial + 1;
    private _record = createHashMapFromArray [
        ["id",A3I_siteSerial], ["kind",_kind], ["context","site:" + _marker],
        ["queue",+_roster], ["units",[]], ["groups",[]], ["civilians",[]],
        ["flag",objNull], ["crates",[]], ["positions",[]],
        ["announced",false], ["cleaned",false], ["fault",""]
    ];
    A3I_sites set [_marker,_record];
    spawner setVariable [_marker + "_A3I_pending",count _roster,true];
    private _script = [_marker,_record] spawn A3I_fnc_runSite;
    _record set ["script",_script];
    if (isNil "A3I_siteWatchdogHandle") then {
        A3I_siteWatchdogHandle = [A3I_fnc_siteWatchdog,2] call CBA_fnc_addPerFrameHandler;
    };
    _started = true;
};
_started
