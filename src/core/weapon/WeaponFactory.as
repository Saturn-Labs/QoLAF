package core.weapon
{
	import core.scene.Game;
	import core.unit.Unit;
	import data.*;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class WeaponFactory
	{
		public function WeaponFactory()
		{
			super();
		}
		
		public static function create(param1:String, param2:Game, param3:Unit, param4:int, param5:int = -1, param6:String = ""):Weapon
		{
			var _loc7_:Weapon = null;
			var _loc10_:Object = null;
			var _loc8_:ITextureManager = TextureLocator.getService();
			var _loc11_:IDataManager = DataLocator.getService();
			var _loc9_:Object = _loc11_.loadKey("Weapons", param1);
			if (!param2.isLeaving)
			{
				_loc7_ = param2.weaponManager.getWeapon(_loc9_.type);
				_loc7_.init(_loc9_, param4, param5, param6);
				_loc7_.key = param1;
				_loc7_.unit = param3;
				if (_loc9_.hasOwnProperty("fireEffect"))
				{
					_loc7_.fireEffect = _loc9_.fireEffect;
				}
				else
				{
					_loc7_.fireEffect = "";
				}
				if (_loc9_.hasOwnProperty("useShipSystem"))
				{
					_loc7_.useShipSystem = _loc9_.useShipSystem;
				}
				else
				{
					_loc7_.useShipSystem = false;
				}
				if (_loc9_.hasOwnProperty("randomAngle"))
				{
					_loc7_.randomAngle = _loc9_.randomAngle;
				}
				else
				{
					_loc7_.randomAngle = false;
				}
				if (_loc9_.hasOwnProperty("fireBackwards"))
				{
					_loc7_.fireBackwards = _loc9_.fireBackwards;
				}
				else
				{
					_loc7_.fireBackwards = false;
				}
				if (_loc9_.hasOwnProperty("isMissileWeapon") || _loc7_ is Beam)
				{
					_loc7_.isMissileWeapon = _loc9_.isMissileWeapon;
				}
				else
				{
					_loc7_.isMissileWeapon = false;
				}
				if (_loc9_.hasOwnProperty("hasChargeUp"))
				{
					_loc7_.hasChargeUp = _loc9_.hasChargeUp;
				}
				else
				{
					_loc7_.hasChargeUp = false;
				}
				if (_loc9_.hasOwnProperty("specialCondition") && _loc9_.specialCondition != "")
				{
					_loc7_.specialCondition = _loc9_.specialCondition;
					if (_loc9_.hasOwnProperty("specialBonusPercentage"))
					{
						_loc7_.specialBonusPercentage = _loc9_.specialBonusPercentage;
					}
					else
					{
						_loc7_.specialBonusPercentage = 0;
					}
				}
				if (_loc9_.hasOwnProperty("maxChargeDuration"))
				{
					_loc7_.chargeUpTimeMax = _loc9_.maxChargeDuration;
				}
				else
				{
					_loc7_.chargeUpTimeMax = 750;
				}
				if (param4 > 0)
				{
					_loc10_ = _loc9_.techLevels[param4 - 1];
					_loc7_.projectileFunction = _loc9_.projectile == null ? "" : _loc10_.projectile;
				}
				else
				{
					_loc7_.projectileFunction = _loc9_.projectile == null ? "" : _loc9_.projectile;
				}
				_loc7_.alive = true;
			}
			return _loc7_;
		}
	}
}
