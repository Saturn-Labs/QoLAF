package core.spawner
{
	import core.boss.Boss;
	import core.scene.Game;
	
	public class SpawnFactory
	{
		public function SpawnFactory()
		{
			super();
		}
		
		public static function createSpawner(param1:Object, param2:String, param3:Game, param4:Boss = null):Spawner
		{
			var _loc5_:Spawner = param3.spawnManager.getSpawner(param1.type);
			_loc5_.obj = param1;
			_loc5_.isHostile = true;
			if (param1.hasOwnProperty("AIFaction1") && param1.AIFaction1 != "")
			{
				_loc5_.factions.push(param1.AIFaction1);
			}
			if (param1.hasOwnProperty("AIFaction2") && param1.AIFaction2 != "")
			{
				_loc5_.factions.push(param1.AIFaction2);
			}
			_loc5_.bodyName = param1.name;
			_loc5_.key = param2;
			_loc5_.objKey = param1.key;
			_loc5_.innerRadius = param1.innerRadius;
			_loc5_.outerRadius = param1.outerRadius;
			_loc5_.collisionRadius = param1.collisionRadius;
			_loc5_.orbitRadius = param1.orbitRadius;
			_loc5_.spawnerType = param1.type;
			if (_loc5_.orbitRadius == 0)
			{
				_loc5_.angleVelocity = 0;
			}
			else
			{
				_loc5_.angleVelocity = 1 / (_loc5_.orbitRadius * 3.141592653589793);
			}
			_loc5_.rotationSpeed = 0;
			_loc5_.hidden = param1.hidden;
			_loc5_.level = param1.level;
			_loc5_.hp = param1.hp;
			_loc5_.hpMax = _loc5_.hp;
			_loc5_.shieldHp = param1.shieldHp;
			_loc5_.shieldHpMax = _loc5_.shieldHp;
			_loc5_.tryAdjustUberStats(param4);
			_loc5_.initialHardenedShield = param4 == null ? true : false;
			_loc5_.explosionSound = param1.explosionSound;
			_loc5_.explosionEffect = param1.explosionEffect;
			if (_loc5_.isMech() && param1.explosionEffect == null)
			{
				_loc5_.explosionEffect = "Vk5Hgk-n2UqelveFMqdCfw";
			}
			else if (_loc5_.spawnerType == "organic" && param1.explosionEffect == null)
			{
				_loc5_.explosionEffect = "QZPBVWcMEUqxnySWvkwTAw";
			}
			_loc5_.switchTexturesByObj(param1);
			if (param1.turrets != null)
			{
				_loc5_.addTurrets(param1);
			}
			_loc5_.alive = true;
			return _loc5_;
		}
	}
}
