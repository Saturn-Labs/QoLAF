package core.states.AIStates {
	import core.hud.components.BeamLine;
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.states.IState;
	import core.states.StateMachine;
	
	public class Instant implements IState {
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
		
		public function Instant(g:Game, p:Projectile, color:uint, glowColor:uint, thickness:Number, alpha:Number, amplitude:Number, frequency:Number, texture:String = null) {
			super();
			this.g = g;
			this.p = p;
			this.color = color;
			this.glowColor = glowColor;
			this.amplitude = amplitude;
			this.frequency = frequency;
			this.alpha = alpha;
			this.thickness = 4 * thickness;
			if(texture != null && texture != "") {
				this.texture = texture;
			} else {
				this.texture = "line2";
			}
			if(p.isHeal || p.unit.factions.length > 0) {
				this.isEnemy = false;
			} else {
				this.isEnemy = p.unit.type == "enemyShip" || p.unit.type == "turret";
			}
		}
		
		public function enter() : void {
			var _local1:* = null;
			lineInner = g.beamLinePool.getLine();
			lineInner.init(1,frequency,amplitude,0xffffff,0,3,0xffffff,texture);
			lineInner.visible = false;
			g.canvasEffects.addChild(lineInner);
			lineOuter = g.beamLinePool.getLine();
			lineOuter.init(1,frequency,amplitude,color,0,3,glowColor,texture);
			lineOuter.visible = false;
			g.canvasEffects.addChild(lineOuter);
		}
		
		public function execute() : void {
			if(tick == 0 && p.range != 0) {
				p.ttl = p.ttl * (0.25 + 0.75 * p.range / p.weapon.range);
				p.ttlMax = p.ttlMax * (0.25 + 0.75 * p.range / p.weapon.range);
				tick = 1;
			}
			if(p.alive) {
				if(p.ttl > 0.25 * p.ttlMax) {
					lineInner.x = p.pos.x;
					lineInner.y = p.pos.y;
					lineInner.lineTo(p.pos.x + Math.cos(p.rotation) * p.range,p.pos.y + Math.sin(p.rotation) * p.range);
					lineInner.thickness = 0.3 * thickness * (0.1 + 0.9 * p.range / p.weapon.range) * (0.2 + 0.8 * (p.ttl - 0.25 * p.ttlMax) / (0.75 * p.ttlMax));
					lineInner.alpha = (p.ttl - 0.25 * p.ttlMax) / (0.75 * p.ttlMax);
					lineInner.visible = true;
				} else {
					lineInner.visible = false;
				}
				lineOuter.x = p.pos.x;
				lineOuter.y = p.pos.y;
				lineOuter.lineTo(p.pos.x + Math.cos(p.rotation) * p.range,p.pos.y + Math.sin(p.rotation) * p.range);
				lineOuter.thickness = thickness * (0.1 + 0.9 * p.range / p.weapon.range) * (0.2 + 0.8 * p.ttl / p.ttlMax);
				lineOuter.alpha = alpha * p.ttl / p.ttlMax;
				lineOuter.visible = true;
			} else {
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
		
		public function exit() : void {
		}
		
		public function set stateMachine(sm:StateMachine) : void {
			this.sm = sm;
		}
		
		public function get type() : String {
			return "Instant";
		}
	}
}

