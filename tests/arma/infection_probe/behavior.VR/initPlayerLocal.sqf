// Observation camera only. This fixture never opens or edits an Antistasi save.
player allowDamage false;
player setCaptive true;
removeAllWeapons player;
private _camera = "camera" camCreate [1010,990,5];
_camera cameraEffect ["Internal", "BACK"];
showCinemaBorder false;
while {true} do {
    private _view = missionNamespace getVariable ["Infection_behaviorView", []];
    if (count _view == 5) then {
        _view params ["_class", "_scenario", "_unit", "_target", "_phase"];
        private _focus = if (isNull _unit) then {[1000,1000,1]} else {getPosATL _unit vectorAdd [0,0,1]};
        if (!isNull _target && {!isNull _unit}) then {
            _focus = ((getPosATL _unit) vectorAdd (getPosATL _target)) vectorMultiply 0.5;
            _focus = _focus vectorAdd [0,0,1];
        };
        _camera camSetTarget _focus;
        _camera camSetPos (_focus vectorAdd [12,-12,7]);
        _camera camCommit 0.5;
        hintSilent format ["CONTROLLED TEST\n%1\n%2\n%3\nAutomated encounter; visual review is separate.", _class, _scenario, _phase];
    } else {
        hintSilent "Controlled encounter probe\nWaiting for server state.";
    };
    sleep 0.5;
};
