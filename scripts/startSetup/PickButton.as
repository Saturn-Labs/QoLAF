package startSetup {
	import com.greensock.TweenMax;
	import core.hud.components.Box;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import starling.filters.GlowFilter;
	import textures.TextureLocator;
	
	public class PickButton extends Sprite {
		private var bgr:Box;
		
		private var callback:Function;
		
		private var image:Image;
		
		public var mouseOverCallback:Function = null;
		
		private var isSelected:Boolean = false;
		
		private var rotationTween:TweenMax;
		
		public function PickButton(imageName:String, callback:Function, isGuiTexture:Boolean = false) {
			super();
			if(isGuiTexture) {
				image = new Image(TextureLocator.getService().getTextureGUIByTextureName(imageName));
			} else {
				image = new Image(TextureLocator.getService().getTextureMainByTextureName(imageName));
			}
			this.callback = callback;
			var _local4:Number = 100;
			bgr = new Box(90,90,"normal",0.8,0);
			addChild(bgr);
			image.pivotX = image.width / 2;
			image.pivotY = image.height / 2;
			image.x = bgr.width / 2;
			image.y = bgr.height / 2;
			addChild(image);
			addEventListener("touch",onTouch);
			useHandCursor = true;
			pivotX = width / 2;
			pivotY = height / 2;
		}
		
		private function onTouch(e:TouchEvent) : void {
			var _local2:ISound = null;
			if(isSelected) {
				return;
			}
			if(e.getTouch(this,"began")) {
				callback();
				e.stopPropagation();
				_local2 = SoundLocator.getService();
				if(_local2 != null) {
					_local2.play("3hVYqbNNSUWoDGk_pK1BdQ");
				}
			} else if(e.interactsWith(this)) {
				callback();
			}
		}
		
		public function select() : void {
			isSelected = true;
			image.alpha = 1;
			rotationTween = TweenMax.to(image,0.7,{
				"rotation":3.141592653589793 * 1.5,
				"onComplete":function():void {
					if(!RymdenRunt.isBuggedFlashVersion) {
						image.filter = new GlowFilter(0xffffff,1,1,0.7);
					}
					image.scaleX = 1.3;
					image.scaleY = 1.3;
				}
			});
			bgr.filter = new GlowFilter(0xffffff,0.8,1,0.7);
		}
		
		public function deselect() : void {
			isSelected = false;
			if(!RymdenRunt.isBuggedFlashVersion) {
				bgr.filter = new GlowFilter(0xffffff,0.4,1,0.7);
			}
			image.alpha = 0.4;
			image.scaleX = 1;
			image.scaleY = 1;
			if(image.filter) {
				image.filter.dispose();
			}
			image.filter = null;
			TweenMax.to(image,1,{"rotation":0});
		}
	}
}

