package core.hud.components.techTree
{
   import com.greensock.TweenMax;
   import core.credits.CreditManager;
   import core.hud.components.Button;
   import core.hud.components.LootItem;
   import core.hud.components.PriceCommodities;
   import core.hud.components.Text;
   import core.hud.components.TextBitmap;
   import core.hud.components.cargo.Cargo;
   import core.hud.components.dialogs.CreditBuyBox;
   import core.hud.components.dialogs.LootPopupConfirmMessage;
   import core.player.EliteTechSkill;
   import core.player.EliteTechs;
   import core.player.Player;
   import core.player.TechSkill;
   import core.scene.Game;
   import core.weapon.WeaponDataHolder;
   import debug.Console;
   import feathers.controls.ScrollContainer;
   import feathers.controls.Slider;
   import generics.Localize;
   import playerio.Message;
   import sound.SoundLocator;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.events.TouchEvent;

   public class TechTree extends Sprite
   {
      private static const UPGRADE_LEVEL_REQUIREMENTS:Array = [1, 2, 4, 8, 12, 16];

      private var container:ScrollContainer;

      private var myCargo:Cargo;

      private var _nrOfUpgrades:Vector.<int>;

      private var upgradeCallback:Function;

      private var buyWithResourcesButton:Button;

      private var switchEliteTechButton:Button;

      private var buyWithFluxButton:Button;

      private var resetButton:Button;

      private var resetPackageButton:Button;

      private var cheatButton:Button;

      private var confirmBox:LootPopupConfirmMessage;

      public var techBars:Vector.<TechBar>;

      public var techSelectedForUpgrade:TechLevelIcon = null;

      public var eliteTechSelectedForUpgrade:EliteTechIcon = null;

      private var eliteSlider:Slider;

      private var eliteSliderLabel:Text;

      private var canUpgrade:Boolean;

      private var g:Game;

      private var me:Player;

      private var scrollHeight:Number;

      private var upgradeInfo:Sprite;

      private var nameText:Text;

      private var description:Text;

      private var descriptionNextLevel:Text;

      private var eliteUpgradeHeading:TextBitmap;

      private var mineralType1Cost:PriceCommodities = null;

      private var mineralType2Cost:PriceCommodities = null;

      private var mineralType3Cost:PriceCommodities = null;

      private var mineralType4Cost:PriceCommodities = null;

      private var autoUpdateEliteUpgradeStartValue:int = 0;

      private var upgradeEliteLevelTo:int = 1;

      private var isUpgradingEliteTech:Boolean = false;

      private var fluxReset:int = 0;

      public function TechTree(param1:Game, param2:Number = 400, param3:Boolean = false, param4:Function = null)
      {
         container = new ScrollContainer();
         _nrOfUpgrades = Vector.<int>([0, 0, 0, 0, 0, 0, 0]);
         techBars = new Vector.<TechBar>();
         eliteSlider = new Slider();
         eliteSliderLabel = new Text();
         upgradeInfo = new Sprite();
         nameText = new Text();
         description = new Text();
         descriptionNextLevel = new Text();
         eliteUpgradeHeading = new TextBitmap();
         super();
         this.g = param1;
         this.me = param1.me;
         this.myCargo = param1.myCargo;
         this.canUpgrade = param3;
         this.upgradeCallback = param4;
         this._nrOfUpgrades = me.nrOfUpgrades;
         this.scrollHeight = param2;
         nameText.font = "Verdana";
         description.font = "Verdana";
         descriptionNextLevel.font = "Verdana";
      }

      public static function hasRequiredLevel(param1:int, param2:int):Boolean
      {
         return getRequiredLevel(param1) <= param2;
      }

      public static function getRequiredLevel(param1:int):int
      {
         return TechTree.UPGRADE_LEVEL_REQUIREMENTS[param1 - 1];
      }

      public function load():void
      {
         var techSkills:Vector.<TechSkill>;
         var i:int;
         var tl:TechSkill;
         var techBar:TechBar;
         container.width = 390;
         container.height = scrollHeight;
         addChild(container);
         hideEliteSlider();
         techSkills = g.me.techSkills;
         i = 0;
         while (i < techSkills.length)
         {
            tl = techSkills[i];
            techBar = new TechBar(g, tl, me, canUpgrade);
            techBar.x = 20;
            techBar.y = i * 45;
            if (canUpgrade)
            {
               techBar.addEventListener("mClick", click);
            }
            techBar.addEventListener("mOver", over);
            techBar.addEventListener("mOut", out);
            techBars.push(techBar);
            container.addChild(techBar);
            i++;
         }
         switchEliteTechButton = new Button(changeEliteTech, "Switch Elite Tech", "normal");
         switchEliteTechButton.x = 410;
         switchEliteTechButton.y = -48 - switchEliteTechButton.height;
         switchEliteTechButton.visible = false;
         buyWithResourcesButton = new Button(buyUpgrade, "Buy", "normal");
         buyWithResourcesButton.x = 410;
         buyWithResourcesButton.y = -40;
         buyWithResourcesButton.visible = false;
         buyWithFluxButton = new Button(handleClickBuyWithFlux, "Buy for 100 Flux", "positive");
         buyWithFluxButton.x = 410 + buyWithResourcesButton.width + 16;
         buyWithFluxButton.y = -40;
         buyWithFluxButton.visible = false;
         resetButton = new Button(buyReset, "Reset Upgrades");
         resetButton.x = 20;
         resetButton.y = 410;
         resetButton.enabled = g.me.nrOfUpgrades[0] > 0 && !isUpgradingEliteTech;
         resetPackageButton = new Button(buyResetPackage, "Get Reset Package", "buy");
         resetPackageButton.x = resetButton.x + resetButton.width + 10;
         resetPackageButton.y = 410;
         resetPackageButton.enabled = g.me.nrOfUpgrades[0] > 0 && !isUpgradingEliteTech;
         if (g.me.isDeveloper)
         {
            cheatButton = new Button(cheat, "Cheat", "negative");
            cheatButton.visible = false;
            cheatButton.y = 410;
            cheatButton.x = 350;
            addChild(cheatButton);
         }
         if (canUpgrade)
         {
            addChild(buyWithResourcesButton);
            if (g.me.level >= 1)
            {
               addChild(resetButton);
               addChild(resetPackageButton);
               addChild(buyWithFluxButton);
               addChild(switchEliteTechButton);
            }
         }
         upgradeInfo.addChild(nameText);
         upgradeInfo.addChild(description);
         upgradeInfo.addChild(descriptionNextLevel);
         upgradeInfo.addChild(eliteUpgradeHeading);
         upgradeInfo.addChild(eliteSliderLabel);
         upgradeInfo.addChild(eliteSlider);
         addChild(upgradeInfo);
         upgradeInfo.visible = false;
         eliteSlider.addEventListener("change", function(param1:Event):void
            {
               updateEliteUpgradeLevels();
               updateUpgradeInfo();
               updateEliteTechUpgradeInfo(eliteTechSelectedForUpgrade);
            });
      }

      private function handleClickBuyWithFlux(param1:TouchEvent):void
      {
         var e:TouchEvent = param1;
         g.creditManager.refresh(function():void
            {
               var confirmBuyWithFlux:CreditBuyBox;
               if (techSelectedForUpgrade != null)
               {
                  confirmBuyWithFlux = new CreditBuyBox(g, CreditManager.getCostUpgrade(techSelectedForUpgrade.level), "Are you sure you want to buy this upgrade?");
                  confirmBuyUpgradeWithFlux(e, confirmBuyWithFlux);
               }
               else
               {
                  confirmBuyWithFlux = new CreditBuyBox(g, EliteTechs.getFluxCostRange(eliteTechSelectedForUpgrade.level + 1, eliteSlider.value), "Are you sure you want to buy this upgrade?");
                  confirmBuyEliteUpgradeWithFlux(e, confirmBuyWithFlux);
               }
               g.addChildToOverlay(confirmBuyWithFlux);
               confirmBuyWithFlux.addEventListener("close", function():void
                  {
                     buyWithFluxButton.enabled = true;
                     confirmBuyWithFlux.removeEventListeners();
                     g.removeChildFromOverlay(confirmBuyWithFlux, true);
                  });
            });
      }

      private function confirmBuyUpgradeWithFlux(param1:TouchEvent, param2:CreditBuyBox):void
      {
         var e:TouchEvent = param1;
         var confirmBuyWithFlux:CreditBuyBox = param2;
         confirmBuyWithFlux.addEventListener("accept", function():void
            {
               var tsfu:TechLevelIcon = techSelectedForUpgrade;
               Game.trackEvent("used flux", "bought upgrade", "number " + techSelectedForUpgrade.level, CreditManager.getCostUpgrade(techSelectedForUpgrade.level));
               TweenMax.delayedCall(1.2, function():void
                  {
                     Game.trackEvent("upgrades", "Techs", tsfu.name + " " + tsfu.level, g.me.level);
                  });
               buyUpgradeWithFlux(e);
               confirmBuyWithFlux.removeEventListeners();
            });
      }

      private function confirmBuyEliteUpgradeWithFlux(param1:TouchEvent, param2:CreditBuyBox):void
      {
         var e:TouchEvent = param1;
         var confirmBuyWithFlux:CreditBuyBox = param2;
         confirmBuyWithFlux.addEventListener("accept", function():void
            {
               var etsfu:EliteTechIcon = eliteTechSelectedForUpgrade;
               Game.trackEvent("used flux", "bought elite upgrade", "number " + eliteTechSelectedForUpgrade.level, EliteTechs.getFluxCostRange(eliteTechSelectedForUpgrade.level + 1, eliteSlider.value));
               TweenMax.delayedCall(1.2, function():void
                  {
                     Game.trackEvent("upgrades", "EliteTechs", etsfu.name + " " + etsfu.level, g.me.level);
                  });
               autoUpdateEliteUpgradeStartValue = eliteSlider.value;
               buyEliteUpgradeWithFlux(e);
               confirmBuyWithFlux.removeEventListeners();
            });
      }

      private function updateSliderPos(param1:int, param2:int):void
      {
         if (eliteSliderLabel == null)
         {
            return;
         }
         eliteSliderLabel.y = param2;
         eliteSlider.y = param2 + 14;
         eliteSliderLabel.x = param1 + eliteSlider.width + 10;
         eliteSlider.x = param1;
      }

      private function addSlider(param1:Slider, param2:Number, param3:String, param4:int, param5:int):void
      {
         param1.minimum = 1;
         param1.maximum = 100;
         param1.step = 1;
         param1.width = 200;
         param1.value = param2;
         param1.direction == "horizontal";
         param1.useHandCursor = true;
         eliteSliderLabel.htmlText = param3;
      }

      public function get nrOfUpgrades():Vector.<int>
      {
         return _nrOfUpgrades;
      }

      private function changeEliteTech(param1:TouchEvent):void
      {
         var popup:EliteTechPopupMenu;
         var e:TouchEvent = param1;
         autoUpdateEliteUpgradeStartValue = 0;
         if (eliteTechSelectedForUpgrade != null)
         {
            popup = new EliteTechPopupMenu(g, eliteTechSelectedForUpgrade);
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
            eliteTechSelectedForUpgrade.update(eliteTechSelectedForUpgrade.level);
            return;
         }
      }

      private function click(param1:Event):void
      {
         if (param1.target is TechLevelIcon)
         {
            handleClickTechIcon(param1.target as TechLevelIcon);
         }
         else if (param1.target is EliteTechIcon)
         {
            handleClickEliteTechIcon(param1.target as EliteTechIcon);
         }
      }

      private function handleClickTechIcon(param1:TechLevelIcon):void
      {
         hideEliteSlider();
         if (techSelectedForUpgrade != null)
         {
            techSelectedForUpgrade.updateState("can be upgraded");
            if (techSelectedForUpgrade == param1)
            {
               techSelectedForUpgrade = null;
               buyWithResourcesButton.visible = false;
               buyWithFluxButton.visible = false;
               upgradeInfo.visible = false;
               switchEliteTechButton.visible = false;
               return;
            }
         }
         else if (eliteTechSelectedForUpgrade != null)
         {
            eliteTechSelectedForUpgrade.updateState("special selected and can be upgraded");
            eliteTechSelectedForUpgrade = null;
         }
         techSelectedForUpgrade = param1;
         buyWithResourcesButton.visible = true;
         buyWithFluxButton.visible = true;
         switchEliteTechButton.visible = false;
         if (!canAfford(param1))
         {
            buyWithResourcesButton.enabled = false;
         }
         else
         {
            buyWithResourcesButton.enabled = true;
         }
         buyWithResourcesButton.text = "Buy";
         buyWithFluxButton.text = "Buy for " + CreditManager.getCostUpgrade(param1.level) + " Flux";
         updateTechUpgradeInfo(techSelectedForUpgrade);
      }

      private function hideEliteSlider():void
      {
         if (eliteSlider == null)
         {
            return;
         }
         eliteSlider.visible = false;
         eliteSliderLabel.visible = false;
      }

      private function showEliteSlider():void
      {
         eliteSlider.visible = true;
         eliteSliderLabel.visible = true;
      }

      private function handleClickEliteTechIcon(param1:EliteTechIcon):void
      {
         if (techSelectedForUpgrade != null)
         {
            techSelectedForUpgrade.updateState("can be upgraded");
            techSelectedForUpgrade = null;
         }
         else if (eliteTechSelectedForUpgrade != null)
         {
            eliteTechSelectedForUpgrade.updateState("special selected and can be upgraded");
            if (eliteTechSelectedForUpgrade == param1 && !isUpgradingEliteTech)
            {
               eliteTechSelectedForUpgrade = null;
               buyWithResourcesButton.visible = false;
               buyWithFluxButton.visible = false;
               upgradeInfo.visible = false;
               switchEliteTechButton.visible = false;
               eliteUpgradeHeading.visible = false;
               return;
            }
         }
         eliteTechSelectedForUpgrade = param1;
         if (this.eliteTechSelectedForUpgrade.level < 100 && !isUpgradingEliteTech)
         {
            buyWithResourcesButton.visible = true;
            buyWithFluxButton.visible = true;
            if (!canAffordET(param1))
            {
               buyWithResourcesButton.enabled = false;
            }
            else
            {
               buyWithResourcesButton.enabled = true;
            }
            switchEliteTechButton.y = -48 - switchEliteTechButton.height;
            showEliteSlider();
            eliteSlider.maximum = 100;
            eliteSlider.minimum = eliteTechSelectedForUpgrade.level + 1;
            eliteSlider.value = eliteSlider.minimum;
         }
         else
         {
            buyWithResourcesButton.visible = false;
            buyWithFluxButton.visible = false;
            switchEliteTechButton.visible = false;
            switchEliteTechButton.y = -40;
            hideEliteSlider();
            resetButton.enabled = false;
         }
         if (!isUpgradingEliteTech)
         {
            switchEliteTechButton.visible = true;
            switchEliteTechButton.enabled = true;
         }
         buyWithResourcesButton.text = "Buy";
         buyWithFluxButton.text = "Buy for " + EliteTechs.getFluxCostRange(param1.level + 1, eliteSlider.value) + " Flux";
         updateEliteTechUpgradeInfo(param1);
         updateEliteUpgradeLevels();
      }

      private function updateEliteUpgradeLevels():void
      {
         eliteSlider.minimum = eliteTechSelectedForUpgrade.level + 1;
         eliteSlider.maximum = 100;
         eliteSlider.step = 1;
         upgradeEliteLevelTo = eliteSlider.value;
      }

      private function over(param1:Event):void
      {
         var _loc2_:TechLevelIcon = null;
         var _loc3_:EliteTechIcon = null;
         if (techSelectedForUpgrade != null || eliteTechSelectedForUpgrade != null)
         {
            return;
         }
         eliteSlider.visible = false;
         eliteSliderLabel.visible = false;
         if (param1.target is TechLevelIcon)
         {
            _loc2_ = param1.target as TechLevelIcon;
            updateTechUpgradeInfo(_loc2_);
         }
         else if (param1.target is EliteTechIcon)
         {
            _loc3_ = param1.target as EliteTechIcon;
            updateEliteTechUpgradeInfo(_loc3_);
         }
      }

      private function out(param1:Event):void
      {
         if (techSelectedForUpgrade != null || eliteTechSelectedForUpgrade != null)
         {
            return;
         }
         upgradeInfo.visible = false;
      }

      private function updateUpgradeInfo():void
      {
         if (descriptionNextLevel == null || eliteTechSelectedForUpgrade == null)
         {
            return;
         }
         var _loc2_:String = Localize.t("Upgrade to level [amount]");
         var _loc1_:int = 1;
         if (eliteSlider != null)
         {
            _loc1_ = eliteSlider.value;
         }
         _loc2_ = _loc2_.replace("[amount]", _loc1_);
         eliteUpgradeHeading.text = _loc2_;
         eliteUpgradeHeading.format.color = 16755268;
         eliteUpgradeHeading.format.size = 16;
         descriptionNextLevel.htmlText = eliteTechSelectedForUpgrade.getDescriptionNextLevel(_loc1_);
      }

      private function updateEliteTechUpgradeInfo(param1:EliteTechIcon):void
      {
         var _loc9_:String = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc5_:int = 0;
         var _loc12_:int = 0;
         var _loc3_:* = 0;
         var _loc6_:int = 0;
         var _loc2_:int = 0;
         var _loc10_:int = 0;
         var _loc4_:int = 0;
         var _loc11_:Number = NaN;
         if (g.me.isDeveloper && param1.level < 100)
         {
            cheatButton.enabled = true;
            cheatButton.visible = true;
         }
         upgradeInfo.visible = true;
         upgradeInfo.x = 410;
         description.visible = false;
         descriptionNextLevel.visible = false;
         eliteUpgradeHeading.visible = false;
         removeMineralCosts();
         description.x = 2;
         description.width = 270;
         description.wordWrap = true;
         description.color = 978670;
         description.visible = true;
         description.size = 10;
         description.htmlText = param1.getDescription();
         description.y = 0;
         nameText.visible = false;
         switchEliteTechButton.y = description.y + description.height + 20;
         if (param1.level == 100)
         {
            switchEliteTechButton.visible = false;
         }
         if (param1.level < 100 && param1.techSkill.activeEliteTech != null && param1.techSkill.activeEliteTech != "")
         {
            _loc9_ = param1.mineralType1;
            _loc7_ = eliteSlider.value;
            if (_loc7_ < param1.level + 1)
            {
               _loc7_ = param1.level + 1;
            }
            descriptionNextLevel.x = 2;
            descriptionNextLevel.width = 270;
            descriptionNextLevel.wordWrap = true;
            descriptionNextLevel.color = 11184810;
            descriptionNextLevel.visible = true;
            descriptionNextLevel.size = 12;
            updateUpgradeInfo();
            _loc8_ = container.y + container.height;
            _loc8_ = _loc8_ + -buyWithResourcesButton.height;
            if (buyWithResourcesButton.visible)
            {
               buyWithResourcesButton.y = _loc8_;
               buyWithFluxButton.y = _loc8_;
            }
            _loc8_ += -15;
            _loc5_ = EliteTechs.getResource1CostRange(param1.level + 1, _loc7_);
            if (_loc5_ > 0 && _loc9_ != null)
            {
               _loc12_ = param1.level + 1;
               _loc3_ = _loc7_;
               _loc6_ = param1.getCostForResource("d6H3w_34pk2ghaQcXYBDag", _loc12_, _loc3_);
               _loc2_ = param1.getCostForResource("H5qybQDy9UindMh9yYIeqg", _loc12_, _loc3_);
               _loc10_ = param1.getCostForResource("gO_f-y0QEU68vVwJ_XVmOg", _loc12_, _loc3_);
               _loc4_ = 2;
               _loc11_ = 0.3;
               if (_loc10_ >= 0)
               {
                  mineralType4Cost = new PriceCommodities(g, "gO_f-y0QEU68vVwJ_XVmOg", _loc10_, "Verdana", 12);
                  mineralType4Cost.x = _loc4_;
                  _loc8_ += -mineralType4Cost.height;
                  mineralType4Cost.y = _loc8_;
                  mineralType4Cost.visible = true;
                  if (_loc10_ == 0)
                  {
                     mineralType4Cost.alpha = _loc11_;
                  }
                  upgradeInfo.addChild(mineralType4Cost);
               }
               if (_loc2_ >= 0)
               {
                  mineralType3Cost = new PriceCommodities(g, "H5qybQDy9UindMh9yYIeqg", _loc2_, "Verdana", 12);
                  mineralType3Cost.x = _loc4_;
                  _loc8_ += -mineralType3Cost.height;
                  mineralType3Cost.y = _loc8_;
                  mineralType3Cost.visible = true;
                  if (_loc2_ == 0)
                  {
                     mineralType3Cost.alpha = _loc11_;
                  }
                  upgradeInfo.addChild(mineralType3Cost);
               }
               if (_loc6_ >= 0)
               {
                  mineralType2Cost = new PriceCommodities(g, "d6H3w_34pk2ghaQcXYBDag", _loc6_, "Verdana", 12);
                  mineralType2Cost.x = _loc4_;
                  _loc8_ += -mineralType2Cost.height;
                  mineralType2Cost.y = _loc8_;
                  mineralType2Cost.visible = true;
                  if (_loc6_ == 0)
                  {
                     mineralType2Cost.alpha = _loc11_;
                  }
                  upgradeInfo.addChild(mineralType2Cost);
               }
               mineralType1Cost = new PriceCommodities(g, _loc9_, _loc5_, "Verdana", 12);
               mineralType1Cost.x = 2;
               _loc8_ += -mineralType1Cost.height;
               mineralType1Cost.y = _loc8_;
               mineralType1Cost.visible = true;
               upgradeInfo.addChild(mineralType1Cost);
               buyWithFluxButton.text = "Buy for " + EliteTechs.getFluxCostRange(param1.level + 1, _loc7_) + " Flux";
               _loc8_ += -105;
               eliteUpgradeHeading.y = _loc8_ - eliteUpgradeHeading.height;
               updateSliderPos(0, eliteUpgradeHeading.y + eliteSlider.height);
               if (!isUpgradingEliteTech && eliteTechSelectedForUpgrade != null)
               {
                  showEliteSlider();
               }
               else
               {
                  hideEliteSlider();
               }
               eliteUpgradeHeading.visible = true;
               descriptionNextLevel.y = eliteSlider.y + 16;
            }
         }
      }

      private function updateTechUpgradeInfo(param1:TechLevelIcon):void
      {
         var _loc4_:String = null;
         var _loc6_:int = 0;
         var _loc8_:String = null;
         var _loc5_:int = 0;
         var _loc9_:String = null;
         var _loc7_:String = null;
         var _loc3_:int = 0;
         upgradeInfo.visible = true;
         upgradeInfo.x = 410;
         description.visible = false;
         descriptionNextLevel.visible = false;
         eliteSlider.visible = false;
         eliteSliderLabel.visible = false;
         eliteUpgradeHeading.visible = false;
         removeMineralCosts();
         description.x = 2;
         description.width = 270;
         description.wordWrap = true;
         description.color = 11184810;
         description.visible = true;
         description.size = 12;
         if (param1.level == 0)
         {
            if (param1.table == "BasicTechs")
            {
               _loc4_ = param1.description;
            }
            for each (var _loc2_:* in me.weaponData)
            {
               if (_loc2_.key == param1.tech)
               {
                  _loc4_ = _loc2_.desc;
               }
            }
         }
         else
         {
            _loc4_ = param1.description;
         }
         description.htmlText = "<FONT COLOR='#ffaa44' size='16'>" + param1.upgradeName + "</FONT>\n";
         description.htmlText += _loc4_;
         description.y = nameText.y + nameText.height;
         nameText.visible = true;
         if (param1.level > 0)
         {
            _loc6_ = description.y + description.height + 25;
            _loc8_ = param1.mineralType1;
            _loc5_ = getMineralType1Cost(param1.level, param1.playerLevel);
            if (_loc5_ > 0 && _loc8_ != null && param1.playerLevel < param1.level)
            {
               _loc9_ = hasRequiredLevel(param1.level, me.level) ? "" : "<FONT COLOR='#ff4444' SIZE='18'>Requires level " + getRequiredLevel(param1.level) + "</FONT>\n";
               _loc4_ = _loc9_ + _loc4_;
               mineralType1Cost = new PriceCommodities(g, _loc8_, _loc5_, "Verdana", 12);
               mineralType1Cost.x = 2;
               mineralType1Cost.y = _loc6_;
               mineralType1Cost.visible = true;
               upgradeInfo.addChild(mineralType1Cost);
               _loc6_ += mineralType1Cost.height;
               _loc7_ = param1.mineralType2;
               _loc3_ = getMineralType2Cost(param1.level);
               if (_loc3_ > 0 && _loc7_ != null)
               {
                  mineralType2Cost = new PriceCommodities(g, _loc7_, _loc3_, "Verdana", 12);
                  mineralType2Cost.x = 2;
                  mineralType2Cost.y = _loc6_;
                  mineralType2Cost.visible = true;
                  upgradeInfo.addChild(mineralType2Cost);
                  _loc6_ += 16;
               }
            }
         }
         buyWithResourcesButton.y = _loc6_ + 25;
         buyWithFluxButton.y = _loc6_ + 25;
      }

      private function removeMineralCosts():void
      {
         if (mineralType1Cost != null && upgradeInfo.contains(mineralType1Cost))
         {
            upgradeInfo.removeChild(mineralType1Cost);
         }
         if (mineralType2Cost != null && upgradeInfo.contains(mineralType2Cost))
         {
            upgradeInfo.removeChild(mineralType2Cost);
         }
         if (mineralType3Cost != null && upgradeInfo.contains(mineralType3Cost))
         {
            upgradeInfo.removeChild(mineralType3Cost);
         }
         if (mineralType4Cost != null && upgradeInfo.contains(mineralType4Cost))
         {
            upgradeInfo.removeChild(mineralType4Cost);
         }
      }

      private function buyResetPackage(param1:TouchEvent):void
      {
         var e:TouchEvent = param1;
         g.creditManager.refresh(function():void
            {
               var resets:int = 10;
               var confirmBox:CreditBuyBox = new CreditBuyBox(g, 1000, "Do you want to buy " + resets + " resets?");
               confirmBox.addEventListener("accept", function():void
                  {
                     g.rpc("buyResetPackage", function(param1:Message):void
                        {
                           if (param1.getBoolean(0))
                           {
                              g.me.freeResets += resets;
                              g.showMessageDialog("Your purchase was successful! \nYou have " + g.me.freeResets + " resets.");
                           }
                        });
                     confirmBox.removeEventListeners();
                     g.removeChildFromOverlay(confirmBox, true);
                     resetPackageButton.enabled = true;
                  });
               confirmBox.addEventListener("close", function():void
                  {
                     confirmBox.removeEventListeners();
                     g.removeChildFromOverlay(confirmBox, true);
                     resetPackageButton.enabled = true;
                  });
               g.addChildToOverlay(confirmBox, true);
            });
      }

      private function buyReset(param1:TouchEvent):void
      {
         var e:TouchEvent = param1;
         if (g.me.nrOfUpgrades[0] == 0)
         {
            return;
         }
         g.creditManager.refresh(function():void
            {
               confirmBox = new LootPopupConfirmMessage();
               var cost:int = 200;
               g.rpc("getTotalUpgradeCost", function(param1:Message):void
                  {
                     var _loc6_:int = 0;
                     var _loc3_:String = null;
                     var _loc2_:int = 0;
                     var _loc4_:LootItem = null;
                     var _loc5_:int = param1.length;
                     confirmBox.text = "Are you sure you want to <FONT COLOR='#aa8822'>reset</FONT> all upgrades for <FONT COLOR='#aa8822'>" + cost + " flux</FONT>? The entire resource cost for this ship will be refunded." + "\n\nYou have: <FONT COLOR='#aa8822'>" + CreditManager.FLUX + " flux</FONT>\n\nYou will get back:\n\n";
                     _loc6_ = 0;
                     while (_loc6_ < _loc5_)
                     {
                        _loc3_ = param1.getString(_loc6_);
                        _loc2_ = param1.getInt(_loc6_ + 1);
                        _loc4_ = new LootItem("Commodities", _loc3_, _loc2_);
                        if (_loc4_.name == "Flux")
                        {
                           fluxReset = _loc2_;
                        }
                        confirmBox.addItem(_loc4_);
                        _loc6_ += 2;
                     }
                     if (me.freeResets > 0)
                     {
                        confirmBox.text = "Are you sure you want to <FONT COLOR='#aa8822'> reset </FONT> all upgrades? You have <FONT COLOR='#aa8822'>" + me.freeResets + " free</FONT> reset remaining. The entire resource cost will be refunded." + "\n\nYou have: <FONT COLOR='#aa8822'>" + CreditManager.FLUX + " flux</FONT>\n\nYou will get back:\n\n";
                        confirmBox.confirmButton.enabled = true;
                     }
                     else if (cost > CreditManager.FLUX)
                     {
                        confirmBox.confirmButton.enabled = false;
                     }
                     g.addChildToOverlay(confirmBox, true);
                     confirmBox.addEventListener("accept", onAcceptReset);
                     confirmBox.addEventListener("close", onCloseReset);
                  });
            });
      }

      public function resetTechSkills(param1:Message):void
      {
         var t:TechSkill;
         var tb:TechBar;
         var m:Message = param1;
         if (m.getBoolean(0))
         {
            g.creditManager.refresh();
            g.me.nrOfUpgrades = Vector.<int>([0, 0, 0, 0, 0, 0, 0]);
            _nrOfUpgrades = g.me.nrOfUpgrades;
            if (g.me.freeResets <= 0)
            {
               Game.trackEvent("used flux", "bought reset", "level " + g.me.level, 200);
            }
            else
            {
               g.me.freeResets -= 1;
            }
            for each (t in g.me.techSkills)
            {
               t.level = Player.getSkinTechLevel(t.tech, g.me.activeSkin);
               t.activeEliteTech = "";
               t.activeEliteTechLevel = 0;
               t.eliteTechs = new Vector.<EliteTechSkill>();
            }
            for each (tb in techBars)
            {
               tb.reset();
            }
            myCargo.reloadCargoFromServer(function():void
               {
                  upgradeInfo.visible = false;
                  enableTouch();
                  resetButton.enabled = false;
               });
            switchEliteTechButton.visible = false;
            buyWithFluxButton.visible = false;
            buyWithResourcesButton.visible = false;
            if (fluxReset > 0)
            {
               Game.trackEvent("used flux", "bought elite upgrade", "reset", -fluxReset);
               trace("tracked flux reset: " + -fluxReset);
            }
            g.showErrorDialog("Reset complete! All resources spent on this ship has been refunded. You will now take off from the upgrade station.", false, function():void
               {
                  g.me.leaveBody();
               });
         }
         else
         {
            enableTouch();
            g.showErrorDialog(m.getString(1));
         }
      }

      private function sendResetRequest():void
      {
         g.rpc("resetUpgrades", resetTechSkills);
      }

      private function onAcceptReset(param1:Event):void
      {
         disableTouch();
         sendResetRequest();
         resetButton.enabled = false;
         g.removeChildFromOverlay(confirmBox, true);
         confirmBox.removeEventListeners();
      }

      private function onCloseReset(param1:Event):void
      {
         g.removeChildFromOverlay(confirmBox, true);
         resetButton.enabled = true;
         confirmBox.removeEventListeners();
      }

      private function cheat(param1:TouchEvent):void
      {
         var _loc2_:Message = null;
         disableTouch();
         cheatButton.enabled = false;
         cheatButton.visible = false;
         if (eliteTechSelectedForUpgrade != null)
         {
            _loc2_ = g.createMessage("cheatUpgrade");
            _loc2_.add(eliteTechSelectedForUpgrade.table);
            _loc2_.add(eliteTechSelectedForUpgrade.tech);
            _loc2_.add(eliteTechSelectedForUpgrade.techSkill.activeEliteTech);
            _loc2_.add(100);
            g.rpcMessage(_loc2_, upgradedEliteTech);
         }
      }

      private function buyUpgrade(param1:TouchEvent):void
      {
         var _loc3_:Message = null;
         var _loc2_:int = 0;
         disableTouch();
         buyWithResourcesButton.enabled = false;
         buyWithFluxButton.enabled = false;
         if (techSelectedForUpgrade != null)
         {
            _loc3_ = g.createMessage("upgrade");
            _loc3_.add(techSelectedForUpgrade.table);
            _loc3_.add(techSelectedForUpgrade.tech);
            _loc3_.add(techSelectedForUpgrade.level);
            Game.trackEvent("upgrades", "Techs", techSelectedForUpgrade.name + " " + techSelectedForUpgrade.level, g.me.level);
            g.rpcMessage(_loc3_, upgraded);
         }
         else if (eliteTechSelectedForUpgrade != null)
         {
            _loc3_ = g.createMessage("upgradeEliteTech");
            _loc3_.add(eliteTechSelectedForUpgrade.table);
            _loc3_.add(eliteTechSelectedForUpgrade.tech);
            _loc3_.add(eliteTechSelectedForUpgrade.techSkill.activeEliteTech);
            _loc3_.add(eliteTechSelectedForUpgrade.techSkill.activeEliteTechLevel + 1);
            _loc2_ = eliteSlider.value;
            autoUpdateEliteUpgradeStartValue = _loc2_;
            _loc3_.add(_loc2_);
            Game.trackEvent("upgrades", "EliteTechs", eliteTechSelectedForUpgrade.name + " " + eliteTechSelectedForUpgrade.level + " to " + _loc2_, g.me.level);
            g.rpcMessage(_loc3_, upgradedEliteTech);
         }
      }

      private function buyUpgradeWithFlux(param1:TouchEvent):void
      {
         disableTouch();
         buyWithResourcesButton.enabled = false;
         buyWithFluxButton.enabled = false;
         var _loc2_:Message = g.createMessage("buyUpgradeWithFlux");
         _loc2_.add(techSelectedForUpgrade.table);
         _loc2_.add(techSelectedForUpgrade.tech);
         _loc2_.add(techSelectedForUpgrade.level);
         g.rpcMessage(_loc2_, upgraded);
      }

      private function buyEliteUpgradeWithFlux(param1:TouchEvent):void
      {
         isUpgradingEliteTech = true;
         disableTouch();
         buyWithResourcesButton.enabled = false;
         buyWithFluxButton.enabled = false;
         var _loc4_:Message = g.createMessage("buyEliteTechUpgradeWithFlux");
         _loc4_.add(eliteTechSelectedForUpgrade.table);
         _loc4_.add(eliteTechSelectedForUpgrade.tech);
         _loc4_.add(eliteTechSelectedForUpgrade.techSkill.activeEliteTech);
         var _loc3_:int = eliteTechSelectedForUpgrade.techSkill.activeEliteTechLevel + 1;
         var _loc2_:* = _loc3_;
         if (eliteSlider.value == 100)
         {
            _loc2_ = 100;
         }
         _loc4_.add(_loc3_);
         _loc4_.add(_loc2_);
         g.rpcMessage(_loc4_, upgradedEliteTech);
      }

      private function upgradedEliteTech(param1:Message):void
      {
         var m:Message = param1;
         if (m.getBoolean(0))
         {
            Console.write("Upgrade successful!");
            SoundLocator.getService().play("7zeIcPFb-UWzgtR_3nrZ8Q");
            g.creditManager.refresh();
            myCargo.reloadCargoFromServer(function():void
               {
                  var tech:String;
                  var eliteTech:String;
                  var level:int;
                  var eti:EliteTechIcon;
                  var ts:TechSkill;
                  var tween:TweenMax;
                  upgradeInfo.visible = false;
                  disableTouch();
                  tech = m.getString(1);
                  eliteTech = m.getString(2);
                  level = m.getInt(3);
                  eti = eliteTechSelectedForUpgrade;
                  if (eliteTechSelectedForUpgrade.tech == tech)
                  {
                     ts = eliteTechSelectedForUpgrade.techSkill;
                     ts.activeEliteTech = eliteTech;
                     ts.activeEliteTechLevel = level;
                     eliteTechSelectedForUpgrade.level = level;
                     ts.addEliteTechData(eliteTech, level);
                     eliteTechSelectedForUpgrade.update(level);
                  }
                  tween = TweenMax.from(eti, 1, {
                           "scaleX": 3,
                           "scaleY": 3,
                           "rotation": 3.141592653589793 * 8,
                           "delay": 0.1,
                           "onComplete": function():void
                           {
                              eti.update(level);
                              if (autoUpdateEliteUpgradeStartValue == level)
                              {
                                 isUpgradingEliteTech = false;
                                 updateEliteTechUpgradeInfo(eti);
                                 eliteTechSelectedForUpgrade = eti;
                                 if (level != 100)
                                 {
                                    buyWithFluxButton.enabled = true;
                                    buyWithResourcesButton.enabled = true;
                                    buyWithFluxButton.visible = true;
                                    buyWithResourcesButton.visible = true;
                                    switchEliteTechButton.visible = true;
                                 }
                                 enableTouch();
                                 updateEliteUpgradeLevels();
                                 updateUpgradeInfo();
                                 if (eliteSlider.minimum < 100)
                                 {
                                    eliteSlider.value = eliteSlider.minimum;
                                 }
                              }
                              else if (autoUpdateEliteUpgradeStartValue > level)
                              {
                                 eliteTechSelectedForUpgrade = eti;
                                 buyEliteUpgradeWithFlux(null);
                                 hideEliteSlider();
                                 return;
                              }
                           }
                        });
               });
         }
         else
         {
            if (m.length > 1)
            {
               g.showErrorDialog(m.getString(1));
            }
            enableTouch();
         }
      }

      private function upgraded(param1:Message):void
      {
         var m:Message = param1;
         if (m.getBoolean(0))
         {
            Console.write("Upgrade successful!");
            SoundLocator.getService().play("7zeIcPFb-UWzgtR_3nrZ8Q");
            g.creditManager.refresh();
            _nrOfUpgrades[0]++;
            _nrOfUpgrades[techSelectedForUpgrade.level]++;
            myCargo.reloadCargoFromServer(function():void
               {
                  var tween:TweenMax;
                  upgradeInfo.visible = false;
                  tween = TweenMax.from(techSelectedForUpgrade, 1, {
                           "scaleX": 3,
                           "scaleY": 3,
                           "rotation": 3.141592653589793 * 8,
                           "delay": 0.1,
                           "onComplete": function():void
                           {
                              techSelectedForUpgrade.upgrade();
                              techSelectedForUpgrade = null;
                              enableTouch();
                           }
                        });
               });
         }
         else
         {
            if (m.length > 1)
            {
               g.showErrorDialog(m.getString(1));
            }
            enableTouch();
            techSelectedForUpgrade = null;
         }
         if (g.me.nrOfUpgrades[0] == 0)
         {
            resetButton.enabled = false;
         }
         buyWithFluxButton.enabled = true;
         buyWithResourcesButton.enabled = true;
         buyWithResourcesButton.visible = false;
         buyWithFluxButton.visible = false;
         if (!isUpgradingEliteTech)
         {
            resetButton.visible = true;
         }
      }

      public function exit():void
      {
         autoUpdateEliteUpgradeStartValue = 0;
         dispose();
      }

      override public function dispose():void
      {
         for each (var _loc1_:* in techBars)
         {
            _loc1_.dispose();
         }
         isUpgradingEliteTech = false;
         autoUpdateEliteUpgradeStartValue = 0;
         techBars = null;
         removeEventListeners();
      }

      private function disableTouch():void
      {
         hideEliteSlider();
         for each (var _loc1_:* in techBars)
         {
            _loc1_.touchable = false;
         }
         resetButton.enabled = false;
         switchEliteTechButton.enabled = false;
      }

      private function enableTouch():void
      {
         for each (var _loc1_:* in techBars)
         {
            _loc1_.touchable = true;
         }
         resetButton.enabled = true;
         switchEliteTechButton.enabled = true;
      }

      private function canAfford(param1:TechLevelIcon):Boolean
      {
         return canAffordMineralType1(param1) && canAffordMineralType2(param1);
      }

      private function canAffordET(param1:EliteTechIcon):Boolean
      {
         return canAffordETMineralType1(param1) && canAffordETMineralType2(param1);
      }

      private function canAffordETMineralType1(param1:EliteTechIcon):Boolean
      {
         return myCargo.hasMinerals(param1.mineralType1, EliteTechs.getResource1Cost(param1.level + 1));
      }

      private function canAffordETMineralType2(param1:EliteTechIcon):Boolean
      {
         param1.updateMineralType2();
         return myCargo.hasMinerals(param1.mineralType2, EliteTechs.getResource2Cost(param1.level + 1));
      }

      private function canAffordMineralType1(param1:TechLevelIcon):Boolean
      {
         return myCargo.hasMinerals(param1.mineralType1, getMineralType1Cost(param1.level, param1.playerLevel));
      }

      private function canAffordMineralType2(param1:TechLevelIcon):Boolean
      {
         if (param1.mineralType2 == null)
         {
            return true;
         }
         return myCargo.hasMinerals(param1.mineralType2, getMineralType2Cost(param1.level));
      }

      private function getMineralType1Cost(param1:int, param2:int):Number
      {
         return 400 * nrOfUpgrades[0] + Math.pow(4 * nrOfUpgrades[0], 2) + 200 * Math.pow(2, param1);
      }

      private function getMineralType2Cost(param1:int):int
      {
         return 160 + nrOfUpgrades[param1] * 520 + param1 * 40;
      }
   }
}
