// Attach only to an already registered task and a fully released formation.
params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_watchInterceptionTask,_this] call CBA_fnc_directCall};
private _name = _record getOrDefault ["name",""];
private _current = (missionNamespace getVariable ["A3I_interceptions",createHashMap]) getOrDefault [_name,createHashMap];
private _deadline = _record getOrDefault ["deadline",-1];
if (_current getOrDefault ["serial",-1] != _record getOrDefault ["serial",-2]
    || {!([west] call A3I_fnc_isActive)} || {_record getOrDefault ["retired",true]}
    || {_record getOrDefault ["phase",""] != "marching"} || {_record getOrDefault ["settled",false]}
    || {_record getOrDefault ["created",-1] != _record getOrDefault ["size",-2]}
    || {_record getOrDefault ["taskHandle",-1] >= 0} || {scriptDone (_record getOrDefault ["script",scriptNull])}
    || {!(_deadline isEqualType 0 && {finite _deadline} && {_deadline >= _record getOrDefault ["departedAt",1e12]})}
    || {(missionNamespace getVariable ["A3A_tasksData",[]]) findIf {_x # 0 == _name && {_x # 1 == "CONVOY"} && {_x # 2 == "CREATED"}} == -1}) exitWith {false};
_record set ["taskHandle",[A3I_fnc_interceptionTaskTick,0,[_name,_record get "serial"]] call CBA_fnc_addPerFrameHandler];
true
