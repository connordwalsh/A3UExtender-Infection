// Internal atomic creation for the survivor-defense controller. The record owns
// the exact actor and original civilian group even if later initialization fails.
// Returns [created, reason]; never falls back to an infected Occupant official.
params [["_record",createHashMap,[createHashMap]]];
if (!isServer || {isRemoteExecuted}) exitWith {[false,"server_local_only"]};
if (canSuspend) exitWith {[A3I_fnc_createLiberationSurvivor,_this] call CBA_fnc_directCall};
if (!([west] call A3I_fnc_isActive) || {_record getOrDefault ["survivorCleaned",false]})
    exitWith {[false,"inactive"]};
private _name = _record getOrDefault ["name",""];
private _town = _record getOrDefault ["town",""];
if !(_name isEqualType "" && {_name != ""} && {_town isEqualType ""}
    && {_town in (missionNamespace getVariable ["citiesX",[]])} && {_town in allMapMarkers}
    && {!isNil "sidesX"} && {sidesX getVariable [_town,sideUnknown] == west})
    exitWith {[false,"town"]};
if (_record getOrDefault ["survivorAttempted",false]) exitWith {
    private _vip = _record getOrDefault ["vip",objNull];
    [!isNull _vip && {_vip getVariable ["A3I_liberationId",""] == _name}
        && {_record getOrDefault ["survivorReady",false]},"existing"]
};
private _civilians = missionNamespace getVariable ["A3A_faction_civ",createHashMap];
if !(_civilians isEqualType createHashMap) exitWith {[false,"civilian_template"]};
if (_civilians getOrDefault ["attributeCivNonHuman",false]) exitWith {[false,"nonhuman_civilians"]};
if (isNil "A3A_customUnitTypes" || {isNil "A3A_faction_reb"}
    || {isNil "skillFIA"} || {isNil "A3A_rebelSkillMul"}) exitWith {[false,"campaign_not_ready"]};
private _role = ""; private _class = "";
{
    private _candidate = _civilians getOrDefault [_x,""];
    if !(_candidate isEqualType "" && {_candidate find "loadouts_civ_" == 0}) then {continue};
    private _definition = A3A_customUnitTypes getVariable [_candidate,[]];
    if (count _definition < 4) then {continue};
    private _base = _definition # 3;
    private _index = (_definition # 1) findIf {_x # 0 == "baseClass"};
    if (_index != -1) then {_base = (_definition # 1) # _index # 1};
    // A scalar verified human class gives placement and creation the same body.
    // A template with an unsupported VIP definition may still supply Man/Worker.
    if (_base isEqualType "" && {isClass (configFile >> "CfgVehicles" >> _base)}
        && {_base isKindOf "CAManBase"}
        && {!(_base in (A3I_dependencies get "basicClasses"))}) exitWith {
        _role = _candidate; _class = _base;
    };
} forEach ["unitVIP","unitMan","unitWorker"];
if (_role == "") exitWith {[false,"human_role"]};
private _radius = 50 min ([_town] call A3A_fnc_sizeMarker);
if (_radius < 2) exitWith {[false,"town_size"]};
private _search = [getMarkerPos _town,1,_radius / 2,_class] call A3I_fnc_findSpawnPosition;
if (_search # 0 isEqualTo []) exitWith {[false,_search # 1]};
private _position = _search # 0;
if !(_position inArea _town) exitWith {[false,"town_bounds"]};
// The whole function is unscheduled: no ownership/placement scheduling gap.
_record set ["survivorAttempted",true];
private _group = createGroup [civilian,false];
_record set ["vipGroup",_group];
if (isNull _group) exitWith {[false,"group_limit"]};
_group setVariable ["A3I_liberationId",_name];
private _identity = [_civilians,_role] call A3A_fnc_createRandomIdentity;
private _vip = [_group,_role,_position,[],0,"NONE",_identity] call A3A_fnc_createUnit;
_record set ["vip",_vip];
if (isNull _vip) exitWith {[false,"creation_failed"]};
_vip setVariable ["A3I_liberationId",_name];
[_vip,false,false] call A3A_fnc_FIAinit;
_vip setVariable ["spawner",false,true];
_vip setUnitPos "UP"; _vip setDir random 360;
[_vip,createHashMapFromArray [["speaker","NoVoice"]]] call A3A_fnc_setIdentity;
if (primaryWeapon _vip == "") then {
    private _weapons = (missionNamespace getVariable ["allRifles",[]]) select {
        _x isEqualType "" && {isClass (configFile >> "CfgWeapons" >> _x)}
            && {([_x] call A3A_fnc_loadout_defaultWeaponMag) isNotEqualTo []}
    };
    if (_weapons isNotEqualTo []) then {
        private _weapon = selectRandom _weapons;
        _vip addMagazineGlobal (([_weapon] call A3A_fnc_loadout_defaultWeaponMag) # 0);
        _vip addWeaponGlobal _weapon;
    };
};
[_vip,"townVIP"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_vip];
[_vip,"STAND","FULL",{side _this != civilian}] remoteExecCall ["BIS_fnc_ambientAnimCombat",0];
_record set ["survivorReady",true];
[true,""]
