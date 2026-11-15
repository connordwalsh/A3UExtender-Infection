if (!([west] call A3I_fnc_isActive)) exitWith {_this call A3I_fnc_originalENCTrader};
params [["_source","",[""]]];
if (!isServer) exitWith {};
if (isRemoteExecuted && {!(remoteExecutedOwner in ([2]+(missionNamespace getVariable ["hcArray",[]])))}) exitWith {};
[{
    if (missionNamespace getVariable ["isTraderQuestCompleted",false]) exitWith {};
    if (!isNil "A3I_dealerUnlockHandle" && {!scriptDone A3I_dealerUnlockHandle}) exitWith {};
    A3I_dealerUnlockHandle=_this spawn A3I_fnc_unlockDealer;
    [{scriptDone (_this # 0)}, {
        if (A3I_dealerUnlockHandle isEqualTo (_this # 0)) then {
            if (!(missionNamespace getVariable ["isTraderQuestCompleted",false])) then {
                isTraderQuestAssigned=false; publicVariable "isTraderQuestAssigned";
            };
            A3I_dealerUnlockHandle=nil;
        };
    },[A3I_dealerUnlockHandle]] call CBA_fnc_waitUntilAndExecute;
},[_source]] call CBA_fnc_execNextFrame;
