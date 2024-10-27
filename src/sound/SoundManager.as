package sound
{
   import com.greensock.TweenMax;
   import core.scene.Game;
   import data.DataLocator;
   import data.IDataManager;
   import debug.Console;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.media.SoundChannel;
   import flash.media.SoundMixer;
   import flash.media.SoundTransform;
   import flash.utils.Dictionary;
   import playerio.Client;
   import playerio.GameFS;

   public class SoundManager extends Sprite implements ISound
   {
      private static var audioPath:String = "/sound/";

      public static const TYPE_MUSIC:String = "music";

      public static const TYPE_EFFECT:String = "effects";

      public static const TYPE_VOICE:String = "voice";

      private var musicObjects:Dictionary;

      private var effectObjects:Dictionary;

      private var soundObjects:Dictionary;

      private var soundObjectsByName:Dictionary;

      private var callbackQueue:Dictionary;

      private var _effectVolume:Number = 0.5;

      private var _musicVolume:Number = 0.5;

      private var loadItems:Array;

      private var totalItems:int = 0;

      private var currItem:int = 0;

      private var percentageLoaded:int = 0;

      private var fs:GameFS;

      private var _client:Client;

      public function SoundManager(param1:Client)
      {
         musicObjects = new Dictionary();
         effectObjects = new Dictionary();
         soundObjects = new Dictionary();
         soundObjectsByName = new Dictionary();
         callbackQueue = new Dictionary();
         super();
         _client = param1;
         this.fs = param1.gameFS;
         percentageLoaded = 0;
         currItem = 1;
         volume = 0.5;
      }

      public function set client(param1:Client):void
      {
         _client = param1;
         this.fs = _client.gameFS;
      }

      public function play(param1:String, param2:Function = null, param3:Function = null):void
      {
         internalPlay("effects", param1, false, false, param2, param3);
      }

      public function playMusic(param1:String, param2:Boolean = false, param3:Boolean = false, param4:Function = null, param5:Function = null, param6:Boolean = false):void
      {
         var fadeDelay:int;
         var key:String = param1;
         var loop:Boolean = param2;
         var resume:Boolean = param3;
         var loadCompleteCallback:Function = param4;
         var playCompleteCallback:Function = param5;
         var fade:Boolean = param6;
         stopAllMusicExcept(key);
         fadeDelay = 0;
         if (fade)
         {
            fadeDelay = 1;
         }
         TweenMax.delayedCall(fadeDelay, function():void
            {
               internalPlay("music", key, loop, resume, loadCompleteCallback, playCompleteCallback);
            });
      }

      public function preCacheSound(param1:String, param2:Function = null, param3:String = "effect"):void
      {
         var key:String = param1;
         var callback:Function = param2;
         var type:String = param3;
         if (soundObjects.hasOwnProperty(key))
         {
            if (callback != null)
            {
               callback();
            }
            return;
         }
         getSoundObject(key, function(param1:SoundObject):void
            {
               if (callback != null)
               {
                  callback();
               }
            }, type);
      }

      public function stop(param1:String, param2:Function = null):void
      {
         var key:String = param1;
         var callback:Function = param2;
         getSoundObject(key, function(param1:SoundObject):void
            {
               param1.stop();
               if (callback != null)
               {
                  callback();
               }
            });
      }

      public function stopMusic():void
      {
         for each (var _loc1_:* in musicObjects)
         {
            _loc1_.pause();
         }
      }

      public function stopAllMusicExcept(param1:String, param2:Boolean = true):void
      {
         var _loc4_:int = 1;
         for each (var _loc3_:* in musicObjects)
         {
            if (_loc3_.key != param1)
            {
               if (param2)
               {
                  _loc3_.fadeStop();
               }
               else
               {
                  _loc3_.stop();
               }
            }
         }
      }

      private function internalPlay(param1:String, param2:String, param3:Boolean, param4:Boolean, param5:Function = null, param6:Function = null):void
      {
         var type:String = param1;
         var key:String = param2;
         var loop:Boolean = param3;
         var resume:Boolean = param4;
         var loadCompleteCallback:Function = param5;
         var playCompleteCallback:Function = param6;
         if (type == "effects" && _effectVolume < 0.1 && loadCompleteCallback == null && playCompleteCallback == null)
         {
            return;
         }
         if (type == "music" && _musicVolume < 0.1 && loadCompleteCallback == null && playCompleteCallback == null)
         {
            return;
         }
         getSoundObject(key, function(param1:SoundObject):void
            {
               var sc:SoundChannel;
               var sObject:SoundObject = param1;
               var volume:Number = sObject.originalVolume;
               if (type == "music")
               {
                  volume *= musicVolume;
               }
               else if (type == "effects")
               {
                  volume *= effectVolume;
               }
               if (resume)
               {
                  sc = sObject.resume(volume, loop);
               }
               else
               {
                  sc = sObject.playObject(volume, loop);
               }
               if (loadCompleteCallback != null)
               {
                  loadCompleteCallback(sc);
               }
               if (sc == null)
               {
                  return;
               }
               if (playCompleteCallback != null)
               {
                  sc.addEventListener("soundComplete", (function():*
                        {
                           var onComplete:Function;
                           return onComplete = function(param1:Event):void
                           {
                              sc.removeEventListener("soundComplete", onComplete);
                              playCompleteCallback();
                           };
                        })());
               }
            }, type);
      }

      public function load(param1:Array):void
      {
         loadItems = param1;
         totalItems = param1.length;
         loadOne(currItem - 1);
      }

      private function loadOne(param1:int):void
      {
         var _loc2_:SoundObject = new SoundObject(fs.getUrl(audioPath + loadItems[param1].toString(), Login.useSecure));
         _loc2_.addEventListener("progress", onLoadProgress);
         _loc2_.addEventListener("complete", onLoadComplete);
         _loc2_.addEventListener("ioError", onIOError);
      }

      private function onIOError(param1:IOErrorEvent):void
      {
         Console.write("Load sound error: " + param1);
      }

      private function onLoadProgress(param1:Event):void
      {
         var _loc2_:int = Math.ceil(param1.target.bytesLoaded / param1.target.bytesTotal * 100 * currItem / totalItems);
         if (_loc2_ > percentageLoaded)
         {
            percentageLoaded = _loc2_;
         }
         dispatchEvent(new Event("preloadProgress"));
      }

      private function onLoadComplete(param1:Event):void
      {
         soundObjects[loadItems[currItem - 1]] = param1.target as SoundObject;
         if (currItem == totalItems)
         {
            param1.target.removeEventListener("progress", onLoadProgress);
            param1.target.removeEventListener("complete", onLoadComplete);
            param1.target.removeEventListener("ioError", onIOError);
            dispatchEvent(new Event("preloadComplete"));
         }
         else
         {
            currItem += 1;
            loadOne(currItem - 1);
         }
      }

      public function get percLoaded():int
      {
         return percentageLoaded;
      }

      private function getSoundObject(param1:String, param2:Function, param3:String = "effects"):void
      {
         var _loc6_:IDataManager = null;
         var _loc5_:Object = null;
         var _loc4_:Array = null;
         if (param1 == null)
         {
            return;
         }
         if (soundObjects.hasOwnProperty(param1))
         {
            param2(soundObjects[param1] as SoundObject);
         }
         else
         {
            _loc6_ = DataLocator.getService();
            _loc5_ = _loc6_.loadKey("Sounds", param1);
            if (_loc5_ == null)
            {
               return;
            }
            if (callbackQueue.hasOwnProperty(param1))
            {
               _loc4_ = callbackQueue[param1];
               _loc4_.push(param2);
            }
            else
            {
               _loc4_ = [];
               _loc4_.push(param2);
               callbackQueue[param1] = _loc4_;
               cacheSound(param3, param1, _loc5_);
            }
         }
      }

      private function cacheSound(param1:String, param2:String, param3:Object):void
      {
         var type:String = param1;
         var key:String = param2;
         var obj:Object = param3;
         loadSoundFromFS(obj.type + "/" + obj.fileName, function(param1:SoundObject):void
            {
               param1.originalVolume = obj.volume;
               soundObjects[key] = param1;
               param1.key = key;
               if (type == "music")
               {
                  musicObjects[key] = param1;
               }
               else
               {
                  param1.multipleAllowed = true;
                  effectObjects[key] = param1;
               }
               for each (var _loc2_:* in callbackQueue[key])
               {
                  _loc2_(param1);
               }
               delete callbackQueue[key];
            });
      }

      private function loadSoundFromUrl(param1:String, param2:Function):void
      {
         var url:String = param1;
         var callback:Function = param2;
         var s:SoundObject = new SoundObject(url);
         s.addEventListener("complete", (function():*
               {
                  var onComplete:Function;
                  return onComplete = function(param1:Event):void
                  {
                     var _loc2_:SoundObject = param1.target as SoundObject;
                     s.removeEventListener("complete", onComplete);
                     s.removeEventListener("ioError", onIOError);
                     callback(_loc2_);
                  };
               })());
         s.addEventListener("ioError", onIOError);
      }

      private function loadSoundFromFS(param1:String, param2:Function):void
      {
         var fileName:String = param1;
         var callback:Function = param2;
         loadSoundFromUrl(fs.getUrl(audioPath + fileName, Login.useSecure), function(param1:SoundObject):void
            {
               callback(param1);
            });
      }

      public function get musicVolume():Number
      {
         return _musicVolume;
      }

      public function set musicVolume(param1:Number):void
      {
         _musicVolume = param1;
         for each (var _loc2_:* in musicObjects)
         {
            _loc2_.volume = _loc2_.originalVolume * param1;
         }
         if (Game.instance)
         {
            Playlist.play(Game.instance.solarSystem.key);
         }
      }

      public function get effectVolume():Number
      {
         return _effectVolume;
      }

      public function set effectVolume(param1:Number):void
      {
         _effectVolume = param1;
         for each (var _loc2_:* in effectObjects)
         {
            _loc2_.volume = _loc2_.originalVolume * param1;
         }
      }

      public function get volume():Number
      {
         return SoundMixer.soundTransform.volume;
      }

      public function set volume(param1:Number):void
      {
         var _loc3_:SoundTransform = SoundMixer.soundTransform;
         _loc3_.volume = param1;
         SoundMixer.soundTransform = _loc3_;
         for each (var _loc2_:* in soundObjects)
         {
            _loc2_.volume = _loc2_.originalVolume * param1;
         }
      }

      public function stopAll():void
      {
         SoundMixer.stopAll();
      }
   }
}
