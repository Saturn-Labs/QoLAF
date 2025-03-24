package core.boss {
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.unit.Unit;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.core.Starling;
	
	public class Trigger {
		public var id:int;
		
		public var target:int;
		
		public var delay:Number;
		
		public var activate:Boolean;
		
		public var inactivate:Boolean;
		
		public var vulnerable:Boolean;
		
		public var invulnerable:Boolean;
		
		public var kill:Boolean;
		
		public var threshhold:Number;
		
		public var inactivateSelf:Boolean;
		
		public var editBase:Boolean;
		
		public var speed:int;
		
		public var rotationSpeed:Number;
		
		public var targetRange:int;
		
		public var rotationForced:Boolean;
		
		public var acceleration:Number;
		
		public var xpos:int;
		
		public var ypos:int;
		
		public var radius:int;
		
		public var explosionEffect:String;
		
		public var soundName:String;
		
		private var triggerRdy:Boolean;
		
		private var activationTarget:Unit;
		
		private var activationTargetBoss:Boss;
		
		private var activationOwner:Unit;
		
		private var g:Game;
		
		public function Trigger(g:Game) {
			super();
			this.g = g;
			triggerRdy = true;
			activationTarget = null;
			activationTargetBoss = null;
			activationOwner = null;
		}
		
		public function reEnable() : void {
			triggerRdy = true;
		}
		
		public function tryActivateTrigger(u:Unit, b:Boss) : void {
			var _local3:Number = (u.hp + u.shieldHp) / (u.hpMax + u.shieldHpMax);
			if((_local3 <= threshhold || !u.alive) && triggerRdy) {
				triggerRdy = false;
				activationTarget = b.getComponent(target);
				if(editBase) {
					activationTargetBoss = b;
				}
				if(inactivateSelf) {
					activationOwner = u;
				}
				xpos += b.course.pos.x;
				ypos += b.course.pos.y;
				radius = b.bossRadius;
				delay /= 1000;
				if(delay < 0.025) {
					delay = 0.025;
				}
				Starling.juggler.delayCall(activateTrigger,delay);
			}
		}
		
		private function activateTrigger() : void {
			var _local1:ISound = null;
			if(g.camera != null && g.camera.isCircleOnScreen(xpos,ypos,radius)) {
				if(soundName != "") {
					_local1 = SoundLocator.getService();
					_local1.play(soundName);
				}
				if(explosionEffect != "") {
					EmitterFactory.create(explosionEffect,g,xpos,ypos,null,true);
				}
			}
			if(activationTarget != null) {
				activationTarget.triggersToActivte--;
				if(activationTarget.triggersToActivte <= 0) {
					if(activate) {
						activationTarget.alive = true;
						activationTarget.activate();
						activationTarget.visible = true;
					}
					if(inactivate) {
						activationTarget.active = false;
						activationTarget.visible = false;
					}
					if(vulnerable) {
						activationTarget.alive = true;
						activationTarget.visible = true;
						activationTarget.invulnerable = false;
					}
					if(invulnerable) {
						activationTarget.invulnerable = true;
					}
					if(kill) {
						activationTarget.hp = 0;
						activationTarget.shieldHp = 0;
						activationTarget.alive = false;
						activationTarget.visible = false;
						activationTarget.destroy();
					}
				}
			}
			if(activationOwner != null) {
				activationOwner.active = false;
			}
			if(activationTargetBoss != null) {
				activationTargetBoss.acceleration = acceleration;
				activationTargetBoss.speed = speed;
				activationTargetBoss.rotationSpeed = rotationSpeed;
				activationTargetBoss.rotationForced = rotationForced;
				activationTargetBoss.targetRange = targetRange;
			}
		}
	}
}

