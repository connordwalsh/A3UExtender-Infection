params ["_record"];
if (!isServer || {isRemoteExecuted} || {!canSuspend}) exitWith {};
private _target = _record get "source";
private _parking = [_target,_record get "class"] call A3I_fnc_findSupplyPosition;
if (_parking # 0 isEqualTo []) exitWith {_record set ["fault","no_safe_parking"]};
isNil {
    private _current = A3I_supplyTasks getOrDefault [_record get "name",createHashMap];
    if (_current getOrDefault ["serial",-1] != _record get "serial"
        || {_record get "settled"} || {_record get "phase" != "preparing"}
        || {!((_record get "kind") in ([_target] call A3I_fnc_supplySiteKinds))}) exitWith {
        _record set ["fault","source_changed_before_spawn"];
    };
    private _created = [_record get "kind",_parking # 0,_parking # 1,_record get "class"]
        call A3I_fnc_createSupplyTruck;
    private _truck = _created # 0;
    if (isNull _truck) exitWith {_record set ["fault",_created # 1]};
    _record set ["truck",_truck];
    _truck setVariable ["A3I_supplyTaskOwner",[_record get "name",_record get "serial"]];
    _record set ["deadline",time + (_record get "duration")];
    private _description = format ["Intelligence reports a %1 truck was positioned in %2 before the infection. Bring the truck back to friendly territory for distribution.<br/><br/>Deliver it to Rebel HQ (within 100 metres), or inside a Rebel-held base, outpost, airfield, factory, resource site or seaport. Keep the truck intact; it remains yours after delivery. You have %3 minutes. Recovery continues if the settlement changes hands.",
        _record get "kind",[_target] call A3A_fnc_localizar,(_record get "duration") / 60];
    [[teamPlayer,civilian],_record get "name",[_description,"Supplies Seizure",_target],
        getPosATL _truck,false,0,true,"rearm",true] call BIS_fnc_taskCreate;
    [_record get "name","LOG","CREATED"] call A3A_fnc_taskUpdate;
    _record set ["taskRegistered",true]; _record set ["phase","active"];
};
