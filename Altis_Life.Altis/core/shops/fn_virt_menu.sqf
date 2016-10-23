#include "..\..\script_macros.hpp"
/*
    File: fn_virt_menu.sqf
    Author: Bryan "Tonic" Boardwine
    Description:
    Initialize the virtual shop menu.
*/

private ["_exit","_shopSide","_license","_levelAssert","_levelName","_levelType","_levelValue","_levelMsg","_flag"];

params [
    ["_shopNPC", objNull, [objNull]],
    "",
    "",
    ["_shopType", "", [""]]
];

if (isNull _shopNPC || {_shopType isEqualTo ""}) exitWith {};

_shopSide = M_CONFIG(getText,"VirtualShops",_shopType,"side");

life_shop_type = _shopType;
life_shop_npc = _shopNPC;

private _exit = false;

if !(_shopSide isEqualTo "") then {
    _flag = switch (playerSide) do {case west: {"cop"}; case independent: {"med"}; default {"civ"};};
    if !(_flag isEqualTo _shopSide) then {_exit = true;};
};

if (_exit) exitWith {};

private _conditions = M_CONFIG(getText,"VirtualShops",_shopType,"conditions");

if !([_conditions] call life_fnc_levelCheck) exitWith {hint "Can't open yada yada yada non creative string";};

createDialog "shops_menu";

[] call life_fnc_virt_update;
