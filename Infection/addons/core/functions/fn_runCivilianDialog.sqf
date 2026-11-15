/*
    Author:
        MaxxLite
    
    Description:
        Handles the intel/civ response from dialogCiv
    
    Params:
        _unit <Default: ObjNull>
        _caller <Default: ObjNull>
    
    Dependencies:
        N/A
    
    Scope:
        Server
    
    Environment:
        Unscheduled
    
    Usage:
        [_unit, _caller] call A3A_fnc_dialogCivFinished;
    
    Return:
        true (success) false (failure)
*/

// Adapted from Ultimate: preserve civilian response and intel behavior.
if (!isServer || {isRemoteExecuted} || {!canSuspend}) exitWith {false};
params [["_unit", ObjNull], ["_caller", ObjNull]];

if (_unit isEqualTo ObjNull || _caller isEqualTo ObjNull) exitWith {nil};

// Check if the caller is inside a vehicle
if !(isNull objectParent _caller) exitWith {
    [_unit, localize "STR_antistasi_actions_talk_with_civ_in_vehicle_fail"] remoteExec ["globalChat", _caller];
    false
};

if (_unit getVariable ["A3U_civDialogHasSpoken", false]) exitWith {
    private _failMessage = selectRandom [
        localize "STR_antistasi_actions_talk_with_civ_fail_alreadyspoken1", 
        localize "STR_antistasi_actions_talk_with_civ_fail_alreadyspoken2"
    ];

    [_unit, _failMessage] remoteExec ["globalChat", _caller];
};

private _city = [citiesX, _unit] call BIS_fnc_nearestPosition; 
private _citySide = sidesX getVariable [_city, sideUnknown];
private _possibleMarkers = [call A3I_fnc_extractionTargets, _unit, true] call A3A_fnc_findIfNearAndHostile;

private _isDialogSuccessful = ((captive _caller || _citySide isEqualTo teamPlayer) && (4 >= random 10) && (_possibleMarkers isNotEqualTo []));

if (_isDialogSuccessful) exitWith {
    private _roll = random 100;
    private _missionInProgress = (missionNamespace getVariable ["A3U_dialogCivMissionInProgress", false]) || {call A3I_fnc_extractionTaskBusy};

    if (_roll > 50 && {_missionInProgress isEqualTo false}) then {
        [selectRandom _possibleMarkers, _unit, _caller] spawn A3I_fnc_requestCivilianExtraction;

        if (hideEnemyMarkers) then {
            if (30 >= (random 100)) then {
                [
                    {
                        private _message = selectRandom [
                            "STR_antistasi_actions_talk_with_civ_success_zone_reveal1", 
                            "STR_antistasi_actions_talk_with_civ_success_zone_reveal2"
                        ];

                        [(_this#0), (localize _message)] remoteExec ["globalChat", (_this#1)];
                    },
                    [_unit, _caller], 
                    5 // 5s is around the time it takes me to read the entire paragraph
                ] call CBA_fnc_waitAndExecute;

                [1, "A civilian has revealed a zone"] call A3U_fnc_revealRandomZones;
            };
        };
    } else {
        private _intel = ["Civilian", Occupants] call A3A_fnc_selectIntel;
        private _intelMessage = "";

        switch (_intel) do 
        {
            case 502: // dealer
            {
                _intelMessage = selectRandom [
                    "STR_antistasi_actions_talk_with_civ_success_dealer1", 
                    "STR_antistasi_actions_talk_with_civ_success_dealer2"
                ];
            };
            case 300: // weapons
            {
                _intelMessage = selectRandom [
                    "STR_antistasi_actions_talk_with_civ_success_weapons1", 
                    "STR_antistasi_actions_talk_with_civ_success_weapons2"
                ];
            };
            case 301: // traitor
            {
                _intelMessage = selectRandom [
                    "STR_antistasi_actions_talk_with_civ_success_traitor1", 
                    "STR_antistasi_actions_talk_with_civ_success_traitor2"
                ];
            };
            case 302: // money
            {
                _intelMessage = selectRandom [
                    "STR_antistasi_actions_talk_with_civ_success_money1", 
                    "STR_antistasi_actions_talk_with_civ_success_money2"
                ];
            };
            case 102: // decryption key
            {
                _intelMessage = selectRandom [
                    "STR_antistasi_actions_talk_with_civ_success_decryption1", 
                    "STR_antistasi_actions_talk_with_civ_success_decryption2"
                ];
            };
            default {_intelMessage = "STR_antistasi_actions_talk_with_civ_fail1"};
        };
        
        [_unit, (localize _intelMessage)] remoteExec ["globalChat", _caller];
    };

    _unit setVariable ["A3U_civDialogHasSpoken", true, true];

    true
};

private _failMessage = selectRandom [
    "STR_antistasi_actions_talk_with_civ_fail1", 
    "STR_antistasi_actions_talk_with_civ_fail2", 
    "STR_antistasi_actions_talk_with_civ_fail3"
];

if (!(captive _caller) && {_citySide isNotEqualTo teamPlayer}) then {
    _failMessage = selectRandom [
        "STR_antistasi_actions_talk_with_civ_fail_notundercover1",
        "STR_antistasi_actions_talk_with_civ_fail_notundercover2"
    ];
};

[_unit, (localize _failMessage)] remoteExec ["globalChat", _caller];

_unit setVariable ["A3U_civDialogHasSpoken", true, true];

false
