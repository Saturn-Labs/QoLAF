package core.states.AIStates {
	import core.hud.components.BeamLine;
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.states.IState;
	import core.states.StateMachine;
	
	public class InstantSplitting implements IState {
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
		
		private var lines:Vector.<BeamLine> = new Vector.<BeamLine>();
		
		public function InstantSplitting(g:Game, p:Projectile, color:uint, glowColor:uint, thickness:Number, alpha:Number, aiMaxNrOfLines:int, aiBranchingFactor:int, aiSplitChance:Number) {
			super();
			this.g = g;
			this.p = p;
			this.color = color;
			this.glowColor = glowColor;
			this.alpha = alpha;
			this.thickness = thickness;
			this.splitChance = aiSplitChance;
			this.branchingFactor = aiBranchingFactor;
			this.maxNrOfLines = aiMaxNrOfLines;
			if(p.isHeal || p.unit.factions.length > 0) {
				this.isEnemy = false;
			} else {
				this.isEnemy = p.unit.type == "enemyShip" || p.unit.type == "turret";
			}
		}
		
		public function enter() : void {
			var _local1:BeamLine = null;
			_local1 = g.beamLinePool.getLine();
			_local1.init(thickness,1,0,color,alpha,3,glowColor);
			lines.push(_local1);
			g.canvasEffects.addChild(_local1);
		}
		
		public function execute() : void {
			if(p.alive) {
				for each(var _local1 in lines) {
					_local1.x = p.pos.x;
					_local1.y = p.pos.y;
					_local1.lineTo(p.pos.x + Math.cos(p.rotation) * 200,p.pos.y + Math.sin(p.rotation) * 200);
					_local1.alpha = alpha * p.ttl / p.ttlMax;
					_local1.visible = true;
				}
			} else {
				for each(_local1 in lines) {
					_local1.visible = false;
					_local1.clear();
					g.canvasEffects.removeChild(_local1);
				}
				lines = new Vector.<BeamLine>();
			}
		}
		
		public function exit() : void {
		}
		
		public function set stateMachine(sm:StateMachine) : void {
			this.sm = sm;
		}
		
		public function get type() : String {
			return "InstantSplitting";
		}
	}
}

