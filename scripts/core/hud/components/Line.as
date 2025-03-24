package core.hud.components {
	import starling.display.Image;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class Line extends Image {
		private var overlap:Boolean;
		
		public var toX:Number;
		
		public var toY:Number;
		
		private var oldTextureName:String;
		
		public function Line(textureName:String = "line1") {
			var _local2:ITextureManager = TextureLocator.getService();
			super(_local2.getTextureMainByTextureName(textureName));
		}
		
		public function init(textureName:String = "line1", thickness:int = 1, color:uint = 16777215, alpha:Number = 1, overlap:Boolean = false) : void {
			var _local6:ITextureManager = null;
			if(oldTextureName != textureName) {
				_local6 = TextureLocator.getService();
				this.texture = _local6.getTextureMainByTextureName(textureName);
				this.readjustSize(texture.width,texture.height);
				pivotY = texture.height / 2;
			}
			oldTextureName = textureName;
			this.color = color;
			this.alpha = alpha;
			this.overlap = overlap;
			this.thickness = thickness;
			this.touchable = true;
			this.visible = true;
		}
		
		public function lineTo(toX:Number, toY:Number) : void {
			this.toX = toX;
			this.toY = toY;
			var _local3:Number = toX - x;
			var _local5:Number = toY - y;
			var _local4:Number = Math.sqrt(_local3 * _local3 + _local5 * _local5);
			if(_local4 == 0) {
				return;
			}
			this.rotation = 0;
			width = overlap ? _local4 + height : _local4;
			this.rotation = Math.atan2(_local5,_local3);
		}
		
		public function set thickness(value:Number) : void {
			var _local2:Number = this.rotation;
			this.rotation = 0;
			height = value;
			this.rotation = _local2;
		}
		
		override public function dispose() : void {
			super.dispose();
		}
	}
}

