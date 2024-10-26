package qolaf.ui 
{
	import embeds.qolaf.TargetIconBitmap;
	import qolaf.target.TargetSystem;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.textures.Texture;
	import core.scene.Game;
	
	/**
	 * @author rydev
	 */
	public class TargetAimIndicator extends DisplayObjectContainer 
	{
		private var targetSystem:TargetSystem;
		private var arrowAmount:Number;
		private var angleOffseter:Number;
		private var arrowImages:Vector.<Image> = new Vector.<Image>;
		private var angleRotation:Number = 0;
		private var radiusAnim:Number = 0;
		
		public function TargetAimIndicator(targetSystem:TargetSystem, arrows:Number = 3, color:Number = 0xFFFFFF) 
		{
			this.targetSystem = targetSystem;
			arrowAmount = arrows;
			angleOffseter = 360.0 / arrows;
			var arrowTexture:Texture = Texture.fromBitmap(new TargetIconBitmap(), true);
			for (var i:Number = 0; i < arrows; i++) {
				var arrowImage:Image = new Image(arrowTexture);
				arrowImage.color = color;
				arrowImage.alignPivot();
				addChild(arrowImage);
				arrowImages.push(arrowImage);
			}
		}
		
		public function update(): void {
			if (!TargetSystem.canTargetUnit(targetSystem.getCurrentUnit()))
				return;
			var angle:Number = angleRotation;
			var radius:Number = (targetSystem.getCurrentUnit().texture.width / 2 + 25) + Math.sin(radiusAnim) * 4;
			for (var i:Number = 0; i < arrowAmount; i++) {
				var x:Number = radius * Math.cos(angle * (Math.PI / 180)) + targetSystem.getCurrentUnit().x;
				var y:Number = radius * Math.sin(angle * (Math.PI / 180)) + targetSystem.getCurrentUnit().y;
				angle += angleOffseter;
				arrowImages[i].x = x;
				arrowImages[i].y = y;
				var arrowRotAngle:Number = Math.atan2(targetSystem.getCurrentUnit().y - arrowImages[i].y, targetSystem.getCurrentUnit().x - arrowImages[i].x);
				arrowImages[i].rotation = arrowRotAngle;
			}
			angleRotation += 32 * Game.instance.deltaTime;
			radiusAnim += 6 * Game.instance.deltaTime;
		}
	}

}