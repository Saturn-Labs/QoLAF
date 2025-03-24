package core.hud.components.starMap {
	import flash.display.Sprite;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import textures.TextureManager;
	
	public class TransitButton extends starling.display.Sprite {
		public var target:SolarSystem;
		
		private var hovered:Boolean;
		
		private var color:uint;
		
		private var textureImage:Image;
		
		public function TransitButton(target:SolarSystem, color:uint) {
			super();
			this.target = target;
			this.color = color;
			draw();
			useHandCursor = true;
			addEventListener("touch",onTouch);
		}
		
		private function mouseOver(e:TouchEvent) : void {
			hovered = true;
			draw();
		}
		
		private function mouseOut(e:TouchEvent) : void {
			hovered = false;
			draw();
		}
		
		private function draw() : void {
			removeChildren();
			var _local1:flash.display.Sprite = new flash.display.Sprite();
			_local1.graphics.clear();
			var _local2:Vector.<int> = new Vector.<int>();
			var _local3:Vector.<Number> = new Vector.<Number>();
			_local2.push(1,2,2,2);
			_local3.push(-8,8);
			_local3.push(8,8);
			_local3.push(0,-8);
			_local3.push(-8,8);
			var _local4:uint = color;
			if(hovered) {
				_local4 = 0xffffff;
			}
			_local1.graphics.lineStyle(2,_local4);
			_local1.graphics.beginFill(0);
			_local1.graphics.drawPath(_local2,_local3);
			_local1.graphics.endFill();
			textureImage = TextureManager.imageFromSprite(_local1,"transitButton" + hovered.toString());
			addChild(textureImage);
		}
		
		private function onTouch(e:TouchEvent) : void {
			if(e.getTouch(this,"ended")) {
				click(e);
			} else if(e.interactsWith(this)) {
				mouseOver(e);
			} else if(!e.interactsWith(this)) {
				mouseOut(e);
			}
		}
		
		private function click(e:TouchEvent) : void {
			var _local2:ISound = SoundLocator.getService();
			_local2.play("3hVYqbNNSUWoDGk_pK1BdQ");
		}
		
		override public function dispose() : void {
			super.dispose();
		}
	}
}

