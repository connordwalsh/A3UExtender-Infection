/* [native six-field target record] -> success. Offscreen Invader territory only.
   Preserve native defence/attack costs and already-paid virtual garrison roles.
   The offscreen Invader-to-Occupant branch of 12.4.2 markerChange cannot suspend:
   no flag is acquired while spawner==2, and no Rebel capture branch is entered.
   Run that transaction, payment and roster insertion in one local atomic call,
   avoiding a paid capture's ten-second unowned gap or an interrupted waiter. */
params [["_choice",[],[[]]]];
if (!isServer || {!canSuspend} || {isRemoteExecuted && {remoteExecutedOwner != 2}}
    || {!([west] call A3I_fnc_isActive)} || {count _choice != 6}) exitWith {false};
_choice params ["_target","_source","","_threat","_flyover","_landCount"];
if !(_target isEqualType "" && {_source isEqualType ""}
    && {_threat isEqualType 0} && {finite _threat} && {_threat >= 0}
    && {_flyover isEqualTo 0} && {_landCount isEqualType 0} && {finite _landCount}
    && {_landCount >= 1} && {floor _landCount == _landCount}) exitWith {false};
private _valid = {
    [west] call A3I_fnc_isActive
    && {!(missionNamespace getVariable ["areOccupantsDefeated",false])}
    && {!(missionNamespace getVariable ["areInvadersDefeated",false])}
    && {!(missionNamespace getVariable ["bigAttackInProgress",false])}
    && {isNil "A3I_majorGlobalOwner"}
    && {!(missionNamespace getVariable ["garrisonIsChanging",false])}
    && {_target in (airportsX + outposts + milbases + factories + resourcesX + seaports)}
    && {_target in allMapMarkers} && {sidesX getVariable [_target,sideUnknown] == Invaders}
    && {spawner getVariable [_target,2] == 2} && {!(_target in forcedSpawn)}
    && {!(_target in (missionNamespace getVariable ["markersChanging",[]]))}
    && {[_source] call A3I_fnc_majorSourceEligible}
    && {((call A3I_fnc_spawnObservers) findIf {
        _x distance2D getMarkerPos _target < ((missionNamespace getVariable ["distanceSPWN1",distanceSPWN]) max 150)
    }) == -1}
    // The distance loop can be between updates. Respect its AI activation
    // anchors too, before treating a still-inactive target as offscreen.
    && {((units teamPlayer) findIf {alive _x && {_x getVariable ["spawner",false]}
        && {_x distance2D getMarkerPos _target < distanceSPWN1}}) == -1}
    && {((units west) findIf {alive _x && {_x getVariable ["spawner",false]}
        && {_x distance2D getMarkerPos _target < distanceSPWN2}}) == -1}
};
if (!(call _valid)) exitWith {false};
if (([getMarkerPos _target,[_source],{_this call A3I_fnc_majorSourceEligible}]
    call A3I_fnc_tacticalSources) isEqualTo []) exitWith {false};
private _defence = [Invaders,west,_target,1] call A3A_fnc_maxDefenceSpend;
if !(_defence isEqualType 0 && {finite _defence} && {_defence >= 0}) exitWith {false};
private _attack = 400 + (_defence + _threat) * (0.75 + 2^(-_landCount));
if (!finite _attack) exitWith {false};
private _groups = [A3A_faction_occ,"groupsTierMedium"] call SCRT_fnc_unit_flattenTier;
_groups append ([A3A_faction_occ,"groupsTierSquads"] call SCRT_fnc_unit_flattenTier);
_groups = _groups select {_x isEqualType [] && {_x isNotEqualTo []}};
if (_groups isEqualTo []) exitWith {false};
private _success = false;
isNil {
    if (!(call _valid)) exitWith {};
    private _funds = missionNamespace getVariable ["A3A_resourcesAttackOcc",0];
    private _defenderFunds = missionNamespace getVariable ["A3A_resourcesDefenceInv",0];
    if !(_funds isEqualType 0 && {finite _funds} && {_funds > 0}
        && {_defenderFunds isEqualType 0} && {finite _defenderFunds}
        && {_defence == 0 || {_defenderFunds >= _defence}}) exitWith {};
    [west,_target] call A3A_fnc_markerChange;
    if (sidesX getVariable [_target,sideUnknown] != west) exitWith {};
    // Native size/frontier calculations depend on the new owner's side.
    private _troops = 12 max round ((0.5 + random 0.5) * ([_target] call A3A_fnc_garrisonSize));
    private _roles = [];
    while {count _roles < _troops} do {_roles append selectRandom _groups};
    _roles resize _troops;
    [-_defence,Invaders,"defence"] call A3A_fnc_addEnemyResources;
    [-_attack,west,"attack"] call A3A_fnc_addEnemyResources;
    // Same authoritative old-roster representation as native garrisonUpdate.
    // The transaction owns this insertion; no actors or budget tickets exist.
    private _roster = +(garrison getVariable [_target,[]]);
    _roster append _roles; garrison setVariable [_target,_roster,true];
    if (isNil "A3I_majorSourceCooldowns") then {A3I_majorSourceCooldowns = createHashMap};
    A3I_majorSourceCooldowns set [_source,time + 600];
    if (_source in (airportsX + outposts + milbases)) then {[_source,10] call A3A_fnc_addTimeForIdle};
    _success = true;
};
_success
