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
	import qolaf.ui.TargetAimIndicator;
	import qolaf.ui.TargetInfoElement;
	import starling.display.Image;
	import starling.textures.Texture;
	import generics.Util;
	
	/**
	 * @author rydev
	 */
	public class TargetSystem 
	{
		public static const TARGET_MAX_DISTANCE:Number = 1000;
		
		private var game:Game;
		private var currentUnit:Unit = null;
		private var oldUnit:Unit = null;
		private var targetIndicator:TargetAimIndicator;
		private var targetTimeout:Number = 0.0;
		public var lockedTarget:Boolean = false;
		
		public function TargetSystem(game:Game) 
		{
			this.game = game;
			targetIndicator = new TargetAimIndicator(this, 3);
			game.canvas.addChild(targetIndicator);
		}
		
		public function SetCurrentUnit(unit:Unit): void {
			if (targetTimeout > 0 || lockedTarget)
				return;
			oldUnit = currentUnit;
			currentUnit = unit;
			targetTimeout = 0.5;
		}
		
		public function GetCurrentUnit(): Unit {
			return currentUnit;
		}
		
		public function Reset(): void {
			currentUnit = null;
			targetTimeout = 0.0;
			lockedTarget = false;
		}
		
		public function Update(): void 
		{
			var targetInfoElement:TargetInfoElement = game.hud.GetTargetInfoElement();
			if (!TargetSystem.CanTargetUnit(currentUnit))
				Reset();
			if (!lockedTarget && !TargetSystem.IsInRange(currentUnit))
				Reset();
				
			targetIndicator.visible = currentUnit != null;
			targetIndicator.Update();
			targetInfoElement.visible = currentUnit != null;
			if (currentUnit != null) {
				var mainObject:GameObject = currentUnit.parentObj;
				if (mainObject == null)
					mainObject = currentUnit;
				while (mainObject is Unit && (mainObject as Unit).parentObj != null) {
					mainObject = (mainObject as Unit).parentObj;
				}
				
				targetInfoElement.targetName.text = "<font face='Arial' size='14px'><font color='#fcba03'><b>Lv. " + currentUnit.level + "</b></font> " + mainObject.name.replace(/lvl \d+/g, "").replace(/ +/g, " ") + "</font>";
			}
			if (targetTimeout > 0)
				targetTimeout -= game.deltaTime;
		}
		
		public function CurrentUnitValid(): Boolean {
			return TargetSystem.CanTargetUnit(currentUnit);
		}
		
		public static function CanTargetUnit(unit:Unit): Boolean {
			if (Game.instance.playerManager.me == null || Game.instance.playerManager.me.ship == null)
				return false;
			return unit != null && unit.alive && (unit is PlayerShip ? !(unit as PlayerShip).landed : true);
		}
		
		public static function IsInRange(unit:Unit): Boolean {
			if (Game.instance.playerManager.me == null || Game.instance.playerManager.me.ship == null || unit == null)
				return false;
			return GetDistance(Game.instance.playerManager.me.ship, unit) < TARGET_MAX_DISTANCE;
		}
		
		public static function GetDistance(lhs:Unit, rhs:Unit): Number {
			return Util.distance(lhs.pos, rhs.pos);
		}
	}
}