package core.hud.components {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class NativeImageButton extends Sprite {
		private var callback:Function;
		
		private var image:Sprite = new Sprite();
		
		private var hoverImage:Sprite = new Sprite();
		
		public function NativeImageButton(callback:Function, bd:BitmapData) {
			super();
			buttonMode = true;
			tabEnabled = false;
			image.addChild(new Bitmap(bd));
			hoverImage.addChild(new Bitmap(bd));
			hoverImage.blendMode = "add";
			hoverImage.visible = false;
			addChild(image);
			addChild(hoverImage);
			this.callback = callback;
			addEventListener("click",onClick);
			addEventListener("mouseOver",mouseOver);
			addEventListener("mouseOut",mouseOut);
		}
		
		protected function onClick(e:MouseEvent) : void {
			if(callback != null) {
				callback();
			}
		}
		
		protected function mouseOver(e:MouseEvent) : void {
			hoverImage.visible = true;
		}
		
		protected function mouseOut(e:MouseEvent) : void {
			hoverImage.visible = false;
		}
		
		private function removeListeners() : void {
			removeEventListener("mouseDown",onClick);
			removeEventListener("mouseOver",mouseOver);
			removeEventListener("mouseOut",mouseOut);
		}
	}
}

