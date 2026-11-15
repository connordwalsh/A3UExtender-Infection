// Native tasks/resources with actual survivors and budgeted guards; accelerated deadlines/retention.
#include "\x\a3a\addons\core\script_component.hpp"
private _before=entities [[],[],true,false]; private _groupsBefore=+allGroups;
sidesX=[true] call A3A_fnc_createNamespace; server=[true] call A3A_fnc_createNamespace;
respawnTeamPlayer="a3i_extask_hq"; posHQ=[3000,3000,0];
private _source="a3i_extask_source"; private _friendly="a3i_extask_friendly";
createMarker [respawnTeamPlayer,posHQ]; createMarker [_source,[4500,4500,0]]; createMarker [_friendly,[3500,4500,0]];
private _markers=[respawnTeamPlayer,_source,_friendly];
{_x setMarkerShape "ELLIPSE"; _x setMarkerSize [100,100]; sidesX setVariable [_x,west]} forEach _markers;
sidesX setVariable [respawnTeamPlayer,teamPlayer]; sidesX setVariable [_friendly,teamPlayer];
markersX=+_markers; citiesX=[_source]; factories=[_friendly];
outposts=[]; airportsX=[]; milbases=[]; seaports=[]; resourcesX=[]; controlsX=[]; milAdministrationsX=[];
private _players=createGroup teamPlayer;
petros=_players createUnit ["I_G_Soldier_F",posHQ,[],0,"NONE"]; petros enableSimulationGlobal false;
theBoss=objNull; distanceMission=3000; distanceSPWN=300; tierWar=0;
overallHRGain=80; resourcesIsChanging=false; limitHR=0;
server setVariable ["hr",10]; server setVariable ["resourcesFIA",1000];
A3A_faction_reb=createHashMapFromArray [["unitUnarmed","C_man_1"],["uniforms",["U_C_Poloshirt_blue"]],["name","NATO"]];
A3A_faction_civ=createHashMapFromArray [["currencySymbol","$"]];
A3A_buildingBlacklist=[]; A3I_test_observers=[]; A3I_test_aggression=[];
A3A_tasksData=[]; A3A_activeTasks=[]; A3A_taskCount=0;
A3A_resourcesAttackOcc=1000; A3A_resourcesDefenceOcc=1000;
A3A_GCThreshold=600; GVAR(despawnQueue)=[]; GVAR(despawnerRunning)=nil;
A3A_hasACE=false; A3A_recentDamageOcc=[];
unlockedWeapons=[]; unlockedMagazines=[];
boxX=createVehicle ["Box_NATO_Ammo_F",posHQ,[],0,"NONE"];
clearWeaponCargoGlobal boxX; clearMagazineCargoGlobal boxX; clearItemCargoGlobal boxX;
private _building=createVehicle ["Land_i_Barracks_V1_F",getMarkerPos _source,[],0,"CAN_COLLIDE"];
sleep 0.5;
private _wait={params ["_condition",["_seconds",12]];private _until=diag_tickTime+_seconds;
    waitUntil {sleep 0.05;call _condition || {diag_tickTime>_until}};call _condition};
