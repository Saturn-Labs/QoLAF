package core.spawner {
	import core.boss.Boss;
	import core.scene.Game;
	
	public class SpawnFactory {
		public function SpawnFactory() {
			super();
		}
		
		public static function createSpawner(obj:Object, key:String, g:Game, b:Boss = null) : Spawner {
			var _local5:Spawner = g.spawnManager.getSpawner(obj.type);
			_local5.obj = obj;
			_local5.isHostile = true;
			if(obj.hasOwnProperty("AIFaction1") && obj.AIFaction1 != "") {
				_local5.factions.push(obj.AIFaction1);
			}
			if(obj.hasOwnProperty("AIFaction2") && obj.AIFaction2 != "") {
				_local5.factions.push(obj.AIFaction2);
			}
			_local5.bodyName = obj.name;
			_local5.key = key;
			_local5.objKey = obj.key;
			_local5.innerRadius = obj.innerRadius;
			_local5.outerRadius = obj.outerRadius;
			_local5.collisionRadius = obj.collisionRadius;
			_local5.orbitRadius = obj.orbitRadius;
			_local5.spawnerType = obj.type;
			if(_local5.orbitRadius == 0) {
				_local5.angleVelocity = 0;
			} else {
				_local5.angleVelocity = 1 / (_local5.orbitRadius * 3.141592653589793);
			}
			_local5.rotationSpeed = 0;
			_local5.hidden = obj.hidden;
			_local5.level = obj.level;
			_local5.hp = obj.hp;
			_local5.hpMax = _local5.hp;
			_local5.shieldHp = obj.shieldHp;
			_local5.shieldHpMax = _local5.shieldHp;
			_local5.tryAdjustUberStats(b);
			_local5.initialHardenedShield = b == null ? true : false;
			_local5.explosionSound = obj.explosionSound;
			_local5.explosionEffect = obj.explosionEffect;
			if(_local5.isMech() && obj.explosionEffect == null) {
				_local5.explosionEffect = "Vk5Hgk-n2UqelveFMqdCfw";
			} else if(_local5.spawnerType == "organic" && obj.explosionEffect == null) {
				_local5.explosionEffect = "QZPBVWcMEUqxnySWvkwTAw";
			}
			_local5.switchTexturesByObj(obj);
			if(obj.turrets != null) {
				_local5.addTurrets(obj);
			}
			_local5.alive = true;
			return _local5;
		}
	}
}

