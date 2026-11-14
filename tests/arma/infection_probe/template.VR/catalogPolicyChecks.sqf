// Exercise real request/mission endpoints; originals are isolated recording
// fixtures, so delegation is proven separately from native mission gameplay.
private _savedOriginals = missionNamespace getVariable ["A3I_test_originals",[]];
private _savedCalls = missionNamespace getVariable ["A3I_test_catalogCalls",[]];
private _savedLock = missionNamespace getVariable ["A3A_missionRequestInProgress",nil];
A3I_test_originals = []; A3I_test_catalogCalls = [];
A3A_missionRequestInProgress = nil;
["DES",2,true] call A3A_fnc_missionRequest;
["RAN",2,true] call A3A_fnc_missionRequest;
["catalog_server_blocks_removed",A3I_test_originals isEqualTo []
    && {isNil "A3A_missionRequestInProgress"}] call _check;
[] call A3A_fnc_missionRequest;
["catalog_missing_type_blocks_random",A3I_test_originals isEqualTo []
    && {isNil "A3A_missionRequestInProgress"}] call _check;
A3A_missionRequestInProgress = "existing-owner";
["DES",2,true] call A3A_fnc_missionRequest;
["RAN",2,true] call A3A_fnc_missionRequest;
["catalog_busy_lock_untouched",A3A_missionRequestInProgress isEqualTo "existing-owner"] call _check;
A3A_missionRequestInProgress = nil;
{["missionButtonClicked",[_x]] call A3A_fnc_requestMissionDialog} forEach ["DES","RAN"];
["catalog_client_blocks_random_before_selection",A3I_test_catalogCalls isEqualTo []] call _check;
["missionButtonClicked",["CON"]] call A3A_fnc_requestMissionDialog;
["catalog_client_allowed_delegates",A3I_test_catalogCalls isEqualTo
    [["RequestMissionDialog",["missionButtonClicked",["CON"]]]]] call _check;
A3I_test_catalogCalls = [];
private _endpoints = [A3A_fnc_DES_Vehicle,A3A_fnc_DES_Heli,A3A_fnc_DES_Antenna,A3A_fnc_DES_Artillery];
{["fixture_site"] call _x} forEach _endpoints;
["catalog_destroy_direct_blocks",A3I_test_catalogCalls isEqualTo []] call _check;
private _expected = [["RequestMissionDialog",["missionButtonClicked",["RAN"]]],
    ["DestroyVehicle",["fixture_site"]],["DestroyHeli",["fixture_site"]],
    ["DestroyAntenna",["fixture_site"]],["DestroyArtillery",["fixture_site"]]];
private _exerciseOriginals = {
    A3I_test_originals = []; A3I_test_catalogCalls = [];
    ["DES",2,true] call A3A_fnc_missionRequest;
    ["RAN",2,true] call A3A_fnc_missionRequest;
    ["missionButtonClicked",["RAN"]] call A3A_fnc_requestMissionDialog;
    {["fixture_site"] call _x} forEach _endpoints;
    A3I_test_originals isEqualTo [["missionRequest",["DES",2,true]],["missionRequest",["RAN",2,true]]]
        && {A3I_test_catalogCalls isEqualTo _expected}
};
A3A_faction_occ set ["infectionTemplate",""];
["catalog_ordinary_delegates",call _exerciseOriginals] call _check;
A3A_faction_occ set ["infectionTemplate","A3I_Infected"];
A3I_dependencies set ["available",false];
["catalog_missing_dependencies_delegate",call _exerciseOriginals] call _check;
A3I_dependencies set ["available",true];
A3I_test_originals = []; A3I_test_catalogCalls = [];
["DES",2,true] remoteExecCall ["A3A_fnc_missionRequest",2];
["RAN",2,true] remoteExecCall ["A3A_fnc_missionRequest",2];
{["fixture_site"] remoteExec [_x,2]} forEach ["A3A_fnc_DES_Vehicle","A3A_fnc_DES_Heli","A3A_fnc_DES_Antenna","A3A_fnc_DES_Artillery"];
sleep 1;
["catalog_remote_removed_blocks",A3I_test_originals isEqualTo [] && {A3I_test_catalogCalls isEqualTo []}
    && {isNil "A3A_missionRequestInProgress"}] call _check;
private _modern = configFile >> "A3A_RequestMissionDialog" >> "Controls" >> "MainContent" >> "Controls";
private _legacy = configFile >> "missionMenu" >> "Controls";
private _hook = "_this call A3I_fnc_hideRemovedMissionControl";
["catalog_native_control_bases_preserved",configName (inheritsFrom (configFile >> "A3A_RequestMissionDialog" >> "Controls" >> "MainContent")) == "A3A_DefaultControlsGroup"
    && {(["DestroyIcon","RandomIcon"] findIf {configName (inheritsFrom (_modern >> _x)) != "A3A_Picture"}) == -1}
    && {(["DestroyButton","RandomButton"] findIf {configName (inheritsFrom (_modern >> _x)) != "A3A_Button"}) == -1}
    && {(["destroyButton","randomButton"] findIf {configName (inheritsFrom (_legacy >> _x)) != "SimpleButton"}) == -1}] call _check;
["catalog_modern_hooks_preserve_controls",(["DestroyIcon","DestroyButton","RandomIcon","RandomButton"] findIf {
    getText (_modern >> _x >> "onLoad") != _hook || {!(isNumber (_modern >> _x >> "w") || {isText (_modern >> _x >> "w")})}
        // Native Random references a missing localization key in 12.4.2.
        // Test property preservation without asserting upstream translations.
        || {!isText (_modern >> _x >> "text")}
}) == -1 && {getText (_modern >> "RandomButton" >> "onButtonClick") != ""}] call _check;
["catalog_legacy_hooks_preserve_controls",(["destroyButton","randomButton"] findIf {
    getText (_legacy >> _x >> "onLoad") != _hook || {getText (_legacy >> _x >> "action") == ""}
        || {getText (_legacy >> _x >> "text") == ""}
}) == -1] call _check;
["catalog_other_controls_preserved",getText (_modern >> "ConquestButton" >> "onButtonClick") != ""
    && {getText (_modern >> "ConquestButton" >> "onLoad") != _hook}
    && {getText (_legacy >> "asButton" >> "action") != ""}
    && {getText (_legacy >> "asButton" >> "onLoad") != _hook}] call _check;
["catalog_endpoints_registered",(["DES_Vehicle","DES_Heli","DES_Antenna","DES_Artillery"] findIf {
    getText (configFile >> "CfgFunctions" >> "A3A" >> "Missions" >> _x >> "file")
        != ("\x\a3i\addons\core\overrides\fn_" + _x + ".sqf")
}) == -1 && {getText (configFile >> "CfgFunctions" >> "A3A" >> "GUI" >> "requestMissionDialog" >> "file")
    == "\x\a3i\addons\core\overrides\fn_requestMissionDialog.sqf"}] call _check;
A3I_test_originals = _savedOriginals; A3I_test_catalogCalls = _savedCalls;
if (isNil "_savedLock") then {A3A_missionRequestInProgress = nil} else {A3A_missionRequestInProgress = _savedLock};
