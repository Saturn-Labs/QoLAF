package core.states.AIStates
{
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.states.*;
	
	public class AIStateFactory
	{
		public static const BULLET:String = "bullet";
		public static const HOMING_MISSILE:String = "homingMissile";
		public static const BLASTWAVE:String = "blastwave";
		public static const MINE:String = "mine";
		public static const BOOMERANG:String = "boomerang";
		public static const BOUNCING:String = "bouncing";
		public static const CLUSTER:String = "cluster";
		public static const INSTANTSPLITTING:String = "instantSplitting";
		public static const INSTANT:String = "instant";
		public static const TARGETPAINT:String = "targetPainter";
		public function AIStateFactory()
		{
			super();
		}
		
		public static function createProjectileAI(param1:Object, param2:Game, param3:Projectile):IState
		{
			var _loc6_:Number = NaN;
			var _loc5_:Number = NaN;
			var _loc4_:IState = null;
			param3.ai = param1.ai;
			switch (param1.ai)
			{
			case "cluster": 
				_loc4_ = new Cluster(param2, param3);
				break;
			case "bullet": 
			case "targetPainter": 
				_loc4_ = new ProjectileBullet(param2, param3);
				break;
			case "blastwave": 
				_loc4_ = new Blastwave(param2, param3, param1.aiDelay, param1.aiFollow);
				break;
			case "homingMissile": 
				if (param1.hasOwnProperty("aiStick") && param1.aiStick == true)
				{
					param3.aiStuckDuration = param1.aiStickDuration;
				}
				if (param1.aiDelayedAcceleration == true)
				{
					param3.aiDelayedAccelerationTime = param1.aiDelayedAccelerationTime;
				}
				_loc4_ = new Missile(param2, param3);
				break;
			case "boomerang": 
				_loc4_ = new Boomerang(param2, param3);
				break;
			case "bouncing": 
				param3.aiTargetSelf = param1.aiTargetSelf;
				_loc4_ = new Bouncing(param2, param3);
				break;
			case "mine": 
				if (param1.hasOwnProperty("aiDelay"))
				{
					_loc4_ = new Mine(param2, param3, param1.aiDelay);
				}
				else
				{
					_loc4_ = new Mine(param2, param3, 5000);
				}
				break;
			case "instantSplitting": 
				_loc4_ = new InstantSplitting(param2, param3, param1.color, param1.glowColor, param1.thickness, param1.alpha, param1.aiMaxNrOfLines, param1.aiBranchingFactor, param1.aiSplitChance);
				break;
			case "instant": 
				_loc6_ = 0;
				_loc5_ = 0.1;
				if (param1.hasOwnProperty("amplitude"))
				{
					_loc6_ = Number(param1.amplitude);
				}
				if (param1.hasOwnProperty("frequency"))
				{
					_loc5_ = 0.1 * Number(param1.frequency);
				}
				_loc4_ = new Instant(param2, param3, param1.color, param1.glowColor, param1.thickness, param1.alpha, _loc6_, _loc5_, param1.texture);
			}
			return _loc4_;
		}
	}
}
