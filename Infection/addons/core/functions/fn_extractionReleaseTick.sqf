// Independent of a public mission worker; reserve, revalidate and join once.
params ["_arguments","_handle"];
if (!isServer || {isRemoteExecuted}) exitWith {};
private _active = false;
{
    private _record = _y;
    if (_record get "outcome" != "pending" || {time >= _record get "deadline"}) then {
        [_record,false] call A3I_fnc_setExtractionActions;
        continue;
    };
    {
        private _entry = _x;
        private _stage = _entry getOrDefault ["releaseState",""];
        if !(_stage in ["waiting","releasing"]) then {continue};
        _active = true;
        if (_stage == "waiting") then {continue};
        private _unit = _entry get "unit"; private _rescuer = _entry get "rescuer";
        private _token = [_record get "name",_record get "serial",_forEachIndex];
        private _valid = alive _unit && {local _unit} && {alive _rescuer}
            && {side group _rescuer == teamPlayer} && {_unit distance _rescuer <= 4}
            && {!(_rescuer getVariable ["incapacitated",false])} && {!(_rescuer getVariable ["surrendered",false])}
            && {!(_unit getVariable ["incapacitated",false])} && {!(_unit getVariable ["WBK_AI_ISZombie",false])}
            && {side group _unit in [teamPlayer,civilian]} && {_entry get "state" == "pending"}
            && {(_unit getVariable ["A3I_extractionOwner",[]]) isEqualTo _token};
        if (!_valid) then {
            _entry set ["releaseState","waiting"];
            if (!isNull _unit) then {_unit setVariable ["A3I_extractionReleaseState","waiting",true]};
            continue;
        };
        if (time < _entry get "releaseAt") then {continue};
        // Enable local AI before group transfer so a locality handoff cannot strand it.
        {_unit enableAI _x} forEach ["MOVE","AUTOTARGET","TARGET","ANIM"];
        _unit setCaptive false;
        [_unit] joinSilent group _rescuer;
        _entry set ["releaseState","released"];
        _unit setVariable ["A3I_extractionReleaseState","released",true];
        _unit setVariable ["A3I_extractionRecruitToken",_token,true];
        [_unit,_rescuer,_token] remoteExec ["A3I_fnc_extractionRecruitLocal",_rescuer];
    } forEach (_record get "entries");
} forEach (missionNamespace getVariable ["A3I_extractionLedgers",createHashMap]);
if (!_active) then {[_handle] call CBA_fnc_removePerFrameHandler; A3I_extractionReleaseHandle = nil};
