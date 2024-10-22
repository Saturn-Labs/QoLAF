package data
{
   import com.adobe.serialization.json.JSONDecoder;
   import core.artifact.Artifact;
   import debug.Console;
   import embeds.CacheJson;
   import flash.utils.ByteArray;
   import playerio.*;
   import starling.display.Sprite;

   public class DataManager extends Sprite implements IDataManager
   {
      private var CacheFile:Class;

      private var _client:Client;

      private var json:Object;

      public var _artifacts:Vector.<Artifact>;

      public function DataManager(param1:Client)
      {
         CacheFile = embeds.CacheJson;
         _artifacts = new Vector.<Artifact>();
         super();
         this._client = param1;
      }

      public function getArtifacts():Vector.<Artifact>
      {
         return _artifacts;
      }

      public function setClient(param1:Client):void
      {
         _client = param1;
      }

      public function loadKeyFromBigDB(param1:String, param2:String, param3:Function):void
      {
         if (param1 == null || param2 == null || param1.length == 0 || param2.length == 0)
         {
            Console.write("BigDB: key or table is empty or null, key:" + param2 + " table:" + param1);
            return;
         }
         loadFromBigDB(param1, param2, param3);
      }

      private function loadFromBigDB(param1:String, param2:String, param3:Function):void
      {
         var table:String = param1;
         var key:String = param2;
         var callback:Function = param3;
         _client.bigDB.load(table, key, function(param1:DatabaseObject):void
            {
               try
               {
                  callback(param1);
               }
               catch (e:Error)
               {
                  _client.errorLog.writeError(e.toString(), "loadFromBigDB failed, table: " + table + ", key: " + key, e.getStackTrace(), {});
               }
            }, function(param1:PlayerIOError):void
            {
               Console.write("FAILED DATA - TABLE: " + table + " KEY: " + key + " ERROR: " + param1.name);
            });
      }

      public function loadRangeFromBigDB(param1:String, param2:String, param3:Array = null, param4:Function = null, param5:int = 1000):void
      {
         var table:String = param1;
         var index:String = param2;
         var indexPath:Array = param3;
         var callback:Function = param4;
         var maxCount:int = param5;
         _client.bigDB.loadRange(table, index, indexPath, null, null, maxCount, function(param1:Array):void
            {
               callback(param1);
            }, function(param1:PlayerIOError):void
            {
               Console.write("FAILED DATA - TABLE: " + table + " INDEX: " + index + " INDEX_PATH: " + indexPath + " ERROR: " + param1);
            });
      }

      public function loadKeysFromBigDB(param1:String, param2:Array, param3:Function = null):void
      {
         var key:String;
         var table:String = param1;
         var keys:Array = param2;
         var callback:Function = param3;
         var n:int = int(keys.length);
         var i:int = n - 1;
         while (i > -1)
         {
            key = keys[i];
            if (IsNullOrEmpty(key))
            {
               keys.splice(keys.indexOf(key), 1);
            }
            i--;
         }
         _client.bigDB.loadKeys(table, keys, function(param1:Array):void
            {
               callback(param1);
            }, function(param1:PlayerIOError):void
            {
               Console.write("FAILED DATA - TABLE: " + table + " KEYS: " + keys + " ERROR: " + param1);
            });
      }

      private function IsNullOrEmpty(param1:String):Boolean
      {
         if (param1 == null || param1 == "" || param1 == " ")
         {
            return true;
         }
         return false;
      }

      public function loadKey(param1:String, param2:String):Object
      {
         if (IsNullOrEmpty(param1))
         {
            Console.write("error table is null in loadKey");
            return null;
         }
         if (IsNullOrEmpty(param2))
         {
            Console.write("error key: " + param2 + " is null in loadKey for table " + param1);
            return null;
         }
         if (!json.hasOwnProperty(param1) || !json[param1].hasOwnProperty(param2))
         {
            Console.write("error key missing i json cache, table: " + param1 + ", key: " + param2);
            return null;
         }
         return json[param1][param2];
      }

      public function loadKeys(param1:String, param2:Array):Array
      {
         var _loc4_:Object = null;
         var _loc3_:Array = [];
         for each (var _loc5_:* in param2)
         {
            _loc4_ = loadKey(param1, _loc5_);
            _loc4_.key = _loc5_;
            _loc3_.push(_loc4_);
         }
         return _loc3_;
      }

      public function loadTable(param1:String):Object
      {
         if (!json.hasOwnProperty(param1))
         {
            Console.write("error table is missing in cache, table: " + param1);
            return null;
         }
         return json[param1];
      }

      public function loadRange(param1:String, param2:String, param3:String):Object
      {
         var _loc5_:Object = null;
         if (!json.hasOwnProperty(param1))
         {
            Console.write("error table missing i json cache, table: " + param1);
            return null;
         }
         var _loc4_:Object = {};
         for (var _loc6_:* in json[param1])
         {
            _loc5_ = json[param1][_loc6_];
            if (_loc5_.hasOwnProperty(param2))
            {
               if (_loc5_[param2] == param3)
               {
                  _loc4_[_loc6_] = _loc5_;
               }
            }
         }
         return _loc4_;
      }

      public function loadFirstByProperty(param1:String, param2:String, param3:String):Object
      {
         var _loc4_:Object = null;
         if (!json.hasOwnProperty(param1))
         {
            Console.write("error table missing i json cache, table: " + param1);
            return null;
         }
         for (var _loc5_:* in json[param1])
         {
            _loc4_ = json[param1][_loc5_];
            if (_loc4_.hasOwnProperty(param2))
            {
               if (_loc4_[param2] == param3)
               {
                  return _loc4_;
               }
            }
         }
         return null;
      }

      public function cacheCommonData():void
      {
         var _loc2_:ByteArray = new CacheFile() as ByteArray;
         var _loc1_:JSONDecoder = new JSONDecoder(_loc2_.readUTFBytes(_loc2_.length), true);
         json = _loc1_.getValue();
      }
   }
}
