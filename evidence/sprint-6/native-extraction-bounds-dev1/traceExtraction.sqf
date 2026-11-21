params ["_record"];
if (!isServer || {isRemoteExecuted} || {!canSuspend}) exitWith {};
private _source=_record get "source";
private _scene=[_source,0,{
    params ["_units","_group"];
    private _current=A3I_extractionTasks getOrDefault [_record get "name",createHashMap];
    if (_current getOrDefault ["serial",-1] != _record get "serial" || {_record get "settled"}) exitWith {false};
    _record set ["units",+_units]; (_record get "groups") pushBack _group;
    {_x setVariable ["A3I_extractionTaskOwner",[_record get "name",_record get "serial"]]} forEach _units;
    true
}] call A3I_fnc_createExtractionSurvivors;
if (_scene # 2 != "") exitWith {_record set ["fault",_scene # 2]};
private _center=getPosATL ((_record get "units") # 0);
_center set [2,0];
private _context="extraction:"+(_record get "name");
private _guard=[_context,_record get "guardRoles",_center,10,50,"","legacy",4,false,{
    !(_record get "settled") && {_source in (call A3I_fnc_extractionLocations)}
},false,"",{
    params ["_unit"];
    diag_log format ["[EXTRACTION_GUARD_TRACE] candidate %1",[_source,getPosATL _unit,getMarkerPos _source,markerSize _source,_unit inArea _source,_record get "settled",_unit getVariable ["A3I_initialized",false]]];
    if (!(_unit inArea _source) || {_record get "settled"}) exitWith {false};
    _unit setVariable ["A3I_extractionTaskOwner",[_record get "name",_record get "serial"]];
    (_record get "guards") pushBack _unit;
    (_record get "groups") pushBackUnique group _unit;
    true
},_source] call A3I_fnc_spawnGroup;
if (!(_guard # 0) || {count (_record get "guards") != 4}) exitWith {_record set ["fault","guard_"+(_guard # 2)]};
private _guardGroup=_guard # 1 # 0;
[_guardGroup,_center,30] call BIS_fnc_taskPatrol;
isNil {
    if (_record get "settled" || {!(_source in (call A3I_fnc_extractionLocations))}) exitWith {_record set ["fault","source_changed"]};
    _record set ["deadline",time+(_record get "duration")];
    private _ledger=[_record get "name",_record get "units",_record get "deadline"] call A3I_fnc_createExtractionLedger;
    _record set ["ledger",_ledger];
    if (count _ledger == 0) exitWith {_record set ["fault","ledger_registration"]};
    private _description=format ["Rumors have circulated that a group of survivors are stranded near %1. Get out there and bring them to a friendly site.<br/><br/>Free each survivor and escort them to Rebel HQ (within 50 metres), or inside a Rebel-held base, outpost, airfield, factory, resource site or seaport. A small infected group guards the shelter. Delivered survivors become manpower and leave your squad; their equipment returns to the HQ arsenal.<br/><br/>You have %2 minutes. The assignment stays active until every survivor is rescued or killed, or time expires. At least one rescue is required for success. Undelivered survivors are removed one minute after the mission ends, including any still travelling with you.",[_source] call A3A_fnc_localizar,(_record get "duration")/60];
    [[teamPlayer,civilian],_record get "name",[_description,"Extraction Mission",_source],
        getPosATL ((_record get "units") # 0),false,0,true,"run",true] call BIS_fnc_taskCreate;
    [_record get "name","RES","CREATED"] call A3A_fnc_taskUpdate;
    _record set ["taskRegistered",true]; _record set ["phase","active"];
    [_ledger] call A3I_fnc_setExtractionActions;
};

