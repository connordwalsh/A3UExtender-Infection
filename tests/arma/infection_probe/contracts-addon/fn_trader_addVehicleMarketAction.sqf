if (isServer) then {
    if (isNil "A3I_test_dealerMarketCalls") then {A3I_test_dealerMarketCalls=[]};
    A3I_test_dealerMarketCalls pushBack [+_this,isRemoteExecuted,remoteExecutedOwner];
};
_this call A3I_fnc_testNativeTraderMarketAction
