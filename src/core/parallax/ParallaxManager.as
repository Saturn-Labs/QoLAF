package core.parallax
{
   import com.greensock.TweenMax;
   import core.scene.SceneBase;
   import data.DataLocator;
   import debug.Console;
   import generics.Random;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.display.Image;
   import starling.display.MeshBatch;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   import textures.ITextureManager;
   import textures.TextureLocator;

   public class ParallaxManager
   {
      private static const SIZE:Number = 1.8;

      private static const MINI_STARS:int = 70;

      private static const STARS:int = 40;

      private static const MINI_DUSTS:int = 25;

      private static const NEBULAS:int = 8;

      private var g:SceneBase;

      public var stars:Vector.<Quad>;

      public var miniStars:Vector.<Quad>;

      public var miniDusts:Vector.<Quad>;

      public var nebulas:Vector.<Quad>;

      private var nebulaType:String = "";

      private var width:Number;

      private var height:Number;

      private var halfWidth:Number;

      private var halfHeight:Number;

      private var isIntro:Boolean;

      private var random:Random;

      private var target:DisplayObjectContainer;

      private var starBatch:MeshBatch;

      private var nebulaContainer:Sprite;

      private var starTxt:Texture;

      private var nebulaTxt:Texture;

      private var initialized:Boolean = false;

      public var cx:Number = -3;

      public var cy:Number = -2;

      private var nebulaUpdateCount:int;

      private var NEBULA_UPDATE_INTERVAL:int = 200;

      public var visible:Boolean = true;

      private var lastAdjustment:Number = 0;

      public function ParallaxManager(param1:SceneBase, param2:DisplayObjectContainer, param3:Boolean = false)
      {
         stars = new Vector.<Quad>();
         miniStars = new Vector.<Quad>();
         miniDusts = new Vector.<Quad>();
         nebulas = new Vector.<Quad>();
         starBatch = new MeshBatch();
         nebulaContainer = new Sprite();
         super();
         this.g = param1;
         this.target = param2;
         this.isIntro = param3;
         nebulaContainer.blendMode = "none";
         if (!param1)
         {
            return;
         }
         param1.addResizeListener(resize);
      }

      public function load(param1:Object, param2:Function):void
      {
         var solarSystemObj:Object = param1;
         var callback:Function = param2;
         var textureManager:ITextureManager = TextureLocator.getService();
         loadData(solarSystemObj, function(param1:Event):void
            {
               starTxt = textureManager.getTextureMainByTextureName("star.png");
               var _loc2_:Object = DataLocator.getService().loadKey("Images", solarSystemObj.background);
               nebulaType = _loc2_.textureName;
               random = new Random(solarSystemObj.x * solarSystemObj.y + solarSystemObj.x + solarSystemObj.y);
               nebulaTxt = textureManager.getTextureByTextureName(_loc2_.textureName, _loc2_.fileName);
               resize();
               if (callback != null)
               {
                  callback();
               }
            });
      }

      private function loadData(param1:Object, param2:Function):void
      {
         var _loc4_:Object = DataLocator.getService().loadKey("Images", param1.background);
         var _loc5_:String = _loc4_.textureName;
         var _loc3_:ITextureManager = TextureLocator.getService();
         _loc3_.loadTextures([_loc5_ + ".xml", _loc5_ + ".jpg"]);
         _loc3_.addEventListener("preloadComplete", createLoadComplete(param2));
      }

      private function createLoadComplete(param1:Function):Function
      {
         var callback:Function = param1;
         return (function():*
            {
               var lc:Function;
               return lc = function(param1:Event):void
               {
                  callback(param1);
                  TextureLocator.getService().removeEventListener("preloadComplete", lc);
               };
            })();
      }

      public function refresh():void
      {
         var _loc3_:int = 0;
         var _loc1_:Image = null;
         var _loc2_:Image = null;
         if (initialized)
         {
            clear();
         }
         if (g)
         {
            visible = SceneBase.settings.showBackground;
         }
         if (!nebulaTxt || !starTxt)
         {
            Console.write("Parallaxmanager not loaded yet, refreshing");
            TweenMax.delayedCall(0.3, refresh);
            return;
         }
         if (visible)
         {
            _loc3_ = 0;
            while (_loc3_ < 8)
            {
               _loc1_ = new Image(nebulaTxt);
               _loc1_.blendMode = "add";
               _loc1_.pivotX = _loc1_.width / 2;
               _loc1_.pivotY = _loc1_.height / 2;
               nebulas.push(_loc1_);
               if (isIntro)
               {
                  _loc1_.alpha = 0;
               }
               nebulaContainer.addChild(_loc1_);
               _loc3_++;
            }
            nebulaUpdateCount = NEBULA_UPDATE_INTERVAL;
         }
         else
         {
            nebulaContainer.removeChildren(0, -1);
         }
         _loc3_ = 0;
         while (_loc3_ < 40)
         {
            _loc2_ = new Image(starTxt);
            stars.push(_loc2_);
            _loc3_++;
         }
         _loc3_ = 0;
         while (_loc3_ < 70)
         {
            _loc2_ = new Image(starTxt);
            miniStars.push(_loc2_);
            _loc3_++;
         }
         _loc3_ = 0;
         while (_loc3_ < 25)
         {
            _loc2_ = new Image(starTxt);
            miniDusts.push(_loc2_);
            _loc3_++;
         }
         target.addChild(nebulaContainer);
         target.addChild(starBatch);
         initialized = true;
         resize();
      }

      private function clear():void
      {
         if (!initialized)
         {
            return;
         }
         target.removeChildren(0, -1, true);
         nebulas.length = 0;
         stars.length = 0;
         miniStars.length = 0;
         miniDusts.length = 0;
      }

      public function randomize():void
      {
         var _loc1_:Quad = null;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while (_loc2_ < nebulas.length)
         {
            _loc1_ = nebulas[_loc2_];
            if (_loc2_ == 0)
            {
               _loc1_.x = 0;
               _loc1_.y = 0;
            }
            else
            {
               _loc1_.x = -1500 + 3000 * random.randomNumber();
               _loc1_.y = -1500 + 3000 * random.randomNumber();
            }
            if (isIntro)
            {
               _loc1_.x += 1024;
               _loc1_.y += 1024;
            }
            _loc1_.rotation = 3.141592653589793 * 2 * random.randomNumber();
            _loc2_++;
         }
         nebulaUpdateCount = NEBULA_UPDATE_INTERVAL;
         _loc2_ = 0;
         while (_loc2_ < miniStars.length)
         {
            _loc1_ = miniStars[_loc2_];
            if (isIntro)
            {
               _loc1_.x = width * Math.random();
               _loc1_.y = height * Math.random();
            }
            else
            {
               _loc1_.x = -halfWidth + width * Math.random();
               _loc1_.y = -halfHeight + height * Math.random();
            }
            _loc2_++;
         }
         _loc2_ = 0;
         while (_loc2_ < stars.length)
         {
            _loc1_ = stars[_loc2_];
            if (isIntro)
            {
               _loc1_.x = width * Math.random();
               _loc1_.y = height * Math.random();
            }
            else
            {
               _loc1_.x = -halfWidth + width * Math.random();
               _loc1_.y = -halfHeight + height * Math.random();
            }
            _loc2_++;
         }
         _loc2_ = 0;
         while (_loc2_ < miniDusts.length)
         {
            _loc1_ = miniDusts[_loc2_];
            if (isIntro)
            {
               _loc1_.x = width * Math.random() * 2;
               _loc1_.y = height * Math.random() * 2;
            }
            else
            {
               _loc1_.x = -halfWidth + width * Math.random();
               _loc1_.y = -halfHeight + height * Math.random();
            }
            _loc2_++;
         }
      }

      public function update():void
      {
         var _loc11_:int = 0;
         var _loc9_:int = 0;
         var _loc8_:Quad = null;
         if (g != null)
         {
            cx = g.camera.speed.x;
            cy = g.camera.speed.y;
         }
         var _loc5_:Number = cx / 7;
         var _loc10_:Number = cy / 7;
         var _loc7_:Number = cx / 6;
         var _loc6_:Number = cy / 6;
         var _loc4_:Number = cx / 4;
         var _loc2_:Number = cy / 4;
         var _loc3_:Number = cx / 1.8;
         var _loc1_:Number = cy / 1.8;
         if (visible)
         {
            nebulaUpdateCount++;
            if (nebulaUpdateCount > NEBULA_UPDATE_INTERVAL)
            {
               nebulaUpdateCount = 0;
               _loc9_ = int(nebulas.length);
               _loc11_ = 0;
               while (_loc11_ < _loc9_)
               {
                  _loc8_ = nebulas[_loc11_];
                  _loc8_.x = _loc8_.x - _loc5_ * (_loc11_ / _loc9_);
                  _loc8_.y -= _loc10_ * (_loc11_ / _loc9_);
                  _loc11_++;
               }
            }
         }
         starBatch.clear();
         _loc9_ = int(stars.length);
         _loc11_ = 0;
         while (_loc11_ < _loc9_)
         {
            _loc8_ = stars[_loc11_];
            _loc8_.x = _loc8_.x - _loc4_;
            _loc8_.y -= _loc2_;
            starBatch.addMesh(_loc8_);
            _loc11_++;
         }
         _loc9_ = int(miniStars.length);
         _loc11_ = 0;
         while (_loc11_ < _loc9_)
         {
            _loc8_ = miniStars[_loc11_];
            _loc8_.x = _loc8_.x - _loc7_;
            _loc8_.y -= _loc6_;
            starBatch.addMesh(_loc8_);
            _loc11_++;
         }
         _loc9_ = int(miniDusts.length);
         _loc11_ = 0;
         while (_loc11_ < _loc9_)
         {
            _loc8_ = miniDusts[_loc11_];
            _loc8_.x = _loc8_.x - _loc3_;
            _loc8_.y -= _loc1_;
            starBatch.addMesh(_loc8_);
            _loc11_++;
         }
      }

      public function draw():void
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         var _loc1_:Number = NaN;
         if (g)
         {
            _loc1_ = g.time - lastAdjustment;
            if (_loc1_ < 1000)
            {
               return;
            }
            lastAdjustment = g.time;
         }
         _loc2_ = int(stars.length);
         _loc3_ = 0;
         while (_loc3_ < _loc2_)
         {
            adjustPosition(stars[_loc3_]);
            _loc3_++;
         }
         _loc2_ = int(miniStars.length);
         _loc3_ = 0;
         while (_loc3_ < _loc2_)
         {
            adjustPosition(miniStars[_loc3_]);
            _loc3_++;
         }
         _loc2_ = int(miniDusts.length);
         _loc3_ = 0;
         while (_loc3_ < _loc2_)
         {
            adjustPosition(miniDusts[_loc3_]);
            _loc3_++;
         }
      }

      private function adjustPosition(param1:DisplayObject):void
      {
         var _loc2_:Number = param1.x;
         var _loc3_:Number = param1.y;
         if (isIntro)
         {
            if (_loc2_ > halfWidth * 2)
            {
               param1.x = _loc2_ - width;
            }
            else if (_loc2_ < -halfWidth * 2)
            {
               param1.x = _loc2_ + width;
            }
            if (_loc3_ > halfHeight * 2)
            {
               param1.y = _loc3_ - height;
            }
            else if (_loc3_ < -halfHeight * 2)
            {
               param1.y = _loc3_ + height;
            }
            return;
         }
         if (_loc2_ > halfWidth)
         {
            param1.x = _loc2_ - width;
         }
         else if (_loc2_ < -halfWidth)
         {
            param1.x = _loc2_ + width;
         }
         if (_loc3_ > halfHeight)
         {
            param1.y = _loc3_ - height;
         }
         else if (_loc3_ < -halfHeight)
         {
            param1.y = _loc3_ + height;
         }
      }

      public function glow():void
      {
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         _loc1_ = int(nebulas.length);
         _loc2_ = 0;
         while (_loc2_ < _loc1_)
         {
            nebulas[_loc2_].rotation = 0;
            nebulas[_loc2_].width *= 100;
            _loc2_++;
         }
         _loc1_ = int(stars.length);
         _loc2_ = 0;
         while (_loc2_ < _loc1_)
         {
            stars[_loc2_].scaleY = 0.1;
            stars[_loc2_].scaleX = 100;
            _loc2_++;
         }
         _loc1_ = int(miniStars.length);
         _loc2_ = 0;
         while (_loc2_ < _loc1_)
         {
            miniStars[_loc2_].scaleY = 0.3;
            miniStars[_loc2_].scaleX = 100;
            _loc2_++;
         }
         _loc1_ = int(miniDusts.length);
         _loc2_ = 0;
         while (_loc2_ < _loc1_)
         {
            miniDusts[_loc2_].scaleY = 0.5;
            miniDusts[_loc2_].scaleX = 100;
            _loc2_++;
         }
      }

      public function removeGlow():void
      {
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         _loc1_ = int(nebulas.length);
         _loc2_ = 0;
         while (_loc2_ < _loc1_)
         {
            nebulas[_loc2_].rotation = 0;
            nebulas[_loc2_].width /= 100;
            _loc2_++;
         }
         _loc1_ = int(stars.length);
         _loc2_ = 0;
         while (_loc2_ < _loc1_)
         {
            stars[_loc2_].scaleY = 1;
            stars[_loc2_].scaleX = 1;
            _loc2_++;
         }
         _loc1_ = int(miniStars.length);
         _loc2_ = 0;
         while (_loc2_ < _loc1_)
         {
            miniStars[_loc2_].scaleY = 1;
            miniStars[_loc2_].scaleX = 1;
            _loc2_++;
         }
         _loc1_ = int(miniDusts.length);
         _loc2_ = 0;
         while (_loc2_ < _loc1_)
         {
            miniDusts[_loc2_].scaleY = 1;
            miniDusts[_loc2_].scaleX = 1;
            _loc2_++;
         }
      }

      private function resize(param1:Event = null):void
      {
         width = Starling.current.stage.stageWidth * 1.8;
         height = Starling.current.stage.stageHeight * 1.8;
         halfWidth = width / 2;
         halfHeight = height / 2;
         randomize();
      }
   }
}
