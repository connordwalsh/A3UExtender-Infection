// Return a report naming the actual accepted route, never an unrelated convoy.
if (!isServer || {!canSuspend} || {isRemoteExecuted}) exitWith {""};
private _result = [] call A3I_fnc_startInterception;
private _text = "";
if (_result # 0) then {
    private _job = A3I_interceptions get (_result # 1);
    waitUntil {sleep 0.1; _job getOrDefault ["taskRegistered",false] || {_job getOrDefault ["settled",false]}};
    if (_job getOrDefault ["taskRegistered",false]) then {
        _text = format ["A large group of infected has been spotted moving from %1 to %2. A Horde Interception task is now available. Neutralize the horde before its first member reaches the destination.",
            [_job get "source"] call A3A_fnc_localizar,[_job get "target"] call A3A_fnc_localizar];
    };
};
if (_text == "") then {
    // Preserve the native unavailable-route intel payout.
    private _money = (round (random 10)) * 100;
    [0,_money] remoteExec ["A3A_fnc_resourcesFIA",2];
    _text = "The reported infected movement could not be confirmed. Other information in the report has been sold.";
};
_text
