// Read-only server predicate: [cleared, reason, remaining obligations]. It
// neither captures a location nor changes ordinary Ultimate capture rules.
params [["_marker","",[""]]];
if (!isServer || {isRemoteExecuted} || {!([west] call A3I_fnc_isActive)})
    exitWith {[false,"server_local_active_only",-1]};
if (canSuspend) exitWith {[A3I_fnc_siteClearance,_this] call CBA_fnc_directCall};
if (!(_marker in allMapMarkers) || {isNil "sidesX"} || {isNil "spawner"} || {isNil "garrison"})
    exitWith {[false,"campaign_not_ready",-1]};
if (sidesX getVariable [_marker,sideUnknown] != west) exitWith {[false,"ownership",-1]};
if (spawner getVariable [_marker,2] != 0) exitWith {[false,"site_not_active",-1]};
private _record = (missionNamespace getVariable ["A3I_sites",createHashMap])
    getOrDefault [_marker,createHashMap];
if (count _record == 0 || {_record getOrDefault ["cleaned",true]}
    || {scriptDone (_record getOrDefault ["script",scriptNull])}
    || {_record getOrDefault ["context",""] != "site:" + _marker})
    exitWith {[false,"controller_unavailable",-1]};
private _remaining = _record getOrDefault ["clearanceRemaining",-1];
if (!(_remaining isEqualType 0) || {!finite _remaining} || {_remaining < 0})
    exitWith {[false,"ledger_unavailable",-1]};
if (_record getOrDefault ["fault","missing"] != "") exitWith {[false,"site_fault",_remaining]};
if (_record getOrDefault ["clearanceMissing",0] > 0) exitWith {[false,"missing_defender",_remaining]};
if (_record getOrDefault ["queue",["unknown"]] isNotEqualTo []) exitWith {[false,"queued_defenders",_remaining]};
if (_remaining > 0) exitWith {[false,"remaining_defenders",_remaining]};
if (((_record getOrDefault ["units",[]]) findIf {alive _x}) != -1)
    exitWith {[false,"living_defenders",_remaining]};
if (_record getOrDefault ["kind",""] in ["Resource","Outpost","Milbase","Airport"]
    && {garrison getVariable [_marker,["unknown"]] isNotEqualTo []})
    exitWith {[false,"garrison_pending",_remaining]};
[true,"",0]
