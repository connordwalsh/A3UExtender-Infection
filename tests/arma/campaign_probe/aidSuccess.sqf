// Controlled delivery/clearance with native AI escort activation and real timer.
params ["_record","_check","_wait"];
private _name=_record get "name";private _target=_record get "target";
private _package=_record get "package";private _ledger=_record get "ledger";
private _pickup=_record get "pickupMarker";
private _center=getMarkerPos _target;
private _group=createGroup [teamPlayer,true];
private _escort=_group createUnit ["I_G_Soldier_F",_center,[],0,"NONE"];
_escort allowDamage false;_escort disableAI "MOVE";_escort disableAI "TARGET";_escort disableAI "AUTOTARGET";
// Native distanceUnits and distance activation recognize this AI as an escort.
_escort setVariable ["spawner",true,true];
_package setPosATL _center;
["capable_native_escort",[_escort] call A3A_fnc_canFight && {_escort in ([80,0,_package,teamPlayer] call A3A_fnc_distanceUnits)}] call _check;
private _active=[{_target in (missionNamespace getVariable ["A3I_sites",createHashMap])},180] call _wait;
["escort_activates_town",_active] call _check;
if (!_active) exitWith {deleteVehicle _escort;deleteGroup _group};
private _site=A3I_sites get _target;
private _expected=count (([_target] call A3I_fnc_cityRoster) # 0)+count (garrison getVariable [_target,[]]);
private _full=[{count (_site get "units")>=_expected && {count (_site get "queue")==0}},180] call _wait;
["full_town_population",_full && {_expected>=10},[_expected,count (_site get "units")]] call _check;
private _units=+(_site get "units");
private _living=_units select {alive _x};
if (_living isEqualTo []) exitWith {deleteVehicle _escort;deleteGroup _group};
// Hold one real town infected nearby to make the pause condition deterministic.
private _blocker=_living # 0;
_blocker disableAI "MOVE";_blocker setPosATL (_center vectorAdd [8,0,0]);
sleep 3;
private _before=_ledger get "unloadedSeconds";sleep 5;
["nearby_infected_pause",alive _blocker && {_blocker distance _package<50}
    && {_ledger get "unloadedSeconds"==_before} && {!(_ledger get "wasEligible")}] call _check;
// Controlled engine deaths, not a combat, weapon or player escort claim.
{if (alive _x) then {_x setDamage 1}} forEach _units;
private _clear=[{(_units findIf {alive _x})==-1},30] call _wait;
["town_clearance",_clear] call _check;
private _support=+(A3A_townData get _target);
private _start=diag_tickTime;
private _required=_ledger get "requiredSeconds";
private _progressBefore=_ledger get "unloadedSeconds";
private _unloading=[{_ledger get "wasEligible"},30] call _wait;
["clearance_resumes_unloading",_unloading] call _check;
private _settled=[{_record get "settled"},_required+120] call _wait;
["native_unloading_succeeded",_settled && {_record get "outcome"=="delivered"}
    && {_ledger get "unloadedSeconds"==_required},[_required,_ledger get "unloadedSeconds",diag_tickTime-_start]] call _check;
["timer_not_shortened",diag_tickTime-_start>=_required-_progressBefore-2] call _check;
["native_task_succeeded",[_name] call BIS_fnc_taskState=="SUCCEEDED"
    && {(A3A_tasksData findIf {_x # 0==_name && {_x # 1=="SUPP"} && {_x # 2=="SUCCEEDED"}})>=0}] call _check;
private _bonus=[1,2] select (_record get "difficult");
private _delta=5*_bonus*200/((_support # 0) max 50);
private _gov=0 max ((_support # 2)-_delta);private _reb=0 max ((_support # 3)+_delta);
private _sum=_gov+_reb;if (_sum>100) then {_gov=_gov*100/_sum;_reb=_reb*100/_sum};
private _rewarded=[{private _now=A3A_townData get _target;abs ((_now # 2)-_gov)<0.001 && {abs ((_now # 3)-_reb)<0.001}},30] call _wait;
["native_support_reward",_rewarded,[_support,A3A_townData get _target,[_gov,_reb]]] call _check;
private _clean=[{_record get "assetRetired" && {isNull _package}},30] call _wait;
["package_cleanup",_clean && {!(_pickup in allMapMarkers)}] call _check;
["supply_lock_released",isNil "A3I_aidSupplyLock" && {isNil "A3A_supplyMissionActive"}] call _check;
private _after=+(A3A_townData get _target);sleep 5;
["reward_stable",(A3A_townData get _target) isEqualTo _after] call _check;
deleteVehicle _escort;deleteGroup _group;
private _retired=[{!(_target in A3I_sites)},180] call _wait;
["town_despawns_after_escort",_retired] call _check;
["escort_cleanup",isNull _escort && {isNull _group}] call _check;
["hq_intact",alive petros && {!isNull boxX} && {!isNull flagX}] call _check;
