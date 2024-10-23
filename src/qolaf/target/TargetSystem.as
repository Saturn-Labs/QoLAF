package qolaf.target 
{
	import core.GameObject;
	import core.boss.Boss;
	import core.scene.Game;
	import core.ship.Ship;
	import core.solarSystem.Body;
	import core.unit.Unit;
	import embeds.qolaf.TargetIconBitmap;
	import qolaf.ui.TargetAimIndicator;
	import qolaf.ui.TargetInfoElement;
	import starling.display.Image;
	import starling.textures.Texture;
	
	/**
	 * @author rydev
	 */
	public class TargetSystem 
	{
		private var game:Game;
		private var currentUnit:Unit = null;
		private var oldUnit:Unit = null;
		//private var targetIcon:Image;
		private var sinAnimValue:Number = 0;
		private var targetIndicator:TargetAimIndicator;
		
		public function TargetSystem(game:Game) 
		{
			this.game = game;
			targetIndicator = new TargetAimIndicator(this, 3);
			//targetIcon = new Image(Texture.fromBitmap(new TargetIconBitmap()))
			game.canvas.addChild(targetIndicator);
			//targetIcon.alignPivot();
		}
		
		public function SetCurrentUnit(unit:Unit): void {
			oldUnit = currentUnit;
			currentUnit = unit;
		}
		
		public function GetCurrentUnit(): Unit {
			return currentUnit;
		}
		
		public function Update(): void 
		{
			var targetInfoElement:TargetInfoElement = game.hud.GetTargetInfoElement();
			if (!TargetSystem.CanTargetUnit(currentUnit))
				currentUnit = null;
			targetIndicator.visible = currentUnit != null;
			targetIndicator.Update();
			targetInfoElement.visible = currentUnit != null;
			if (currentUnit != null) {
				//targetIcon.x = currentUnit.x;
				//targetIcon.y = (currentUnit.y - currentUnit.movieClip.texture.height / 2.0) - 20 + Math.sin(sinAnimValue) * 3;
				
				var mainObject:GameObject = currentUnit.parentObj;
				if (mainObject == null)
					mainObject = currentUnit;
				while (mainObject is Unit && (mainObject as Unit).parentObj != null) {
					mainObject = (mainObject as Unit).parentObj;
				}
				
				if (mainObject is Unit || mainObject is Body || mainObject is Boss)
					targetInfoElement.targetName.text = "<FONT COLOR='#fcba03'>Lv. " + currentUnit.level + "</FONT> " + mainObject.name;
			}
			sinAnimValue += 8 * game.deltaTime;
		}
		
		public static function CanTargetUnit(unit:Unit): Boolean {
			return unit != null && unit.type != "playerShip" && unit.alive;
		}
	}
}