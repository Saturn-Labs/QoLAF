package core.turret {
	import core.boss.Boss;
	import core.scene.Game;
	import core.ship.ShipFactory;
	import core.weapon.Weapon;
	import core.weapon.WeaponFactory;
	import data.DataLocator;
	import data.IDataManager;
	import generics.Util;
	
	public class TurretFactory {
		public function TurretFactory() {
			super();
		}
		
		public static function createTurret(obj:Object, key:String, g:Game, b:Boss = null) : Turret {
			var _local6:Number = NaN;
			var _local7:Weapon = null;
			var _local8:IDataManager = DataLocator.getService();
			var _local9:Object = _local8.loadKey("Turrets",key);
			var _local5:Turret = g.turretManager.getTurret();
			if(_local9.aimArc == 6 * 60) {
				_local5.aimArc = 3.141592653589793 * 2;
			} else {
				_local5.aimArc = Util.degreesToRadians(_local9.aimArc);
			}
			_local5.aimSkill = _local9.aimSkill;
			_local5.rotationSpeed = _local9.rotationSpeed;
			_local5.name = _local9.name;
			_local5.xp = _local9.xp;
			_local5.level = _local9.level;
			_local5.isHostile = true;
			if(obj.hasOwnProperty("AIFaction1") && obj.AIFaction1 != "") {
				_local5.factions.push(obj.AIFaction1);
			}
			if(obj.hasOwnProperty("AIFaction2") && obj.AIFaction2 != "") {
				_local5.factions.push(obj.AIFaction2);
			}
			_local5.forcedRotation = _local9.forcedRotation;
			if(_local5.forcedRotation) {
				_local5.forcedRotationSpeed = _local9.forcedRotationSpeed;
				_local5.forcedRotationAim = _local9.forcedRotationAim;
			}
			ShipFactory.createBody(_local9.body,g,_local5);
			if(g.isSystemTypeSurvival() && b != null) {
				_local5.level = b.level;
			}
			if(g.isSystemTypeSurvival() && _local5.level < g.hud.uberStats.uberLevel) {
				_local6 = g.hud.uberStats.CalculateUberRankFromLevel(_local5.level);
				_local5.uberDifficulty = g.hud.uberStats.CalculateUberDifficultyFromRank(g.hud.uberStats.uberRank - _local6,_local5.level);
				_local5.uberLevelFactor = 1 + (g.hud.uberStats.uberLevel - _local5.level) / 100;
				if(b != null) {
					_local5.uberDifficulty *= g.hud.uberStats.uberRank / 2 + 1;
				}
				_local5.xp *= _local5.uberLevelFactor;
				_local5.level = g.hud.uberStats.uberLevel;
				_local5.hp = _local5.hpMax = _local5.hpMax * _local5.uberDifficulty;
				_local5.shieldHp = _local5.shieldHpMax = _local5.shieldHpMax * _local5.uberDifficulty;
			}
			_local5.pos.x = 1000000;
			_local5.pos.y = 1000000;
			if(_local9.hasOwnProperty("weapon")) {
				_local7 = WeaponFactory.create(_local9.weapon,g,_local5,0);
				_local5.weapon = _local7;
			}
			return _local5;
		}
	}
}

