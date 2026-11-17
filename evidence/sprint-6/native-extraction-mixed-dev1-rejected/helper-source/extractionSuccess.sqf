// Trusted server AI release and controlled delivery, not a player action test.
params ["_record","_survivors","_guards","_groups","_check","_wait"];
private _mixedMode=call compile preprocessFileLineNumbers "\x\a3i\tests\campaign\extraction-mixed-mode.sqf";
private _rescueCount=if (_mixedMode) then {1} else {count _survivors};
private _name=_record get "name";
private _ledger=_record get "ledger";
private _funds=server getVariable "resourcesFIA";
private _hr=server getVariable "hr";
private _factor=_record get "hrFactor";
private _bonus=[1,2] select (_record get "difficult");
// Remove the real mission guards through engine deaths, without claiming combat.
{_x setDamage 1} forEach _guards;
private _rescuerGroup=createGroup [teamPlayer,true];
private _rescuer=_rescuerGroup createUnit ["I_G_Soldier_F",getPosATL (_survivors # 0),[],0,"NONE"];
_rescuer disableAI "MOVE";
removeAllWeapons _rescuer;
["server_ai_rescuer",alive _rescuer && {!isPlayer _rescuer} && {side group _rescuer==teamPlayer}] call _check;
["public_player_action_rejects_ai",!([_survivors # 0,_rescuer] call A3I_fnc_requestExtractionRelease)] call _check;
private _itemCount={params ["_box"];private _cargo=getItemCargo _box;private _index=(_cargo # 0) find "FirstAidKit";
    if (_index < 0) then {0} else {(_cargo # 1) # _index}};
private _itemsBefore=[boxX] call _itemCount;
private _itemsDelivered=0;
private _releaseOK=true;private _joinOK=true;private _nativeOK=true;
private _deliveryOK=true;private _partialOK=true;private _hrOK=true;
private _details=[];
{
    private _unit=_x;
    private _index=_forEachIndex;
    private _entry=(_ledger get "entries") # _index;
    _rescuer setPosATL getPosATL _unit;
    private _accepted=[_unit,_rescuer] call A3I_fnc_beginExtractionRelease;
    _releaseOK=_releaseOK && {_accepted};
    private _released=[{(_unit getVariable ["A3I_extractionReleaseState",""])=="released"},12] call _wait;
    _joinOK=_joinOK && {_released} && {group _unit==_rescuerGroup} && {!captive _unit};
    private _token=[_ledger get "name",_ledger get "serial",_index];
    private _initialized=[{(_unit getVariable ["A3I_extractionRecruitInitialized",[]]) isEqualTo _token
        && {_unit getVariable ["spawner",false]} && {abs ((_unit getUnitTrait "camouflageCoef")-0.8)<0.001}},15] call _wait;
    _nativeOK=_nativeOK && {_initialized};
    // Known recoverable inventory, without altering conversion or arsenal handlers.
    _unit addItem "FirstAidKit";
    private _kits={_x=="FirstAidKit"} count items _unit;
    _itemsDelivered=_itemsDelivered+_kits;
    _unit setPosATL (getMarkerPos respawnTeamPlayer);
    private _delivered=[{_entry get "state"=="rescued" && {_entry getOrDefault ["converted",false]} && {isNull _unit}},15] call _wait;
    _deliveryOK=_deliveryOK && {_delivered} && {_entry get "destination"==respawnTeamPlayer} && {_kits>0};
    private _credited=ceil ((_index+1)*_factor);
    private _expectedHR=_hr+_credited;
    if (limitHR != 0) then {_expectedHR=_expectedHR min (tierWar*limitHR+100)};
    private _paid=[{server getVariable "hr"==_expectedHR},15] call _wait;
    _hrOK=_hrOK && {_paid} && {_record get "hrCredited"==_credited};
    if (_index < count _survivors-1) then {
        _partialOK=_partialOK && {!(_record get "settled")}
            && {_ledger get "unresolved"==count _survivors-_index-1}
            && {[_name] call BIS_fnc_taskState=="CREATED"}
            && {server getVariable "resourcesFIA"==_funds};
    };
    _details pushBack [_index,_accepted,_released,_initialized,_delivered,_credited,server getVariable "hr"];
} forEach (_survivors select [0,_rescueCount]);
if (_mixedMode) then {{_x setDamage 1} forEach (_survivors select [_rescueCount])};
["trusted_releases_accepted",_releaseOK,_details] call _check;
["survivors_join_ai_group",_joinOK] call _check;
["native_recruit_initialization",_nativeOK] call _check;
["delivered_survivors_removed",_deliveryOK] call _check;
["partial_rescues_keep_task",_partialOK] call _check;
["incremental_manpower_exact",_hrOK,[_hr,_factor,_record get "hrCredited",server getVariable "hr"]] call _check;
["inventory_returns_to_hq",([boxX] call _itemCount)==_itemsBefore+_itemsDelivered,
    [_itemsBefore,_itemsDelivered,[boxX] call _itemCount]] call _check;
private _settled=[{_record get "settled"},30] call _wait;
[["all_rescued_succeeded","mixed_resolved_succeeded"] select _mixedMode,_settled && {_record get "outcome"=="succeeded"}
    && {_ledger get "rescued"==_rescueCount} && {_ledger get "killed"==(count _survivors-_rescueCount)}] call _check;
["native_task_succeeded",(A3A_tasksData findIf {_x # 0==_name && {_x # 1=="RES"} && {_x # 2=="SUCCEEDED"}})>=0
    && {[_name] call BIS_fnc_taskState=="SUCCEEDED"}] call _check;
private _expectedFunds=_funds+100*_rescueCount*_bonus;
private _paid=[{server getVariable "resourcesFIA"==_expectedFunds},30] call _wait;
["completion_reward_exact",_paid,[_funds,_expectedFunds,server getVariable "resourcesFIA"]] call _check;
private _clean=[{_record get "assetRetired" && {((_survivors+_guards) findIf {!isNull _x})==-1}
    && {(_groups findIf {!isNull _x})==-1}},150] call _wait;
["native_delayed_asset_cleanup",_clean] call _check;
private _context="extraction:"+_name;
["budget_released",((keys A3I_budgetRecords) findIf {(A3I_budgetRecords get _x) # 0==_context})==-1] call _check;
private _hrAfter=server getVariable "hr";sleep 5;
["rewards_stable",server getVariable "resourcesFIA"==_expectedFunds && {server getVariable "hr"==_hrAfter}] call _check;
deleteVehicle _rescuer;deleteGroup _rescuerGroup;sleep 0.2;
["rescuer_cleanup",isNull _rescuer && {isNull _rescuerGroup}] call _check;
["hq_intact",alive petros && {!isNull boxX} && {!isNull flagX}] call _check;
