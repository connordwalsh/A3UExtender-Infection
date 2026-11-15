params ["_record"];
if (!isServer || {isRemoteExecuted} || {!canSuspend}) exitWith {};
private _created = [_record get "source",_record get "class",{
    params ["_target","_escorts","_group","_ticket","_context"];
    private _name = _record get "name";
    private _current = A3I_eliminationTasks getOrDefault [_name,createHashMap];
    if (_current getOrDefault ["serial",-1] != _record get "serial"
        || {_record get "settled"} || {_record get "phase" != "preparing"}) exitWith {false};
    // Runs inside the factory's unscheduled creation transaction: references and
    // the death observer exist before native scheduled creature AI can run.
    _record set ["units",[_target]+_escorts]; _record set ["group",_group];
    { _x setVariable ["A3I_eliminationTaskOwner",[_name,_record get "serial"]] } forEach (_record get "units");
    _record set ["deadline",time+(_record get "duration")];
    private _ledger = [_name,_target,_record get "deadline"] call A3I_fnc_createEliminationLedger;
    _record set ["ledger",_ledger];
    if (count _ledger == 0) exitWith {false};
    private _source = _record get "source";
    private _center = getMarkerPos _source;
    private _radius = if (_source in (missionNamespace getVariable ["milAdministrationsX",[]])) then {50}
        else {((markerSize _source # 0) min (markerSize _source # 1)) min 100};
    private _search = _name+"_search";
    createMarker [_search,_center]; _record set ["searchMarker",_search];
    _search setMarkerShape "ELLIPSE"; _search setMarkerSize [_radius,_radius];
    _search setMarkerBrush "Border"; _search setMarkerColor "ColorOPFOR";
    private _type = getText (configFile >> "CfgVehicles" >> typeOf _target >> "displayName");
    private _description = format ["A powerful special infected, %1, has been reported in %2. Search the marked area and neutralize it.<br/><br/>Its accompanying special infected are other types. Only the reported target must be killed. The search area marks its reported location and does not track its movements. You have %3 minutes. Keep hunting if the settlement changes hands.",
        _type,[_source] call A3A_fnc_localizar,(_record get "duration")/60];
    [[teamPlayer,civilian],_name,[_description,"Elimination Task",_search],
        _center,false,0,true,"kill",true] call BIS_fnc_taskCreate;
    [_name,"AS","CREATED"] call A3A_fnc_taskUpdate;
    _record set ["taskRegistered",true]; _record set ["phase","active"];
    true
}] call A3I_fnc_spawnEliminationScene;
if !(_created # 0) then {_record set ["fault",_created # 2]};
