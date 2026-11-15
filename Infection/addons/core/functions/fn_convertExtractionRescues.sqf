// Deliveries are durable ledger outcomes; pay incremental cumulative native HR once.
params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_convertExtractionRescues,_this] call CBA_fnc_directCall};
private _current=(missionNamespace getVariable ["A3I_extractionTasks",createHashMap]) getOrDefault [_record getOrDefault ["name",""],createHashMap];
if (_current getOrDefault ["serial",-1] != _record getOrDefault ["serial",-2]) exitWith {false};
_record=_current;
private _ledger=_record get "ledger";
if (count _ledger == 0 || {!(_record get "taskRegistered")}) exitWith {false};
private _targetHR=ceil ((_ledger get "rescued")*(_record get "hrFactor"));
private _delta=_targetHR-(_record get "hrCredited");
if (_delta > 0) then {_record set ["hrCredited",_targetHR]; [_delta,0] spawn A3A_fnc_resourcesFIA};
{
    if (_x get "state" != "rescued" || {_x getOrDefault ["converted",false]}) then {continue};
    private _unit=_x get "unit";
    if (isNull _unit) then {_x set ["converted",true]; continue};
    if (!((_unit getVariable ["A3I_extractionTaskOwner",[]]) isEqualTo [_record get "name",_record get "serial"]) || {isPlayer _unit}) then {continue};
    private _liveOwner=_unit getVariable ["A3I_extractionOwner",[]];
    private _expectedOwner=[_ledger get "name",_ledger get "serial",_forEachIndex];
    if (_liveOwner isNotEqualTo [] && {!(_liveOwner isEqualTo _expectedOwner)}) then {continue};
    if (isNil "boxX" || {isNull boxX}) then {continue};
    // Native refugee inventory recovery, applied to every approved delivery site.
    {private _weapon=[_x] call BIS_fnc_baseWeapon;
        if (_weapon != "" && {!(_weapon in unlockedWeapons)}) then {boxX addWeaponCargoGlobal [_weapon,1]}
    } forEach weapons _unit;
    {if !(_x in unlockedMagazines) then {boxX addMagazineCargoGlobal [_x,1]}} forEach magazines _unit;
    {if (_x != "") then {boxX addItemCargoGlobal [_x,1]}} forEach
        (items _unit+primaryWeaponItems _unit+assignedItems _unit+secondaryWeaponItems _unit);
    _x set ["converted",true];
    deleteVehicle _unit;
} forEach (_ledger get "entries");
true
