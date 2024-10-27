package core.tutorial
{
   import com.greensock.TweenMax;
   import core.drops.DropBase;
   import core.hud.components.dialogs.CrewDialogBox;
   import core.hud.components.explore.ExploreArea;
   import core.player.CrewMember;
   import core.player.Mission;
   import core.scene.Game;
   import core.solarSystem.Area;
   import core.solarSystem.Body;
   import core.spawner.Spawner;
   import flash.utils.Timer;
   import generics.Localize;
   import playerio.Message;
   import sound.ISound;
   import sound.SoundLocator;
   import starling.display.Image;
   import textures.ITextureManager;
   import textures.TextureLocator;

   public class Tutorial
   {
      private static var dialogs:Vector.<CrewDialogBox> = new Vector.<CrewDialogBox>();

      private var g:Game;

      private var soundManager:ISound;

      private var tutorialArray:Array;

      private var introStartId:String = "intro start";

      private var introId:String = "intro";

      private var controlsHint:Image;

      private var dialogBox:CrewDialogBox;

      private var showExploreAdviceId:String = "explore areas";

      private var showCompressorAdviceId:String = "compressor advice";

      private var showMissionCompleteAdviceId:String = "mission complete";

      private var showForumAdviceId:String = "forum";

      private var showFacebookInviteHintId:String = "facebook invites";

      private var showArtifactUpgradeAdviceId:String = "artifact upgrade";

      private var showCargoAdviceId:String = "cargo upgrade";

      private var showUpgradeAdviceId:String = "upgrade tree";

      private var showExploreAdvice2Id:String = "can leave explore";

      private var showArtifactFoundId:String = "artifact found";

      private var showSendCrewHintId:String = "send crew to explore";

      private var showForgotCrewHintId:String = "forgot crew on explore";

      private var showLandingHintId:String = "land on body";

      private var showKillSpawnerHintId:String = "kill spawner";

      private var showShopLocationHintId:String = "weapon factory location";

      private var showShopAdviceId:String = "weapon production";

      private var showWarpGateHintId:String = "warp gate location";

      private var showChangeWeaponId:String = "change weapon";

      private var showWarpGateAdviceId:String = "warp license";

      private var showMapTargetAdviceId:String = "map targets";

      private var showRecycleAdviceId:String = "recycle";

      private var showSpecialUnlocksId:String = "special unlocks";

      public function Tutorial(param1:Game)
      {
         super();
         this.g = param1;
      }

      public static function clear():void
      {
         var _loc3_:int = 0;
         var _loc2_:CrewDialogBox = null;
         var _loc1_:int = int(dialogs.length);
         _loc3_ = _loc1_ - 1;
         while (_loc3_ > -1)
         {
            _loc2_ = dialogs[_loc3_];
            _loc2_.hide();
            _loc3_--;
         }
      }

      public static function add(param1:CrewDialogBox):void
      {
         if (dialogs.indexOf(param1) == -1)
         {
            dialogs.push(param1);
         }
      }

      public static function remove(param1:CrewDialogBox):void
      {
         if (dialogs.indexOf(param1) == -1)
         {
            return;
         }
         dialogs.splice(dialogs.indexOf(param1), 1);
      }

      public function init(param1:Message, param2:int):int
      {
         var _loc4_:int = 0;
         tutorialArray = [];
         var _loc3_:int = param1.getInt(param2++ );
         _loc4_ = 0;
         while (_loc4_ < _loc3_)
         {
            tutorialArray.push(param1.getString(param2++ ));
            _loc4_++;
         }
         return param2;
      }

      public function showIntroTutorial():void
      {
         var textureManager:ITextureManager;
         var that:Tutorial;
         addCheckPoint(introStartId);
         clear();
         dialogBox = new CrewDialogBox(g, this);
         g.addChildToMenu(dialogBox);
         dialogBox.x = g.stage.stageWidth / 2 - 180;
         dialogBox.y = 70;
         textureManager = TextureLocator.getService();
         controlsHint = new Image(textureManager.getTextureGUIByTextureName("controls3.png"));
         controlsHint.x = g.stage.stageWidth / 2 - controlsHint.width / 2;
         controlsHint.y = 50;
         controlsHint.alpha = 0.8;
         controlsHint.touchable = false;
         g.addChildToMenu(controlsHint);
         that = this;
         dialogBox.show("Captain! The auto pilot is offline, you better do something...\n<FONT COLOR='#aa8822'>See controls below</FONT>.", "ZsG7ikQTNUKCT7yHcC6ZLw", [87, 38], -1, function():void
            {
               TweenMax.delayedCall(2, function():void
                  {
                     TweenMax.to(controlsHint, 10, {
                              "alpha": 0,
                              "onComplete": function():void
                              {
                                 g.removeChildFromMenu(controlsHint);
                                 controlsHint = null;
                              }
                           });
                  });
               g.removeChildFromMenu(dialogBox);
               TweenMax.delayedCall(15, showFirstNewMission);
            }, 1, false);
         dialogBox.visible = false;
         dialogBox.touchable = false;
      }

      public function showExploreAdvice(param1:ExploreArea):void
      {
         var dialogBox:CrewDialogBox;
         var area:ExploreArea = param1;
         if (hasCheckPoint(showExploreAdviceId) || area == null)
         {
            return;
         }
         dialogBox = new CrewDialogBox(g, this);
         dialogBox.x = g.stage.stageWidth / 2 - 180;
         dialogBox.y = 180;
         g.addChildToOverlay(dialogBox);
         dialogBox.show("<FONT COLOR='#aaaa22'>EXPLORE AREAS</FONT>\nWe should send down a team to investigate the <FONT COLOR='#aa8822'>" + area.name + "</FONT>.\n\nIf we are lucky we might find minerals that we can use to upgrade our ship with new technology.\n\n", null, null, -1, function():void
            {
               g.removeChildFromOverlay(dialogBox);
            }, 0, true, true);
         addCheckPoint(showExploreAdviceId);
      }

      public function showCompressorAdvice():void
      {
         var dialogBox:CrewDialogBox;
         if (hasCheckPoint(showCompressorAdviceId))
         {
            return;
         }
         clear();
         dialogBox = new CrewDialogBox(g, this);
         dialogBox.x = g.stage.stageWidth / 2 - 180;
         dialogBox.y = 180;
         g.addChildToOverlay(dialogBox);
         dialogBox.show("<FONT COLOR='#aaaa22'>Cargo Compressor</FONT>\nThe cargo space is determined by the compressor, <FONT COLOR='#aa8822'>upgrade</FONT> it and you can store more junk.\n\n\n", null, null, -1, function():void
            {
               g.removeChildFromOverlay(dialogBox);
            }, 0, true, true);
         addCheckPoint(showCompressorAdviceId);
      }

      public function showMissionCompleteAdvice():void
      {
         var dialogBox:CrewDialogBox;
         if (hasCheckPoint(showMissionCompleteAdviceId))
         {
            return;
         }
         clear();
         dialogBox = new CrewDialogBox(g, this);
         dialogBox.x = g.stage.stageWidth / 2 - 180;
         dialogBox.y = 40;
         g.addChildToOverlay(dialogBox);
         dialogBox.show("<FONT COLOR='#aaaa22'>Mission Complete</FONT>\nCaptain! We completed a mission, <FONT COLOR='#aa8822'>press i</FONT> to see the reward.\n\n\n", null, [73], -1, function():void
            {
               g.removeChildFromOverlay(dialogBox);
            }, 0, true, false);
         addCheckPoint(showMissionCompleteAdviceId);
      }

      public function showForumAdvice():void
      {
         var dialogBox:CrewDialogBox;
         if (hasCheckPoint(showForumAdviceId))
         {
            return;
         }
         dialogBox = new CrewDialogBox(g, this);
         dialogBox.x = g.stage.stageWidth / 2 - 180;
         dialogBox.y = 180;
         g.addChildToOverlay(dialogBox);
         dialogBox.show("<FONT COLOR='#aaaa22'>Forum & Wiki</FONT>\nCaptain! I want to remind you that we have discovered a huge amount of data in subspace. If you want to find answers, go there! \n\n<FONT COLOR='#8888ff'>Forum: http://forum.astroflux.net</FONT>\n\n<FONT COLOR='#8888ff'>Wiki: http://astroflux.org/wiki/</FONT>\n\n\n", null, null, -1, function():void
            {
               g.removeChildFromOverlay(dialogBox);
            }, 0, true, true);
         addCheckPoint(showForumAdviceId);
      }

      public function showFoundNewStaticMission(param1:Object):void
      {
         var dialogBox:CrewDialogBox;
         var missionObject:Object = param1;
         clear();
         dialogBox = new CrewDialogBox(g, this);
         dialogBox.x = 40;
         dialogBox.y = 40;
         g.addChildToOverlay(dialogBox);
         dialogBox.show("<FONT COLOR='#88ff88'>New Mission Chain</FONT>\n\nCaptain! We have recieved a new mission entry in our system, with codename: <FONT COLOR='#88ff88'>" + missionObject.title + "</FONT>\n\nOpen the mission screen to view the details after takeoff.\n\n", null, null, -1, function():void
            {
               g.removeChildFromOverlay(dialogBox);
            }, 0, true, false);
      }

      public function showFoundNewTimeMission(param1:Object):void
      {
         var missionObject:Object = param1;
         var dialogBox:CrewDialogBox = new CrewDialogBox(g, this);
         dialogBox.x = 40;
         dialogBox.y = 40;
         g.addChildToOverlay(dialogBox);
         dialogBox.show("<FONT COLOR='#ffff88'>Additional Timed Mission</FONT>\n\nCaptain!\n\n We just recieved a transmission that upgraded our mission system to handle an additional timed mission.\n\n<FONT COLOR='#ffff88'>" + missionObject.title + "</FONT>\n\nI think they have seen our progress and feel they can trust us with more work.\nOpen the mission screen to view the details after takeoff.\n\n", null, null, -1, function():void
            {
               g.removeChildFromOverlay(dialogBox);
            }, 0, true, false);
      }

      public function showFirstNewMission():void
      {
         var addedArrow:Boolean;
         var b:Body;
         var s:Spawner;
         var img:Image;
         var img2:Image;
         var dialogBox:CrewDialogBox = new CrewDialogBox(g, this);
         dialogBox.x = 40;
         dialogBox.y = 40;
         g.addChildToOverlay(dialogBox);
         addedArrow = false;
         for each (b in g.bodyManager.bodies)
         {
            if (b.key == "SWqDETtcD0i6Wc3s81yccQ" || b.key == "U8PYtFoC5U6c2A_gar9j2A" || b.key == "TLYpHghGOU6FaZtxDiVXBA")
            {
               for each (s in b.spawners)
               {
                  if (s.alive)
                  {
                     addedArrow = true;
                     g.hud.compas.addHintArrowByKey(b.key);
                     break;
                  }
               }
               if (addedArrow)
               {
                  break;
               }
            }
         }
         dialogBox.show("<FONT COLOR='#ffff88'>Captain! Someone is hailing us, let’s open the comm channels.</FONT>\n\n<FONT COLOR='#8888ff'>Lieutenant Kreiger:</FONT> “Great, yet another refugee from Azuron. The last thing I needed… this sector have been flooded by your kind lately. I got some bad news, I doubt you’ll even last one day…  If you want to survive you need to learn how to fight, and you need to learn fast. If you want any help you’ll have to earn it. \n\n<FONT COLOR='#88ff88'><b>KILL 10 SEEKERS</b></FONT>\n\nThey are roaming around this area. And by the way, a small hint: they are cannibals so you'd be better of dead than by surrendering.” \n\n", null, null, -1, function():void
            {
               g.removeChildFromOverlay(dialogBox);
            }, 0, true, false);
         img = new Image(TextureLocator.getService().getTextureMainByTextureName("enemy_slug_1"));
         img2 = new Image(TextureLocator.getService().getTextureMainByTextureName("enemy_slug_2"));
         img.x = 190;
         img.y = 180;
         img2.x = img.x + img.width + 10;
         img2.y = 180;
         dialogBox.addChild(img);
         dialogBox.addChild(img2);
      }

      public function showArtifactLimitAdvice():void
      {
         var dialogBox:CrewDialogBox = new CrewDialogBox(g, this);
         dialogBox.x = g.stage.stageWidth / 2 - 180;
         dialogBox.y = 180;
         g.addChildToOverlay(dialogBox);
         dialogBox.show("<FONT COLOR='#FF4444'>" + Localize.t("Artifact Limit of [limit]").replace("[limit]", 250) + "</FONT>\n\n" + Localize.t("An unfortunate event has occured, we have overloaded our artifact capacity of <font color='#ffffff'>[limit]</font> and have to recycle artifact to be able to pickup new artifacts.\n\n<font color='#ffffff'>Please recycle artifacts now!</font>").replace("[limit]", 250) + "\n\n\n", null, null, -1, function():void
            {
               g.removeChildFromOverlay(dialogBox);
            }, 0, true, true);
      }

      public function showMissionCompleteText(param1:Mission, param2:String, param3:String):void
      {
         var mission:Mission = param1;
         var drop:String = param2;
         var text:String = param3;
         var dialogBox:CrewDialogBox = new CrewDialogBox(g, this);
         var _mission:Mission = mission;
         var _drop:String = drop;
         dialogBox.x = 40;
         dialogBox.y = 40;
         g.addChildToOverlay(dialogBox);
         dialogBox.show("<FONT COLOR='#FF4444'>Mission Complete!</FONT>\n\n" + text + "\n\n\n", null, null, -1, function():void
            {
               g.rpc("requestMissionReward", function(param1:Message):void
                  {
                     var _loc6_:String = null;
                     var _loc4_:String = null;
                     var _loc2_:Number = NaN;
                     var _loc7_:Boolean = param1.getBoolean(0);
                     if (!_loc7_)
                     {
                        g.showErrorDialog("Mission not complete.");
                        return;
                     }
                     var _loc5_:DropBase = g.dropManager.getDropItems(_drop, g, _mission.created);
                     var _loc9_:int = 0;
                     for each (var _loc3_:* in _loc5_.items)
                     {
                        _loc6_ = _loc3_.table;
                        _loc4_ = _loc3_.item;
                        _loc2_ = Number(_loc3_.quantity);
                        g.myCargo.addItem(_loc6_, _loc4_, _loc2_);
                        g.textManager.createDropText(_loc3_.name, _loc2_, 20, 5000, 16777215, 24 * _loc9_);
                        _loc9_++;
                     }
                     g.hud.cargoButton.update();
                     g.hud.resourceBox.update();
                     g.hud.cargoButton.flash();
                     g.me.removeMission(_mission);
                     g.creditManager.refresh();
                     g.textManager.createMissionCompleteText();
                     var _loc8_:ISound = SoundLocator.getService();
                     _loc8_.preCacheSound("7zeIcPFb-UWzgtR_3nrZ8Q");
                  }, mission.id, mission.majorType);
               g.removeChildFromOverlay(dialogBox);
            }, 0, true, false, "Collect Reward");
      }

      public function showFacebookInviteHint():void
      {
         var dialogBox:CrewDialogBox;
         if (hasCheckPoint(showFacebookInviteHintId))
         {
            return;
         }
         dialogBox = new CrewDialogBox(g, this);
         dialogBox.x = g.stage.stageWidth / 2 - 180;
         dialogBox.y = 180;
         g.addChildToOverlay(dialogBox);
         dialogBox.show("<FONT COLOR='#88ff88'>Facebook invites!</FONT>\n\nCaptain, it looks like we can invite people to this galaxy through a net portal to gain extra flux.\n\nPress V to open Flux Shop -> Get More -> Invite button.\n\n\n", null, null, -1, function():void
            {
               g.removeChildFromOverlay(dialogBox);
            }, 0, true, true);
         addCheckPoint(showFacebookInviteHintId);
      }

      public function showArtifactUpgradeAdvice():void
      {
         var dialogBox:CrewDialogBox;
         if (hasCheckPoint(showArtifactUpgradeAdviceId))
         {
            return;
         }
         clear();
         dialogBox = new CrewDialogBox(g, this);
         dialogBox.x = g.stage.stageWidth / 2 - 180;
         dialogBox.y = 180;
         g.addChildToOverlay(dialogBox);
         dialogBox.show("<FONT COLOR='#aaaa22'>Artifact Upgrades</FONT>\nCaptain " + g.me.name + "! Here we can upgrade an artifact up to <FONT COLOR='#aa8822'>" + 10 + " times</FONT>. \n\nSelect a crew member and then pick the artifact you want to upgrade.\n\n\n", null, [67], -1, function():void
            {
               g.removeChildFromOverlay(dialogBox);
            }, 0, true, false);
         addCheckPoint(showArtifactUpgradeAdviceId);
      }

      public function showCargoAdvice():void
      {
         var dialogBox:CrewDialogBox;
         if (hasCheckPoint(showCargoAdviceId))
         {
            return;
         }
         clear();
         dialogBox = new CrewDialogBox(g, this);
         dialogBox.x = g.stage.stageWidth / 2 - 180;
         dialogBox.y = 40;
         g.addChildToOverlay(dialogBox);
         dialogBox.show("<FONT COLOR='#aaaa22'>Full Cargo</FONT>\nCaptain! Our cargo is full and we need to recycle our junk at the <FONT COLOR='#aa8822'>recycle station</FONT>. \n\nYou can also upgrade the cargo capacity, <FONT COLOR='#aa8822'>press C</FONT>.\n\n\n", null, [67], -1, function():void
            {
               g.removeChildFromOverlay(dialogBox);
            }, 0, true, false);
         addCheckPoint(showCargoAdviceId);
      }

      public function showUpgradeAdvice():void
      {
         var dialogBox:CrewDialogBox;
         if (hasCheckPoint(showUpgradeAdviceId))
         {
            return;
         }
         dialogBox = new CrewDialogBox(g, this);
         dialogBox.x = g.stage.stageWidth / 2 - 180;
         dialogBox.y = 180;
         g.addChildToOverlay(dialogBox);
         dialogBox.show("<FONT COLOR='#aaaa22'>Upgrades</FONT>\nCaptain!. \n\nWe can upgrade weapons, engine, shield or armor on this station. This will help us against all the hostile aliens in the area.\n\n\n", null, null, -1, function():void
            {
               g.removeChildFromOverlay(dialogBox);
            }, 0, true, true);
         addCheckPoint(showUpgradeAdviceId);
      }

      public function showExploreAdvice2():void
      {
         var dialogBox:CrewDialogBox;
         if (hasCheckPoint(showExploreAdvice2Id))
         {
            return;
         }
         dialogBox = new CrewDialogBox(g, this);
         dialogBox.x = g.stage.stageWidth / 2 - 180;
         dialogBox.y = 180;
         g.addChildToOverlay(dialogBox);
         dialogBox.show("<FONT COLOR='#aaaa22'>EXPLORING</FONT>\nWe can leave the planet now and come back later to claim your reward.\n\n", null, null, -1, function():void
            {
               g.removeChildFromOverlay(dialogBox);
            }, 0, true, true);
         addCheckPoint(showExploreAdvice2Id);
      }

      public function showArtifactFound(param1:ExploreArea):void
      {
         var crewMembers:Vector.<CrewMember>;
         var name0:String;
         var name1:String;
         var dialogBox:CrewDialogBox;
         var area:ExploreArea = param1;
         if (hasCheckPoint(showArtifactFoundId))
         {
            return;
         }
         crewMembers = g.me.crewMembers;
         if (crewMembers == null)
         {
            return;
         }
         name0 = crewMembers.length > 0 ? g.me.crewMembers[0].name : "[No Name]";
         name1 = crewMembers.length > 0 ? g.me.crewMembers[1].name : "[No Name]";
         if (area == null)
         {
            return;
         }
         clear();
         dialogBox = new CrewDialogBox(g, this);
         dialogBox.x = g.stage.stageWidth / 2 - 180;
         dialogBox.y = 180;
         g.addChildToOverlay(dialogBox);
         dialogBox.show("<FONT COLOR='#2288aa'>ARTIFACT FOUND!</FONT>\nCaptain! We found this odd looking artifact in the <FONT COLOR='#aa8822'>" + area.name + "</FONT> and then <FONT COLOR='#aa8822'>" + name1 + "</FONT> detected a powerful force radiating from it.\n\n", null, null, -1, function():void
            {
               g.removeChildFromOverlay(dialogBox);
            }, 1, true, true);
         addCheckPoint(showArtifactFoundId);
      }

      public function showSendCrewHint():void
      {
         var dialogBox:CrewDialogBox;
         if (hasCheckPoint(showSendCrewHintId))
         {
            return;
         }
         dialogBox = new CrewDialogBox(g, this);
         dialogBox.x = g.stage.stageWidth / 2 - 180;
         dialogBox.y = 180;
         g.addChildToOverlay(dialogBox);
         dialogBox.show("<FONT COLOR='#aaaa22'>AWAY TEAM</FONT>\nThe number of crew members and average skill determines how long and how successful the mission will be.\n\nBut please, don't pick me, I don't like bugs.\n\n", null, null, -1, function():void
            {
               g.removeChildFromOverlay(dialogBox);
            }, 0, true, true);
         addCheckPoint(showSendCrewHintId);
      }

      public function showForgotCrewHint():Boolean
      {
         var dialogBox:CrewDialogBox;
         var name:String;
         var crew:int;
         if (hasCheckPoint(showForgotCrewHintId) || g.solarSystem.key != "DrMy6JjyO0OI0ui7c80bNw" || g.myCargo.getCommoditiesAmount("flpbTKautkC1QzjWT28gkw") != 0)
         {
            return false;
         }
         clear();
         dialogBox = new CrewDialogBox(g, this);
         dialogBox.x = g.stage.stageWidth / 2 - 180;
         dialogBox.y = 180;
         g.addChildToOverlay(dialogBox);
         if (g.me.crewMembers[0].fullLocation != "" || g.me.crewMembers[1].fullLocation != "")
         {
            if (g.me.crewMembers[0].fullLocation != "")
            {
               crew = 0;
               name = g.me.crewMembers[0].name;
            }
            else
            {
               crew = 1;
               name = g.me.crewMembers[1].name;
            }
            dialogBox.show("<FONT COLOR='#aa8822'>Captain!!!</FONT> Please don't leave me on this godforsaken piece of rock! I've found a lot of <FONT COLOR='#aa8822'>resources</FONT>, please please come and pick me up...\n\n\n", null, null, -1, function():void
               {
                  g.removeChildFromOverlay(dialogBox);
               }, crew, true, true);
         }
         else
         {
            dialogBox.show("Captain, we don't have enough <FONT COLOR='#aa8822'>resources</FONT> to activate this warp gate. We have to go back to serach for more on some planet...\n\n\n", null, null, -1, function():void
               {
                  g.removeChildFromOverlay(dialogBox);
               }, 1, true, true);
         }
         addCheckPoint(showForgotCrewHintId);
         return true;
      }

      public function showLandingHint(param1:Body):void
      {
         var dialogBox:CrewDialogBox;
         var name:String;
         var body:Body = param1;
         if (hasCheckPoint(showLandingHintId))
         {
            return;
         }
         clear();
         dialogBox = new CrewDialogBox(g, this);
         dialogBox.x = g.stage.stageWidth / 2 - 180;
         dialogBox.y = 40;
         g.addChild(dialogBox);
         if (body == null)
         {
            return;
         }
         name = "";
         if (body.type == "planet")
         {
            name = body.name;
         }
         else
         {
            name = "the " + body.name;
         }
         dialogBox.show("Captain, we are in orbit.\n\nPress <FONT COLOR='#ffaa44'>L</FONT> to land.\n", "Ajb0qZREAk2hvfq93KuPDw", null, 15, function():void
            {
               g.removeChild(dialogBox);
            }, 1);
         addCheckPoint(showLandingHintId);
      }

      public function showKillSpawnerHint(param1:Body):void
      {
         var dialogBox:CrewDialogBox;
         var b:Body = param1;
         if (hasCheckPoint(showKillSpawnerHintId))
         {
            return;
         }
         if (b == null)
         {
            return;
         }
         if (b.type != "planet" || !b.isOnScreen(g.camera))
         {
            return;
         }
         clear();
         dialogBox = new CrewDialogBox(g, this);
         dialogBox.x = g.stage.stageWidth / 2 - 180;
         dialogBox.y = 40;
         g.addChild(dialogBox);
         dialogBox.show("<FONT COLOR='#aa2222'>ALERT!</FONT>\nKill the alien spawner to deactivate the force field so we can explore the planet.\n\n", null, null, 15, function():void
            {
               g.removeChild(dialogBox);
            }, 0);
         addCheckPoint(showKillSpawnerHintId);
      }

      public function showShopLocationHint():void
      {
         var dialogBox:CrewDialogBox;
         if (hasCheckPoint(showShopLocationHintId))
         {
            return;
         }
         clear();
         dialogBox = new CrewDialogBox(g, this);
         dialogBox.x = g.stage.stageWidth / 2 - 180;
         dialogBox.y = 40;
         pauseTutorial(10, function():void
            {
               g.addChild(dialogBox);
               if (g.hud != null && g.hud.compas != null)
               {
                  g.hud.compas.addHintArrow("shop");
                  dialogBox.show("<FONT COLOR='#8888ff'>WEAPON FACTORY!</FONT>\nWe just discovered an abandoned weapon factory. Maybe we can produce a <FONT COLOR='#aa8822'>new weapon</FONT> with our new minerals.\n\n", null, null, 15, function():void
                     {
                        g.removeChild(dialogBox);
                     }, 1, true);
               }
            });
         addCheckPoint(showShopLocationHintId);
      }

      public function showShopAdvice():void
      {
         var dialogBox:CrewDialogBox;
         if (hasCheckPoint(showShopAdviceId))
         {
            return;
         }
         dialogBox = new CrewDialogBox(g, this);
         dialogBox.x = g.stage.stageWidth / 2 - 180;
         dialogBox.y = 180;
         g.addChildToOverlay(dialogBox);
         dialogBox.show("<FONT COLOR='#22ff22'>PRODUCTION</FONT>\nWow.. we can get new weapon here using our <FONT COLOR='#aa8822'>steel</FONT>.\n\n\n", null, null, -1, function():void
            {
               g.removeChildFromOverlay(dialogBox);
            }, 0, true, true);
         addCheckPoint(showShopAdviceId);
      }

      public function showWarpGateHint():void
      {
         var dialogBox:CrewDialogBox;
         if (hasCheckPoint(showWarpGateHintId))
         {
            return;
         }
         dialogBox = new CrewDialogBox(g, this);
         dialogBox.x = g.stage.stageWidth / 2 - 180;
         dialogBox.y = 40;
         g.addChild(dialogBox);
         if (g.hud != null && g.hud.compas != null)
         {
            g.hud.compas.addHintArrow("warpGate");
            dialogBox.show("<FONT COLOR='#88ff88'>WARP GATE</FONT>\nWe just discovered a warp gate, maybe we can find out were we are in the galaxy.\n\n", null, null, 7, function():void
               {
                  g.removeChild(dialogBox);
               });
         }
         addCheckPoint(showWarpGateHintId);
      }

      public function showChangeWeapon():void
      {
         var dialogBox:CrewDialogBox;
         if (hasCheckPoint(showChangeWeaponId))
         {
            return;
         }
         clear();
         dialogBox = new CrewDialogBox(g, this);
         pauseTutorial(4, function():void
            {
               dialogBox.x = g.stage.stageWidth / 2 - 180;
               dialogBox.y = 40;
               g.addChild(dialogBox);
               dialogBox.show("<FONT COLOR='#88ff88'>CHANGE WEAPON</FONT>\nPress <FONT COLOR='#aa8822'>1-5</FONT> to switch between weapons.\n\n\n", null, [50], 7, function():void
                  {
                     g.removeChild(dialogBox);
                  }, 0, true);
            });
         addCheckPoint(showChangeWeaponId);
      }

      public function showWarpGateAdvice():void
      {
         var dialogBox:CrewDialogBox;
         if (showForgotCrewHint())
         {
            return;
         }
         if (hasCheckPoint(showWarpGateAdviceId))
         {
            return;
         }
         dialogBox = new CrewDialogBox(g, this);
         dialogBox.x = g.stage.stageWidth / 2 - 180;
         dialogBox.y = 180;
         g.addChildToOverlay(dialogBox);
         dialogBox.show("I think we need to <FONT COLOR='#aa8822'>buy a warp license</FONT>\nif we want to travel to a different system.\n\n\n", null, null, -1, function():void
            {
               g.removeChildFromOverlay(dialogBox);
            }, 1, true, true);
         addCheckPoint(showWarpGateAdviceId);
      }

      public function showFleeGodDamit():void
      {
         var dialogBox:CrewDialogBox;
         clear();
         dialogBox = new CrewDialogBox(g, this);
         pauseTutorial(3, function():void
            {
               dialogBox.x = g.stage.stageWidth / 2 - 180;
               dialogBox.y = 40;
               g.addChild(dialogBox);
               dialogBox.show("WARP!!! I said warp damit! Waaaaaaaaarp!\n\n", null, null, 3, function():void
                  {
                     dialogBox.show("Whaaaaaaaaaahhhhhrp!!!!\n\n", null, null, 2, function():void
                        {
                           dialogBox.show("Gaaaaaaaaaaahhhhhhhhh!!!!\n\n", null, null, 2, function():void
                              {
                                 g.removeChild(dialogBox);
                              }, 0, false);
                        }, 1, false);
                  }, 0, false);
            });
      }

      public function showMapTargetHint():void
      {
         if (hasCheckPoint(showMapTargetAdviceId))
         {
            return;
         }
         clear();
         addCheckPoint(showMapTargetAdviceId);
      }

      public function showRecycleAdvice():void
      {
         var dialogBox:CrewDialogBox;
         if (hasCheckPoint(showRecycleAdviceId))
         {
            return;
         }
         dialogBox = new CrewDialogBox(g, this);
         dialogBox.x = g.stage.stageWidth / 2 - 180;
         dialogBox.y = 180;
         g.addChildToOverlay(dialogBox);
         dialogBox.show("<FONT COLOR='#88ff88'>RECYCLE</FONT>\nWow.. this is awesome! We can recycle all our <FONT COLOR='#aa8822'>metal scrap</FONT> into valuable minerals it seems.\n\n", null, null, -1, function():void
            {
               g.removeChildFromOverlay(dialogBox);
            }, 0, true, true);
         addCheckPoint(showRecycleAdviceId);
      }

      public function showSpecialUnlocks(param1:ExploreArea):void
      {
         var specialType:int;
         var dialogBox:CrewDialogBox;
         var area:ExploreArea = param1;
         if (hasCheckPoint(showSpecialUnlocksId))
         {
            return;
         }
         if (area == null || area.specialTypes == null || area.specialTypes.length == 0)
         {
            return;
         }
         specialType = int(area.specialTypes[0]);
         dialogBox = new CrewDialogBox(g, this);
         dialogBox.x = g.stage.stageWidth / 2 - 180;
         dialogBox.y = 180;
         g.addChildToOverlay(dialogBox);
         dialogBox.show("<FONT COLOR='#88ff88'>SPECIAL SKILLS</FONT>\nAn area on this planet is " + Area.SPECIALTYPEHTML[specialType] + ". Your crew can gain " + Area.SPECIALTYPEHTML[specialType] + " skill by exploring this area. \n\n", null, null, -1, function():void
            {
               g.removeChildFromOverlay(dialogBox);
            }, 1, true, true);
         addCheckPoint(showSpecialUnlocksId);
      }

      private function pauseTutorial(param1:int, param2:Function):void
      {
         var pauseTime:int = param1;
         var callback:Function = param2;
         var pauseTimer:Timer = new Timer(1000, pauseTime);
         pauseTimer.start();
         pauseTimer.addEventListener("timerComplete", (function():*
               {
                  var f:Function;
                  return f = function():void
                  {
                     pauseTimer.stop();
                     pauseTimer.removeEventListener("timerComplete", f);
                     callback();
                  };
               })());
      }

      private function hasCheckPoint(param1:String):Boolean
      {
         for each (var _loc2_:* in tutorialArray)
         {
            if (_loc2_ == param1)
            {
               return true;
            }
         }
         return false;
      }

      private function addCheckPoint(param1:String):void
      {
         if (hasCheckPoint(param1))
         {
            return;
         }
         tutorialArray.push(param1);
         g.send("addTutorialCheckPoint", param1);
      }

      public function resize():void
      {
         if (controlsHint != null)
         {
            controlsHint.x = g.stage.stageWidth / 2 - controlsHint.width / 2;
            controlsHint.y = g.stage.stageHeight - controlsHint.height - 80;
         }
         if (dialogBox != null)
         {
            dialogBox.x = g.stage.stageWidth / 2 - 180;
         }
      }

      public function dispose():void
      {
         dialogs.splice(0, dialogs.length);
      }
   }
}
