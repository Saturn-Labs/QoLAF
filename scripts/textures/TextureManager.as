package textures {
	import data.DataLocator;
	import data.IDataManager;
	import debug.Console;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	import playerio.Client;
	import playerio.GameFS;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	public class TextureManager extends starling.display.Sprite implements ITextureManager {
		public static var BASIC_TEXTURE:Texture;
		
		public static var BASIC_TEXTURES:Vector.<Texture>;
		
		private static const pathToTextures:String = "/textures/";
		
		private static var xmlDict:Dictionary;
		
		private static var textureAtlasDict:Dictionary = new Dictionary();
		
		private var pLoaded:int = 0;
		
		private var itemsArray:Array = [];
		
		private var totalItems:int;
		
		private var currItem:int = 1;
		
		private var currentRequest:String = "";
		
		private var fs:GameFS;
		
		private var _client:Client;
		
		private var callbackQueue:Dictionary;
		
		private var dataManager:IDataManager;
		
		public function TextureManager(client:Client) {
			super();
			this.client = client;
			xmlDict = new Dictionary();
			callbackQueue = new Dictionary();
			itemsArray = [];
			pLoaded = 0;
			itemsArray = [];
			totalItems = 0;
			BASIC_TEXTURE = Texture.empty(1,1);
			BASIC_TEXTURES = Vector.<Texture>([BASIC_TEXTURE]);
			dataManager = DataLocator.getService();
		}
		
		public static function imageFromSprite(displayObject:DisplayObject, name:String = null) : Image {
			var _local3:Rectangle = displayObject.getBounds(displayObject);
			var _local4:Image = new Image(textureFromDisplayObject(displayObject,name));
			_local4.x = _local3.x;
			_local4.y = _local3.y;
			return _local4;
		}
		
		public static function textureFromDisplayObject(displayObject:DisplayObject, name:String = null) : Texture {
			var rect:Rectangle;
			var tempSprite:flash.display.Sprite;
			var bmd:BitmapData;
			var matrix:Matrix;
			var texture:Texture;
			if(name != null && Boolean(textureAtlasDict.hasOwnProperty(name)) && textureAtlasDict[name] != null) {
				return textureAtlasDict[name];
			}
			rect = displayObject.getBounds(displayObject);
			if(rect.width > 2048) {
				rect.width = 2048;
				Console.write("Bitmap too big, shrinking");
			}
			if(rect.height > 2048) {
				rect.height = 2048;
				Console.write("Bitmap too big, shrinking");
			}
			if(rect.width <= 2 || rect.height <= 2) {
				tempSprite = new flash.display.Sprite();
				tempSprite.graphics.beginFill(0xff0000);
				tempSprite.graphics.drawRect(0,0,50,50);
				displayObject = tempSprite;
				rect = displayObject.getBounds(displayObject);
			}
			bmd = new BitmapData(rect.width,rect.height,true,0);
			matrix = new Matrix();
			matrix.translate(-rect.x,-rect.y);
			bmd.draw(displayObject,matrix);
			texture = Texture.fromBitmapData(bmd,false);
			texture.root.onRestore = function():void {
				var _local1:BitmapData = new BitmapData(rect.width,rect.height,true,0);
				var _local2:Matrix = new Matrix();
				_local2.translate(-rect.x,-rect.y);
				_local1.draw(displayObject,_local2);
				try {
					texture.root.uploadBitmapData(_local1);
				}
				catch(e:Error) {
					trace("Texture restoration failed: " + e.message);
				}
				_local1.dispose();
				_local1 = null;
			};
			bmd.dispose();
			bmd = null;
			if(name == null) {
				return texture;
			}
			textureAtlasDict[name] = texture;
			return texture;
		}
		
		public static function getCustomTextureFromName(name:String) : Texture {
			if(textureAtlasDict.hasOwnProperty(name)) {
				return textureAtlasDict[name];
			}
			return null;
		}
		
		public function loadTextures(itemsArray:Array) : void {
			currItem = 1;
			this.itemsArray = itemsArray;
			totalItems = itemsArray.length;
			loadOne(currItem - 1,itemsArray);
		}
		
		private function loadOne(what:int, itemsArray:Array) : void {
			var _local5:Loader = null;
			var _local3:LoaderContext = null;
			var _local4:URLLoader = null;
			currentRequest = itemsArray[what].toString();
			if(currentRequest.match("png|jpg")) {
				_local5 = new Loader();
				_local5.contentLoaderInfo.addEventListener("progress",onInternalProgress);
				_local5.contentLoaderInfo.addEventListener("complete",onInternalComplete);
				_local5.contentLoaderInfo.addEventListener("ioError",onIOError);
				_local3 = new LoaderContext(true);
				_local3.imageDecodingPolicy = "onLoad";
				_local5.load(new URLRequest(fs.getUrl("/textures/" + itemsArray[what].toString(),Login.useSecure)),_local3);
			} else if(currentRequest.match("xml")) {
				_local4 = new URLLoader(new URLRequest(fs.getUrl("/textures/" + itemsArray[what].toString(),Login.useSecure)));
				_local4.addEventListener("progress",onInternalProgress);
				_local4.addEventListener("complete",onInternalComplete);
				_local4.addEventListener("ioError",onIOError);
			}
		}
		
		private function onInternalProgress(e:flash.events.Event) : void {
			var _local2:int = Math.ceil(e.target.bytesLoaded / e.target.bytesTotal * 100 * currItem / totalItems);
			if(_local2 > pLoaded) {
				pLoaded = _local2;
			}
			dispatchEvent(new starling.events.Event("preloadProgress"));
		}
		
		private function onInternalComplete(e:flash.events.Event) : void {
			var _local3:Bitmap = null;
			var _local2:Texture = null;
			if(currentRequest.match("png|jpg")) {
				currentRequest = currentRequest.replace(".png",".xml");
				currentRequest = currentRequest.replace(".jpg",".xml");
				_local3 = e.target.content as Bitmap;
				_local2 = Texture.fromBitmap(_local3,false);
				textureAtlasDict[itemsArray[currItem - 1]] = new TextureAtlas(_local2,xmlDict[currentRequest]);
			} else if(currentRequest.match("xml")) {
				xmlDict[itemsArray[currItem - 1]] = new XML(e.target.data);
			}
			if(currItem == totalItems) {
				e.target.removeEventListener("progress",onInternalProgress);
				e.target.removeEventListener("complete",onInternalComplete);
				dispatchEvent(new starling.events.Event("preloadComplete"));
			} else {
				currItem += 1;
				loadOne(currItem - 1,itemsArray);
			}
		}
		
		public function get percLoaded() : int {
			return pLoaded;
		}
		
		public function getTextureGUIByTextureName(textureName:String) : Texture {
			var _local2:Texture = getTextureByTextureName(textureName,"texture_gui1_test.png");
			if(_local2 == null) {
				_local2 = getTextureByTextureName(textureName,"texture_gui2.png");
			}
			return _local2;
		}
		
		public function getTextureGUIByKey(key:String) : Texture {
			var _local2:Texture = getTextureByKey(key,"texture_gui1_test.png");
			if(_local2 == null) {
				_local2 = getTextureByKey(key,"texture_gui2.png");
			}
			return _local2;
		}
		
		public function getTextureMainByKey(textureObjKey:String) : Texture {
			return getTextureByKey(textureObjKey,"texture_main_NEW.png");
		}
		
		public function getTexturesMainByKey(textureObjKey:String) : Vector.<Texture> {
			return getTexturesByKey(textureObjKey,"texture_main_NEW.png");
		}
		
		public function getTextureMainByTextureName(textureName:String) : Texture {
			return getTextureByTextureName(textureName,"texture_main_NEW.png");
		}
		
		public function getTexturesMainByTextureName(textureName:String) : Vector.<Texture> {
			return getTexturesByTextureName(textureName,"texture_main_NEW.png");
		}
		
		public function getTextureAtlas(atlasName:String) : TextureAtlas {
			return textureAtlasDict[atlasName];
		}
		
		public function getTexturesByKey(textureObjKey:String, atlas:String) : Vector.<Texture> {
			if(textureObjKey == null || textureObjKey.length == 0) {
				Console.write("Texture key can not be null or empty.");
				return null;
			}
			var _local3:Object = dataManager.loadKey("Images",textureObjKey);
			if(_local3 == null) {
				Console.write("Texture data is null: " + textureObjKey);
				return null;
			}
			return getTexturesByTextureName(_local3.textureName,atlas);
		}
		
		private function getTextureByKey(textureObjKey:String, atlas:String) : Texture {
			if(textureObjKey == null || textureObjKey.length == 0) {
				textureObjKey = "nFdCy6w1p06Of4v-ql53fg";
			}
			var _local3:Object = dataManager.loadKey("Images",textureObjKey);
			if(_local3 == null) {
				Console.write("Texture data is null: " + textureObjKey);
			}
			return getTextureByTextureName(_local3.textureName,atlas);
		}
		
		public function getTextureByTextureName(textureName:String, textureAtlas:String) : Texture {
			if(textureName == null || textureName.length == 0) {
				throw new Error("Texture filename can not be null or empty.");
			}
			if(textureAtlas == null || textureAtlas.length == 0) {
				throw new Error("Texture atlas can not be null or empty.");
			}
			var _local4:TextureAtlas = textureAtlasDict[textureAtlas];
			if(_local4 == null) {
				throw new Error("Texture atlas is null! key: " + textureAtlas);
			}
			textureName = textureName.replace(".png","");
			textureName = textureName.replace(".jpg","");
			var _local3:Texture = _local4.getTexture(textureName);
			if(_local3 == null) {
				_local3 = _local4.getTexture(textureName + "1");
			}
			return _local3;
		}
		
		public function getTexturesByTextureName(prefix:String, textureAtlas:String) : Vector.<Texture> {
			if(prefix == null || prefix.length == 0) {
				throw new Error("Texture filename can not be null or empty.");
			}
			if(textureAtlas == null || textureAtlas.length == 0) {
				throw new Error("Texture atlas can not be null or empty.");
			}
			var _local4:TextureAtlas = textureAtlasDict[textureAtlas];
			if(_local4 == null) {
				throw new Error("Texture atlas is null! key: " + textureAtlas);
			}
			var _local3:Vector.<Texture> = _local4.getTextures(prefix.replace(".png",""));
			if(_local3 == null) {
				throw new Error("Texture is null, can not be!!! FileName: " + prefix + " atlas: " + textureAtlas);
			}
			return _local3;
		}
		
		private function onIOError(error:IOErrorEvent) : void {
			Console.write("Error loading texture: " + error);
		}
		
		public function set client(value:Client) : void {
			_client = value;
			fs = value.gameFS;
		}
		
		public function disposeCustomTextures() : void {
			var _local1:Boolean = false;
			var _local4:TextureAtlas = null;
			var _local2:Texture = null;
			var _local3:Array = [];
			for(var _local5 in textureAtlasDict) {
				_local1 = false;
				if(_local5 == "texture_gui1_test.png" || _local5 == "texture_gui2.png" || _local5 == "texture_main_NEW.png" || _local5 == "texture_body.png") {
					_local1 = true;
				}
				if(!_local1) {
					_local3.push(_local5);
				}
			}
			for each(_local5 in _local3) {
				if(textureAtlasDict[_local5] is TextureAtlas) {
					_local4 = TextureAtlas(textureAtlasDict[_local5]);
					if(_local4 != null) {
						_local4.dispose();
						_local4 = null;
						delete xmlDict[_local5.replace("jpg","xml")];
						delete textureAtlasDict[_local5];
						continue;
					}
				}
				_local2 = Texture(textureAtlasDict[_local5]);
				if(_local2 != null) {
					_local2.dispose();
					_local2.base.dispose();
					_local2 = null;
					delete textureAtlasDict[_local5];
				}
			}
		}
	}
}

