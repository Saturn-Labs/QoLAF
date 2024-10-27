package core.states.gameStates
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Sine;
   import core.artifact.Artifact;
   import core.artifact.ArtifactCargoBox;
   import core.artifact.ArtifactFactory;
   import core.credits.CreditManager;
   import core.hud.components.ButtonExpandableHud;
   import core.hud.components.ToolTip;
   import core.hud.components.dialogs.CreditBuyBox;
   import core.player.FleetObj;
   import core.scene.Game;
   import core.ship.ShipFactory;
   import data.IDataManager;
   import generics.Localize;
   import playerio.Message;
   import sound.SoundLocator;
   import starling.display.Button;
   import starling.display.Image;
   import starling.display.MovieClip;
   import starling.display.Sprite;
   import starling.text.TextField;
   import starling.text.TextFormat;
   import textures.TextureLocator;

   public class PodState extends PlayState
   {
      private var bgr:Image;

      private var tracks1:Image;

      private var tracks2:Image;

      private const TRACK1_Y:Number = 140;

      private const TRACK2_Y:Number = 340;

      private var podsContainer:Sprite;

      private var buttonContainer:Sprite;

      private var lootContainer:Sprite;

      private var buy1Button:Button;

      private var buy10Button:Button;

      private var boughtPods:int = 0;

      private var nrOfPodsText:TextField;

      private var closeButton:ButtonExpandableHud;

      private var pods:Vector.<Pod>;

      private var floatTween:TweenMax;

      private var currentPod:Pod;

      public function PodState(param1:Game)
      {
         pods = new Vector.<Pod>();
         super(param1);
         textureManager = TextureLocator.getService();
      }

      override public function enter():void
      {
         var image:Image;
         var lootBgr:Image;
         var countBgr:Image;
         var shipBgr:Image;
         var dataManager:IDataManager;
         var skin:Object;
         var fleetObj:FleetObj;
         var ship:Object;
         var obj2:Object;
         var shipImage:MovieClip;
         var message:Message;
         super.enter();
         drawBlackBackground();
         tracks1 = new Image(textureManager.getTextureGUIByTextureName("pod_tracks.png"));
         tracks1.pivotX = tracks1.width / 2;
         tracks1.rotation = 3.141592653589793;
         tracks1.x = 422.5;
         tracks1.y = 140;
         addChild(tracks1);
         tracks2 = new Image(textureManager.getTextureGUIByTextureName("pod_tracks.png"));
         tracks2.pivotX = tracks2.width / 2;
         tracks2.x = 422.5;
         tracks2.y = 340;
         addChild(tracks2);
         bgr = new Image(textureManager.getTextureGUIByTextureName("pod_bgr.png"));
         addChild(bgr);
         image = new Image(textureManager.getTextureGUIByTextureName("pod_rails.png"));
         image.x = 40;
         image.y = 85;
         addChild(image);
         image = new Image(textureManager.getTextureGUIByTextureName("pod_sleigh.png"));
         image.x = 280;
         image.y = 90;
         addChild(image);
         closeButton = new ButtonExpandableHud(function():void
            {
               sm.changeState(new RoamingState(g));
            }, Localize.t("close"));
         closeButton.x = bgr.width - 56 - closeButton.width;
         closeButton.y = 10;
         addChild(closeButton);
         podsContainer = new Sprite();
         addChild(podsContainer);
         buttonContainer = new Sprite();
         addChild(buttonContainer);
         lootBgr = new Image(textureManager.getTextureGUIByTextureName("pod_loot_display.png"));
         lootBgr.y = 35;
         lootBgr.x = 290;
         addChild(lootBgr);
         countBgr = new Image(textureManager.getTextureGUIByTextureName("pod_count_display.png"));
         countBgr.y = 56;
         countBgr.x = 670;
         addChild(countBgr);
         shipBgr = new Image(textureManager.getTextureGUIByTextureName("pod_ship_display.png"));
         shipBgr.y = 47;
         shipBgr.x = 40;
         addChild(shipBgr);
         lootContainer = new Sprite();
         addChild(lootContainer);
         buy1Button = new Button(textureManager.getTextureGUIByTextureName("pod_buy_1_button.png"), Localize.t("BUY 1"), null, textureManager.getTextureGUIByTextureName("pod_buy_1_button_hover.png"), textureManager.getTextureGUIByTextureName("pod_buy_1_button_disabled.png"));
         buy1Button.x = 265;
         buy1Button.y = 428;
         buy1Button.textFormat.color = 16777215;
         buy1Button.textFormat.font = "DAIDRR";
         buy1Button.enabled = false;
         buttonContainer.addChild(buy1Button);
         buy1Button.addEventListener("triggered", function():void
            {
               var buyConfirm:CreditBuyBox = new CreditBuyBox(g, CreditManager.getCostPods(), Localize.t("You will recieve 1 pod."));
               buyConfirm.addEventListener("accept", function():void
                  {
                     buyPods(1);
                     buyConfirm.removeEventListeners();
                  });
               buyConfirm.addEventListener("close", function():void
                  {
                     buyConfirm.removeEventListeners();
                     buy1Button.enabled = true;
                  });
               g.addChildToOverlay(buyConfirm);
            });
         new ToolTip(g, buy1Button, Localize.t("Awesome! :D But if you buy 10 pods you will have a greater chance to get a rare reward."), null, "PodState");
         buy10Button = new Button(textureManager.getTextureGUIByTextureName("pod_buy_10_button.png"), Localize.t("BUY 10"), null, textureManager.getTextureGUIByTextureName("pod_buy_10_button_hover.png"), textureManager.getTextureGUIByTextureName("pod_buy_10_button_disabled.png"));
         buy10Button.x = 415;
         buy10Button.y = 428;
         buy10Button.textFormat.color = 16777215;
         buy10Button.textFormat.font = "DAIDRR";
         buy10Button.enabled = false;
         buttonContainer.addChild(buy10Button);
         buy10Button.addEventListener("triggered", function():void
            {
               var buyConfirm:CreditBuyBox = new CreditBuyBox(g, CreditManager.getCostPods() * 10, Localize.t("You will recieve 10 pods."));
               buyConfirm.addEventListener("accept", function():void
                  {
                     buyPods(10);
                     buyConfirm.removeEventListeners();
                  });
               buyConfirm.addEventListener("close", function():void
                  {
                     buyConfirm.removeEventListeners();
                     buy10Button.enabled = true;
                  });
               g.addChildToOverlay(buyConfirm);
            });
         new ToolTip(g, buy10Button, Localize.t("Good choice! 8D"), null, "PodState");
         nrOfPodsText = new TextField(100, 30, "---", new TextFormat("DAIDRR", 12, 11184810));
         nrOfPodsText.x = 660;
         nrOfPodsText.y = 55;
         addChild(nrOfPodsText);
         new ToolTip(g, nrOfPodsText, Localize.t("Number of pods that you have left to open."), null, "PodState");
         dataManager = g.dataManager;
         skin = dataManager.loadKey("Skins", g.me.activeSkin);
         fleetObj = g.me.getActiveFleetObj();
         ship = dataManager.loadKey("Ships", skin.ship);
         obj2 = dataManager.loadKey("Images", ship.bitmap);
         shipImage = new MovieClip(textureManager.getTexturesMainByTextureName(obj2.textureName));
         shipImage.pivotX = shipImage.width / 2;
         shipImage.pivotY = shipImage.height / 2;
         shipImage.y = 67;
         shipImage.x = 85;
         shipImage.scaleX = shipImage.scaleY = shipImage.width > 35 ? 35 / shipImage.width : shipImage.scaleX;
         addChild(shipImage);
         shipImage.filter = ShipFactory.createPlayerShipColorMatrixFilter(fleetObj);
         new ToolTip(g, shipImage, "<FONT COLOR=\"#FFFFFF\">" + skin.name + "</FONT> : " + Localize.t("Your current ship, any weapon that is found will be tied to this ship."), null, "PodState");
         g.hud.show = false;
         message = g.createMessage("getPodCount");
         g.rpcMessage(message, initPodCount);
         loadCompleted();
      }

      private function initPodCount(param1:Message):void
      {
         var pod:Pod;
         var m:Message = param1;
         boughtPods = m.getInt(0);
         var i:int = 0;
         while (i < boughtPods)
         {
            pod = new Pod(g);
            pods.push(pod);
            i++;
         }
         UpdateNrOfPods();
         if (boughtPods > 0)
         {
            buy1Button.enabled = false;
            buy10Button.enabled = false;
            pod = pods[0];
            podsContainer.addChild(pod);
            animateReadyPod(pod, function():void
               {
                  readyOpenPod(m);
               });
         }
         else
         {
            buy1Button.enabled = true;
            buy10Button.enabled = true;
         }
      }

      private function buyPods(param1:int):void
      {
         var i:int;
         var pod:Pod;
         var count:int = param1;
         var message:Message = g.createMessage("buyPod", count);
         g.rpcMessage(message, readyOpenPod);
         Game.trackEvent("used flux", "pod", count + "st", CreditManager.getCostPods() * count);
         i = 0;
         while (i < count)
         {
            pod = new Pod(g);
            pods.push(pod);
            i++;
         }
         boughtPods += count;
         pod = pods[0];
         buy1Button.enabled = false;
         buy10Button.enabled = false;
         podsContainer.addChild(pod);
         animateReadyPod(pod, function():void
            {
            });
      }

      private function animateReadyPod(param1:Pod, param2:Function):void
      {
         var pod:Pod = param1;
         var callback:Function = param2;
         pod.y = 248;
         soundManager.preCacheSound("eucUcmDqTUudHmw_S7U5oQ");
         soundManager.preCacheSound("nNNvkjb7O0ezA29C19_kmQ");
         soundManager.preCacheSound("d9sleGULzUCNGImfHOdkuA");
         soundManager.preCacheSound("f5msdkJp8EmqT0gXFokkKg");
         TweenMax.fromTo(pod, 1, {"x": g.stage.stageWidth / 2 + 1000 + bgr.width / 2}, {
                  "x": g.stage.stageWidth / 2 + bgr.width / 2,
                  "onComplete": callback
               });
         pod.rotation = -0.02;
         floatTween = TweenMax.to(pod, 1, {
                  "rotation": 0.02,
                  "repeat": 30,
                  "yoyo": true,
                  "ease": Sine.easeInOut,
                  "onComplete": function():void
                  {
                     pod.rotation = 0;
                     callback();
                  }
               });
      }

      private function animateInPod(param1:Pod, param2:Function):void
      {
         var pod:Pod = param1;
         var callback:Function = param2;
         pod.y = 248;
         currentPod = pod;
         TweenMax.fromTo(pod, 1, {"x": pod.x}, {
                  "x": 400,
                  "onComplete": function():void
                  {
                     animateCloseTracks(function():void
                        {
                           callback();
                        });
                  }
               });
      }

      private function animateOutPod(param1:Pod, param2:Function):void
      {
         var pod:Pod = param1;
         var callback:Function = param2;
         pod.y = 248;
         pod.animateClose();
         animateCloseTracks(function():void
            {
               animateOpenTracks();
               TweenMax.fromTo(pod, 1, {"x": pod.x}, {
                        "x": -1000,
                        "onComplete": function():void
                        {
                           callback();
                        }
                     });
            }, false);
      }

      private function animateOpenPod(param1:Pod, param2:Function):void
      {
         var pod:Pod = param1;
         var callback:Function = param2;
         pod.animateOpen();
         animateOpenTracks(function():void
            {
               TweenMax.delayedCall(2, callback);
            });
      }

      private function animateOpenTracks(param1:Function = null):void
      {
         var callback:Function = param1;
         soundManager.play("eucUcmDqTUudHmw_S7U5oQ");
         TweenMax.fromTo(tracks1, 0.5, {"y": tracks1.y}, {
                  "y": tracks1.y - 40,
                  "onComplete": function():void
                  {
                     soundManager.stop("eucUcmDqTUudHmw_S7U5oQ");
                     if (Boolean(callback))
                     {
                        callback();
                     }
                  }
               });
         TweenMax.fromTo(tracks2, 0.5, {"y": tracks2.y}, {"y": tracks2.y + 23});
      }

      private function animateCloseTracks(param1:Function = null, param2:Boolean = true):void
      {
         var callback:Function = param1;
         var snap:Boolean = param2;
         var delay:int = 0;
         if (snap)
         {
            delay = 0.5;
         }
         TweenMax.delayedCall(delay, function():void
            {
               soundManager.play("eucUcmDqTUudHmw_S7U5oQ");
               TweenMax.fromTo(tracks1, 0.5, {"y": tracks1.y}, {
                        "y": tracks1.y + 40,
                        "onComplete": function():void
                        {
                           soundManager.stop("eucUcmDqTUudHmw_S7U5oQ");
                           if (snap)
                           {
                              if (currentPod)
                              {
                                 TweenMax.to(currentPod, 0.05, {"rotation": 0});
                              }
                              soundManager.play("nNNvkjb7O0ezA29C19_kmQ");
                              floatTween.kill();
                           }
                           if (Boolean(callback))
                           {
                              callback();
                           }
                        }
                     });
               TweenMax.fromTo(tracks2, 0.5, {"y": tracks2.y}, {"y": tracks2.y - 23});
            });
      }

      private function readyOpenPod(param1:Message):void
      {
         var m:Message = param1;
         var pod:Pod = pods[0];
         podsContainer.addChild(pod);
         g.blockHotkeys = false;
         closeButton.enabled = true;
         UpdateNrOfPods();
         animateInPod(pod, function():void
            {
               var pod2:Pod;
               if (boughtPods > 1)
               {
                  pod2 = pods[1];
                  podsContainer.addChild(pod2);
                  animateReadyPod(pod2, function():void
                     {
                     });
               }
               pod.listenForClick(createClickOpenPod(pod));
            });
         g.creditManager.refresh();
         g.hud.buyFluxButton.updateCredits();
      }

      private function createClickOpenPod(param1:Pod):Function
      {
         var pod:Pod = param1;
         return (function():*
            {
               var internalFunc:Function;
               return internalFunc = function():void
               {
                  var message:Message;
                  UpdateNrOfPods();
                  closeButton.enabled = false;
                  g.blockHotkeys = true;
                  soundManager.play("f5msdkJp8EmqT0gXFokkKg");
                  message = g.createMessage("openPod");
                  g.rpcMessage(message, function(param1:Message):void
                     {
                        boughtPods--;
                        onOpenPod(param1, pod);
                     });
               };
            })();
      }

      private function onOpenPod(param1:Message, param2:Pod):void
      {
         SoundLocator.getService().play("7zeIcPFb-UWzgtR_3nrZ8Q");
         showLoot(param1, param2);
         openPod(param1, param2);
      }

      private function openPod(param1:Message, param2:Pod):void
      {
         var m:Message = param1;
         var pod:Pod = param2;
         animateOpenPod(pod, function():void
            {
               animateOutPod(pod, function():void
                  {
                     pods.shift().removeFromParent(true);
                     if (boughtPods == 0)
                     {
                        openingComplete();
                        return;
                     }
                     readyOpenPod(m);
                  });
            });
      }

      private function openingComplete():void
      {
         g.blockHotkeys = false;
         closeButton.enabled = true;
         boughtPods = 0;
         UpdateNrOfPods();
         buy1Button.enabled = true;
         buy10Button.enabled = true;
      }

      private function showLoot(param1:Message, param2:Pod):void
      {
         var textColor:uint;
         var preview3:Image;
         var nameText:TextField;
         var weapon:Object;
         var preview1:Image;
         var skin:Object;
         var ship:Object;
         var preview2:MovieClip;
         var commodity:Object;
         var m:Message = param1;
         var pod:Pod = param2;
         var success:Boolean = m.getBoolean(0);
         var table:String = m.getString(1);
         var name:String = m.getString(2);
         var key:String = m.getString(3);
         var converted:Boolean = m.getBoolean(4);
         var count:int = m.getInt(5);
         var quality:String = m.getString(6);
         if (!success)
         {
            if (m.length > 1)
            {
               g.showErrorDialog(m.getString(1));
               return;
            }
            g.showErrorDialog(Localize.t("The pod couldn't be opened."));
            return;
         }
         lootContainer.visible = true;
         lootContainer.removeChildren(0, -1, true);
         lootContainer.x = 418;
         lootContainer.y = 110;
         ToolTip.disposeType("artifactBox");
         textColor = 16777215;
         if (quality == "rare")
         {
            textColor = 16729343;
            soundManager.play("d9sleGULzUCNGImfHOdkuA");
         }
         else if (quality == "legendary")
         {
            soundManager.play("d9sleGULzUCNGImfHOdkuA");
            textColor = 16761634;
         }
         pod.animateLootText(Localize.t(quality.toUpperCase()), textColor);
         pod.animateSpinColor(textColor);
         if (converted)
         {
            preview3 = new Image(textureManager.getTextureGUIByTextureName("credit_medium.png"));
            preview3.alignPivot();
            preview3.y = -34;
            lootContainer.addChild(preview3);
            nameText = new TextField(200, 30, "", new TextFormat("DAIDRR"));
            nameText.x = preview3.x;
            nameText.format.color = textColor;
            nameText.format.horizontalAlign = "center";
            nameText.text = count + " Flux";
            nameText.format.size = 14;
            nameText.pivotX = nameText.width / 2;
            lootContainer.addChild(nameText);
            TweenMax.fromTo(lootContainer, 0.5, {
                     "y": 300,
                     "alpha": 0
                  }, {
                     "y": lootContainer.y,
                     "alpha": 1
                  });
         }
         else if (table == "Artifacts")
         {
            ArtifactFactory.createArtifact(key, g, g.me, function(param1:Artifact):void
               {
                  var _loc2_:ArtifactCargoBox = new ArtifactCargoBox(g, param1);
                  _loc2_.update();
                  _loc2_.alignPivot();
                  _loc2_.scaleX = _loc2_.scaleY = 1.2;
                  _loc2_.y = -34;
                  lootContainer.addChild(_loc2_);
                  nameText = new TextField(200, 30, "", new TextFormat("DAIDRR"));
                  nameText.x = _loc2_.x;
                  nameText.format.color = textColor;
                  nameText.text = name;
                  nameText.format.size = 14;
                  nameText.format.horizontalAlign = "center";
                  nameText.pivotX = nameText.width / 2;
                  lootContainer.addChild(nameText);
                  TweenMax.fromTo(lootContainer, 0.5, {
                           "y": 300,
                           "alpha": 0
                        }, {
                           "y": lootContainer.y,
                           "alpha": 1
                        });
                  g.me.artifacts.push(param1);
               });
         }
         else if (table == "Weapons")
         {
            weapon = g.dataManager.loadKey(table, key);
            preview1 = new Image(textureManager.getTextureGUIByKey(weapon.techIcon));
            preview1.alignPivot();
            preview1.y = -34;
            lootContainer.addChild(preview1);
            nameText = new TextField(200, 30, "", new TextFormat("DAIDRR"));
            nameText.x = preview1.x;
            nameText.format.color = textColor;
            nameText.format.horizontalAlign = "center";
            nameText.format.size = 14;
            nameText.text = name;
            nameText.pivotX = nameText.width / 2;
            lootContainer.addChild(nameText);
            TweenMax.fromTo(lootContainer, 0.5, {
                     "y": 300,
                     "alpha": 0
                  }, {
                     "y": lootContainer.y,
                     "alpha": 1
                  });
         }
         else if (table == "Skins")
         {
            skin = g.dataManager.loadKey(table, key);
            ship = g.dataManager.loadKey("Ships", skin.ship);
            preview2 = new MovieClip(textureManager.getTexturesMainByKey(ship.bitmap));
            preview2.alignPivot();
            preview2.y = -34;
            lootContainer.addChild(preview2);
            nameText = new TextField(200, 30, "", new TextFormat("DAIDRR"));
            nameText.x = preview2.x;
            nameText.format.color = textColor;
            nameText.format.horizontalAlign = "center";
            nameText.format.size = 14;
            nameText.text = name;
            nameText.pivotX = nameText.width / 2;
            lootContainer.addChild(nameText);
            TweenMax.fromTo(lootContainer, 0.5, {
                     "y": 300,
                     "alpha": 0
                  }, {
                     "y": lootContainer.y,
                     "alpha": 1
                  });
         }
         else if (table == "PayVaultItems")
         {
            nameText = new TextField(200, 30, "", new TextFormat("DAIDRR", 16));
            nameText.format.color = textColor;
            nameText.format.horizontalAlign = "center";
            nameText.text = count + " " + name;
            nameText.pivotX = nameText.width / 2;
            lootContainer.addChild(nameText);
            TweenMax.fromTo(lootContainer, 0.5, {
                     "y": 300,
                     "alpha": 0
                  }, {
                     "y": lootContainer.y,
                     "alpha": 1
                  });
         }
         else
         {
            commodity = g.dataManager.loadKey(table, key);
            preview3 = new Image(textureManager.getTextureGUIByKey(commodity.bitmap));
            preview3.alignPivot("left", "center");
            lootContainer.addChild(preview3);
            nameText = new TextField(10, 10, "", new TextFormat("DAIDRR"));
            nameText.format.color = textColor;
            nameText.format.horizontalAlign = "center";
            nameText.text = count + " " + name;
            nameText.autoSize = "bothDirections";
            nameText.pivotX = nameText.width / 2 - preview3.width - 5;
            lootContainer.addChild(nameText);
            preview3.x = nameText.x - nameText.width / 2;
            preview3.y = nameText.height / 2;
            lootContainer.y += 5;
            TweenMax.fromTo(lootContainer, 0.5, {
                     "y": 300,
                     "alpha": 0
                  }, {
                     "y": lootContainer.y,
                     "alpha": 1
                  });
         }
      }

      private function UpdateNrOfPods():void
      {
         nrOfPodsText.text = Localize.t("[nr] Pods").replace("[nr]", pods.length);
         g.hud.updatePodCount(pods.length);
      }

      override public function tickUpdate():void
      {
         super.tickUpdate();
      }

      override public function execute():void
      {
         if (loaded)
         {
            if (!g.blockHotkeys && keybinds.isEscPressed)
            {
               sm.changeState(new RoamingState(g));
            }
         }
         super.execute();
      }

      override public function exit(param1:Function):void
      {
         ToolTip.disposeType("PodState");
         container.removeChildren(0, -1, true);
         super.exit(param1);
      }
   }
}

