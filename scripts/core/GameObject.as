package core {
	import data.DataLocator;
	import data.IDataManager;
	import debug.Console;
	import flash.geom.Point;
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	import textures.TextureManager;
	
	public class GameObject {
		protected var _mc:MovieClip;
		
		protected var _name:String;
		
		protected var _pos:Point;
		
		protected var _rotation:Number = 0;
		
		public var canvas:Sprite;
		
		public var forcedRotation:Boolean;
		
		public var forcedRotationSpeed:Number;
		
		public var forcedRotationAim:Boolean;
		
		public var forcedRotationAngle:Number = 0;
		
		public var distanceToCamera:int = 0;
		
		public var distanceToCameraX:int = 0;
		
		public var distanceToCameraY:int = 0;
		
		public var nextDistanceCalculation:int = -1;
		
		public var isAddedToCanvas:Boolean = false;
		
		private var oldImageObjKey:String = "";
		
		protected var _textures:Vector.<Texture>;
		
		public var layer:int;
		
		private var _id:int;
		
		protected var imgObj:Object;
		
		public var textureWidth:int = 0;
		
		public function GameObject() {
			super();
			_pos = new Point();
		}
		
		public function get radius() : Number {
			return _mc.width * 0.5;
		}
		
		public function set alpha(value:Number) : void {
			_mc.alpha = value;
		}
		
		public function get alpha() : Number {
			return _mc.alpha;
		}
		
		public function set color(value:uint) : void {
			_mc.color = value;
		}
		
		public function get color() : uint {
			return _mc.color;
		}
		
		public function set x(value:Number) : void {
			_pos.x = value;
		}
		
		public function set y(value:Number) : void {
			_pos.y = value;
		}
		
		public function get x() : Number {
			return _pos.x;
		}
		
		public function get y() : Number {
			return _pos.y;
		}
		
		public function get pivotX() : Number {
			return _mc.pivotX;
		}
		
		public function get pivotY() : Number {
			return _mc.pivotY;
		}
		
		public function get scaleX() : Number {
			return _mc.scaleX;
		}
		
		public function get scaleY() : Number {
			return _mc.scaleY;
		}
		
		public function set scaleX(value:Number) : void {
			_mc.scaleX = value;
		}
		
		public function set scaleY(value:Number) : void {
			_mc.scaleY = value;
		}
		
		public function set blendMode(value:String) : void {
			_mc.blendMode = value;
		}
		
		public function get texture() : Texture {
			return _mc.texture;
		}
		
		public function set visible(value:Boolean) : void {
			_mc.visible = value;
		}
		
		public function get visible() : Boolean {
			return _mc.visible;
		}
		
		public function switchTexturesByObj(obj:Object, textureAtlas:String = "texture_main_NEW.png") : void {
			var _local4:ITextureManager = TextureLocator.getService();
			var _local6:IDataManager = DataLocator.getService();
			imgObj = _local6.loadKey("Images",obj.bitmap);
			var _local3:int = 12;
			var _local5:Boolean = false;
			if(imgObj == null) {
				_textures = TextureManager.BASIC_TEXTURES;
				Console.write("No texture, objName: " + obj.name + " bitmap: " + obj.bitmap);
			} else {
				if(imgObj.animate) {
					_local3 = int(imgObj.animationDelay == 0 ? 33 : 33 / imgObj.animationDelay);
				}
				if(oldImageObjKey != obj.bitmap) {
					_textures = _local4.getTexturesByKey(obj.bitmap,textureAtlas);
				}
			}
			if(_textures.length == 0) {
				Console.write("No texture, objName: " + obj.name + " bitmap: " + obj.bitmap);
				return;
			}
			if(_mc == null) {
				_mc = new MovieClip(_textures,_local3);
				_mc.touchable = false;
			} else if(oldImageObjKey != obj.bitmap) {
				swapFrames(_mc,_textures);
				_mc.fps = _local3;
				_mc.readjustSize();
			}
			oldImageObjKey = obj.bitmap;
			if(imgObj != null && imgObj.scale != null) {
				scaleX = scaleY = imgObj.scale;
			}
			if(imgObj != null && imgObj.animate && imgObj.animateOnStart) {
				Starling.juggler.add(_mc);
				_mc.play();
			}
			_mc.pivotX = Math.round(_mc.width / 2 / scaleX);
			_mc.pivotY = Math.round(_mc.height / 2 / scaleY);
			if(imgObj != null && Boolean(imgObj.hasOwnProperty("mirror")) && imgObj.mirror) {
				scaleY = -scaleY;
			}
		}
		
		public function swapFrames(clip:MovieClip, textures:Vector.<Texture>) : void {
			while(clip.numFrames > 1) {
				clip.removeFrameAt(0);
			}
			for each(var _local3 in textures) {
				clip.addFrame(_local3);
			}
			clip.removeFrameAt(0);
			clip.currentFrame = 0;
		}
		
		public function update() : void {
			if(forcedRotation) {
				forcedRotationAngle += forcedRotationSpeed;
				_rotation = forcedRotationAngle;
			}
		}
		
		public function draw() : void {
			if(imgObj == null) {
				return;
			}
			_mc.x = x;
			_mc.y = y;
			if(forcedRotation) {
				_mc.rotation = _rotation;
			} else {
				_mc.rotation = rotation;
			}
		}
		
		public function set pos(value:Point) : void {
			_pos = value;
		}
		
		public function get pos() : Point {
			return _pos;
		}
		
		public function set rotation(value:Number) : void {
			_rotation = value;
		}
		
		public function get rotation() : Number {
			return _rotation;
		}
		
		public function set name(value:String) : void {
			_name = value;
		}
		
		public function get name() : String {
			return _name;
		}
		
		public function reset() : void {
			_pos.x = 0;
			_pos.y = 0;
			_rotation = 0;
			if(_mc != null) {
				_mc.x = 0;
				_mc.y = 0;
				_mc.rotation = 0;
				_mc.scaleX = 1;
				_mc.scaleY = 1;
				if(_mc.filter) {
					_mc.filter.dispose();
					_mc.filter = null;
				}
				_mc.blendMode = "normal";
				_mc.stop();
				Starling.juggler.remove(_mc);
				_mc.alpha = 1;
				_mc.visible = true;
			}
			_id = 0;
			layer = 0;
			forcedRotation = false;
			forcedRotationSpeed = 0;
			forcedRotationAim = false;
			forcedRotationAngle = 0;
			imgObj = null;
			distanceToCamera = 0;
			distanceToCameraX = 0;
			distanceToCameraY = 0;
			nextDistanceCalculation = -1;
			isAddedToCanvas = false;
		}
		
		public function addToCanvas() : void {
			isAddedToCanvas = true;
			if(imgObj == null) {
				return;
			}
			canvas.addChild(_mc);
		}
		
		public function removeFromCanvas() : void {
			isAddedToCanvas = false;
			if(imgObj == null) {
				return;
			}
			canvas.removeChild(_mc);
		}
		
		public function get hasImage() : Boolean {
			if(imgObj == null) {
				return false;
			}
			return true;
		}
		
		public function get movieClip() : MovieClip {
			return _mc;
		}
		
		public function get id() : int {
			return _id;
		}
		
		public function set id(value:int) : void {
			_id = value;
		}
		
		public function getGlobalPos(resultPoint:Point = null) : Point {
			if(resultPoint == null) {
				resultPoint = new Point();
			}
			resultPoint.x += pivotX;
			resultPoint.y += pivotY;
			_mc.localToGlobal(resultPoint,resultPoint);
			return resultPoint;
		}
	}
}

