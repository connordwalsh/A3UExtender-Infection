// Internal final launch transaction, called after the complete formation releases.
params ["_record",["_difficult",false,[true]]];
if (!isServer || {isRemoteExecuted}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_registerInterceptionTask,_this] call CBA_fnc_directCall};
private _name = _record getOrDefault ["name",""];
private _current = (missionNamespace getVariable ["A3I_interceptions",createHashMap]) getOrDefault [_name,createHashMap];
if (_current getOrDefault ["serial",-1] != _record getOrDefault ["serial",-2]
    || {!([west] call A3I_fnc_isActive)} || {_record getOrDefault ["retired",true]}
    || {_record getOrDefault ["phase",""] != "marching"}
    || {_record getOrDefault ["settled",false]} || {_record getOrDefault ["taskRegistered",false]}
    || {scriptDone (_record getOrDefault ["script",scriptNull])}
    || {_record getOrDefault ["created",-1] != _record getOrDefault ["size",-2]}
    || {"CONVOY" in (missionNamespace getVariable ["A3A_activeTasks",[]])}
    || {(missionNamespace getVariable ["A3A_tasksData",[]]) findIf {_x # 0 == _name || {_x # 1 == "CONVOY"}} != -1}) exitWith {false};
private _source = _record getOrDefault ["source",""];
private _target = _record getOrDefault ["target",""];
private _distance = _record getOrDefault ["routeDistance",-1];
if (!(_source in allMapMarkers) || {!(_target in allMapMarkers)}
    || {!(_distance isEqualType 0 && {finite _distance} && {_distance > 0} && {_distance <= 2500})}) exitWith {false};
// At least an hour, extended for slow walking over longer approved routes.
// This is a tuning allowance, not a promise of actual terrain travel time.
private _duration = 3600 max (_distance / 0.3 + 600);
_record set ["deadline",time + _duration];
_record set ["difficult",_difficult];
_record set ["outcome","pending"];
_record set ["settled",false];
private _description = format ["A large group of infected have been spotted moving from %1 to %2. Intercept and neutralize the horde.<br/><br/>The horde is on the move. Neutralize every infected before the first reaches %2. You have %3 minutes. The horde will continue toward its destination if Russian forces take control of it.",
    [_source] call A3A_fnc_localizar,[_target] call A3A_fnc_localizar,ceil (_duration / 60)];
[[teamPlayer,civilian],_name,[_description,"Horde Interception",_target],
    getMarkerPos _target,false,0,true,"attack",true] call BIS_fnc_taskCreate;
[_name,"CONVOY","CREATED"] call A3A_fnc_taskUpdate;
_record set ["taskRegistered",true];
if (_record getOrDefault ["lifecycleHandle",-1] < 0) then {[_record] call A3I_fnc_watchInterceptionLifecycle};
private _watching = [_record] call A3I_fnc_watchInterceptionTask;
if (!_watching) then {
    _record set ["fault","task_watch_failed"];
    [_record] call A3I_fnc_finishInterception;
};
_watching
