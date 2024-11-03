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
		
		private var _currentUnit:Unit = null;
		private var _oldUnit:Unit = null;
		private var _targetIndicator:TargetAimIndicator;
		private var _targetTimeout:Number = 0.0;
		public var _lockedTarget:Boolean = false;
		
		public function TargetSystem(game:Game) 
		{
			this._game = game;
			_targetIndicator = new TargetAimIndicator(this, 3);
			game.canvas.addChild(_targetIndicator);
		}
		
		public function set unit(value:Unit): void {
			if (_targetTimeout > 0 || _lockedTarget)
				return;
			_oldUnit = _currentUnit;
			_currentUnit = value;
			dispatchEvent(new TargetUpdatedEvent(TargetUpdatedEvent.EVENT, value));
			_targetTimeout = 0.5;
		}
		
		public function get unit(): Unit {
			return _currentUnit;
		}
		
		public function get oldUnit(): Unit {
			return _oldUnit;
		}
		
		private function reset(): void {
			_oldUnit = _currentUnit;
			_currentUnit = null;
			dispatchEvent(new TargetUpdatedEvent(TargetUpdatedEvent.EVENT, null));
			_targetTimeout = 0.0;
			_lockedTarget = false;
		}
		
		public function update(): void 
		{
			var targetInfoElement:TargetInfoElement = _game.hud.getTargetInfoElement();
			if (!TargetSystem.canTargetUnit(_currentUnit))
				reset();
			if (!_lockedTarget && !TargetSystem.isInRange(_currentUnit))
				reset();
				
			_targetIndicator.visible = _currentUnit != null;
			targetInfoElement.visible = _currentUnit != null;
			if (_targetTimeout > 0)
				_targetTimeout -= _game.deltaTime;
		}
		
		public function isTargetValid(): Boolean {
			return TargetSystem.canTargetUnit(_currentUnit);
		}
		
		public static function canTargetUnit(unit:Unit): Boolean {
			if (Game.instance.playerManager.me == null || Game.instance.playerManager.me.ship == null)
				return false;
			return unit != null && unit.alive && (unit is PlayerShip ? !(unit as PlayerShip).landed && !(unit as PlayerShip).player.isMe : true);
		}
		
		public static function isInRange(unit:Unit): Boolean {
			if (Game.instance.playerManager.me == null || Game.instance.playerManager.me.ship == null || unit == null)
				return false;
			return getDistance(Game.instance.playerManager.me.ship, unit) < TARGET_MAX_DISTANCE;
		}
		
		public static function getDistance(lhs:Unit, rhs:Unit):Number {
			return Util.distance(lhs.pos, rhs.pos);
		}
	}
}