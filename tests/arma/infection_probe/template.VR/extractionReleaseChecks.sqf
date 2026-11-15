// Dedicated server transactions with real AI; not a connected-client action test.
private _before = entities [[],[],true,false]; private _groupsBefore = +allGroups;
sidesX = [true] call A3A_fnc_createNamespace;
respawnTeamPlayer = "a3i_release_hq"; createMarker [respawnTeamPlayer,[500,500,0]];
airportsX=[]; milbases=[]; outposts=[]; factories=[]; resourcesX=[]; seaports=[];
citiesX=[]; controlsX=[]; milAdministrationsX=[];
A3A_hasACE=false; A3A_rebelSkillMul=1; skillFIA=1; tkPunish=false;
A3A_faction_reb=createHashMapFromArray [["unitUnarmed","C_man_1"],["unitSL","I_officer_F"],["unitSniper","I_sniper_F"]];
private _group=createGroup teamPlayer; private _rescuers=createGroup teamPlayer;
private _actors=[];
private _new = {
    private _u=[_group,"C_man_1",[4000,4000,0],[],0,"NONE"] call A3A_fnc_createUnit;
    _u setCaptive true; _u disableAI "MOVE"; _u disableAI "AUTOTARGET"; _u disableAI "TARGET";
    _actors pushBack _u; _u
};
private _rescuer=_rescuers createUnit ["I_G_Soldier_F",[4001,4000,0],[],0,"NONE"];
_rescuer disableAI "MOVE"; _rescuer setVariable ["owner",_rescuer,true];
private _a=call _new; private _b=call _new;
private _r=["release",[_a,_b],time+120] call A3I_fnc_createExtractionLedger;
["exrelease_unbound_refused",!([_a,_rescuer] call A3I_fnc_beginExtractionRelease)] call _check;
["exrelease_bind",[_r] call A3I_fnc_setExtractionActions] call _check;
["exrelease_duplicate_bind",[_r] call A3I_fnc_setExtractionActions
    && {((_r get "entries") # 0) get "releaseState" == "waiting"}] call _check;
["exrelease_public_ai_refused",!([_a,_rescuer] call A3I_fnc_requestExtractionRelease)] call _check;
_rescuer setPosATL [4020,4000,0];
["exrelease_distance_refused",!([_a,_rescuer] call A3I_fnc_beginExtractionRelease)] call _check;
_rescuer setPosATL [4001,4000,0]; _rescuer setVariable ["incapacitated",true];
["exrelease_incapacitated_refused",!([_a,_rescuer] call A3I_fnc_beginExtractionRelease)] call _check;
_rescuer setVariable ["incapacitated",false];
["exrelease_reserved",[_a,_rescuer] call A3I_fnc_beginExtractionRelease] call _check;
["exrelease_duplicate_request_refused",!([_a,_rescuer] call A3I_fnc_beginExtractionRelease)] call _check;
_rescuer setPosATL [4020,4000,0]; sleep 1;
["exrelease_walkaway_retry",((_r get "entries") # 0) get "releaseState" == "waiting" && {group _a == _group}] call _check;
_rescuer setPosATL [4001,4000,0];
[_a,_rescuer] call A3I_fnc_beginExtractionRelease;
private _until=diag_tickTime+8;
waitUntil {sleep 0.1; (_a getVariable ["A3I_extractionReleaseState",""]) == "released" || {diag_tickTime>_until}};
["exrelease_joins_rebel_group",group _a == _rescuers && {!captive _a} && {_a checkAIFeature "MOVE"}
    && {_a checkAIFeature "AUTOTARGET"}] call _check;
sleep 1;
["exrelease_native_initialization",_a getVariable ["spawner",false]
    && {(_a getVariable ["A3I_extractionRecruitInitialized",[]]) isEqualTo ["release",_r get "serial",0]}] call _check;
["exrelease_release_not_delivery",_r get "rescued" == 0 && {_r get "outcome" == "pending"}] call _check;
["exrelease_released_refused",!([_a,_rescuer] call A3I_fnc_beginExtractionRelease)] call _check;
// Deadline closes a pending release without recruitment or reward.
_rescuer setPosATL getPosATL _b;
[_b,_rescuer] call A3I_fnc_beginExtractionRelease;
_r set ["deadline",time-1]; sleep 1.2;
["exrelease_deadline_cancels",group _b == _group && {captive _b}
    && {isNil {_b getVariable "A3I_extractionReleaseState"}}] call _check;
["exrelease_deadline_refused",!([_b,_rescuer] call A3I_fnc_beginExtractionRelease)] call _check;
["release",_r get "serial"] call A3I_fnc_releaseExtractionLedger;
sleep 1;
["exrelease_cleanup_handlers",isNil "A3I_extractionReleaseHandle" && {count A3I_extractionLedgers == 0}] call _check;
["exrelease_cleanup_keeps_recruited",alive _a && {group _a == _rescuers}] call _check;
// A reused name cannot bind a stale ledger or authorize a new actor.
private _c=call _new;
private _r2=["release",[_c],time+60] call A3I_fnc_createExtractionLedger;
["exrelease_stale_binding_refused",!([_r] call A3I_fnc_setExtractionActions)] call _check;
[_r2] call A3I_fnc_setExtractionActions;
_rescuer setPosATL getPosATL _c; [_c,_rescuer] call A3I_fnc_beginExtractionRelease;
["release",_r2 get "serial"] call A3I_fnc_releaseExtractionLedger;
sleep 4;
["exrelease_cancelled_ledger_no_late_join",group _c == _group && {captive _c}
    && {isNil "A3I_extractionReleaseHandle"}] call _check;
private _d=call _new;
private _r3=["foreign",[_d],time+60] call A3I_fnc_createExtractionLedger;
[_r3] call A3I_fnc_setExtractionActions;
_d setVariable ["A3I_extractionOwner",["another_system",123,0]];
_d setVariable ["A3I_extractionReleaseState","foreign",true];
["exrelease_foreign_ownership_refused",!([_d,_rescuer] call A3I_fnc_beginExtractionRelease)] call _check;
["foreign",_r3 get "serial"] call A3I_fnc_releaseExtractionLedger;
["exrelease_foreign_state_preserved",(_d getVariable ["A3I_extractionReleaseState",""]) == "foreign"
    && {(_d getVariable ["A3I_extractionOwner",[]]) isEqualTo ["another_system",123,0]}] call _check;
["exrelease_foreign_jip_key_retired",((_r3 get "entries") # 0) get "actionKey" == ""] call _check;
sleep 1;
{deleteVehicle _x} forEach (_actors+[_rescuer,sidesX]);
deleteGroup _group; deleteGroup _rescuers; deleteMarker respawnTeamPlayer;
sleep 1;
["exrelease_final_cleanup",(entities [[],[],true,false])-_before isEqualTo []
    && {allGroups-_groupsBefore isEqualTo []}] call _check;
