// Automatic Russian supply attacks remain world activity in Infection campaigns.
// Other convoy entry points retain their native behavior until their replacements
// are integrated; ordinary campaigns always delegate unchanged.
if (!([west] call A3I_fnc_isActive)) exitWith {_this call A3I_fnc_originalConvoy};
params ["_destination","_origin",["_type",""],["_pool","legacy"]];
if !(_type == "Supplies" && {_pool == "attack"} && {!isNil "sidesX"}
    && {sidesX getVariable [_origin,sideUnknown] == Invaders}) exitWith {_this call A3I_fnc_originalConvoy};
if (!isServer || {isRemoteExecuted && {remoteExecutedOwner != 2}}) exitWith {};
if (!canSuspend) exitWith {
    [{_this spawn A3I_fnc_backgroundSupplyConvoy},+_this] call CBA_fnc_execNextFrame;
};
_this call A3I_fnc_backgroundSupplyConvoy
