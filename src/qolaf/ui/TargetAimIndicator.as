package qolaf.ui 
{
	import embeds.qolaf.TargetIconBitmap;
	import qolaf.target.TargetSystem;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.events.Event;
	import starling.events.EnterFrameEvent;
	import core.scene.Game;
	
	/**
	 * @author rydev
	 */
	public class TargetAimIndicator extends DisplayObjectContainer 
	{
		private var _targetSystem:TargetSystem;
		private var _arrowAmount:Number;
		private var _angleOffseter:Number;
		private var _arrowImages:Vector.<Image> = new Vector.<Image>;
		private var _angleRotation:Number = 0;
		private var _radiusAnim:Number = 0;
		
		public function TargetAimIndicator(targetSystem:TargetSystem, arrows:Number = 3, color:Number = 0xFFFFFF) 
		{
			this._targetSystem = targetSystem;
			_arrowAmount = arrows;
			_angleOffseter = 360.0 / arrows;
			var arrowTexture:Texture = Texture.fromBitmap(new TargetIconBitmap(), true);
			for (var i:Number = 0; i < arrows; i++) {
				var arrowImage:Image = new Image(arrowTexture);
				arrowImage.color = color;
				arrowImage.alignPivot();
				addChild(arrowImage);
				_arrowImages.push(arrowImage);
			}
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function onEnterFrame(e:EnterFrameEvent): void {
			if (!TargetSystem.canTargetUnit(_targetSystem.getCurrentUnit()))
				return;
			var angle:Number = _angleRotation;
			var radius:Number = (_targetSystem.getCurrentUnit().texture.width / 2 + 25) + Math.sin(_radiusAnim) * 4;
			for (var i:Number = 0; i < _arrowAmount; i++) {
				var x:Number = radius * Math.cos(angle * (Math.PI / 180)) + _targetSystem.getCurrentUnit().x;
				var y:Number = radius * Math.sin(angle * (Math.PI / 180)) + _targetSystem.getCurrentUnit().y;
				angle += _angleOffseter;
				_arrowImages[i].x = x;
				_arrowImages[i].y = y;
				var arrowRotAngle:Number = Math.atan2(_targetSystem.getCurrentUnit().y - _arrowImages[i].y, _targetSystem.getCurrentUnit().x - _arrowImages[i].x);
				_arrowImages[i].rotation = arrowRotAngle;
			}
			_angleRotation += 32 * e.passedTime;
			_radiusAnim += 6 * e.passedTime;
		}
	}

}