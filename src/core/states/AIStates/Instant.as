package core.states.AIStates
{
	import core.hud.components.BeamLine;
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.states.IState;
	import core.states.StateMachine;
	
	public class Instant implements IState
	{
		protected var g:Game;
		
		protected var p:Projectile;
		
		private var sm:StateMachine;
		
		private var isEnemy:Boolean;
		
		private var color:uint;
		
		private var thickness:Number;
		
		private var alpha:Number;
		
		private var amplitude:Number;
		
		private var frequency:Number;
		
		private var glowColor:uint;
		
		private var lineInner:BeamLine;
		
		private var lineOuter:BeamLine;
		
		private var texture:String;
		
		private var tick:int = 0;
		public function Instant(param1:Game, param2:Projectile, param3:uint, param4:uint, param5:Number, param6:Number, param7:Number, param8:Number, param9:String = null)
		{
			super();
			this.g = param1;
			this.p = param2;
			this.color = param3;
			this.glowColor = param4;
			this.amplitude = param7;
			this.frequency = param8;
			this.alpha = param6;
			this.thickness = 4 * param5;
			if (param9 != null && param9 != "")
			{
				this.texture = param9;
			}
			else
			{
				this.texture = "line2";
			}
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
			var _loc1_:* = null;
			lineInner = g.beamLinePool.getLine();
			lineInner.init(1, frequency, amplitude, 16777215, 0, 3, 16777215, texture);
			lineInner.visible = false;
			g.canvasEffects.addChild(lineInner);
			lineOuter = g.beamLinePool.getLine();
			lineOuter.init(1, frequency, amplitude, color, 0, 3, glowColor, texture);
			lineOuter.visible = false;
			g.canvasEffects.addChild(lineOuter);
		}
		
		public function execute():void
		{
			if (tick == 0 && p.range != 0)
			{
				p.ttl = p.ttl * (0.25 + 0.75 * p.range / p.weapon.range);
				p.ttlMax = p.ttlMax * (0.25 + 0.75 * p.range / p.weapon.range);
				tick = 1;
			}
			if (p.alive)
			{
				if (p.ttl > 0.25 * p.ttlMax)
				{
					lineInner.x = p.pos.x;
					lineInner.y = p.pos.y;
					lineInner.lineTo(p.pos.x + Math.cos(p.rotation) * p.range, p.pos.y + Math.sin(p.rotation) * p.range);
					lineInner.thickness = 0.3 * thickness * (0.1 + 0.9 * p.range / p.weapon.range) * (0.2 + 0.8 * (p.ttl - 0.25 * p.ttlMax) / (0.75 * p.ttlMax));
					lineInner.alpha = (p.ttl - 0.25 * p.ttlMax) / (0.75 * p.ttlMax);
					lineInner.visible = true;
				}
				else
				{
					lineInner.visible = false;
				}
				lineOuter.x = p.pos.x;
				lineOuter.y = p.pos.y;
				lineOuter.lineTo(p.pos.x + Math.cos(p.rotation) * p.range, p.pos.y + Math.sin(p.rotation) * p.range);
				lineOuter.thickness = thickness * (0.1 + 0.9 * p.range / p.weapon.range) * (0.2 + 0.8 * p.ttl / p.ttlMax);
				lineOuter.alpha = alpha * p.ttl / p.ttlMax;
				lineOuter.visible = true;
			}
			else
			{
				lineInner.visible = false;
				lineInner.clear();
				g.beamLinePool.removeLine(lineInner);
				g.canvasEffects.removeChild(lineInner);
				lineOuter.visible = false;
				lineOuter.clear();
				g.beamLinePool.removeLine(lineOuter);
				g.canvasEffects.removeChild(lineOuter);
			}
			p.course.time += 33;
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
			return "Instant";
		}
	}
}
