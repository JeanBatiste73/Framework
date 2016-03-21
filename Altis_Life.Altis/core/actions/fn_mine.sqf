#
include "..\..\script_macros.hpp"
    /*
		File: fn_mine.sqf
		Author: Devilfloh
		Editor: Dardo

		Description:
		Same as fn_gather,but it allows use of probabilities for mining.
	*/
private["_maxGather", "_resource", "_amount", "_requiredItem", "_mined"];
if (life_action_inUse) exitWith {};
if ((vehicle player) != player) exitWith {};
if ((player GVAR "restrained")) exitWith {
    hint localize "STR_NOTF_isrestrained";
};
_exit = false;
if ((player GVAR "playerSurrender")) exitWith {
    hint localize "STR_NOTF_surrender";
};
life_action_inUse = true;
_zone = "";
_requiredItem = "";
_zoneSize = (getNumber(missionConfigFile >> "CfgGather" >> "zoneSize"));

_resourceCfg = missionConfigFile >> "CfgGather" >> "Minerals";


scopeName "notMined";

_percent = (floor random 100) + 1; //Make sure it's not 0

for [{
    _i = 0
}, {
    _i < count(_resourceCfg)
}, {
    _i = _i + 1
}] do {
    _curConfig = (_resourceCfg select _i);
    _resources = getArray(_curConfig >> "mined");
    _maxGather = getNumber(_curConfig >> "amount");
    _resourceZones = getArray(_curConfig >> "zones");
    _requiredItem = getText(_curConfig >> "item");

    _mined = "";

    if (count _resources == 0) exitWith {}; //Smart guy :O
    for "_i"
    from 0 to(count _resources) do {
            if (EQUAL(count _resources, 1)) exitWith {
                if (typeName(_resources select 0) != "ARRAY") then {
                    _mined = _resources select 0;
                }
                else {
                    _mined = _resources select 0 select 0;
                };
            };
            _resource = _resources select _i select 0;
            _prob = _resources select _i select 1;
            _probdiff = _resources select _i select 2;
            if ((_percent > _prob) && (_percent < _probdiff)) exitWith {
                _mined = _resource;
            };
        };
        if (_mined == "") then {
            breakTo "notMined";
        }; {
            if ((player distance(getMarkerPos _x)) < _zoneSize) exitWith {
                _zone = _x;
            };
        }
    forEach _resourceZones;

    if (_zone != "") exitWith {};
};



if (_zone == "") exitWith {
    life_action_inUse = false;
};

if (_requiredItem != "") then {
    _valItem = GVAR_MNS "life_inv_" + _requiredItem;

    if (_valItem < 1) exitWith {
        switch (_requiredItem) do {
            case "pickaxe":
                {
                    titleText[(localize "STR_NOTF_Pickaxe"), "PLAIN"];
                };
        };
        life_action_inUse = false;
        _exit = true;
    };
};

if (_exit) exitWith {
    life_action_inUse = false;
};

_amount = round(random(_maxGather)) + 1;
_diff = [_mined, _amount, life_carryWeight, life_maxWeight] call life_fnc_calWeightDiff;
if (_diff == 0) exitWith {
    hint localize "STR_NOTF_InvFull";
    life_action_inUse = false;
};
player say3D "mining";

for "_i"
from 0 to 4 do {
    player playMoveNow "AinvPercMstpSnonWnonDnon_Putdown_AmovPercMstpSnonWnonDnon";
    waitUntil {
        animationState player != "AinvPercMstpSnonWnonDnon_Putdown_AmovPercMstpSnonWnonDnon";
    };
    sleep 0.5;
};

if (([true, _mined, _diff] call life_fnc_handleInv)) then {
    _itemName = M_CONFIG(getText, "VirtualItems", _mined, "displayName");
    titleText[format[localize "STR_NOTF_Gather_Success", (localize _itemName), _diff], "PLAIN"];
};

sleep 1;
life_action_inUse = false;