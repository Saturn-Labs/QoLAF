package textures
{
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

   public class TextureManager extends starling.display.Sprite implements ITextureManager
   {
      public static var BASIC_TEXTURE:Texture;

      public static var BASIC_TEXTURES:Vector.<Texture>;

      private static const pathToTextures:String = "/textures/";

      private static var xmlDict:Dictionary;

      private static var textureAtlasDict:Dictionary = new Dictionary();

      private var pLoaded:int = 0;

      private var itemsArray:Array;

      private var totalItems:int;

      private var currItem:int = 1;

      private var currentRequest:String = "";

      private var fs:GameFS;

      private var _client:Client;

      private var callbackQueue:Dictionary;

      private var dataManager:IDataManager;

      public function TextureManager(param1:Client)
      {
         itemsArray = [];
         super();
         this.client = param1;
         xmlDict = new Dictionary();
         callbackQueue = new Dictionary();
         itemsArray = [];
         pLoaded = 0;
         itemsArray = [];
         totalItems = 0;
         BASIC_TEXTURE = Texture.empty(1, 1);
         BASIC_TEXTURES = Vector.<Texture>([BASIC_TEXTURE]);
         dataManager = DataLocator.getService();
      }

      public static function imageFromSprite(param1:DisplayObject, param2:String = null):Image
      {
         var _loc4_:Rectangle = param1.getBounds(param1);
         var _loc3_:Image = new Image(textureFromDisplayObject(param1, param2));
         _loc3_.x = _loc4_.x;
         _loc3_.y = _loc4_.y;
         return _loc3_;
      }

      public static function textureFromDisplayObject(param1:DisplayObject, param2:String = null):Texture
      {
         var rect:Rectangle;
         var tempSprite:flash.display.Sprite;
         var bmd:BitmapData;
         var matrix:Matrix;
         var texture:Texture;
         var displayObject:DisplayObject = param1;
         var name:String = param2;
         if (name != null && Boolean(textureAtlasDict.hasOwnProperty(name)) && textureAtlasDict[name] != null)
         {
            return textureAtlasDict[name];
         }
         rect = displayObject.getBounds(displayObject);
         if (rect.width > 2048)
         {
            rect.width = 2048;
            Console.write("Bitmap too big, shrinking");
         }
         if (rect.height > 2048)
         {
            rect.height = 2048;
            Console.write("Bitmap too big, shrinking");
         }
         if (rect.width <= 2 || rect.height <= 2)
         {
            tempSprite = new flash.display.Sprite();
            tempSprite.graphics.beginFill(16711680);
            tempSprite.graphics.drawRect(0, 0, 50, 50);
            displayObject = tempSprite;
            rect = displayObject.getBounds(displayObject);
         }
         bmd = new BitmapData(rect.width, rect.height, true, 0);
         matrix = new Matrix();
         matrix.translate(-rect.x, -rect.y);
         bmd.draw(displayObject, matrix);
         texture = Texture.fromBitmapData(bmd, false);
         texture.root.onRestore = function():void
         {
            var _loc1_:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
            var _loc2_:Matrix = new Matrix();
            _loc2_.translate(-rect.x, -rect.y);
            _loc1_.draw(displayObject, _loc2_);
            try
            {
               texture.root.uploadBitmapData(_loc1_);
            }
            catch (e:Error)
            {
               trace("Texture restoration failed: " + e.message);
            }
            _loc1_.dispose();
            _loc1_ = null;
         };
         bmd.dispose();
         bmd = null;
         if (name == null)
         {
            return texture;
         }
         textureAtlasDict[name] = texture;
         return texture;
      }

      public static function getCustomTextureFromName(param1:String):Texture
      {
         if (textureAtlasDict.hasOwnProperty(param1))
         {
            return textureAtlasDict[param1];
         }
         return null;
      }

      public function loadTextures(param1:Array):void
      {
         currItem = 1;
         this.itemsArray = param1;
         totalItems = param1.length;
         loadOne(currItem - 1, param1);
      }

      private function loadOne(param1:int, param2:Array):void
      {
         var _loc5_:Loader = null;
         var _loc3_:LoaderContext = null;
         var _loc4_:URLLoader = null;
         currentRequest = param2[param1].toString();
		 trace(fs.getUrl("/textures/" + param2[param1].toString(), Login.useSecure));
         if (currentRequest.match("png|jpg"))
         {
            _loc5_ = new Loader();
            _loc5_.contentLoaderInfo.addEventListener("progress", onInternalProgress);
            _loc5_.contentLoaderInfo.addEventListener("complete", onInternalComplete);
            _loc5_.contentLoaderInfo.addEventListener("ioError", onIOError);
            _loc3_ = new LoaderContext(true);
            _loc3_.imageDecodingPolicy = "onLoad";
            _loc5_.load(new URLRequest(fs.getUrl("/textures/" + param2[param1].toString(), Login.useSecure)), _loc3_);
         }
         else if (currentRequest.match("xml"))
         {
            _loc4_ = new URLLoader(new URLRequest(fs.getUrl("/textures/" + param2[param1].toString(), Login.useSecure)));
            _loc4_.addEventListener("progress", onInternalProgress);
            _loc4_.addEventListener("complete", onInternalComplete);
            _loc4_.addEventListener("ioError", onIOError);
         }
      }

      private function onInternalProgress(param1:flash.events.Event):void
      {
         var _loc2_:int = Math.ceil(param1.target.bytesLoaded / param1.target.bytesTotal * 100 * currItem / totalItems);
         if (_loc2_ > pLoaded)
         {
            pLoaded = _loc2_;
         }
         dispatchEvent(new starling.events.Event("preloadProgress"));
      }

      private function onInternalComplete(param1:flash.events.Event):void
      {
         var _loc3_:Bitmap = null;
         var _loc2_:Texture = null;
         if (currentRequest.match("png|jpg"))
         {
            currentRequest = currentRequest.replace(".png", ".xml");
            currentRequest = currentRequest.replace(".jpg", ".xml");
            _loc3_ = param1.target.content as Bitmap;
            _loc2_ = Texture.fromBitmap(_loc3_, false);
            textureAtlasDict[itemsArray[currItem - 1]] = new TextureAtlas(_loc2_, xmlDict[currentRequest]);
         }
         else if (currentRequest.match("xml"))
         {
            xmlDict[itemsArray[currItem - 1]] = new XML(param1.target.data);
         }
         if (currItem == totalItems)
         {
            param1.target.removeEventListener("progress", onInternalProgress);
            param1.target.removeEventListener("complete", onInternalComplete);
            dispatchEvent(new starling.events.Event("preloadComplete"));
         }
         else
         {
            currItem += 1;
            loadOne(currItem - 1, itemsArray);
         }
      }

      public function get percLoaded():int
      {
         return pLoaded;
      }

      public function getTextureGUIByTextureName(param1:String):Texture
      {
         var _loc2_:Texture = getTextureByTextureName(param1, "texture_gui1_test.png");
         if (_loc2_ == null)
         {
            _loc2_ = getTextureByTextureName(param1, "texture_gui2.png");
         }
         return _loc2_;
      }

      public function getTextureGUIByKey(param1:String):Texture
      {
         var _loc2_:Texture = getTextureByKey(param1, "texture_gui1_test.png");
         if (_loc2_ == null)
         {
            _loc2_ = getTextureByKey(param1, "texture_gui2.png");
         }
         return _loc2_;
      }

      public function getTextureMainByKey(param1:String):Texture
      {
         return getTextureByKey(param1, "texture_main_NEW.png");
      }

      public function getTexturesMainByKey(param1:String):Vector.<Texture>
      {
         return getTexturesByKey(param1, "texture_main_NEW.png");
      }

      public function getTextureMainByTextureName(param1:String):Texture
      {
         return getTextureByTextureName(param1, "texture_main_NEW.png");
      }

      public function getTexturesMainByTextureName(param1:String):Vector.<Texture>
      {
         return getTexturesByTextureName(param1, "texture_main_NEW.png");
      }

      public function getTextureAtlas(param1:String):TextureAtlas
      {
         return textureAtlasDict[param1];
      }

      public function getTexturesByKey(param1:String, param2:String):Vector.<Texture>
      {
         if (param1 == null || param1.length == 0)
         {
            Console.write("Texture key can not be null or empty.");
            return null;
         }
         var _loc3_:Object = dataManager.loadKey("Images", param1);
         if (_loc3_ == null)
         {
            Console.write("Texture data is null: " + param1);
            return null;
         }
         return getTexturesByTextureName(_loc3_.textureName, param2);
      }

      private function getTextureByKey(param1:String, param2:String):Texture
      {
         if (param1 == null || param1.length == 0)
         {
            param1 = "nFdCy6w1p06Of4v-ql53fg";
         }
         var _loc3_:Object = dataManager.loadKey("Images", param1);
         if (_loc3_ == null)
         {
            Console.write("Texture data is null: " + param1);
         }
         return getTextureByTextureName(_loc3_.textureName, param2);
      }

      public function getTextureByTextureName(param1:String, param2:String):Texture
      {
         if (param1 == null || param1.length == 0)
         {
            throw new Error("Texture filename can not be null or empty.");
         }
         if (param2 == null || param2.length == 0)
         {
            throw new Error("Texture atlas can not be null or empty.");
         }
         var _loc4_:TextureAtlas = textureAtlasDict[param2];
         if (_loc4_ == null)
         {
            throw new Error("Texture atlas is null! key: " + param2);
         }
         param1 = param1.replace(".png", "");
         param1 = param1.replace(".jpg", "");
         var _loc3_:Texture = _loc4_.getTexture(param1);
         if (_loc3_ == null)
         {
            _loc3_ = _loc4_.getTexture(param1 + "1");
         }
         return _loc3_;
      }

      public function getTexturesByTextureName(param1:String, param2:String):Vector.<Texture>
      {
         if (param1 == null || param1.length == 0)
         {
            throw new Error("Texture filename can not be null or empty.");
         }
         if (param2 == null || param2.length == 0)
         {
            throw new Error("Texture atlas can not be null or empty.");
         }
         var _loc4_:TextureAtlas = textureAtlasDict[param2];
         if (_loc4_ == null)
         {
            throw new Error("Texture atlas is null! key: " + param2);
         }
         var _loc3_:Vector.<Texture> = _loc4_.getTextures(param1.replace(".png", ""));
         if (_loc3_ == null)
         {
            throw new Error("Texture is null, can not be!!! FileName: " + param1 + " atlas: " + param2);
         }
         return _loc3_;
      }

      private function onIOError(param1:IOErrorEvent):void
      {
         Console.write("Error loading texture: " + param1);
      }

      public function set client(param1:Client):void
      {
         _client = param1;
         fs = param1.gameFS;
      }

      public function disposeCustomTextures():void
      {
         var _loc4_:Boolean = false;
         var _loc3_:TextureAtlas = null;
         var _loc1_:Texture = null;
         var _loc2_:Array = [];
         for (var _loc5_:* in textureAtlasDict)
         {
            _loc4_ = false;
            if (_loc5_ == "texture_gui1_test.png" || _loc5_ == "texture_gui2.png" || _loc5_ == "texture_main_NEW.png" || _loc5_ == "texture_body.png")
            {
               _loc4_ = true;
            }
            if (!_loc4_)
            {
               _loc2_.push(_loc5_);
            }
         }
         for each (_loc5_ in _loc2_)
         {
            if (textureAtlasDict[_loc5_] is TextureAtlas)
            {
               _loc3_ = TextureAtlas(textureAtlasDict[_loc5_]);
               if (_loc3_ != null)
               {
                  _loc3_.dispose();
                  _loc3_ = null;
                  delete xmlDict[_loc5_.replace("jpg", "xml")];
                  delete textureAtlasDict[_loc5_];
                  continue;
               }
            }
            _loc1_ = Texture(textureAtlasDict[_loc5_]);
            if (_loc1_ != null)
            {
               _loc1_.dispose();
               _loc1_.base.dispose();
               _loc1_ = null;
               delete textureAtlasDict[_loc5_];
            }
         }
      }
   }
}
