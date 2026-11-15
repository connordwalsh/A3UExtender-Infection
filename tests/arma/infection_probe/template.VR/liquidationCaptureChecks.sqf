// Controlled live ownership transitions with native campaign side effects.
#include "\x\a3a\addons\core\script_component.hpp"
private _before = entities [[],[],true,false];
private _groupsBefore = +allGroups;
private _savedCap = A3I_activeLimit;
private _savedContext = A3I_contextLimit;
private _setLimits = {
    params ["_global","_context"];
    ["A3I_activeLimit",_global,2,"server",false] call CBA_settings_fnc_set;
    ["A3I_contextLimit",_context,2,"server",false] call CBA_settings_fnc_set;
};
private _wait = {
    params ["_predicate",["_timeout",8]];
    private _deadline = diag_tickTime + _timeout;
    waitUntil {sleep 0.05;call _predicate || {diag_tickTime > _deadline}};
    call _predicate
};
private _source = "a3i_lcap_town";
private _target = "a3i_lcap_factory";
private _ordinary = "a3i_lcap_ordinary";
private _position = [5000,4500,0];
sidesX = [true] call A3A_fnc_createNamespace;
spawner = [true] call A3A_fnc_createNamespace;
garrison = [true] call A3A_fnc_createNamespace;
server = [true] call A3A_fnc_createNamespace;
killZones = [true] call A3A_fnc_createNamespace;
respawnTeamPlayer = "Synd_HQ";
createMarker [_source,[4000,4500,0]];
createMarker [_target,_position];
createMarker [_ordinary,[8000,4500,0]];
createMarker [respawnTeamPlayer,[5200,4500,0]];
private _markers = [_source,_target,_ordinary,respawnTeamPlayer];
{
    _x setMarkerShape "ELLIPSE"; _x setMarkerSize [50,50];
    sidesX setVariable [_x,west]; spawner setVariable [_x,2];
    garrison setVariable [_x,[]]; server setVariable [_x,0];
} forEach _markers;
sidesX setVariable [_target,Invaders]; sidesX setVariable [_ordinary,Invaders];
sidesX setVariable [respawnTeamPlayer,teamPlayer];
citiesX = [_source]; factories = [_target,_ordinary];
airportsX = []; outposts = []; milbases = []; resourcesX = []; seaports = [];
milAdministrationsX = []; controlsX = []; markersX = +_markers; forcedSpawn = [];
antennas = []; antennasDead = []; staticsToSave = []; A3A_milBuildingWhitelist = [];
distanceSPWN = 1000; distanceSPWN1 = 1000; distanceSPWN2 = 1000;
distanceForLandAttack = 2000; distanceMission = 1500;
NavGrid = [[[4000,4500,0],1,0,[[1,0,1000]]],[[5000,4500,0],1,0,[[0,0,1000]]]];
A3A_navCellHM = createHashMap; {_forEachIndex call A3A_fnc_addToNavCells} forEach NavGrid;
A3A_markerNavPoints = createHashMap;
A3A_recentDamageOcc = []; A3A_recentDamageInv = [];
A3A_hasACE = false; A3A_GCThreshold = 600;
GVAR(despawnQueue) = []; GVAR(despawnerRunning) = nil;
A3A_faction_reb = createHashMapFromArray [["name","Fixture Rebels"],["diveGear",[]],["flyGear",[]]];
A3A_faction_inv = createHashMapFromArray [["name","Fixture Invaders"]];
A3A_faction_civ = createHashMapFromArray [["attributeLowCiv",true],["currencySymbol","$"]];
A3A_supportStrikes = []; A3A_supportSpends = []; A3A_supportMarkerTypes = [[_target,0,0,1]];
A3A_tasksData = []; A3A_activeTasks = []; A3A_taskCount = 0;
A3A_invaderBalanceMul = 10; A3A_balanceVehicleCost = 10; A3A_balancePlayerScale = 1; A3A_balanceResourceRate = 100;
bigAttackInProgress = false; HQAttackInProgress = false; theBoss = objNull;
areOccupantsDefeated = false; areInvadersDefeated = false;
// Keep fixture garrison preferences fixed while native tierCheck still runs.
tierPreference = 10; tierWar = 0; gameMode = 3; plusGarrison = true; debug = false;
aggressionOccupants = 0; aggressionInvaders = 0;
resourcesIsChanging = false; limitHR = 0; server setVariable ["hr",100];
garrisonIsChanging = false; markersChanging = [];
{garrison setVariable [_x + "_preference",[]]} forEach ["Other","Airport","Outpost","MilitaryBase"];
private _petrosGroup = createGroup [teamPlayer,true];
petros = _petrosGroup createUnit ["I_G_Soldier_F",[5200,4500,0],[],0,"NONE"];
petros enableSimulationGlobal false;
hcArray = [];
A3I_test_originals = []; A3I_test_support = []; A3I_test_aggression = []; A3I_test_zones = [];
A3I_test_comms = []; A3I_test_markerUpdates = [];
A3I_test_nativeMarkerChange = false; A3I_test_applyMarkerChange = false;

