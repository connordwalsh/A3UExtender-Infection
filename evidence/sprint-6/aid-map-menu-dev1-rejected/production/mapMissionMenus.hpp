// Keep the native shortcut outside Infection; the server still validates requests.
class A3U
{
    class CfgMapContextMenu
    {
        class Location
        {
            class ContextBase;
            class A3A_ultimate_dynamic_hover_menu_DeliverSupplies: ContextBase
            {
                condition = "!([west] call A3I_fnc_isActive) && {_isCommander && !_isDestroyed && {isNil 'A3A_supplyMissionActive'} && {_this select 0 in citiesX}}";
            };
            class A3I_HumanitarianAid: A3A_ultimate_dynamic_hover_menu_DeliverSupplies
            {
                title = "Humanitarian Aid";
                tooltip = "Deliver supplies to survivors in this infected-held town and protect the unloading area. Final availability is checked when requested.";
                condition = "([west] call A3I_fnc_isActive) && {_isCommander} && {!_isDestroyed} && {!isNil 'sidesX'} && {_this select 0 in citiesX} && {sidesX getVariable [_this select 0,sideUnknown] == west} && {!(call A3I_fnc_aidTaskBusy)}";
            };
        };
    };
};
