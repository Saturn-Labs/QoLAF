package core.weapon {
	import core.scene.Game;
	import core.unit.Unit;
	import data.*;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class WeaponFactory {
		public function WeaponFactory() {
			super();
		}
		
		public static function create(key:String, g:Game, s:Unit, techLevel:int, eliteTechLevel:int = -1, eliteTech:String = "") : Weapon {
			var _local8:Weapon = null;
			var _local11:Object = null;
			var _local9:ITextureManager = TextureLocator.getService();
			var _local10:IDataManager = DataLocator.getService();
			var _local7:Object = _local10.loadKey("Weapons",key);
			if(!g.isLeaving) {
				_local8 = g.weaponManager.getWeapon(_local7.type);
				_local8.init(_local7,techLevel,eliteTechLevel,eliteTech);
				_local8.key = key;
				_local8.unit = s;
				if(_local7.hasOwnProperty("fireEffect")) {
					_local8.fireEffect = _local7.fireEffect;
				} else {
					_local8.fireEffect = "";
				}
				if(_local7.hasOwnProperty("useShipSystem")) {
					_local8.useShipSystem = _local7.useShipSystem;
				} else {
					_local8.useShipSystem = false;
				}
				if(_local7.hasOwnProperty("randomAngle")) {
					_local8.randomAngle = _local7.randomAngle;
				} else {
					_local8.randomAngle = false;
				}
				if(_local7.hasOwnProperty("fireBackwards")) {
					_local8.fireBackwards = _local7.fireBackwards;
				} else {
					_local8.fireBackwards = false;
				}
				if(_local7.hasOwnProperty("isMissileWeapon") || _local8 is Beam) {
					_local8.isMissileWeapon = _local7.isMissileWeapon;
				} else {
					_local8.isMissileWeapon = false;
				}
				if(_local7.hasOwnProperty("hasChargeUp")) {
					_local8.hasChargeUp = _local7.hasChargeUp;
				} else {
					_local8.hasChargeUp = false;
				}
				if(_local7.hasOwnProperty("specialCondition") && _local7.specialCondition != "") {
					_local8.specialCondition = _local7.specialCondition;
					if(_local7.hasOwnProperty("specialBonusPercentage")) {
						_local8.specialBonusPercentage = _local7.specialBonusPercentage;
					} else {
						_local8.specialBonusPercentage = 0;
					}
				}
				if(_local7.hasOwnProperty("maxChargeDuration")) {
					_local8.chargeUpTimeMax = _local7.maxChargeDuration;
				} else {
					_local8.chargeUpTimeMax = 750;
				}
				if(techLevel > 0) {
					_local11 = _local7.techLevels[techLevel - 1];
					_local8.projectileFunction = _local7.projectile == null ? "" : _local11.projectile;
				} else {
					_local8.projectileFunction = _local7.projectile == null ? "" : _local7.projectile;
				}
				_local8.alive = true;
			}
			return _local8;
		}
	}
}

