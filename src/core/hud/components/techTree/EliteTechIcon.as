package core.hud.components.techTree
{
   import com.greensock.TweenMax;
   import core.hud.components.ToolTip;
   import core.player.EliteTechs;
   import core.player.TechSkill;
   import core.scene.Game;
   import data.DataLocator;
   import data.IDataManager;
   import generics.Localize;
   import generics.Random;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.text.TextField;
   import starling.text.TextFormat;
   import textures.ITextureManager;
   import textures.TextureLocator;

   public class EliteTechIcon extends Sprite
   {
      public static var ICON_WIDTH:int = 40;

      public static var ICON_PADDING:int = 5;

      public static const STATE_LOCKED:String = "locked";

      public static const STATE_NO_SPECIAL:String = "no special selected";

      public static const STATE_SELECTED:String = "selected";

      public static const STATE_UPGRADABLE:String = "special selected and can be upgraded";

      public static const STATE_FULLY_UPGRADED:String = "fully upgraded";

      public static const STATE_CANT_BE_UPGRADED:String = "cant upgrade";

      public var level:int;

      public var mineralType1:String;

      public var mineralType2:String;

      public var table:String;

      public var tech:String;

      public var upgradeNameRaw:String;

      public var upgradeName:String;

      public var description:String;

      public var techSkill:TechSkill;

      private var bitmap:Image;

      private var bitmapHover:Image;

      private var bitmapNotAvailable:Image;

      private var bitmapAvailable:Image;

      private var bitmapSelected:Image;

      private var bitmapMax:Image;

      private var bitmapLocked:Image;

      private var textureManager:ITextureManager;

      private var dataManager:IDataManager;

      private var techItemObject:Object;

      private var state:String;

      private var tb:TechBar;

      private var showTooltip:Boolean;

      private var canBeUpgraded:Boolean;

      private var number:TextField;

      private var g:Game;

      private var icon:Image;

      public function EliteTechIcon(param1:Game, param2:TechBar, param3:String, param4:TechSkill, param5:Boolean, param6:Boolean)
      {
         super();
         this.g = param1;
         this.tb = param2;
         this.table = param4.table;
         this.tech = param4.tech;
         this.techSkill = param4;
         this.showTooltip = param5;
         this.canBeUpgraded = param6;
         textureManager = TextureLocator.getService();
         dataManager = DataLocator.getService();
         techItemObject = dataManager.loadKey(table, tech);
         var _loc7_:Object = dataManager.loadKey("Images", techItemObject.techIcon);
         var _loc8_:String = _loc7_.textureName + "_levels.png";
         upgradeName = Localize.t(param4.activeEliteTech);
         upgradeNameRaw = param4.activeEliteTech;
         description = techItemObject.description;
         mineralType1 = "flpbTKautkC1QzjWT28gkw";
         setMineralType2();
         this.level = param4.activeEliteTechLevel;
         bitmap = new Image(textureManager.getTextureGUIByTextureName(_loc8_));
         addChild(bitmap);
         bitmapNotAvailable = new Image(textureManager.getTextureGUIByTextureName("ti_na.png"));
         bitmapNotAvailable.touchable = false;
         bitmapNotAvailable.visible = false;
         bitmapHover = new Image(textureManager.getTextureGUIByTextureName(_loc8_));
         bitmapHover.touchable = false;
         bitmapHover.blendMode = "add";
         bitmapAvailable = new Image(textureManager.getTextureGUIByTextureName("ti_a.png"));
         bitmapAvailable.touchable = false;
         bitmapAvailable.color = 65280;
         bitmapAvailable.visible = false;
         addChild(bitmapAvailable);
         bitmapSelected = new Image(textureManager.getTextureGUIByTextureName("ti_a.png"));
         bitmapSelected.touchable = false;
         bitmapSelected.color = 16777215;
         bitmapSelected.visible = false;
         bitmapLocked = new Image(textureManager.getTextureByTextureName("lock.png", "texture_gui1_test.png"));
         bitmapLocked.touchable = false;
         bitmapLocked.visible = false;
         bitmapLocked.x = 10;
         bitmapLocked.y = 5;
         bitmapLocked.blendMode = "add";
         addChild(bitmapLocked);
         bitmapMax = new Image(textureManager.getTextureGUIByTextureName("ti_a.png"));
         bitmapMax.touchable = false;
         bitmapMax.color = 16777215;
         bitmapMax.blendMode = "add";
         bitmapMax.visible = false;
         number = new TextField(40, 40, "", new TextFormat("font13", 12, 16777215));
         number.batchable = true;
         number.touchable = false;
         addIcon();
         this.addEventListener("touch", onTouch);
         updateState(param3);
         if (param5)
         {
            new ToolTip(Game.instance, this, "<font color='#ffffff'>" + Localize.t(description) + "</font>");
         }
      }

      private function updateIcon():void
      {
         if (icon != null)
         {
            this.removeChildren();
         }
         addIcon();
      }

      private function addIcon():void
      {
         var _loc1_:String = null;
         if (techSkill.activeEliteTech != null && techSkill.activeEliteTech != "")
         {
            _loc1_ = EliteTechs.getIconName(techSkill.activeEliteTech) + ".png";
            icon = new Image(textureManager.getTextureGUIByTextureName(_loc1_));
            bitmapHover = new Image(textureManager.getTextureGUIByTextureName(_loc1_));
            bitmapHover.blendMode = "add";
            bitmapHover.visible = false;
            bitmapSelected = new Image(textureManager.getTextureGUIByTextureName(_loc1_));
            bitmapSelected.blendMode = "add";
            bitmapSelected.visible = false;
         }
         else
         {
            icon = new Image(textureManager.getTextureGUIByTextureName("ti2_increase_dmg.png"));
         }
         icon.pivotX = icon.width / 2;
         icon.pivotY = icon.height / 2;
         icon.x = ICON_WIDTH / 2;
         icon.y = ICON_WIDTH / 2;
         addChild(icon);
         addChild(bitmapSelected);
         addChild(bitmapHover);
         addChild(number);
      }

      private function setMineralType2():void
      {
         var _loc4_:int = 0;
         var _loc1_:int = 0;
         _loc4_ = 0;
         while (_loc4_ < upgradeNameRaw.length)
         {
            _loc1_ += upgradeNameRaw.charCodeAt(_loc4_);
            _loc4_++;
         }
         _loc1_ %= 3;
         var _loc3_:Random = new Random(_loc1_ + 20 * (level + 1));
         var _loc2_:Number = _loc3_.randomNumber();
         if (_loc2_ < 0.33)
         {
            mineralType2 = "d6H3w_34pk2ghaQcXYBDag";
         }
         else if (_loc2_ < 0.66)
         {
            mineralType2 = "H5qybQDy9UindMh9yYIeqg";
         }
         else
         {
            mineralType2 = "gO_f-y0QEU68vVwJ_XVmOg";
         }
      }

      public function getMineralType2(param1:int):String
      {
         var _loc5_:int = 0;
         var _loc2_:int = 0;
         _loc5_ = 0;
         while (_loc5_ < upgradeName.length)
         {
            _loc2_ += upgradeName.charCodeAt(_loc5_);
            _loc5_++;
         }
         _loc2_ %= 3;
         var _loc4_:Random = new Random(_loc2_ + 20 * param1);
         var _loc3_:Number = _loc4_.randomNumber();
         if (_loc3_ < 0.33)
         {
            return "d6H3w_34pk2ghaQcXYBDag";
         }
         if (_loc3_ < 0.66)
         {
            return "H5qybQDy9UindMh9yYIeqg";
         }
         return "gO_f-y0QEU68vVwJ_XVmOg";
      }

      public function getCostForResource(param1:String, param2:int, param3:*):int
      {
         var _loc5_:int = 0;
         var _loc4_:* = 0;
         _loc4_ = param2;
         while (_loc4_ <= param3)
         {
            if (getMineralType2(_loc4_) == param1)
            {
               _loc5_ += EliteTechs.getResource2Cost(_loc4_);
            }
            _loc4_++;
         }
         return _loc5_;
      }

      public function updateMineralType2():void
      {
         setMineralType2();
      }

      public function updateState(param1:String):void
      {
         if (level >= 100)
         {
            param1 = "fully upgraded";
         }
         this.state = param1;
         bitmap.alpha = bitmapHover.alpha = 1;
         useHandCursor = canBeUpgraded;
         bitmapAvailable.visible = false;
         bitmapHover.visible = false;
         bitmapMax.visible = false;
         bitmapNotAvailable.visible = false;
         bitmapSelected.visible = false;
         number.scaleX = number.scaleY = 1;
         var _loc4_:Array = TweenMax.getTweensOf(number);
         for each (var _loc2_:* in _loc4_)
         {
            _loc2_.kill();
         }
         var _loc5_:Array = TweenMax.getTweensOf(icon);
         for each (var _loc3_:* in _loc5_)
         {
            _loc3_.kill();
         }
         switch (param1)
         {
            case "locked":
               bitmap.alpha = bitmapHover.alpha = 0.3;
               bitmapLocked.visible = true;
               number.format.size = 16;
               number.text = "?";
               number.x = ICON_WIDTH / 2 + 2;
               number.y = ICON_WIDTH / 2 + 5;
               number.alignPivot();
               useHandCursor = false;
               if (icon != null)
               {
                  icon.visible = false;
               }
               break;
            case "no special selected":
               bitmap.alpha = bitmapHover.alpha = 0.3;
               bitmapLocked.visible = false;
               bitmapAvailable.visible = true;
               number.format.size = 28;
               number.text = "?";
               number.x = ICON_WIDTH / 2 + 1;
               number.y = ICON_WIDTH / 2 + 1;
               number.alignPivot();
               TweenMax.fromTo(number, 1, {
                        "scaleX": 1,
                        "scaleY": 1
                     }, {
                        "scaleX": 1.2,
                        "scaleY": 1.2,
                        "yoyo": true,
                        "repeat": -1
                     });
               if (icon != null)
               {
                  icon.visible = false;
               }
               break;
            case "selected":
               updateLevelText();
               updateIcon();
               number.alignPivot("left", "top");
               bitmapHover.visible = true;
               bitmapSelected.visible = true;
               break;
            case "special selected and can be upgraded":
               updateLevelText();
               updateIcon();
               number.alignPivot("left", "top");
               bitmap.alpha = bitmapHover.alpha = 0.5;
               bitmapAvailable.visible = false;
               break;
            case "fully upgraded":
               bitmap.alpha = bitmapHover.alpha = 1;
               bitmapAvailable.visible = false;
               updateLevelText();
         }
      }

      private function updateLevelText():void
      {
         if (level == 100)
         {
            number.x = 0;
            number.text = "MAX";
            number.format.color = 0;
            number.format.horizontalAlign = "center";
         }
         else
         {
            number.x = -5;
            number.format.color = 16777215;
            number.text = level.toString();
            number.format.horizontalAlign = "right";
         }
         number.format.size = 12;
         number.format.verticalAlign = "bottom";
      }

      private function mouseOver(param1:TouchEvent = null):void
      {
         if (state == "selected")
         {
            return;
         }
         bitmapHover.visible = true;
         if (!showTooltip)
         {
            this.dispatchEventWith("mOver", true);
         }
      }

      private function mouseOut(param1:TouchEvent):void
      {
         if (state == "selected")
         {
            return;
         }
         bitmapHover.visible = false;
         if (!showTooltip)
         {
            this.dispatchEventWith("mOut", true);
         }
      }

      public function update(param1:int):void
      {
         level = param1;
         updateState("special selected and can be upgraded");
         updateIcon();
         mouseClick(new TouchEvent("", new Vector.<Touch>()), true);
      }

      private function mouseClick(param1:TouchEvent, param2:Boolean = false):void
      {
         var popup:EliteTechPopupMenu;
         var e:TouchEvent = param1;
         var isFake:Boolean = param2;
         if (!canBeUpgraded)
         {
            return;
         }
         if (state == "locked")
         {
            bitmapHover.visible = false;
            return;
         }
         if (!isFake && (state == "fully upgraded" || state == "no special selected"))
         {
            popup = new EliteTechPopupMenu(g, this);
            g.addChildToOverlay(popup);
            popup.addEventListener("close", (function():*
                  {
                     var closePopup:Function;
                     return closePopup = function(param1:Event):void
                     {
                        g.removeChildFromOverlay(popup);
                        popup.removeEventListeners();
                     };
                  })());
            return;
         }
         if (state == "selected")
         {
            updateState("special selected and can be upgraded");
         }
         else if (state == "special selected and can be upgraded")
         {
            updateState("selected");
         }
         this.dispatchEventWith("mClick", true);
      }

      private function onTouch(param1:TouchEvent):void
      {
         if (param1.getTouch(this, "ended"))
         {
            mouseClick(param1);
         }
         else if (param1.interactsWith(this))
         {
            mouseOver(param1);
         }
         else
         {
            mouseOut(param1);
         }
      }

      public function upgrade():void
      {
         if (level == 100)
         {
            updateState("fully upgraded");
         }
         else
         {
            updateState("special selected and can be upgraded");
         }
      }

      public function getDescriptionNextLevel(param1:int = -1):String
      {
         if (param1 == -1)
         {
            param1 = level + 1;
         }
         if (state == "locked" || techSkill.activeEliteTech == null || techSkill.activeEliteTech == "")
         {
            return "";
         }
         return EliteTechs.getStatTextByLevel(techSkill.activeEliteTech, techItemObject, param1);
      }

      public function getDescription():String
      {
         var _loc1_:String = "";
         if (state == "locked")
         {
            _loc1_ = Localize.t("The Elite Tech Specializations are unlocked once [name] reaches level 6.").replace("[name]", upgradeName);
         }
         else if (techSkill.activeEliteTech == null || techSkill.activeEliteTech == "")
         {
            _loc1_ = Localize.t("Select an Elite Tech Specialization for [name]").replace("[name]", upgradeName) + ":";
         }
         else
         {
            _loc1_ = "<FONT COLOR='#ffaa44' size='16'>" + EliteTechs.getName(techSkill.activeEliteTech) + "</FONT>\n";
            _loc1_ += "<FONT COLOR='#88ff88'>" + EliteTechs.getStatTextByLevel(techSkill.activeEliteTech, techItemObject, level) + "</FONT>";
         }
         return _loc1_;
      }

      override public function dispose():void
      {
         removeEventListeners();
         super.dispose();
      }
   }
}