import com.greensock.TweenMax;
import core.hud.components.TextBitmap;
import core.hud.components.ToolTip;
import core.scene.Game;
import generics.Localize;
import sound.SoundLocator;
import starling.display.Button;
import starling.display.Image;
import starling.display.Sprite;
import textures.ITextureManager;
import textures.TextureLocator;

class Pod extends Sprite
{
   public var top:Image;

   public var bottom:Image;

   public var center:Button;

   private var lootText:TextBitmap;

   private var cTween:TweenMax;

   private var tween:TweenMax;

   public function Pod(param1:Game)
   {
      super();
      var _loc2_:ITextureManager = TextureLocator.getService();
      top = new Image(_loc2_.getTextureGUIByTextureName("pod_large_top.png"));
      bottom = new Image(_loc2_.getTextureGUIByTextureName("pod_large_bottom.png"));
      center = new Button(_loc2_.getTextureGUIByTextureName("pod_large_center.png"));
      top.alignPivot("center", "bottom");
      top.y = 33;
      bottom.alignPivot("center", "top");
      bottom.x = 54;
      bottom.y = -33;
      center.alignPivot();
      center.x = 12;
      center.y = -5;
      center.enabled = false;
      lootText = new TextBitmap(0, 0, "", 20);
      new ToolTip(param1, center, Localize.t("Click to open!"), null, "PodState");
      this.addChild(top);
      this.addChild(bottom);
      this.addChild(center);
   }