A3I_liquidationClaims = createHashMap;
A3I_sites = createHashMap;
A3A_milAdministrations = []; A3A_destroyedMilAdministrations = [];
reinforceMarkerOccupants = []; reinforceMarkerInvaders = [];
canReinforceOccupants = []; canReinforceInvaders = [];
A3A_resourcesAttackOcc = 0; A3A_resourcesDefenceOcc = 0;
A3A_resourcesAttackInv = 0; A3A_resourcesDefenceInv = 0;
private _worker = [] spawn {sleep 300};
private _site = createHashMapFromArray [["id",1],["kind","Resource"],["context","site:" + _target],
    ["cleaned",false],["fault",""],["script",_worker],["queue",[]],["units",[]],
    ["clearanceRemaining",1],["clearanceMissing",0],["spawnedAny",true],["captured",sideUnknown],["road",true]];
A3I_sites set [_target,_site];
private _claim = createHashMap;
private _resetClaim = {
    _claim = createHashMapFromArray [["name","A3I_LIQ_capture_fixture"],["target",_target],
        ["settled",false],["outcome","pending"],["deadline",dateToNumber date + 0.01]];
    A3I_liquidationClaims set [_target,_claim];
    // Native capture publishes these object variables. Publish the reset too,
    // so a queued network update cannot restore the previous trial's owner.
    sidesX setVariable [_target,west,true]; spawner setVariable [_target,0,true]; garrison setVariable [_target,[],true];
    _site set ["clearanceRemaining",1]; _site set ["captured",sideUnknown];
};
private _write = {params ["_marker","_side"]; sidesX setVariable [_marker,_side,true]; true};
call _resetClaim;
["liq_capture_claim_resolves",count ([_target] call A3I_fnc_liquidationClaim) > 0
    && {count (["missing"] call A3I_fnc_liquidationClaim) == 0}] call _check;
["liq_capture_remaining_blocks",!([_target,teamPlayer,_write,[_target,teamPlayer]] call A3I_fnc_liquidationTransition)
    && {sidesX getVariable _target == west} && {_claim get "outcome" == "pending"}] call _check;
_site set ["clearanceRemaining",0]; _site set ["queue",["pending"]];
["liq_capture_queue_blocks",!([_target,teamPlayer,_write,[_target,teamPlayer]] call A3I_fnc_liquidationTransition)] call _check;
_site set ["queue",[]]; _site set ["clearanceMissing",1];
["liq_capture_missing_blocks",!([_target,teamPlayer,_write,[_target,teamPlayer]] call A3I_fnc_liquidationTransition)] call _check;
_site set ["clearanceMissing",0]; spawner setVariable [_target,2];
["liq_capture_despawn_blocks",!([_target,teamPlayer,_write,[_target,teamPlayer]] call A3I_fnc_liquidationTransition)] call _check;
spawner setVariable [_target,0]; airportsX = [_target]; tierWar = 2;
["liq_capture_military_tier_blocks",!([_target,teamPlayer,_write,[_target,teamPlayer]] call A3I_fnc_liquidationTransition)] call _check;
airportsX = []; tierWar = 0; _claim set ["deadline",dateToNumber date - 0.001];
["liq_capture_expiry_blocks",!([_target,teamPlayer,_write,[_target,teamPlayer]] call A3I_fnc_liquidationTransition)] call _check;
_claim set ["deadline",dateToNumber date + 0.01];
["liq_capture_failed_write_no_result",!([_target,teamPlayer,{false}] call A3I_fnc_liquidationTransition)
    && {_claim get "outcome" == "pending"}] call _check;
["liq_capture_clear_freezes_success",[_target,teamPlayer,_write,[_target,teamPlayer]] call A3I_fnc_liquidationTransition
    && {_claim get "outcome" == "won"} && {sidesX getVariable _target == teamPlayer}
    && {count ([_target] call A3I_fnc_liquidationClaim) == 0}] call _check;
call _resetClaim;
isNil {
    [_target,east,_write,[_target,east]] call A3I_fnc_liquidationTransition;
    [_target,teamPlayer,_write,[_target,teamPlayer]] call A3I_fnc_liquidationTransition;
};
["liq_capture_russian_then_rebel_stays_cancelled",_claim get "outcome" == "cancelled"
    && {_claim get "captureOwner" == east} && {sidesX getVariable _target == teamPlayer}] call _check;
call _resetClaim; A3I_liquidationClaims deleteAt _target;
["liq_capture_unassigned_native_write",[_target,teamPlayer,_write,[_target,teamPlayer]] call A3I_fnc_liquidationTransition
    && {_claim get "outcome" == "pending"}] call _check;

// Exercise the copied native permanent-site body through the production override.
call _resetClaim;
[teamPlayer,_target] call A3A_fnc_markerChange;
["liq_capture_native_site_blocks_before_clear",sidesX getVariable _target == west
    && {markersChanging isEqualTo []} && {_claim get "outcome" == "pending"}] call _check;
_site set ["clearanceRemaining",0];
[teamPlayer,_target] call A3A_fnc_markerChange;
["liq_capture_native_site_commits",sidesX getVariable _target == teamPlayer
    && {_claim get "outcome" == "won"} && {markersChanging isEqualTo []}
    && {garrison getVariable _target isEqualTo []}] call _check;
