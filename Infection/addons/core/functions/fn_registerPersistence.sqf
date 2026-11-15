#include "\x\a3a\addons\core\script_component.hpp"
if (!isServer || {isRemoteExecuted} || {!isNil "A3I_adminSaveHandle"}) exitWith {false};
A3I_adminSaveHandle = [CBA_EVENT_SERVER_GAME_SAVE,A3I_fnc_saveAdministrationExtras] call A3A_fnc_addEventHandler;
A3I_adminLoadHandle = [CBA_EVENT_SERVER_GAME_LOAD,A3I_fnc_loadAdministrationExtras] call A3A_fnc_addEventHandler;
true
