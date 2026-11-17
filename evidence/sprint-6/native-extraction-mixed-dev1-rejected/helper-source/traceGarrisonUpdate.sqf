// Observe only: preserve arguments, scheduling and the native implementation.
diag_log format ["[INFECTION_LIQ_DIAGNOSTIC] garrison_enter %1",[_this,diag_frameNo]];
_this call A3ITrace_fnc_nativeGarrisonUpdate;
diag_log format ["[INFECTION_LIQ_DIAGNOSTIC] garrison_exit %1",[_this,garrison getVariable [_this # 2,[]],diag_frameNo]];
