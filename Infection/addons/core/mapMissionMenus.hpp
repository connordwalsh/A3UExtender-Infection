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
                tooltip = "Deliver supplies to survivors in this infected-held town and protect the unloading area.";
                condition = "([west] call A3I_fnc_isActive) && {_isCommander} && {!_isDestroyed} && {[_this select 0] call A3I_fnc_aidTargetEligible} && {!(call A3I_fnc_aidTaskBusy)}";
            };
        };
    };
};
