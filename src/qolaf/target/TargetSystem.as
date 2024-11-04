package qolaf.target 
{
	import core.GameObject;
	import core.boss.Boss;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import core.ship.Ship;
	import core.solarSystem.Body;
	import core.unit.Unit;
	import embeds.qolaf.TargetIconBitmap;
	import flash.events.EventDispatcher;
	import qolaf.events.TargetUpdatedEvent;
	import qolaf.ui.TargetAimIndicator;
	import qolaf.ui.TargetInfoElement;
	import starling.display.Image;
	import starling.textures.Texture;
	import generics.Util;
	
	/**
	 * @author rydev
	 */
	public class TargetSystem extends EventDispatcher
	{
		public static const TARGET_MAX_DISTANCE:Number = 1000;
		
		private var _game:Game;
		
		private var _currentTarget:ITarget = null;
		private var _oldTarget:ITarget = null;
		private var _targetIndicator:TargetAimIndicator;
		private var _targetTimeout:Number = 0.0;
		public var _lockedTarget:Boolean = false;
		
		public function TargetSystem(game:Game) 
		{
			this._game = game;
			_targetIndicator = new TargetAimIndicator(this, 3);
			game.canvas.addChild(_targetIndicator);
		}
		
		public function set target(target:ITarget): void {
			if (_targetTimeout > 0 || _lockedTarget)
				return;
			_oldTarget = _currentTarget;
			_currentTarget = target;
			dispatchEvent(new TargetUpdatedEvent(TargetUpdatedEvent.EVENT, target));
			_targetTimeout = 0.5;
		}
		
		public function get target():ITarget {
			return _currentTarget;
		}
		
		public function get oldTarget():ITarget {
			return _oldTarget;
		}
		
		private function reset(): void {
			_oldTarget = _currentTarget;
			_currentTarget = null;
			dispatchEvent(new TargetUpdatedEvent(TargetUpdatedEvent.EVENT, null));
			_targetTimeout = 0.0;
			_lockedTarget = false;
		}
		
		public function update(): void 
		{
			var targetInfoElement:TargetInfoElement = _game.hud.getTargetInfoElement();
			if (!TargetSystem.canTarget(_currentTarget))
				reset();
			if (!_lockedTarget && !TargetSystem.isTargetInRange(_currentTarget))
				reset();
				
			_targetIndicator.visible = _currentTarget != null;
			targetInfoElement.visible = _currentTarget != null;
			if (_targetTimeout > 0)
				_targetTimeout -= _game.deltaTime;
		}
		
		public function isTargetValid(): Boolean {
			return TargetSystem.canTarget(_currentTarget);
		}
		
		public static function canTarget(target:ITarget): Boolean {
			if (Game.instance.playerManager.me == null || Game.instance.playerManager.me.ship == null)
				return false;
			return target != null && target.isAlive() && (target is PlayerShip ? !(target as PlayerShip).landed && !(target as PlayerShip).player.isMe : true);
		}
		
		public static function isTargetInRange(target:ITarget): Boolean {
			if (Game.instance.playerManager.me == null || Game.instance.playerManager.me.ship == null || target == null)
				return false;
			return getDistance(Game.instance.playerManager.me.ship, target) < TARGET_MAX_DISTANCE;
		}
		
		public static function getDistance(lhs:ITarget, rhs:ITarget):Number {
			return Util.distance(lhs.getPosition(), rhs.getPosition());
		}
	}
}