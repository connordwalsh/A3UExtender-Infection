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

A3I_test_originals=[]; A3I_test_comms=[]; hcArray=[];
A3I_extractionTasks=createHashMap;
private _variants=["RES_Refugees","RES_Prisoners","RES_Deserters","RIV_RES_Prisoners"];
private _aliases=["originalRESRefugees","originalRESPrisoners","originalRESDeserters","originalRIVRESPrisoners"];
private _get={
    [{count A3I_extractionTasks==1}] call _wait;
    private _job=(values A3I_extractionTasks) param [0,createHashMap];
    if (count _job>0) then {
        [{_job get "phase" != "preparing"}] call _wait;
        {_x enableSimulationGlobal false} forEach ((_job get "units")+(_job get "guards"));
    };
    _job
};
private _retire={params ["_job"];
    if (count (_job get "ledger")>0) then {(_job get "ledger") set ["deadline",time-1]};
    [{_job get "settled"}] call _wait;
    _job set ["cleanupAt",time-1];_job set ["taskDeleteAt",time-1];
    [{count A3I_extractionTasks==0 && {isNil "A3I_extractionTaskHandle"}}] call _wait;
};
private _saved=A3A_faction_occ; A3A_faction_occ=createHashMap;
private _expected=[];
{[_source] call (missionNamespace getVariable ("A3A_fnc_"+_x));
    _expected pushBack [_aliases # _forEachIndex,[_source]]
} forEach _variants;
["RES",2,true] call A3A_fnc_missionRequest;
[[_source],"A3A_fnc_RES_Refugees"] call A3A_fnc_scheduler;
_expected append [["missionRequest",["RES",2,true]],["originalScheduler",[[_source],"A3A_fnc_RES_Refugees"]]];
["exdispatch_native_delegation",A3I_test_originals isEqualTo _expected] call _check;
A3A_faction_occ=_saved;A3I_test_originals=[];
{
    [_source] call (missionNamespace getVariable ("A3A_fnc_"+_x));
    private _job=call _get;
    ["exdispatch_direct_"+_x,count _job>0 && {_job get "taskRegistered"}
        && {count (_job get "guards")==4} && {A3I_test_originals isEqualTo []}] call _check;
    if (count _job>0) then {[_job] call _retire};
} forEach _variants;
{
    hcArray=[98765];[[_source],"A3A_fnc_"+_x] call A3A_fnc_scheduler;
    private _job=call _get;
    ["exdispatch_scheduler_"+_x,count _job>0 && {_job get "taskRegistered"}
        && {((_job get "units") findIf {!local _x})==-1} && {A3I_test_originals isEqualTo []}] call _check;
    if (count _job>0) then {[_job] call _retire};
} forEach _variants;
hcArray=[];
["RES",2,false] call A3A_fnc_missionRequest;private _job=call _get;
[{A3I_test_comms isNotEqualTo []},3] call _wait;
["exdispatch_request_after_registration",count _job>0 && {_job get "taskRegistered"}
    && {A3I_test_comms findIf {(_x param [2,""])==localize "STR_chats_mission_request_success"}>=0}] call _check;
private _serial=A3I_extractionTaskSerial;
["RES",2,true] call A3A_fnc_missionRequest;
["exdispatch_duplicate_refused",A3I_extractionTaskSerial==_serial && {count A3I_extractionTasks==1}] call _check;
if (count _job>0) then {[_job] call _retire};
A3I_test_comms=[];["RES",2,true] remoteExecCall ["A3A_fnc_missionRequest",2];_job=call _get;sleep 0.2;
["exdispatch_remote_silent",count _job>0 && {_job get "taskRegistered"} && {A3I_test_comms isEqualTo []}] call _check;
if (count _job>0) then {[_job] call _retire};
[_source] remoteExecCall ["A3I_fnc_startExtraction",2];sleep 0.2;
["exdispatch_remote_constructor_refused",count A3I_extractionTasks==0] call _check;
A3A_missionRequestInProgress=true;
private _waiting=["RES",2,true] spawn A3A_fnc_missionRequest;sleep 0.2;
["exdispatch_waits_native_lock",count A3I_extractionTasks==0 && {!scriptDone _waiting}] call _check;
terminate _waiting;sleep 0.2;
["exdispatch_preserves_native_lock",A3A_missionRequestInProgress && {count A3I_extractionTasks==0}] call _check;
A3A_missionRequestInProgress=nil;
sidesX setVariable [_source,east];A3I_test_comms=[];
["RES",2,false] call A3A_fnc_missionRequest;sleep 0.2;
["exdispatch_no_human_fallback",count A3I_extractionTasks==0 && {A3I_test_originals isEqualTo []}
    && {A3I_test_comms findIf {(_x param [2,""])=="No Extraction Mission is available."}>=0}] call _check;
sidesX setVariable [_source,west];
[""] call A3A_fnc_RES_Refugees;["missing"] call A3A_fnc_RES_Prisoners;sleep 0.3;
["exdispatch_invalid_source_refused",count A3I_extractionTasks==0] call _check;
private _modern=configFile >> "A3A_RequestMissionDialog" >> "Controls" >> "MainContent" >> "Controls" >> "RescueButton";
private _legacy=configFile >> "missionMenu" >> "Controls" >> "resButton";
["exdispatch_menu_hooks",getText (_modern >> "onLoad")=="_this call A3I_fnc_labelExtractionControl"
    && {getText (_legacy >> "onLoad")=="_this call A3I_fnc_labelExtractionControl"}
    && {getText (_modern >> "onButtonClick")!=""} && {getText (_legacy >> "action")!=""}] call _check;
["exdispatch_all_routes_registered",(_variants findIf {
    getText (configFile >> "CfgFunctions" >> "A3A" >> "Missions" >> _x >> "file")
    != ("\x\a3i\addons\core\overrides\fn_"+_x+".sqf")})==-1] call _check;
{deleteVehicle _x} forEach [_building,boxX,petros,sidesX,server];deleteGroup _players;
{deleteMarker _x} forEach _markers;sleep 1.5;
["exdispatch_final_cleanup",(entities [[],[],true,false])-_before isEqualTo [] && {allGroups-_groupsBefore isEqualTo []}
    && {count A3I_extractionTasks==0} && {count A3I_extractionLedgers==0} && {count A3I_budgetRecords==0}
    && {A3A_tasksData isEqualTo []} && {isNil "A3I_extractionTaskHandle"}] call _check;
