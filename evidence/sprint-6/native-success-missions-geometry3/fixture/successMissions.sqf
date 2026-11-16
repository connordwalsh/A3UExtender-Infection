// Real native campaign requests and completion handlers. No endpoint stubs.
private _supplyReproduction=call compile preprocessFileLineNumbers "\x\a3i\tests\campaign\supply-reproduction-mode.sqf";
private _checks=0;private _failures=[];
private _check={params ["_name","_ok",["_details",[]]];
    _checks=_checks+1;if (!_ok) then {_failures pushBack _name};
    diag_log format ["[INFECTION_MISSION_SUCCESS] %1",["check",_name,_ok,_details]];
};
private _wait={params ["_condition",["_seconds",180]];private _until=diag_tickTime+_seconds;
    waitUntil {sleep 1;call _condition || {diag_tickTime>=_until}};call _condition
};
private _request={params ["_type","_serialVar","_registryVar","_namePrefix","_checkPrefix"];
    private _serial=missionNamespace getVariable [_serialVar,0];
    if (_type=="LOG" && {_supplyReproduction}) then {
        diag_log "[INFECTION_SUPPLY_TRACE] targeted_milbase_fuel";
        ["milbase","fuel"] spawn A3I_fnc_startSupplySeizure;
    } else {[_type,2,true] spawn A3A_fnc_missionRequest};
    private _started=[{(missionNamespace getVariable [_serialVar,0])>_serial}] call _wait;
    [_checkPrefix+"dispatch",_started] call _check;
    if (!_started) exitWith {createHashMap};
    private _name=_namePrefix+str (missionNamespace getVariable [_serialVar,0]);
    private _job=(missionNamespace getVariable [_registryVar,createHashMap]) getOrDefault [_name,createHashMap];
    private _ready=[{_job getOrDefault ["taskRegistered",false] || {_job getOrDefault ["settled",false]}}] call _wait;
    [_checkPrefix+"registered",_ready && {_job getOrDefault ["taskRegistered",false]}
        && {_job getOrDefault ["fault",""]==""},[_job getOrDefault ["source",""],_job getOrDefault ["fault",""]]] call _check;
    _job
};
private _nativeState={params ["_name","_type","_state"];
    (A3A_tasksData findIf {_x # 0==_name && {_x # 1==_type} && {_x # 2==_state}})>=0
        && {[_name] call BIS_fnc_taskState==_state}
};
diag_log "[INFECTION_MISSION_SUCCESS] start";
private _targets=call A3I_fnc_eliminationTargets;
["elim_eligible",_targets isNotEqualTo []] call _check;
private _elim=["AS","A3I_eliminationTaskSerial","A3I_eliminationTasks","A3I_ELIM_","elim_"] call _request;
if (_elim getOrDefault ["taskRegistered",false]) then {
    private _name=_elim get "name";private _units=+(_elim get "units");private _group=_elim get "group";
    private _target=(_elim get "ledger") get "unit";private _escorts=_units-[_target];
    private _class=typeOf _target;private _search=_elim get "searchMarker";
    ["elim_primary_approved",alive _target && {_class in (call A3I_fnc_eliminationClasses)}
        && {(_elim get "source") in _targets},[_class]] call _check;
    ["elim_escorts_different",(_escorts findIf {typeOf _x==_class})==-1
        && {(_escorts findIf {typeOf _x in (A3I_dependencies get "basicClasses")})>=0}
        && {(_escorts findIf {typeOf _x in (call A3I_fnc_eliminationClasses)})>=0},[_escorts apply {typeOf _x}]] call _check;
    ["elim_search_area",_search in allMapMarkers && {markerShape _search=="ELLIPSE"}] call _check;
    ["elim_native_created",[_name,"AS","CREATED"] call _nativeState] call _check;
    private _tickets=(keys A3I_budgetRecords) select {((A3I_budgetRecords get _x) # 0) find "elimination:scene:"==0};
    private _funds=server getVariable "resourcesFIA";private _reward=1000*([1,2] select (_elim get "difficult"));
    _target setDamage 1;
    private _settled=[{_elim get "settled"},30] call _wait;
    ["elim_neutralized",_settled && {_elim get "outcome"=="neutralized"}] call _check;
    ["elim_native_succeeded",[_name,"AS","SUCCEEDED"] call _nativeState] call _check;
    private _paid=[{server getVariable "resourcesFIA"==_funds+_reward},30] call _wait;
    ["elim_reward_exact",_paid,[_funds,_reward,server getVariable "resourcesFIA"]] call _check;
    private _clean=[{_elim get "assetRetired" && {(_units findIf {!isNull _x})==-1} && {isNull _group}},60] call _wait;
    ["elim_assets_cleaned",_clean] call _check;
    ["elim_search_removed",!(_search in allMapMarkers)] call _check;
    ["elim_budget_released",(_tickets findIf {_x in A3I_budgetRecords})==-1] call _check;
};
private _supplyTargets=call A3I_fnc_supplyTargets;
if (_supplyReproduction) then {
    private _point=[2645.5,5082.5,0];
    diag_log format ["[INFECTION_SUPPLY_TRACE] %1",["failed_point",_point,surfaceNormal _point,
        ([0,3,6,10] apply {[_x,_point isFlatEmpty [_x,-1,0.2,_x max 1,0,false,objNull]]}),
        ((["fuel"] call A3I_fnc_supplyTruckClasses) apply {[_x,sizeOf _x,_point findEmptyPosition [0,0,_x]]})]];
    // One object per record avoids truncating geometry at the engine log limit.
    {
        diag_log format ["[INFECTION_SUPPLY_TRACE] %1",["failed_point_object",_forEachIndex,str _x,typeOf _x,getPosATL _x,getDir _x,boundingBoxReal _x]];
    } forEach ((nearestTerrainObjects [_point,[],20,false,true]) select [0,15]);
};
// Read-only diagnostics for the failed native truck lifetime. Event handlers
// and observer state do not change vehicle damage, placement, tasks or timers.
private _createdEH=addMissionEventHandler ["EntityCreated",{
    params ["_vehicle"];
    if !(_vehicle isKindOf "Car") exitWith {};
    diag_log format ["[INFECTION_SUPPLY_TRACE] %1",["created",time,typeOf _vehicle,getPosATL _vehicle,getDir _vehicle]];
    diag_log format ["[INFECTION_SUPPLY_TRACE] %1",["created_geometry",typeOf _vehicle,sizeOf typeOf _vehicle,boundingBoxReal _vehicle,
        surfaceNormal getPosATL _vehicle,([0,3,6,10] apply {[_x,(getPosATL _vehicle) isFlatEmpty [_x,-1,0.2,_x max 1,0,false,_vehicle]]})]];
    {
        diag_log format ["[INFECTION_SUPPLY_TRACE] %1",["created_geometry_object",_forEachIndex,str _x,typeOf _x,getPosATL _x,getDir _x,boundingBoxReal _x]];
    } forEach ((nearestTerrainObjects [_vehicle,[],20,false,true]) select [0,15]);
    _vehicle addEventHandler ["Killed",{
        params ["_vehicle"];
        diag_log format ["[INFECTION_SUPPLY_TRACE] %1",["killed",time,typeOf _vehicle,getPosATL _vehicle,damage _vehicle,
            _vehicle getVariable ["A3I_supplyTaskOwner",[]]]];
    }];
    _vehicle addEventHandler ["Deleted",{
        params ["_vehicle"];
        diag_log format ["[INFECTION_SUPPLY_TRACE] %1",["deleted",time,typeOf _vehicle,getPosATL _vehicle,alive _vehicle,damage _vehicle,
            _vehicle getVariable ["A3I_supplyTaskOwner",[]]]];
    }];
}];
A3I_probeSupplySnapshots=createHashMap;
private _trace=[{
    {
        private _job=_y;private _vehicle=_job get "truck";
        private _state=[_job get "phase",_job get "outcome",_job get "fault",isNull _vehicle,alive _vehicle,
            damage _vehicle,typeOf _vehicle,getPosATL _vehicle,getDir _vehicle,_vehicle getVariable ["ownerSide",sideUnknown],
            _job get "taskRegistered",[_x] call BIS_fnc_taskState];
        if !(_state isEqualTo (A3I_probeSupplySnapshots getOrDefault [_x,[]])) then {
            diag_log format ["[INFECTION_SUPPLY_TRACE] %1",["state",time,_x,_job get "class",_job get "source",_state]];
            A3I_probeSupplySnapshots set [_x,_state];
        };
    } forEach (missionNamespace getVariable ["A3I_supplyTasks",createHashMap]);
},0.05] call CBA_fnc_addPerFrameHandler;
["supply_eligible",_supplyTargets isNotEqualTo []] call _check;
private _supply=["LOG","A3I_supplySerial","A3I_supplyTasks","A3I_SUPPLY_","supply_"] call _request;
if (_supply getOrDefault ["taskRegistered",false]) then {
    if (_supplyReproduction) then {sleep 10};
    private _name=_supply get "name";private _truck=_supply get "truck";
    ["supply_allowed_kind",(_supply get "source") in _supplyTargets
        && {(_supply get "kind") in ([_supply get "source"] call A3I_fnc_supplySiteKinds)},[_supply get "source",_supply get "kind",typeOf _truck]] call _check;
    ["supply_truck_ready",alive _truck && {canMove _truck} && {fuel _truck>0} && {crew _truck isEqualTo []}] call _check;
    ["supply_native_created",[_name,"LOG","CREATED"] call _nativeState] call _check;
    private _funds=server getVariable "resourcesFIA";private _reward=300*([1,2] select (_supply get "difficult"));
    private _position=(getPosATL petros) findEmptyPosition [10,60,typeOf _truck];
    ["supply_hq_position",_position isNotEqualTo []] call _check;
    if (_position isNotEqualTo []) then {
        // Controlled delivery placement exercises the real predicate, not driving.
        _truck setVelocity [0,0,0];_truck setPosATL _position;
        private _settled=[{_supply get "settled"},30] call _wait;
        ["supply_delivered",_settled && {_supply get "outcome"=="delivered"}] call _check;
        ["supply_native_succeeded",[_name,"LOG","SUCCEEDED"] call _nativeState] call _check;
        private _paid=[{server getVariable "resourcesFIA"==_funds+_reward},30] call _wait;
        ["supply_reward_exact",_paid,[_funds,_reward,server getVariable "resourcesFIA"]] call _check;
        private _retired=[{_supply get "assetRetired"},30] call _wait;
        ["supply_truck_kept",_retired && {alive _truck} && {canMove _truck} && {_truck getVariable ["ownerSide",sideUnknown]==teamPlayer}] call _check;
        ["supply_persistent_truck",_truck in staticsToSave && {{_x==_truck} count staticsToSave==1}] call _check;
        sleep 5;
        ["supply_settlement_stable",alive _truck && {server getVariable "resourcesFIA"==_funds+_reward}] call _check;
    };
};
removeMissionEventHandler ["EntityCreated",_createdEH];
[_trace] call CBA_fnc_removePerFrameHandler;
["hq_intact",alive petros && {!isNull boxX} && {!isNull flagX}] call _check;
diag_log format ["[INFECTION_MISSION_SUCCESS] %1",["complete",_checks,_failures]];
