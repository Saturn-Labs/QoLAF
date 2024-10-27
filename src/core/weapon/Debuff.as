package core.weapon
{
   import generics.Localize;

   public class Debuff
   {
      public static const TOTALTYPES:int = 11;

      public static const DOT:int = 0;

      public static const DOT_STACKING:int = 1;

      public static const BOMB:int = 2;

      public static const REDUCE_ARMOR:int = 3;

      public static const BURN:int = 4;

      public static const DISABLE_REGEN:int = 5;

      public static const DISABLE_HEAL:int = 6;

      public static const REDUCED_DAMAGE:int = 7;

      public static const REDUCED_KINETIC_RESIST:int = 8;

      public static const REDUCED_ENERGY_RESIST:int = 9;

      public static const REDUCED_CORROSIVE_RESIST:int = 10;

      public function Debuff()
      {
         super();
      }

      public static function debuffText(param1:int, param2:int, param3:Damage):String
      {
         var _loc4_:String = "";
         var _loc5_:String = "";
         if (param1 == 0 || param1 == 1)
         {
            _loc5_ = " over";
            _loc4_ += param3.debuffdamageText(param2, param2, _loc5_);
            if (param1 == 1)
            {
               _loc4_ += Localize.t("\nThe debuff stacks.\n");
            }
         }
         else if (param1 == 2)
         {
            _loc5_ = " after";
            _loc4_ += param3.debuffdamageText(3, param2, _loc5_);
         }
         else if (param1 == 3)
         {
            _loc4_ += Localize.t("<FONT COLOR='#eeeeee'>[value]</FONT> reduced armor per stack for <FONT COLOR='#eeeeee'>[duration]</FONT> seconds").replace("[value]", param3.dmg().toFixed(0)).replace("[duration]", param2);
            _loc4_ = _loc4_ + Localize.t("\nCan reduce armor below zero for a maximum bonus of +50%.\n");
            _loc4_ = _loc4_ + Localize.t("\nThe debuff stacks up to 100x.\n");
         }
         else if (param1 == 4)
         {
            _loc5_ = " over";
            _loc4_ += param3.debuffdamageText(0.5 * param2, param2, _loc5_);
            _loc4_ = _loc4_ + Localize.t("\nThe debuff decays over time\n");
         }
         else if (param1 == 5)
         {
            _loc4_ += Localize.t("Disables shield regeneration for <FONT COLOR='#eeeeee'>[duration]</FONT> seconds \n").replace("[duration]", param2);
         }
         else if (param1 == 6)
         {
            _loc4_ += Localize.t("Disables healing for <FONT COLOR='#eeeeee'>[duration]</FONT> seconds \n").replace("[duration]", param2);
         }
         else if (param1 == 7)
         {
            _loc4_ += Localize.t("Reduces target's damage by [value]% for <FONT COLOR='#eeeeee'>[duration]</FONT> seconds \n").replace("[value]", param3.dmg().toFixed(0)).replace("[duration]", param2);
         }
         else if (param1 == 8)
         {
            _loc4_ += Localize.t("Reduces target's <FONT COLOR='#00ffff'>Kinetic</FONT> resistance by [value]% for <FONT COLOR='#eeeeee'>[duration]</FONT> seconds \n").replace("[value]", param3.dmg().toFixed(0)).replace("[duration]", param2);
         }
         else if (param1 == 9)
         {
            _loc4_ += Localize.t("Reduces target's <FONT COLOR='#ff030d'>Energy</FONT> resistance by [value]% for <FONT COLOR='#eeeeee'>[duration]</FONT> seconds \n").replace("[value]", param3.dmg().toFixed(0)).replace("[duration]", param2);
         }
         else if (param1 == 10)
         {
            _loc4_ += Localize.t("Reduces target's <FONT COLOR='#009900'>Corrosive</FONT> resistance by [value]% for <FONT COLOR='#eeeeee'>[duration]</FONT> seconds \n").replace("[value]", param3.dmg().toFixed(0)).replace("[duration]", param2);
         }
         return _loc4_;
      }
   }
}
