// Start one server controller per occupied location. Duplicate requests share it.
// A capture handoff may need only an actor controller: the previous faction's
// creator still owns the existing flag, crates and civilians until despawn.
params [["_marker","",[""]], ["_kind","",[""]], ["_assets",true,[true]]];
if (!isServer || {isRemoteExecuted && {remoteExecutedOwner != 2}}) exitWith {false};
if !(_kind in ["Resource","Outpost","Milbase","Airport","Control","City","MilAdmin"] && {_marker in allMapMarkers}
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
    private _road = false;
    private _branch = "persistent";
    private _batchSize = 4;
    private _building = objNull;
    if (_kind == "Control") then {
        _roster = [];
        if !(_marker in controlsX) exitWith {};
        private _center = getMarkerPos _marker;
        // Do not place an infected control inside another faction's main site.
        if ((markersX findIf {_x != _marker && {!(_x in controlsX)}
            && {sidesX getVariable [_x,sideUnknown] != west} && {_center inArea _x}}) != -1) exitWith {};
        _road = isOnRoad _center;
        private _frontline = false;
        if (_road) then {_frontline = [_marker] call A3A_fnc_isFrontline} else {
            private _mainMarkers = markersX - ["Synd_HQ"] - watchpostsFIA - roadblocksFIA - aapostsFIA - atpostsFIA - hmgpostsFIA;
            _frontline = (_mainMarkers findIf {getMarkerPos _x distance _center < distanceSPWN
                && {sidesX getVariable [_x,sideUnknown] == teamPlayer}}) != -1;
        };
        private _selection = [_road,_frontline] call A3I_fnc_controlRoster;
        _roster = _selection # 0;
        _branch = _selection # 1;
    };
    if (_kind == "City") then {
        private _selection = [_marker] call A3I_fnc_cityRoster;
        _roster = _selection # 0;
        _branch = _selection # 1;
        _batchSize = _selection # 2;
    };
    if (_kind == "MilAdmin") then {
        private _selection = [_marker] call A3I_fnc_administrationRoster;
        _roster = _selection # 0;
        _branch = _selection # 1;
        _building = _selection # 2;
    };
    if !(_roster isEqualType []) exitWith {};
    if (_kind == "Control" && {_roster isEqualTo []}) exitWith {};
    if (_kind == "MilAdmin" && {_roster isEqualTo []}) exitWith {};
    if (_kind == "City" && {_branch in ["inactive","invalid_town","invalid_town_data","overlap"]}) exitWith {};
    A3I_siteSerial = A3I_siteSerial + 1;
    private _record = createHashMapFromArray [
        ["id",A3I_siteSerial], ["kind",_kind], ["context","site:" + _marker],
        ["queue",+_roster], ["units",[]], ["groups",[]], ["civilians",[]],
        ["flag",objNull], ["crates",[]], ["positions",[]],
        ["assets",_assets],
        ["announced",false], ["cleaned",false], ["fault",""],
        ["road",_road], ["branch",_branch], ["spawnedAny",false], ["captured",sideUnknown], ["batchSize",_batchSize],
        ["building",_building], ["remainingDefenders",count _roster]
    ];
    A3I_sites set [_marker,_record];
    spawner setVariable [_marker + "_A3I_pending",count _roster,true];
    private _controller = switch (_kind) do {
        case "Control";
        case "City": {A3I_fnc_runPatrol};
        case "MilAdmin": {A3I_fnc_runAdministration};
        default {A3I_fnc_runSite};
    };
    private _script = [_marker,_record] spawn _controller;
    _record set ["script",_script];
    if (isNil "A3I_siteWatchdogHandle") then {
        A3I_siteWatchdogHandle = [A3I_fnc_siteWatchdog,2] call CBA_fnc_addPerFrameHandler;
    };
    _started = true;
};
_started
