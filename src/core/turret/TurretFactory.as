package core.turret
{
	import core.boss.Boss;
	import core.scene.Game;
	import core.ship.ShipFactory;
	import core.weapon.Weapon;
	import core.weapon.WeaponFactory;
	import data.DataLocator;
	import data.IDataManager;
	import generics.Util;
	
	public class TurretFactory
	{
		public function TurretFactory()
		{
			super();
		}
		
		public static function createTurret(param1:Object, param2:String, param3:Game, param4:Boss = null):Turret
		{
			var _loc8_:Number = NaN;
			var _loc5_:Weapon = null;
			var _loc9_:IDataManager = DataLocator.getService();
			var _loc7_:Object = _loc9_.loadKey("Turrets", param2);
			var _loc6_:Turret = param3.turretManager.getTurret();
			if (_loc7_.aimArc == 360)
			{
				_loc6_.aimArc = 3.141592653589793 * 2;
			}
			else
			{
				_loc6_.aimArc = Util.degreesToRadians(_loc7_.aimArc);
			}
			_loc6_.aimSkill = _loc7_.aimSkill;
			_loc6_.rotationSpeed = _loc7_.rotationSpeed;
			_loc6_.name = _loc7_.name;
			_loc6_.xp = _loc7_.xp;
			_loc6_.level = _loc7_.level;
			_loc6_.isHostile = true;
			if (param1.hasOwnProperty("AIFaction1") && param1.AIFaction1 != "")
			{
				_loc6_.factions.push(param1.AIFaction1);
			}
			if (param1.hasOwnProperty("AIFaction2") && param1.AIFaction2 != "")
			{
				_loc6_.factions.push(param1.AIFaction2);
			}
			_loc6_.forcedRotation = _loc7_.forcedRotation;
			if (_loc6_.forcedRotation)
			{
				_loc6_.forcedRotationSpeed = _loc7_.forcedRotationSpeed;
				_loc6_.forcedRotationAim = _loc7_.forcedRotationAim;
			}
			ShipFactory.createBody(_loc7_.body, param3, _loc6_);
			if (param3.isSystemTypeSurvival() && param4 != null)
			{
				_loc6_.level = param4.level;
			}
			if (param3.isSystemTypeSurvival() && _loc6_.level < param3.hud.uberStats.uberLevel)
			{
				_loc8_ = param3.hud.uberStats.CalculateUberRankFromLevel(_loc6_.level);
				_loc6_.uberDifficulty = param3.hud.uberStats.CalculateUberDifficultyFromRank(param3.hud.uberStats.uberRank - _loc8_, _loc6_.level);
				_loc6_.uberLevelFactor = 1 + (param3.hud.uberStats.uberLevel - _loc6_.level) / 100;
				if (param4 != null)
				{
					_loc6_.uberDifficulty *= param3.hud.uberStats.uberRank / 2 + 1;
				}
				_loc6_.xp *= _loc6_.uberLevelFactor;
				_loc6_.level = param3.hud.uberStats.uberLevel;
				_loc6_.hp = _loc6_.hpMax = _loc6_.hpMax * _loc6_.uberDifficulty;
				_loc6_.shieldHp = _loc6_.shieldHpMax = _loc6_.shieldHpMax * _loc6_.uberDifficulty;
			}
			_loc6_.pos.x = 1000000;
			_loc6_.pos.y = 1000000;
			if (_loc7_.hasOwnProperty("weapon"))
			{
				_loc5_ = WeaponFactory.create(_loc7_.weapon, param3, _loc6_, 0);
				_loc6_.weapon = _loc5_;
			}
			return _loc6_;
		}
	}
}
