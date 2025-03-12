package core.states.AIStates
{
	import core.hud.components.BeamLine;
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.states.IState;
	import core.states.StateMachine;
	
	public class InstantSplitting implements IState
	{
		protected var g:Game;
		
		protected var p:Projectile;
		
		private var sm:StateMachine;
		
		private var isEnemy:Boolean;
		
		private var color:uint;
		
		private var thickness:Number;
		
		private var alpha:Number;
		
		private var maxNrOfLines:int;
		
		private var glowColor:uint;
		
		private var branchingFactor:int;
		
		private var splitChance:Number;
		
		private var lines:Vector.<BeamLine>;
		
		public function InstantSplitting(param1:Game, param2:Projectile, param3:uint, param4:uint, param5:Number, param6:Number, param7:int, param8:int, param9:Number)
		{
			lines = new Vector.<BeamLine>();
			super();
			this.g = param1;
			this.p = param2;
			this.color = param3;
			this.glowColor = param4;
			this.alpha = param6;
			this.thickness = param5;
			this.splitChance = param9;
			this.branchingFactor = param8;
			this.maxNrOfLines = param7;
			if (param2.isHeal || param2.unit.factions.length > 0)
			{
				this.isEnemy = false;
			}
			else
			{
				this.isEnemy = param2.unit.type == "enemyShip" || param2.unit.type == "turret";
			}
		}
		
		public function enter():void
		{
			var _loc1_:BeamLine = null;
			_loc1_ = g.beamLinePool.getLine();
			_loc1_.init(thickness, 1, 0, color, alpha, 3, glowColor);
			lines.push(_loc1_);
			g.canvasEffects.addChild(_loc1_);
		}
		
		public function execute():void
		{
			if (p.alive)
			{
				for each (var _loc1_:* in lines)
				{
					_loc1_.x = p.pos.x;
					_loc1_.y = p.pos.y;
					_loc1_.lineTo(p.pos.x + Math.cos(p.rotation) * 200, p.pos.y + Math.sin(p.rotation) * 200);
					_loc1_.alpha = alpha * p.ttl / p.ttlMax;
					_loc1_.visible = true;
				}
			}
			else
			{
				for each (_loc1_ in lines)
				{
					_loc1_.visible = false;
					_loc1_.clear();
					g.canvasEffects.removeChild(_loc1_);
				}
				lines = new Vector.<BeamLine>();
			}
		}
		
		public function exit():void
		{
		}
		
		public function set stateMachine(param1:StateMachine):void
		{
			this.sm = param1;
		}
		
		public function get type():String
		{
			return "InstantSplitting";
		}
	}
}
