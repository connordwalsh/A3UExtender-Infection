// Disabled for every target faction in an Infection campaign, including direct
// calls and HC execution. Merely loading the addon preserves native campaigns.
if ([west] call A3I_fnc_isActive) exitWith {};
_this call A3I_fnc_originalDestroyVehicle