private _start={
    private _accepted=[_source] call A3I_fnc_startExtraction;
    private _r=A3I_extractionTasks getOrDefault ["A3I_EXTRACTION_"+str A3I_extractionTaskSerial,createHashMap];
    [{_r get "phase" != "preparing"}] call _wait;
    {_x enableSimulationGlobal false} forEach ((_r get "units")+(_r get "guards"));
    [_accepted,_r]
};
private _state={params ["_r"];private _i=A3A_tasksData findIf {_x # 0 == _r get "name"};
    if (_i<0) then {"MISSING"} else {A3A_tasksData # _i # 2}};
private _clean={params ["_r"];_r set ["taskDeleteAt",time-1];_r set ["cleanupAt",time-1];
    [{!((_r get "name") in A3I_extractionTasks)},8] call _wait};
["extask_invalid_target_refused",!([_friendly] call A3I_fnc_startExtraction)] call _check;
A3A_tasksData=[["foreign","RES","CREATED",time]];
["extask_foreign_task_refused",!([_source] call A3I_fnc_startExtraction)] call _check;
A3A_tasksData=[];
private _made=call _start;private _r=_made # 1;private _units=+(_r get "units");
["extask_native_task_created",_made # 0 && {_r get "phase" == "active"} && {([_r] call _state)=="CREATED"}
    && {count _units>=2 && {count _units<=6}}] call _check;
["extask_four_managed_guards",count (_r get "guards")==4
    && {((_r get "guards") findIf {!([_x] call A3I_fnc_isManagedUnit) || {!(_x inArea _source)}})==-1}] call _check;
["extask_normal_deadline",_r get "duration"==3600] call _check;
["extask_duplicate_refused",!([_source] call A3I_fnc_startExtraction)] call _check;
private _first=_units # 0;
_first addWeapon "hgun_P07_F";
_first setPosATL posHQ;
[{isNull _first && {server getVariable "hr"==12}}] call _wait;
["extask_delivery_converts_once",isNull _first && {server getVariable "hr"==12}
    && {(_r get "ledger") get "rescued"==1}] call _check;
["extask_delivery_inventory_recovered",("hgun_P07_F" in (getWeaponCargo boxX # 0))] call _check;
["extask_first_rescue_keeps_task",!(_r get "settled") && {([_r] call _state)=="CREATED"}
    && {server getVariable "resourcesFIA"==1000}] call _check;
[_r] call A3I_fnc_convertExtractionRescues; sleep 0.2;
["extask_no_double_manpower",server getVariable "hr"==12] call _check;
{_x setDamage 1} forEach (_units select [1]);
[{_r get "settled" && {server getVariable "resourcesFIA"==1100}}] call _wait;
private _immediateSuccess=[_r] call _state;
[{([_r] call _state)=="SUCCEEDED"},5] call _wait;
["extask_all_resolved_success",_r get "outcome"=="succeeded" && {([_r] call _state)=="SUCCEEDED"},[_immediateSuccess,[_r] call _state]] call _check;
["extask_native_scaled_rewards",server getVariable "resourcesFIA"==1100 && {server getVariable "hr"==12}] call _check;
["extask_native_cleanup_delay",(_r get "cleanupAt")>time+55 && {(_r get "cleanupAt")<=time+60}] call _check;
[_r] call A3I_fnc_finishExtraction; sleep 0.2;
["extask_settlement_once",server getVariable "resourcesFIA"==1100 && {server getVariable "hr"==12}] call _check;
["extask_first_cleanup",[_r] call _clean] call _check;
// Difficult partial rescue at a permanent site, followed by deadline.
tierWar=11; _made=call _start;_r=_made # 1;_units=+(_r get "units");
["extask_hard_deadline",_r get "duration"==1800] call _check;
_first=_units # 0;_first setPosATL getMarkerPos _friendly;
[{isNull _first && {server getVariable "hr"==14}}] call _wait;
private _late=_units # 1;
[_late] joinSilent _players;
(_r get "ledger") set ["deadline",time-1];
[{_r get "settled" && {server getVariable "resourcesFIA"==1300}}] call _wait;
["extask_partial_deadline_success",_r get "outcome"=="succeeded" && {alive _late}
    && {server getVariable "hr"==14}] call _check;
_late setPosATL posHQ; sleep 1.2;
["extask_late_delivery_no_credit",server getVariable "hr"==14 && {server getVariable "resourcesFIA"==1300}] call _check;
["extask_partial_cleanup",[_r] call _clean] call _check;
["extask_undelivered_squad_removed",isNull _late && {!isNull _players} && {alive petros}] call _check;
// No rescued survivors means failure at deadline.
tierWar=0;_made=call _start;_r=_made # 1;
(_r get "ledger") set ["deadline",time-1];
[{_r get "settled"}] call _wait;
private _immediateFailure=[_r] call _state;
[{([_r] call _state)=="FAILED"},5] call _wait;
["extask_zero_rescue_fails",_r get "outcome"=="failed" && {([_r] call _state)=="FAILED"}
    && {server getVariable "hr"==14} && {server getVariable "resourcesFIA"==1300},[_immediateFailure,[_r] call _state]] call _check;
["extask_failed_cleanup",[_r] call _clean] call _check;
// Ownership changes do not erase the already created survivors' objectives.
_made=call _start;_r=_made # 1;_units=+(_r get "units");
sidesX setVariable [_source,east];
[{([_r] call A3I_fnc_extractionTaskOutcome)=="pending"},2] call _wait;
["extask_existing_rescue_survives_capture",!(_r get "settled") && {([_r] call A3I_fnc_extractionTaskOutcome)=="pending"}] call _check;
{_x setDamage 1} forEach _units;
[{_r get "settled"}] call _wait;
["extask_all_killed_fails",_r get "outcome"=="failed"] call _check;
[_r] call _clean; sidesX setVariable [_source,west];
["extask_final_rewards_unchanged",server getVariable "hr"==14 && {server getVariable "resourcesFIA"==1300}] call _check;
{deleteVehicle _x} forEach [_building,boxX,petros,sidesX,server];deleteGroup _players;
{deleteMarker _x} forEach _markers;sleep 1.5;
["extask_final_cleanup",(entities [[],[],true,false])-_before isEqualTo [] && {allGroups-_groupsBefore isEqualTo []}
    && {count A3I_extractionTasks==0} && {count A3I_extractionLedgers==0} && {count A3I_budgetRecords==0}
    && {isNil "A3I_extractionTaskHandle"} && {isNil "A3I_extractionReleaseHandle"}] call _check;
