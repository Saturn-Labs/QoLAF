package core.hud.components
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class NativeImageButton extends Sprite
	{
		private var callback:Function;
		
		private var image:Sprite;
		
		private var hoverImage:Sprite;
		
		public function NativeImageButton(param1:Function, param2:BitmapData)
		{
			image = new Sprite();
			hoverImage = new Sprite();
			super();
			buttonMode = true;
			tabEnabled = false;
			image.addChild(new Bitmap(param2));
			hoverImage.addChild(new Bitmap(param2));
			hoverImage.blendMode = "add";
			hoverImage.visible = false;
			addChild(image);
			addChild(hoverImage);
			this.callback = param1;
			addEventListener("click", onClick);
			addEventListener("mouseOver", mouseOver);
			addEventListener("mouseOut", mouseOut);
		}
		
		protected function onClick(param1:MouseEvent):void
		{
			if (callback != null)
			{
				callback();
			}
		}
		
		protected function mouseOver(param1:MouseEvent):void
		{
			hoverImage.visible = true;
		}
		
		protected function mouseOut(param1:MouseEvent):void
		{
			hoverImage.visible = false;
		}
		
		private function removeListeners():void
		{
			removeEventListener("mouseDown", onClick);
			removeEventListener("mouseOver", mouseOver);
			removeEventListener("mouseOut", mouseOut);
		}
	}
}
