package core
{
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
	
	public class GameObject
	{
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
		
		public function GameObject()
		{
			super();
			_pos = new Point();
		}
		
		public function get radius():Number
		{
			return _mc.width * 0.5;
		}
		
		public function set alpha(param1:Number):void
		{
			_mc.alpha = param1;
		}
		
		public function get alpha():Number
		{
			return _mc.alpha;
		}
		
		public function set color(param1:uint):void
		{
			_mc.color = param1;
		}
		
		public function get color():uint
		{
			return _mc.color;
		}
		
		public function set x(param1:Number):void
		{
			_pos.x = param1;
		}
		
		public function set y(param1:Number):void
		{
			_pos.y = param1;
		}
		
		public function get x():Number
		{
			return _pos.x;
		}
		
		public function get y():Number
		{
			return _pos.y;
		}
		
		public function get pivotX():Number
		{
			return _mc.pivotX;
		}
		
		public function get pivotY():Number
		{
			return _mc.pivotY;
		}
		
		public function get scaleX():Number
		{
			return _mc.scaleX;
		}
		
		public function get scaleY():Number
		{
			return _mc.scaleY;
		}
		
		public function set scaleX(param1:Number):void
		{
			_mc.scaleX = param1;
		}
		
		public function set scaleY(param1:Number):void
		{
			_mc.scaleY = param1;
		}
		
		public function set blendMode(param1:String):void
		{
			_mc.blendMode = param1;
		}
		
		public function get texture():Texture
		{
			return _mc.texture;
		}
		
		public function set visible(param1:Boolean):void
		{
			_mc.visible = param1;
		}
		
		public function get visible():Boolean
		{
			return _mc.visible;
		}
		
		public function switchTexturesByObj(param1:Object, param2:String = "texture_main_NEW.png"):void
		{
			var _loc3_:ITextureManager = TextureLocator.getService();
			var _loc6_:IDataManager = DataLocator.getService();
			imgObj = _loc6_.loadKey("Images", param1.bitmap);
			var _loc5_:int = 12;
			var _loc4_:Boolean = false;
			if (imgObj == null)
			{
				_textures = TextureManager.BASIC_TEXTURES;
				Console.write("No texture, objName: " + param1.name + " bitmap: " + param1.bitmap);
			}
			else
			{
				if (imgObj.animate)
				{
					_loc5_ = int(imgObj.animationDelay == 0 ? 33 : 33 / imgObj.animationDelay);
				}
				if (oldImageObjKey != param1.bitmap)
				{
					_textures = _loc3_.getTexturesByKey(param1.bitmap, param2);
				}
			}
			if (_textures.length == 0)
			{
				Console.write("No texture, objName: " + param1.name + " bitmap: " + param1.bitmap);
				return;
			}
			if (_mc == null)
			{
				_mc = new MovieClip(_textures, _loc5_);
				_mc.touchable = false;
			}
			else if (oldImageObjKey != param1.bitmap)
			{
				swapFrames(_mc, _textures);
				_mc.fps = _loc5_;
				_mc.readjustSize();
			}
			oldImageObjKey = param1.bitmap;
			if (imgObj != null && imgObj.scale != null)
			{
				scaleX = scaleY = imgObj.scale;
			}
			if (imgObj != null && imgObj.animate && imgObj.animateOnStart)
			{
				Starling.juggler.add(_mc);
				_mc.play();
			}
			_mc.pivotX = Math.round(_mc.width / 2 / scaleX);
			_mc.pivotY = Math.round(_mc.height / 2 / scaleY);
			if (imgObj != null && Boolean(imgObj.hasOwnProperty("mirror")) && imgObj.mirror)
			{
				scaleY = -scaleY;
			}
		}
		
		public function swapFrames(param1:MovieClip, param2:Vector.<Texture>):void
		{
			while (param1.numFrames > 1)
			{
				param1.removeFrameAt(0);
			}
			for each (var _loc3_:* in param2)
			{
				param1.addFrame(_loc3_);
			}
			param1.removeFrameAt(0);
			param1.currentFrame = 0;
		}
		
		public function update():void
		{
			if (forcedRotation)
			{
				forcedRotationAngle += forcedRotationSpeed;
				_rotation = forcedRotationAngle;
			}
		}
		
		public function draw():void
		{
			if (imgObj == null)
			{
				return;
			}
			_mc.x = x;
			_mc.y = y;
			if (forcedRotation)
			{
				_mc.rotation = _rotation;
			}
			else
			{
				_mc.rotation = rotation;
			}
		}
		
		public function set pos(param1:Point):void
		{
			_pos = param1;
		}
		
		public function get pos():Point
		{
			return _pos;
		}
		
		public function set rotation(param1:Number):void
		{
			_rotation = param1;
		}
		
		public function get rotation():Number
		{
			return _rotation;
		}
		
		public function set name(param1:String):void
		{
			_name = param1;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function reset():void
		{
			_pos.x = 0;
			_pos.y = 0;
			_rotation = 0;
			if (_mc != null)
			{
				_mc.x = 0;
				_mc.y = 0;
				_mc.rotation = 0;
				_mc.scaleX = 1;
				_mc.scaleY = 1;
				if (_mc.filter)
				{
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
		
		public function addToCanvas():void
		{
			isAddedToCanvas = true;
			if (imgObj == null)
			{
				return;
			}
			canvas.addChild(_mc);
		}
		
		public function removeFromCanvas():void
		{
			isAddedToCanvas = false;
			if (imgObj == null)
			{
				return;
			}
			canvas.removeChild(_mc);
		}
		
		public function get hasImage():Boolean
		{
			if (imgObj == null)
			{
				return false;
			}
			return true;
		}
		
		public function get movieClip():MovieClip
		{
			return _mc;
		}
		
		public function get id():int
		{
			return _id;
		}
		
		public function set id(param1:int):void
		{
			_id = param1;
		}
		
		public function getGlobalPos(param1:Point = null):Point
		{
			if (param1 == null)
			{
				param1 = new Point();
			}
			param1.x += pivotX;
			param1.y += pivotY;
			_mc.localToGlobal(param1, param1);
			return param1;
		}
	}
}
