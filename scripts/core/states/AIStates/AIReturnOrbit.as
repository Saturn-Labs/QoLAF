package core.states.AIStates {
	import core.GameObject;
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.spawner.Spawner;
	import core.states.IState;
	import core.states.StateMachine;
	import flash.geom.Point;
	import movement.Heading;
	
	public class AIReturnOrbit implements IState {
		private var g:Game;
		
		private var s:EnemyShip;
		
		private var sm:StateMachine;
		
		private var target:Point;
		
		public function AIReturnOrbit(g:Game, s:EnemyShip, angle:Number, startTime:Number, t:Heading, nextTurnDirection:int) {
			super();
			s.target = null;
			s.ellipseAlpha = angle;
			s.orbitStartTime = startTime;
			if(s.getConverger() == null) {
				g.client.errorLog.writeError("converger == null in AiReturn, enemy: " + s.name,"","",{});
				return;
			}
			if(!s.aiCloak) {
				s.setConvergeTarget(t);
			}
			s.setNextTurnDirection(nextTurnDirection);
			this.g = g;
			this.s = s;
			if(s.factions.length == 1 && s.factions[0] == "tempFaction") {
				s.factions.splice(0,1);
			}
		}
		
		public function enter() : void {
			var _local2:Number = s.orbitRadius * s.ellipseFactor * Math.cos(s.orbitAngle);
			var _local4:Number = s.orbitRadius * Math.sin(s.orbitAngle);
			var _local1:Spawner = s.spawner;
			if(_local1 == null) {
				g.client.errorLog.writeError("Spawner == null in AiReturn, enemy: " + s.name,"","",{});
				return;
			}
			var _local5:GameObject = _local1.parentObj;
			if(_local5 == null) {
				g.client.errorLog.writeError("Parent Obj == null in AiReturn, enemy: " + s.name,"","",{});
				return;
			}
			if(_local5.pos == null) {
				g.client.errorLog.writeError("Parent Obj pos == null in AiReturn, enemy: " + s.name,"","",{});
				return;
			}
			var _local3:Point = new Point(_local5.pos.x,_local5.pos.y);
			target = new Point();
			target.x = _local2 * Math.cos(s.ellipseAlpha) - _local4 * Math.sin(s.ellipseAlpha) + _local3.x;
			target.y = _local2 * Math.sin(s.ellipseAlpha) + _local4 * Math.cos(s.ellipseAlpha) + _local3.y;
			s.accelerate = false;
			s.setAngleTargetPos(target);
			s.target = null;
			s.stopShooting();
			if(s.course == null) {
				g.client.errorLog.writeError("course == null in AiReturn, enemy: " + s.name,"","",{});
				return;
			}
			s.course.speed.x = s.course.speed.y = 0;
		}
		
		public function execute() : void {
			if(s.isFacingAngleTarget()) {
				s.accelerate = true;
			}
			if(!s.aiCloak) {
				s.runConverger();
			}
			if(g.time > s.orbitStartTime) {
				s.stateMachine.changeState(new AIOrbit(g,s,true));
				return;
			}
			if(!s.isAddedToCanvas) {
				return;
			}
			s.regenerateShield();
			s.updateHealthBars();
			s.engine.update();
			s.updateWeapons();
		}
		
		public function exit() : void {
		}
		
		public function set stateMachine(sm:StateMachine) : void {
			this.sm = sm;
		}
		
		public function get type() : String {
			return "AIReturn";
		}
	}
}

