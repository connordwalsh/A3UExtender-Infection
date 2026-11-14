// Patch only the removed controls. Native labels/actions/layout for every
// remaining category stay intact until its replacement behavior is ready.
class A3A_DefaultDialog;
class A3A_DefaultControlsGroup;
class A3A_Picture;
class A3A_Button;
class A3A_RequestMissionDialog: A3A_DefaultDialog
{
    class Controls
    {
        class MainContent: A3A_DefaultControlsGroup
        {
            class Controls
            {
                class DestroyIcon: A3A_Picture { onLoad = "_this call A3I_fnc_hideRemovedMissionControl"; };
                class DestroyButton: A3A_Button { onLoad = "_this call A3I_fnc_hideRemovedMissionControl"; };
                class RandomIcon: A3A_Picture { onLoad = "_this call A3I_fnc_hideRemovedMissionControl"; };
                class RandomButton: A3A_Button { onLoad = "_this call A3I_fnc_hideRemovedMissionControl"; };
                class ConquestButton: A3A_Button { onLoad = "_this call A3I_fnc_labelLiquidationControl"; };
            };
        };
    };
};
class SimpleMenuBig;
class SimpleButton;
class missionMenu: SimpleMenuBig
{
    class Controls
    {
        class destroyButton: SimpleButton { onLoad = "_this call A3I_fnc_hideRemovedMissionControl"; };
        class randomButton: SimpleButton { onLoad = "_this call A3I_fnc_hideRemovedMissionControl"; };
        class conButton: SimpleButton { onLoad = "_this call A3I_fnc_labelLiquidationControl"; };
    };
};
