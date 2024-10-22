package generics
{
   import com.adobe.serialization.json.JSONDecoder;
   import flash.utils.ByteArray;
   import flash.globalization.LocaleID;
   import flash.globalization.ResourceManager;

   public class Localize
   {
      private static var langObj:Object;

      public static var language:String = "en";

      public static var activateLanguageSelection:Boolean = false;

      private static var LanguageFile:Class = LangJson;

      private static var r:RegExp = new RegExp(/(\W+)/g);

      public function Localize()
      {
         super();
      }

      public static function setLocale(param1:String = "en_US"):void
      {
         // Set the locale using ResourceManager (if needed for other functionalities)
         LocaleID.current = param1 || "en_US";
      }

      public static function t(param1:String):String
      {
         if (!activateLanguageSelection)
         {
            return param1;
         }
         var _loc3_:String = param1.replace(r, "").toLowerCase();
         if (langObj[language] == null)
         {
            return param1;
         }
         var _loc2_:String = langObj[language][_loc3_];
         if (_loc2_ == null || _loc2_ == "")
         {
            return param1;
         }
         return _loc2_.replace(/\\n/g, "\n");
      }

      public static function cacheLanguageData():void
      {
         var _loc2_:ByteArray = new LanguageFile() as ByteArray;
         var _loc1_:JSONDecoder = new JSONDecoder(_loc2_.readUTFBytes(_loc2_.length), true);
         langObj = _loc1_.getValue();
      }

      public static function newData(param1:String):void
      {
         langObj = JSON.parse(param1);
      }
   }
}
