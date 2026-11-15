// Hide removed categories and label implemented replacements; preserve native actions/layout.
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
                class AssassinationButton: A3A_Button { onLoad = "_this call A3I_fnc_labelEliminationControl"; };
                class SupportButton: A3A_Button { onLoad = "_this call A3I_fnc_labelAidControl"; };
                class LogisticsButton: A3A_Button { onLoad = "_this call A3I_fnc_labelSupplyControl"; };
                class ConvoyButton: A3A_Button { onLoad = "_this call A3I_fnc_labelInterceptionControl"; };
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
        class asButton: SimpleButton { onLoad = "_this call A3I_fnc_labelEliminationControl"; };
        class suppButton: SimpleButton { onLoad = "_this call A3I_fnc_labelAidControl"; };
        class logButton: SimpleButton { onLoad = "_this call A3I_fnc_labelSupplyControl"; };
        class convoyButton: SimpleButton { onLoad = "_this call A3I_fnc_labelInterceptionControl"; };
    };
};
