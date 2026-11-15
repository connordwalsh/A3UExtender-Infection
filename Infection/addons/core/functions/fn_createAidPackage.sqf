params [["_position",[],[[]]]];
if (!isServer || {isRemoteExecuted}) exitWith {[objNull,"server_local_only"]};
if (canSuspend) exitWith {[A3I_fnc_createAidPackage,_this] call CBA_fnc_directCall};
if (!([west] call A3I_fnc_isActive) || {isNil "serverInitDone"} || {!serverInitDone}
    || {isNil "A3A_utilityItemHM"} || {isNil "teamPlayer"}) exitWith {[objNull,"campaign_not_ready"]};
if !([_position] call A3I_fnc_aidPackagePositionSafe) exitWith {[objNull,"unsafe_hq_position"]};
if !( ["Land_FoodSacks_01_cargo_brown_F"] call A3A_Logistics_fnc_isLoadable) exitWith {[objNull,"cargo_configuration"]};
private _package = createVehicle ["Land_FoodSacks_01_cargo_brown_F",_position,[],0,"NONE"];
if (isNull _package) exitWith {[objNull,"creation_failed"]};
if (!alive _package || {_package distance2D _position > 1}) exitWith {deleteVehicle _package; [objNull,"placement_changed"]};
_package allowDamage false; _package enableRopeAttach true;
_package setVariable ["A3I_aidPackage",true,true];
// Native AIVEHinit handles non-crewed objects through preparePostMortem and
// returns before vehicle ownership/resource hooks. Preserve that native path.
[_package,teamPlayer] call A3A_fnc_AIVEHinit;
[_package] call A3A_Logistics_fnc_addLoadAction;
[_package,""]
