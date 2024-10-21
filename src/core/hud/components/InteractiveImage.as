package core.hud.components
{
	import flash.errors.IllegalOperationError;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.events.TouchEvent;
	import starling.textures.Texture;
	
	public class InteractiveImage extends DisplayObjectContainer
	{
		protected var layer:Image;
		
		protected var source:Texture;
		
		protected var sourceHover:Texture;
		
		protected var captionText:Text;
		
		private var _captionPos:String;
		
		protected var _enabled:Boolean = true;
		
		private var alwaysShowCaption:Boolean = false;
		
		public function InteractiveImage(param1:Texture = null, param2:Texture = null, param3:String = null, param4:Boolean = false)
		{
			captionText = new Text();
			_captionPos = Position.CENTER;
			super();
			if (param1 != null)
			{
				layer = new Image(param1);
				touchable = true;
				useHandCursor = true;
				texture = param1;
				source = param1;
				sourceHover = param2;
				addChild(layer);
				this.caption = param3;
				addChild(captionText);
				this.alwaysShowCaption = param4;
				if (!param4)
				{
					hideCaption();
				}
				addListeners();
				return;
			}
			throw IllegalOperationError("You tried to create a hotkey without texture.");
		}
		
		public function set texture(param1:Texture):void
		{
			if (param1 == null)
			{
				return;
			}
			layer.texture = param1;
			source = param1;
			layer.readjustSize();
		}
		
		public function set hoverTexture(param1:Texture):void
		{
			sourceHover = param1;
		}
		
		public function set captionPosition(param1:String):void
		{
			_captionPos = param1;
			if (_captionPos == Position.LEFT)
			{
				captionText.y = 0;
				captionText.x = -captionText.width;
			}
			else if (_captionPos == Position.RIGHT)
			{
				captionText.y = 0;
				captionText.x = layer.width;
			}
			else if (_captionPos == Position.BOTTOM)
			{
				captionText.y = layer.height;
				captionText.x = 0;
			}
			else if (_captionPos == Position.INNER_RIGHT)
			{
				captionText.y = 5;
				captionText.x = layer.width - captionText.width - 5;
			}
			else if (_captionPos == Position.INNER_LEFT)
			{
				captionText.y = 5;
				captionText.x = 5;
			}
			else if (_captionPos == Position.CENTER)
			{
				captionText.y = layer.height / 2 - captionText.height / 2;
				captionText.x = layer.width / 2 - captionText.width / 2 + 0.5;
			}
		}
		
		public function showCaption():void
		{
			if (captionText.text != null || captionText.text != "")
			{
				captionText.visible = true;
			}
		}
		
		public function hideCaption():void
		{
			captionText.visible = false;
		}
		
		public function set caption(param1:String):void
		{
			captionText.text = param1;
			captionPosition = _captionPos;
		}
		
		public function get caption():String
		{
			return captionText.text;
		}
		
		public function set captionColor(param1:uint):void
		{
			captionText.color = param1;
		}
		
		public function set captionSize(param1:Number):void
		{
			captionText.size = param1;
		}
		
		public function set enabled(param1:Boolean):void
		{
			if (!_enabled && param1)
			{
				addListeners();
			}
			else if (_enabled && !param1)
			{
				removeListeners();
			}
			_enabled = param1;
		}
		
		protected function onClick(param1:TouchEvent):void
		{
		}
		
		protected function onOver(param1:TouchEvent):void
		{
			if (!alwaysShowCaption)
			{
				showCaption();
			}
			if (sourceHover != null)
			{
				layer.texture = sourceHover;
			}
		}
		
		protected function onOut(param1:TouchEvent):void
		{
			if (!alwaysShowCaption)
			{
				hideCaption();
			}
			layer.texture = source;
		}
		
		private function onTouch(param1:TouchEvent):void
		{
			if (param1.getTouch(this, "ended"))
			{
				onClick(param1);
			}
			else if (param1.interactsWith(this))
			{
				onOver(param1);
			}
			else if (!param1.interactsWith(this))
			{
				onOut(param1);
			}
		}
		
		protected function addListeners():void
		{
			addEventListener("touch", onTouch);
		}
		
		protected function removeListeners():void
		{
			removeEventListener("touch", onTouch);
		}
	}
}