   public function listenForClick(param1:Function):void
   {
      var callback:Function = param1;
      center.enabled = true;
      tween = TweenMax.fromTo(center, 0.3, {
               "alpha": 1,
               "scaleX": 1,
               "scaleY": 1
            }, {
               "alpha": 0.9,
               "scaleX": 1.2,
               "scaleY": 1.2,
               "yoyo": true,
               "repeat": -1
            });
      center.addEventListener("triggered", (function():*
            {
               var f:Function;
               return f = function():void
               {
                  center.removeEventListeners();
                  callback();
                  tween.kill();
                  SoundLocator.getService().play("3hVYqbNNSUWoDGk_pK1BdQ");
                  cTween = TweenMax.fromTo(center, 0.5, {"color": 16777215}, {
                           "color": 16711935,
                           "yoyo": true,
                           "repeat": -1
                        });
               };
            })());
   }

   public function animateOpen(param1:Function = null):void
   {
      var callback:Function = param1;
      cTween.kill();
      TweenMax.fromTo(top, 0.5, {"y": top.y}, {
               "y": top.y - 40,
               "onComplete": function():void
               {
                  if (Boolean(callback))
                  {
                     callback();
                  }
               }
            });
      TweenMax.fromTo(bottom, 0.5, {"y": bottom.y}, {"y": bottom.y + 23});
      TweenMax.fromTo(center, 2, {
               "rotation": 1,
               "alpha": 1,
               "scaleX": 1,
               "scaleY": 1
            }, {
               "rotation": 3.141592653589793 * 8,
               "alpha": 0,
               "scaleX": 5,
               "scaleY": 5
            });
      center.blendMode = "screen";
   }

   public function animateClose(param1:Function = null):void
   {
      var callback:Function = param1;
      TweenMax.fromTo(top, 0.5, {"y": top.y}, {
               "y": top.y + 40,
               "onComplete": function():void
               {
                  if (Boolean(callback))
                  {
                     callback();
                  }
               }
            });
      TweenMax.fromTo(bottom, 0.5, {"y": bottom.y}, {"y": bottom.y - 23});
   }

   public function animateSpinColor(param1:uint):void
   {
      TweenMax.fromTo(center, 2, {"color": 16777215}, {"color": param1});
   }

   public function animateLootText(param1:String, param2:uint):void
   {
      addChild(lootText);
      lootText.text = param1;
      lootText.pivotX = lootText.width / 2;
      lootText.pivotY = lootText.height / 2;
      lootText.format.color = param2;
      lootText.x += 20;
      TweenMax.fromTo(lootText, 2, {
               "scaleX": 1,
               "scaleY": 1,
               "alpha": 1
            }, {
               "scaleX": 3,
               "scaleY": 3,
               "alpha": 0
            });
   }
}