call _resetClaim;
[east,_target] remoteExec ["A3A_fnc_markerChange",2];
[{_claim get "outcome" == "cancelled" && {markersChanging isEqualTo []}}] call _wait;
["liq_capture_native_remote_russian_cancels",sidesX getVariable _target == east
    && {_claim get "outcome" == "cancelled"} && {markersChanging isEqualTo []}] call _check;
private _remoteTrials = [];
for "_trial" from 1 to 12 do {
    call _resetClaim; _site set ["clearanceRemaining",0];
    A3I_test_captureTrace = [];
    [teamPlayer,_target] remoteExec ["A3A_fnc_markerChange",2];
    private _finished = [{_claim get "outcome" == "won" && {markersChanging isEqualTo []}}] call _wait;
    private _trialResult = [_finished,str (sidesX getVariable _target),_claim get "outcome",
        +markersChanging,[_target] call A3I_fnc_siteClearance,+A3I_test_captureTrace];
    diag_log format ["[INFECTION_DIAGNOSTIC] %1",["capture_remote_trial",_trial,_trialResult]];
    _remoteTrials pushBack (_trialResult select [0,4]);
};
A3I_test_captureTrace = nil;
["liq_capture_native_remote_rebel_clearance",(_remoteTrials findIf {!(_x # 0)
    || {_x # 1 != str teamPlayer} || {_x # 2 != "won"} || {_x # 3 isNotEqualTo []}}) == -1,
    _remoteTrials] call _check;

// Town political capture must use the same ledger, then retain native effects.
call _resetClaim; citiesX pushBack _target; factories = [_ordinary]; _site set ["kind","City"];
[_target,true] call A3A_fnc_cityChangeSide;
["liq_capture_native_city_blocks_before_clear",sidesX getVariable _target == west
    && {_claim get "outcome" == "pending"}] call _check;
_site set ["clearanceRemaining",0]; A3I_test_support = []; A3I_test_aggression = [];
[_target,true] call A3A_fnc_cityChangeSide;
sleep 0.3;
["liq_capture_native_city_commits",sidesX getVariable _target == teamPlayer
    && {_claim get "outcome" == "won"}
    && {[-10,10,_target,false] in A3I_test_support}
    && {[west,10,60] in A3I_test_aggression}] call _check;
// Let the independent native maintenance run before fixture globals are retired.
sleep 5.2;
citiesX = [_source]; factories = [_target,_ordinary];

// Road controls keep their ordinary contender rule but require full clearance.
call _resetClaim; controlsX = [_target]; _site set ["kind","Control"];
private _contender = _petrosGroup createUnit ["I_G_Soldier_F",_position,[],0,"NONE"];
_contender disableAI "ALL";
["liq_capture_control_blocks_before_clear",[_target,_site] call A3I_fnc_tryCaptureControl == sideUnknown
    && {sidesX getVariable _target == west}] call _check;
_site set ["clearanceRemaining",0];
["liq_capture_control_commits",[_target,_site] call A3I_fnc_tryCaptureControl == teamPlayer
    && {_claim get "outcome" == "won"} && {_site get "captured" == teamPlayer}] call _check;
deleteVehicle _contender; controlsX = [];

// Administrative capture uses the installed native completed-building registry.
call _resetClaim; _site set ["kind","MilAdmin"]; _site set ["remainingDefenders",0];
private _building = createVehicle ["Land_i_Barracks_V1_F",_position,[],0,"CAN_COLLIDE"];
_site set ["building",_building]; milAdministrationsX = [_target]; A3A_milAdministrations = [_building];
A3I_test_realAdminCapture = true;
["liq_capture_admin_blocks_before_clear",!([_target] call A3I_fnc_tryCaptureAdministration)
    && {sidesX getVariable _target == west} && {A3A_destroyedMilAdministrations isEqualTo []}] call _check;
_site set ["clearanceRemaining",0];
["liq_capture_admin_commits",[_target] call A3I_fnc_tryCaptureAdministration
    && {_claim get "outcome" == "won"} && {_building in A3A_destroyedMilAdministrations}] call _check;
A3I_test_realAdminCapture = false;
deleteVehicle _building; milAdministrationsX = []; A3A_milAdministrations = []; A3A_destroyedMilAdministrations = [];
// Allow native enemy-capture static cleanup to finish before deleting spawner.
{spawner setVariable [_x,2,true]} forEach _markers;
sleep 1.5;
terminate _worker; A3I_liquidationClaims = createHashMap; A3I_sites = createHashMap;
deleteVehicle petros; sleep 0.2; deleteGroup _petrosGroup;
{deleteVehicle _x} forEach [sidesX,spawner,garrison,server,killZones];
{deleteMarker _x} forEach _markers;
sleep 0.2;
["liq_capture_cleanup",(entities [[],[],true,false]) - _before isEqualTo []
    && {allGroups - _groupsBefore isEqualTo []} && {count A3I_liquidationClaims == 0}] call _check;
