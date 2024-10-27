package core.states.gameStates
{
   import com.greensock.TweenMax;
   import core.clan.ClanApplicationCheck;
   import core.credits.CreditManager;
   import core.hud.components.Button;
   import core.hud.components.ButtonExpandableHud;
   import core.hud.components.InputText;
   import core.hud.components.Text;
   import core.hud.components.TextBitmap;
   import core.hud.components.ToolTip;
   import core.hud.components.dialogs.CreditBuyBox;
   import core.hud.components.dialogs.PopupConfirmMessage;
   import core.scene.Game;
   import core.states.IGameState;
   import data.DataLocator;
   import data.IDataManager;
   import facebook.Action;
   import feathers.controls.ScrollContainer;
   import feathers.controls.TextInput;
   import flash.display.Bitmap;
   import generics.Color;
   import generics.Localize;
   import generics.Util;
   import playerio.Message;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.events.KeyboardEvent;
   import starling.events.TouchEvent;

   public class ClanState extends PlayState implements IGameState
   {
      private var confirmBuyWithFlux:CreditBuyBox;

      private var createClanButton:Button;

      private var viewContainer:Sprite;

      private var scrollContainer:ScrollContainer;

      private var applicationsList:ScrollContainer;

      private var dataManager:IDataManager;

      private const STATUS_CLAN:String = "clan";

      private const STATUS_EDIT:String = "edit";

      private const STATUS_APPLY:String = "apply";

      private const STATUS_HANDLE_APPLICATIONS:String = "handle_applications";

      private const STATUS_TOP_CLANS:String = "clans";

      private var STATUS:String = "";

      private var bgr:Image;

      private var toClan:String;

      private var searchField:TextInput;

      private var searchButton:Button;

      private var clanApplicationCheck:ClanApplicationCheck;

      public function ClanState(param1:Game, param2:String = "")
      {
         viewContainer = new Sprite();
         scrollContainer = new ScrollContainer();
         applicationsList = new ScrollContainer();
         super(param1);
         this.toClan = param2;
         dataManager = DataLocator.getService();
      }

      public static function getMemberRankName(param1:Object, param2:String):String
      {
         for each (var _loc3_:* in param1.members)
         {
            if (_loc3_.player != param2)
            {
               continue;
            }
            switch (_loc3_.rank)
            {
               case 1:
                  return param1.rank1;
               case 2:
                  return param1.rank2;
               case 3:
                  return param1.rank3;
               case 4:
                  return param1.rank4;
            }
         }
         return Localize.t("Not a member");
      }

      override public function enter():void
      {
         var closeButton:ButtonExpandableHud;
         var clanKey:String;
         bgr = new Image(textureManager.getTextureGUIByTextureName("map_bgr.png"));
         addChild(bgr);
         closeButton = new ButtonExpandableHud(function():void
            {
               sm.revertState();
            }, Localize.t("close"));
         closeButton.x = bgr.width - 46 - closeButton.width;
         closeButton.y = 0;
         addChild(closeButton);
         g.hud.show = false;
         super.enter();
         drawBlackBackground();
         if (g.me.clanId == "" && toClan == "")
         {
            drawClansView();
         }
         else
         {
            clanKey = toClan == "" ? g.me.clanId : toClan;
            drawClanView(clanKey);
         }
         addChild(viewContainer);
         loadCompleted();
      }

      private function drawClansView():void
      {
         var headline:Text;
         var yourClanButton:Button;
         STATUS = "clans";
         viewContainer.removeChildren(0, -1, true);
         scrollContainer = new ScrollContainer();
         scrollContainer.width = 640;
         scrollContainer.height = 380;
         headline = new Text();
         headline.size = 36;
         headline.text = Localize.t("Clans");
         headline.y = 60;
         headline.x = 60;
         viewContainer.addChild(headline);
         if (g.me.clanId == "")
         {
            createClanButton = new Button(createClan, Localize.t("Create Clan"), "buy");
            createClanButton.x = 680 - createClanButton.width;
            createClanButton.y = 60;
            viewContainer.addChild(createClanButton);
         }
         else
         {
            yourClanButton = new Button(function(param1:TouchEvent):void
               {
                  drawClanView(g.me.clanId);
               }, Localize.t("Your Clan"));
            yourClanButton.x = 680 - yourClanButton.width;
            yourClanButton.y = 60;
            viewContainer.addChild(yourClanButton);
         }
         clanApplicationCheck = new ClanApplicationCheck(g);
         searchField = new InputText(0, 110, 200, 20);
         searchField.addEventListener("keyUp", function(param1:KeyboardEvent):void
            {
               if (param1.keyCode == 13)
               {
                  onSearch();
               }
            });
         searchButton = new Button(onSearch, Localize.t("Search"));
         searchField.x = headline.x;
         searchButton.x = searchField.x + searchField.width + 10;
         searchButton.y = 110;
         viewContainer.addChild(searchField);
         viewContainer.addChild(searchButton);
      }

      private function onSearch(param1:Event = null):void
      {
         var e:Event = param1;
         scrollContainer.removeChildren(0, -1, true);
         scrollContainer.scrollToPosition(0, 0);
         searchButton.enabled = false;
         dataManager.loadRangeFromBigDB("Clans", "ByName", [searchField.text], function(param1:Array):void
            {
               var i:int;
               var obj:Object;
               var cont:Sprite;
               var bgr:Quad;
               var rank:Text;
               var logo:Image;
               var clanName:Text;
               var troons:Text;
               var troonImg:Image;
               var array:Array = param1;
               if (STATUS != "clans")
               {
                  return;
               }
               i = 0;
               array.sort(function(param1:Object, param2:Object):int
                  {
                     if (param1.troons < param2.troons)
                     {
                        return 1;
                     }
                     return -1;
                  });
               for each (obj in array)
               {
                  clanApplicationCheck.checkSpecific(obj, function():void
                     {
                        drawClanView(obj.key);
                     });
                  cont = new Sprite();
                  bgr = new Quad(620, 60, 921102);
                  rank = new Text();
                  rank.text = (i + 1).toString();
                  rank.size = 16;
                  rank.x = 20;
                  rank.y = 20;
                  rank.touchable = false;
                  logo = new Image(textureManager.getTextureGUIByTextureName(obj.logo));
                  logo.color = obj.color;
                  logo.x = 60;
                  logo.y = 15;
                  logo.scaleX = logo.scaleY = 0.3;
                  logo.touchable = false;
                  obj.rank = i + 1;
                  clanName = new Text();
                  clanName.text = obj.name;
                  clanName.x = 120;
                  clanName.y = 20;
                  clanName.size = 16;
                  clanName.touchable = false;
                  troons = new Text();
                  troons.text = Util.formatAmount(obj.troons);
                  troons.x = 575;
                  troons.y = 5;
                  troons.alignRight();
                  troons.size = 36;
                  troons.color = 15985920;
                  troons.touchable = false;
                  troonImg = new Image(textureManager.getTextureGUIByTextureName("troon.png"));
                  troonImg.x = 585;
                  troonImg.y = troons.y + 15;
                  troonImg.touchable = false;
                  cont.addChild(bgr);
                  cont.addChild(logo);
                  cont.addChild(rank);
                  cont.addChild(clanName);
                  cont.addChild(troons);
                  cont.addChild(troonImg);
                  cont.y = i * 80;
                  cont.x = 0;
                  cont.useHandCursor = true;
                  cont.addEventListener("touch", fClanTouch(obj));
                  scrollContainer.addChild(cont);
                  i++;
               }
               viewContainer.addChild(scrollContainer);
               scrollContainer.x = 60;
               scrollContainer.y = 160;
               searchButton.enabled = true;
            }, 20);
      }

      private function fClanTouch(param1:Object):Function
      {
         var obj:Object = param1;
         return (function():*
            {
               var onClanTouch:Function;
               return onClanTouch = function(param1:TouchEvent):void
               {
                  var _loc2_:Quad = param1.target as Quad;
                  if (param1.getTouch(_loc2_, "ended"))
                  {
                     drawClanView(obj.key);
                  }
                  else if (param1.interactsWith(_loc2_))
                  {
                     _loc2_.color = 3026478;
                  }
                  else
                  {
                     _loc2_.color = 921102;
                  }
               };
            })();
      }

      private function drawClanView(param1:String):void
      {
         var clanId:String = param1;
         STATUS = "clan";
         viewContainer.removeChildren(0, -1, true);
         scrollContainer = new ScrollContainer();
         scrollContainer.width = 640;
         scrollContainer.height = 300;
         dataManager.loadKeyFromBigDB("Clans", clanId, function(param1:Object):void
            {
               var applicationCheck:ClanApplicationCheck;
               var haveApplied:Boolean;
               var logo:Image;
               var clansButton:Button;
               var joinButton:Button;
               var leaveButton:Button;
               var clanName:Text;
               var description:Text;
               var hh:Number;
               var handleApplicationButton:Button;
               var editButton:Button;
               var rank:Text;
               var rank2:Text;
               var troons:Text;
               var troonImg:Image;
               var i:int;
               var memberArray:Array;
               var member:Object;
               var mObj:Object;
               var obj:Object = param1;
               if (STATUS != "clan")
               {
                  return;
               }
               applicationCheck = new ClanApplicationCheck(g);
               haveApplied = applicationCheck.checkSpecific(obj, function():void
                  {
                     drawClanView(obj.key);
                  }, function():void
                  {
                     drawClanView(obj.key);
                  });
               logo = new Image(textureManager.getTextureGUIByTextureName(obj.logo));
               logo.color = obj.color;
               logo.x = 60;
               logo.y = 60;
               viewContainer.addChild(logo);
               clansButton = new Button(function():void
                  {
                     drawClansView();
                  }, Localize.t("Search Clans"));
               clansButton.x = 680 - clansButton.width;
               clansButton.y = 60;
               viewContainer.addChild(clansButton);
               if (g.me.clanId == "" && !haveApplied)
               {
                  joinButton = new Button(function():void
                     {
                        drawApplyView(obj.key);
                     }, Localize.t("Join Clan"), "buy");
                  joinButton.x = clansButton.x - joinButton.width - 10;
                  joinButton.y = 60;
                  viewContainer.addChild(joinButton);
               }
               else if (g.me.clanId == obj.key && !isLeader(obj, g.me.id))
               {
                  leaveButton = new Button(function():void
                     {
                        var m:Message = g.createMessage("clanRemoveMember");
                        m.add(g.me.id);
                        leaveButton.enabled = false;
                        g.blockHotkeys = true;
                        g.rpcMessage(m, function(param1:Message):void
                           {
                              var _loc2_:Message = null;
                              if (param1.getBoolean(0))
                              {
                                 _loc2_ = g.createMessage("clanLeave");
                                 _loc2_.add(obj.key);
                                 g.sendMessageToServiceRoom(_loc2_);
                                 g.me.clanId = "";
                                 g.updateServiceRoom();
                                 g.showErrorDialog(Localize.t("You have now left the clan."));
                              }
                              else
                              {
                                 g.showErrorDialog(param1.getString(1));
                              }
                              drawClansView();
                              g.blockHotkeys = false;
                           });
                     }, Localize.t("Leave Clan"), "negative");
                  leaveButton.x = clansButton.x - leaveButton.width - 10;
                  leaveButton.y = 60;
                  viewContainer.addChild(leaveButton);
               }
               clanName = new Text();
               clanName.text = obj.name;
               clanName.x = 180;
               clanName.y = 60;
               clanName.size = 30;
               viewContainer.addChild(clanName);
               while (clanName.width > 300)
               {
                  clanName.size -= 1;
               }
               description = new Text();
               description.width = 340;
               description.wordWrap = true;
               description.text = obj.description;
               description.color = 11184810;
               description.x = 180;
               description.y = 60 + clanName.height + 10;
               description.size = 12;
               viewContainer.addChild(description);
               hh = logo.y + logo.height > description.y + description.height ? logo.y + logo.height : description.y + description.height;
               if (isAllowedToAcceptApplications(obj, g.me.id))
               {
                  handleApplicationButton = new Button(function():void
                     {
                        drawHandleApplicationsView(obj.key);
                     }, Localize.t("Handle Applications"));
                  handleApplicationButton.x = 60;
                  handleApplicationButton.y = hh + 20;
                  viewContainer.addChild(handleApplicationButton);
               }
               if (isLeader(obj, g.me.id))
               {
                  editButton = new Button(function():void
                     {
                        drawEditView(clanId);
                     }, Localize.t("Edit Clan"));
                  editButton.x = handleApplicationButton.x + handleApplicationButton.width + 10;
                  editButton.y = handleApplicationButton.y;
                  viewContainer.addChild(editButton);
               }
               rank = new Text();
               rank.text = Localize.t("Rank");
               rank.size = 16;
               rank.color = 11184810;
               rank.x = 560;
               rank.y = description.y;
               viewContainer.addChild(rank);
               rank2 = new Text();
               rank2.text = obj.rank;
               rank2.size = 22;
               rank2.color = obj.color;
               rank2.x = rank.x + rank.width + 5;
               rank2.y = rank.y + rank.height - rank2.height;
               viewContainer.addChild(rank2);
               troons = new Text();
               troons.text = Util.formatAmount(obj.troons);
               troons.x = 550;
               troons.y = rank.y + 30;
               troons.size = 20;
               troons.color = 15985920;
               viewContainer.addChild(troons);
               troonImg = new Image(textureManager.getTextureGUIByTextureName("troon.png"));
               troonImg.x = troons.x + troons.width + 10;
               troonImg.y = troons.y + 5;
               viewContainer.addChild(troonImg);
               i = 0;
               memberArray = [];
               for each (member in obj.members)
               {
                  memberArray.push(member);
               }
               memberArray.sortOn("troons", 16);
               memberArray.reverse();
               for each (mObj in memberArray)
               {
                  drawClanMember(mObj, i, obj);
                  i++;
               }
               scrollContainer.x = 60;
               scrollContainer.y = 240 > hh + 60 ? 240 : hh + 60;
               scrollContainer.height = 540 - scrollContainer.y;
               viewContainer.addChild(scrollContainer);
            });
      }

      private function drawClanMember(param1:Object, param2:int, param3:Object):void
      {
         var contM:Sprite;
         var bgrM:Quad;
         var positionM:Text;
         var skinObj:Object;
         var shipObj:Object;
         var img:Image;
         var name:Text;
         var level:Text;
         var rankM:Text;
         var rank:int;
         var promoteButtonText:String;
         var promoteStyle:String;
         var promoteButton:Button;
         var demoteButton:Button;
         var kickButton:Button;
         var troonsM:Text;
         var troonImgM:Image;
         var troonContainer:Sprite;
         var promoteContainer:Sprite;
         var mObj:Object = param1;
         var i:int = param2;
         var clanObj:Object = param3;
         var memberId:String = mObj.player;
         if (STATUS != "clan")
         {
            return;
         }
         contM = new Sprite();
         bgrM = new Quad(620, 60, 921102);
         positionM = new Text();
         positionM.text = (i + 1).toString();
         positionM.size = 16;
         positionM.x = 20;
         positionM.y = 20;
         positionM.touchable = false;
         if (mObj.activeSkin == null)
         {
            mObj.activeSkin = "H1XyZ2LoLUKkzwAA4ivQnQ";
         }
         skinObj = dataManager.loadKey("Skins", mObj.activeSkin);
         shipObj = dataManager.loadKey("Ships", skinObj.ship);
         img = new Image(textureManager.getTexturesMainByKey(shipObj.bitmap)[0]);
         img.x = 80;
         img.y = 30;
         img.touchable = false;
         img.pivotX = img.width / 2;
         img.pivotY = img.height / 2;
         img.scaleX = img.scaleY = img.width > 40 ? 40 / img.width : 1;
         name = new Text();
         name.text = mObj.name || "...";
         name.x = 120;
         name.y = 10;
         name.size = 16;
         name.touchable = false;
         while (name.width > 250)
         {
            name.size -= 1;
         }
         level = new Text();
         level.text = Localize.t("lvl") + " " + (mObj.level || "..");
         level.color = 11184810;
         level.x = name.x + name.width + 5;
         level.y = name.y + name.height - level.height - 2;
         level.size = 12;
         level.touchable = false;
         rankM = new Text();
         rankM.text = getMemberRankName(clanObj, memberId);
         rankM.color = clanObj.color;
         rankM.x = 120;
         rankM.y = 30;
         rankM.size = 14;
         rankM.touchable = false;
         while (rankM.width > 250)
         {
            rankM.size -= 1;
         }
         rank = getMemberRank(clanObj, memberId);
         promoteButtonText = rank == 2 ? Localize.t("Promote to leader") : Localize.t("Promote");
         promoteStyle = rank == 2 ? "negative" : "positive";
         promoteButton = new Button(function():void
            {
               var warning:PopupConfirmMessage;
               if (rank == 2)
               {
                  warning = new PopupConfirmMessage(promoteButtonText, Localize.t("Cancel"), "negative");
                  warning.text = Localize.t("<FONT COLOR='#FF4444' SIZE='18'>WARNING!</FONT>\n\nYou are about to give away your clan to someone else. Only one player can be the leader.");
               }
               else
               {
                  warning = new PopupConfirmMessage(promoteButtonText, Localize.t("Cancel"), "positive");
                  warning.text = Localize.t("Do you really want to promote this player?");
               }
               g.blockHotkeys = true;
               warning.addEventListener("accept", function():void
                  {
                     var m:Message = g.createMessage("clanSetMemberRank");
                     m.add(memberId);
                     m.add(rank - 1);
                     promoteButton.enabled = false;
                     demoteButton.enabled = false;
                     kickButton.enabled = false;
                     g.rpcMessage(m, function(param1:Message):void
                        {
                           if (param1.getBoolean(0))
                           {
                              g.showErrorDialog(Localize.t("Player promoted!"));
                           }
                           else
                           {
                              g.showErrorDialog(param1.getString(1));
                           }
                           drawClanView(clanObj.key);
                           g.blockHotkeys = false;
                           g.removeChildFromOverlay(warning, true);
                        });
                  });
               warning.addEventListener("close", function():void
                  {
                     promoteButton.enabled = true;
                     demoteButton.enabled = true;
                     kickButton.enabled = true;
                     g.blockHotkeys = false;
                     g.removeChildFromOverlay(warning, true);
                  });
               g.addChildToOverlay(warning);
            }, promoteButtonText, promoteStyle);
         promoteButton.x = rank == 2 ? 260 : 300;
         promoteButton.y = 20;
         demoteButton = new Button(function():void
            {
               var warning:PopupConfirmMessage = new PopupConfirmMessage(Localize.t("Demote"), Localize.t("cancel"), "negative");
               warning.text = Localize.t("Do you really want to demote this player?");
               g.blockHotkeys = true;
               warning.addEventListener("accept", function():void
                  {
                     var m:Message = g.createMessage("clanSetMemberRank");
                     m.add(memberId);
                     m.add(rank + 1);
                     promoteButton.enabled = false;
                     demoteButton.enabled = false;
                     kickButton.enabled = false;
                     g.blockHotkeys = true;
                     g.rpcMessage(m, function(param1:Message):void
                        {
                           if (param1.getBoolean(0))
                           {
                              g.showErrorDialog(Localize.t("Player demoted!"));
                           }
                           else
                           {
                              g.showErrorDialog(param1.getString(1));
                           }
                           drawClanView(clanObj.key);
                           g.blockHotkeys = false;
                           g.removeChildFromOverlay(warning, true);
                        });
                  });
               warning.addEventListener("close", function():void
                  {
                     promoteButton.enabled = true;
                     demoteButton.enabled = true;
                     kickButton.enabled = true;
                     g.blockHotkeys = false;
                     g.removeChildFromOverlay(warning, true);
                  });
               g.addChildToOverlay(warning);
            }, Localize.t("Demote"), "negative");
         demoteButton.x = promoteButton.x + promoteButton.width + 5;
         demoteButton.y = 20;
         if (rank == 4)
         {
            demoteButton.visible = false;
         }
         kickButton = new Button(function():void
            {
               var warning:PopupConfirmMessage = new PopupConfirmMessage(Localize.t("Kick"), Localize.t("cancel"), "negative");
               warning.text = Localize.t("Do you really want to kick this player?");
               g.blockHotkeys = true;
               warning.addEventListener("accept", function():void
                  {
                     var m:Message = g.createMessage("clanRemoveMember");
                     m.add(memberId);
                     promoteButton.enabled = false;
                     demoteButton.enabled = false;
                     kickButton.enabled = false;
                     g.blockHotkeys = true;
                     warning.enableCloseButton(false);
                     g.rpcMessage(m, function(param1:Message):void
                        {
                           var _loc2_:Message = null;
                           if (param1.getBoolean(0))
                           {
                              _loc2_ = g.createMessage("clanKick");
                              _loc2_.add(memberId);
                              _loc2_.add(mObj.name);
                              _loc2_.add(clanObj.name);
                              g.sendMessageToServiceRoom(_loc2_);
                              g.showErrorDialog(Localize.t("Player kicked!"));
                           }
                           else
                           {
                              g.showErrorDialog(param1.getString(1));
                           }
                           drawClanView(clanObj.key);
                           warning.enableCloseButton(true);
                           g.blockHotkeys = false;
                           g.removeChildFromOverlay(warning, true);
                        });
                  });
               warning.addEventListener("close", function():void
                  {
                     promoteButton.enabled = true;
                     demoteButton.enabled = true;
                     kickButton.enabled = true;
                     g.blockHotkeys = false;
                     g.removeChildFromOverlay(warning, true);
                  });
               g.addChildToOverlay(warning);
            }, Localize.t("Kick"), "negative");
         kickButton.x = demoteButton.x + demoteButton.width + 5;
         kickButton.y = 20;
         troonsM = new Text();
         troonsM.text = Util.formatAmount(mObj.troons || 0);
         troonsM.x = 420;
         troonsM.y = 5;
         troonsM.size = 36;
         troonsM.color = 15985920;
         troonImgM = new Image(textureManager.getTextureGUIByTextureName("troon.png"));
         troonImgM.x = troonsM.x + troonsM.width + 10;
         troonImgM.y = troonsM.y + 15;
         contM.addChild(bgrM);
         contM.addChild(positionM);
         contM.addChild(img);
         contM.addChild(name);
         contM.addChild(rankM);
         troonContainer = new Sprite();
         troonContainer.addChild(level);
         troonContainer.addChild(troonsM);
         troonContainer.addChild(troonImgM);
         contM.addChild(troonContainer);
         promoteContainer = new Sprite();
         promoteContainer.addChild(promoteButton);
         promoteContainer.addChild(demoteButton);
         promoteContainer.addChild(kickButton);
         contM.addChild(promoteContainer);
         promoteContainer.visible = false;
         contM.y = i * 80;
         contM.x = 0;
         scrollContainer.addChild(contM);
         new ToolTip(g, contM, Localize.t("Last Login") + ": " + (mObj.lastSession != null ? mObj.lastSession : "---"), null, "clan");
         if (!isAllowedToPromote(clanObj, g.me.id) || isLeader(clanObj, memberId) || rank == 2 && !isLeader(clanObj, g.me.id))
         {
            return;
         }
         contM.addEventListener("touch", fMemberTouch(clanObj, promoteContainer, troonContainer, contM));
      }

      private function fMemberTouch(param1:Object, param2:Sprite, param3:Sprite, param4:Sprite):Function
      {
         var obj:Object = param1;
         var promoteContainer:Sprite = param2;
         var troonContainer:Sprite = param3;
         var target:Sprite = param4;
         return (function():*
            {
               var onMemberTouch:Function;
               return onMemberTouch = function(param1:TouchEvent):void
               {
                  param1.stopPropagation();
                  if (!param1.getTouch(target, "ended"))
                  {
                     if (!param1.getTouch(target, "began"))
                     {
                        if (param1.interactsWith(target))
                        {
                           troonContainer.visible = false;
                           promoteContainer.visible = true;
                        }
                        else if (!param1.interactsWith(target))
                        {
                           troonContainer.visible = true;
                           promoteContainer.visible = false;
                        }
                     }
                  }
               };
            })();
      }

      private function createClan(param1:TouchEvent):void
      {
         var e:TouchEvent = param1;
         confirmBuyWithFlux = new CreditBuyBox(g, CreditManager.getCostClan(), Localize.t("Are you sure you want to buy a clan?"));
         g.addChildToOverlay(confirmBuyWithFlux);
         confirmBuyWithFlux.addEventListener("accept", function():void
            {
               g.blockHotkeys = true;
               g.rpc("buyClan", function(param1:Message):void
                  {
                     var _loc2_:String = null;
                     g.removeChildFromOverlay(confirmBuyWithFlux, true);
                     g.blockHotkeys = false;
                     if (param1.getBoolean(0))
                     {
                        g.creditManager.refresh();
                        g.showErrorDialog(Localize.t("Clan created!"));
                        _loc2_ = param1.getString(1);
                        g.me.clanId = _loc2_;
                        drawClanView(_loc2_);
                     }
                     else
                     {
                        g.showErrorDialog(param1.getString(1), true);
                        createClanButton.enabled = true;
                     }
                  });
               confirmBuyWithFlux.removeEventListeners();
            });
         confirmBuyWithFlux.addEventListener("close", function():void
            {
               confirmBuyWithFlux.removeEventListeners();
               createClanButton.enabled = true;
               g.removeChildFromOverlay(confirmBuyWithFlux, true);
            });
      }

      private function drawEditView(param1:String):void
      {
         var clanId:String = param1;
         STATUS = "edit";
         dataManager.loadKeyFromBigDB("Clans", clanId, function(param1:Object):void
            {
               var padding:int;
               var backButton:Button;
               var headline:Text;
               var labelName:TextBitmap;
               var inputName:InputText;
               var labelRank1:TextBitmap;
               var inputRank1:InputText;
               var labelRank2:TextBitmap;
               var inputRank2:InputText;
               var labelRank3:TextBitmap;
               var inputRank3:InputText;
               var labelRank4:TextBitmap;
               var inputRank4:InputText;
               var labelDescription:TextBitmap;
               var inputDescription:InputText;
               var bitmap:Bitmap;
               var changeColor:Button;
               var rgb:Array;
               var inputColor:InputText;
               var changeLogo:Button;
               var logo:Image;
               var saveButton:Button;
               var deleteButton:Button;
               var clanObj:Object = param1;
               if (STATUS != "edit")
               {
                  return;
               }
               g.blockHotkeys = true;
               padding = 20;
               viewContainer.removeChildren(0, -1, true);
               backButton = new Button(function():void
                  {
                     g.blockHotkeys = false;
                     drawClanView(g.me.clanId);
                  }, Localize.t("back"));
               backButton.x = 680 - backButton.width;
               backButton.y = 60;
               viewContainer.addChild(backButton);
               headline = new Text();
               headline.size = 36;
               headline.text = Localize.t("Edit");
               headline.y = 60;
               headline.x = 60;
               viewContainer.addChild(headline);
               labelName = new TextBitmap();
               labelName.text = Localize.t("Name");
               labelName.x = 60;
               labelName.y = 160;
               viewContainer.addChild(labelName);
               inputName = new InputText(0, 0, 200, 20);
               inputName.text = clanObj.name;
               inputName.x = 160;
               inputName.y = 160;
               viewContainer.addChild(inputName);
               labelRank1 = new TextBitmap();
               labelRank1.text = Localize.t("Rank") + " 1";
               labelRank1.x = 60;
               labelRank1.y = labelName.y + labelName.height + padding;
               viewContainer.addChild(labelRank1);
               inputRank1 = new InputText(0, 0, 200, 20);
               inputRank1.text = clanObj.rank1;
               inputRank1.x = 160;
               inputRank1.y = labelName.y + labelName.height + padding;
               viewContainer.addChild(inputRank1);
               labelRank2 = new TextBitmap();
               labelRank2.text = Localize.t("Rank") + " 2";
               labelRank2.x = 60;
               labelRank2.y = labelRank1.y + labelRank1.height + padding;
               viewContainer.addChild(labelRank2);
               inputRank2 = new InputText(0, 0, 200, 20);
               inputRank2.text = clanObj.rank2;
               inputRank2.x = 160;
               inputRank2.y = labelRank1.y + labelRank1.height + padding;
               viewContainer.addChild(inputRank2);
               labelRank3 = new TextBitmap();
               labelRank3.text = Localize.t("Rank") + " 3";
               labelRank3.x = 60;
               labelRank3.y = labelRank2.y + labelRank2.height + padding;
               viewContainer.addChild(labelRank3);
               inputRank3 = new InputText(0, 0, 200, 20);
               inputRank3.text = clanObj.rank3;
               inputRank3.x = 160;
               inputRank3.y = labelRank2.y + labelRank2.height + padding;
               viewContainer.addChild(inputRank3);
               labelRank4 = new TextBitmap();
               labelRank4.text = Localize.t("Rank") + " 4";
               labelRank4.x = 60;
               labelRank4.y = labelRank3.y + labelRank3.height + padding;
               viewContainer.addChild(labelRank4);
               inputRank4 = new InputText(0, 0, 200, 20);
               inputRank4.text = clanObj.rank4;
               inputRank4.x = 160;
               inputRank4.y = labelRank3.y + labelRank3.height + padding;
               viewContainer.addChild(inputRank4);
               labelDescription = new TextBitmap();
               labelDescription.text = Localize.t("Description");
               labelDescription.x = 60;
               labelDescription.y = labelRank4.y + labelRank4.height + padding;
               viewContainer.addChild(labelDescription);
               inputDescription = new InputText(0, 0, 200, 50);
               inputDescription.text = clanObj.description;
               inputDescription.x = 160;
               inputDescription.y = labelRank4.y + labelRank4.height + padding;
               viewContainer.addChild(inputDescription);
               changeColor = new Button(function():void
                  {
                     var _loc3_:int = Math.floor(Math.random() * 255);
                     var _loc1_:int = Math.floor(Math.random() * 255);
                     var _loc2_:int = Math.floor(Math.random() * 255);
                     logo.color = Color.RGBtoHEX(_loc3_, _loc1_, _loc2_);
                     inputColor.text = _loc3_ + "," + _loc1_ + "," + _loc2_;
                     changeColor.enabled = true;
                  }, Localize.t("Randomize Color"));
               changeColor.x = 400;
               changeColor.y = 160;
               viewContainer.addChild(changeColor);
               rgb = Color.HEXtoRGB(clanObj.color);
               inputColor = new InputText(0, 0, 100, 20);
               inputColor.text = rgb[0] + "," + rgb[1] + "," + rgb[2];
               inputColor.addEventListener("change", function(param1:Event):void
                  {
                     rgb = inputColor.text.split(",");
                     logo.color = Color.RGBtoHEX(rgb[0], rgb[1], rgb[2]);
                  });
               inputColor.x = changeColor.x + changeColor.width + padding;
               inputColor.y = 160;
               viewContainer.addChild(inputColor);
               changeLogo = new Button(function():void
                  {
                     var _loc1_:Array = clanObj.logo.split("clan_logo");
                     var _loc2_:int = 1;
                     if (_loc1_.length > 1)
                     {
                        _loc2_ = int(_loc1_[1]);
                     }
                     if (_loc2_ == 3)
                     {
                        _loc2_ = 0;
                     }
                     clanObj.logo = "clan_logo" + (_loc2_ + 1).toString();
                     logo.texture = textureManager.getTextureGUIByTextureName(clanObj.logo);
                     changeLogo.enabled = true;
                  }, Localize.t("Next Logo"));
               changeLogo.x = 400;
               changeLogo.y = changeColor.y + changeColor.height + padding;
               viewContainer.addChild(changeLogo);
               logo = new Image(textureManager.getTextureGUIByTextureName(clanObj.logo));
               logo.color = clanObj.color;
               logo.addEventListener("touch", function(param1:TouchEvent):void
                  {
                     var _loc2_:Array = null;
                     var _loc3_:int = 0;
                     if (param1.getTouch(logo, "began"))
                     {
                        _loc2_ = clanObj.logo.split("clan_logo");
                        _loc3_ = 1;
                        if (_loc2_.length > 1)
                        {
                           _loc3_ = int(_loc2_[1]);
                        }
                        if (_loc3_ == 3)
                        {
                           _loc3_ = 0;
                        }
                        clanObj.logo = "clan_logo" + (_loc3_ + 1).toString();
                        logo.texture = textureManager.getTextureGUIByTextureName(clanObj.logo);
                     }
                  });
               logo.x = 400;
               logo.y = changeLogo.y + changeLogo.height + 5;
               viewContainer.addChild(logo);
               saveButton = new Button(function():void
                  {
                     var m:Message;
                     backButton.enabled = false;
                     g.blockHotkeys = true;
                     m = g.createMessage("clanChangeSettings");
                     m.add(inputName.text);
                     m.add(inputRank1.text);
                     m.add(inputRank2.text);
                     m.add(inputRank3.text);
                     m.add(inputRank4.text);
                     m.add(inputDescription.text);
                     m.add(logo.color);
                     m.add(clanObj.logo);
                     g.rpcMessage(m, function(param1:Message):void
                        {
                           if (param1.getBoolean(0))
                           {
                              g.showErrorDialog(Localize.t("Success!"));
                           }
                           else
                           {
                              g.showErrorDialog(param1.getString(1));
                           }
                           drawEditView(clanId);
                        });
                  }, Localize.t("Save Settings"), "buy");
               saveButton.x = 400;
               saveButton.y = logo.y + logo.height + padding;
               viewContainer.addChild(saveButton);
               deleteButton = new Button(function():void
                  {
                     var m:Message;
                     backButton.enabled = false;
                     g.blockHotkeys = true;
                     m = g.createMessage("clanDelete");
                     g.rpcMessage(m, function(param1:Message):void
                        {
                           if (!param1.getBoolean(0))
                           {
                              g.showErrorDialog(param1.getString(1));
                              return;
                           }
                           g.showErrorDialog(Localize.t("Clan deleted."));
                           g.me.clanId = "";
                           TweenMax.delayedCall(2, drawClansView);
                        });
                  }, Localize.t("Delete clan"), "negative");
               deleteButton.x = 400;
               deleteButton.y = logo.y + logo.height + padding + 100;
               viewContainer.addChild(deleteButton);
            });
      }

      private function drawApplyView(param1:String):void
      {
         var clanId:String = param1;
         STATUS = "apply";
         dataManager.loadKeyFromBigDB("Clans", clanId, function(param1:Object):void
            {
               var backButton:Button;
               var info:Text;
               var inputReason:InputText;
               var saveButton:Button;
               var clanObj:Object = param1;
               if (STATUS != "apply")
               {
                  return;
               }
               g.blockHotkeys = true;
               viewContainer.removeChildren(0, -1, true);
               backButton = new Button(function():void
                  {
                     g.blockHotkeys = false;
                     drawClanView(clanObj.key);
                  }, Localize.t("back"));
               backButton.x = 680 - backButton.width;
               backButton.y = 60;
               viewContainer.addChild(backButton);
               info = new Text();
               info.text = Localize.t("You can have one pending application at a time. \nAny active applications will be removed.");
               info.wordWrap = true;
               info.x = 60;
               info.y = 100;
               info.width = 500;
               info.height = 50;
               viewContainer.addChild(info);
               inputReason = new InputText(0, 0, 400, 22);
               inputReason.text = Localize.t("I want to join your clan!");
               inputReason.x = 60;
               inputReason.y = info.y + info.height + 30;
               viewContainer.addChild(inputReason);
               saveButton = new Button(function():void
                  {
                     var m:Message = g.createMessage("clanApply");
                     m.add(clanId);
                     m.add(inputReason.text);
                     g.rpcMessage(m, function(param1:Message):void
                        {
                           if (param1.getBoolean(0))
                           {
                              me.clanApplicationId = clanObj.key;
                              g.sendToServiceRoom("clanApplication", clanObj.key);
                              drawClanView(clanId);
                              g.showErrorDialog(Localize.t("You have applied!"));
                           }
                           else
                           {
                              g.showErrorDialog(param1.getString(1));
                           }
                        });
                  }, Localize.t("Send Application"), "buy");
               saveButton.x = 60;
               saveButton.y = inputReason.y + 40;
               viewContainer.addChild(saveButton);
            });
      }

      private function drawHandleApplicationsView(param1:String):void
      {
         var clanId:String = param1;
         STATUS = "handle_applications";
         dataManager.loadKeyFromBigDB("Clans", clanId, function(param1:Object):void
            {
               var backButton:Button;
               var i:int;
               var application:Object;
               var t:Text;
               var clanObj:Object = param1;
               if (STATUS != "handle_applications")
               {
                  return;
               }
               viewContainer.removeChildren(0, -1, true);
               backButton = new Button(function():void
                  {
                     g.blockHotkeys = false;
                     drawClanView(clanObj.key);
                  }, Localize.t("back"));
               backButton.x = 680 - backButton.width;
               backButton.y = 60;
               viewContainer.addChild(backButton);
               viewContainer.addChild(applicationsList);
               applicationsList.width = 650;
               applicationsList.height = 440;
               applicationsList.x = 80;
               applicationsList.y = 100;
               i = 0;
               for each (application in clanObj.applications)
               {
                  drawApplication(application, i, clanObj);
                  i++;
               }
               if (i == 0)
               {
                  t = new Text();
                  t.text = Localize.t("You have no new applications to handle.");
                  t.size = 16;
                  t.x = 60;
                  t.y = 120;
                  applicationsList.addChild(t);
                  return;
               }
            });
      }

      private function drawApplication(param1:Object, param2:int, param3:Object):void
      {
         var application:Object = param1;
         var i:int = param2;
         var clanObj:Object = param3;
         var playerId:String = application.player;
         var reason:String = application.reason;
         dataManager.loadKeyFromBigDB("PlayerObjects", playerId, function(param1:Object):void
            {
               var contM:Sprite;
               var bgrM:Quad;
               var positionM:Text;
               var skinObj:Object;
               var shipObj:Object;
               var img:Image;
               var name:Text;
               var level:Text;
               var acceptButton:Button;
               var declineButton:Button;
               var troonsM:Text;
               var troonImgM:Image;
               var troonContainer:Sprite;
               var acceptedText:TextBitmap;
               var promoteContainer:Sprite;
               var mObj:Object = param1;
               if (STATUS != "handle_applications")
               {
                  return;
               }
               contM = new Sprite();
               bgrM = new Quad(620, 60, 921102);
               positionM = new Text();
               positionM.text = (i + 1).toString();
               positionM.size = 16;
               positionM.x = 20;
               positionM.y = 20;
               positionM.touchable = false;
               skinObj = dataManager.loadKey("Skins", mObj.activeSkin);
               shipObj = dataManager.loadKey("Ships", skinObj.ship);
               img = new Image(textureManager.getTexturesMainByKey(shipObj.bitmap)[0]);
               img.x = 60;
               img.y = 10;
               img.touchable = false;
               name = new Text();
               name.text = mObj.name;
               name.x = 120;
               name.y = 10;
               name.size = 16;
               name.touchable = false;
               level = new Text();
               level.text = Localize.t("lvl") + " " + mObj.level;
               level.color = 11184810;
               level.x = 260;
               level.y = 20;
               level.size = 12;
               level.touchable = false;
               new ToolTip(g, contM, Localize.t("Application") + ": <FONT COLOR='#ffffff'>" + reason + "</FONT>", null, "clan");
               acceptButton = new Button(function():void
                  {
                     var m:Message = g.createMessage("clanAcceptApplication");
                     m.add(playerId);
                     acceptButton.enabled = false;
                     declineButton.enabled = false;
                     g.blockHotkeys = true;
                     g.rpcMessage(m, function(param1:Message):void
                        {
                           var _loc2_:Message = null;
                           if (param1.getBoolean(0))
                           {
                              _loc2_ = g.createMessage("clanApplicationAccept");
                              _loc2_.add(playerId);
                              _loc2_.add(clanObj.name);
                              g.sendMessageToServiceRoom(_loc2_);
                              g.showErrorDialog(Localize.t("Application accepted!"));
                              Action.join(clanObj.name);
                           }
                           else
                           {
                              g.showErrorDialog(param1.getString(1));
                           }
                           drawHandleApplicationsView(clanObj.key);
                           g.blockHotkeys = false;
                        });
                  }, Localize.t("Accept"), "buy");
               acceptButton.x = 300;
               acceptButton.y = 20;
               declineButton = new Button(function():void
                  {
                     var m:Message = g.createMessage("clanDeclineApplication");
                     m.add(clanObj.key);
                     m.add(playerId);
                     acceptButton.enabled = false;
                     declineButton.enabled = false;
                     g.blockHotkeys = true;
                     g.rpcMessage(m, function(param1:Message):void
                        {
                           var _loc2_:Message = null;
                           if (param1.getBoolean(0))
                           {
                              _loc2_ = g.createMessage("clanApplicationDecline");
                              _loc2_.add(playerId);
                              _loc2_.add(clanObj.name);
                              g.sendMessageToServiceRoom(_loc2_);
                              g.showErrorDialog(Localize.t("Application declined!"));
                           }
                           else
                           {
                              g.showErrorDialog(param1.getString(1));
                           }
                           drawHandleApplicationsView(clanObj.key);
                           g.blockHotkeys = false;
                        });
                  }, Localize.t("Decline"), "negative");
               declineButton.x = acceptButton.x + acceptButton.width + 5;
               declineButton.y = 20;
               troonsM = new Text();
               troonsM.text = mObj.troons == null ? "1000" : mObj.troons.toString();
               troonsM.x = 420;
               troonsM.y = 5;
               troonsM.size = 36;
               troonsM.color = 15985920;
               troonImgM = new Image(textureManager.getTextureGUIByTextureName("troon.png"));
               troonImgM.x = troonsM.x + troonsM.width + 10;
               troonImgM.y = troonsM.y + 15;
               contM.addChild(bgrM);
               contM.addChild(positionM);
               contM.addChild(img);
               contM.addChild(name);
               troonContainer = new Sprite();
               troonContainer.addChild(troonsM);
               troonContainer.addChild(troonImgM);
               troonContainer.addChild(level);
               contM.addChild(troonContainer);
               troonContainer.touchable = false;
               contM.y = i * 80;
               contM.x = 0;
               applicationsList.addChild(contM);
               if (application.accepted)
               {
                  acceptedText = new TextBitmap();
                  acceptedText.text = Localize.t("ACCEPTED").toUpperCase();
                  acceptedText.x = name.x;
                  acceptedText.y = name.y + name.height;
                  acceptedText.format.color = 4521796;
                  contM.addChild(acceptedText);
                  acceptButton.visible = false;
               }
               promoteContainer = new Sprite();
               promoteContainer.addChild(acceptButton);
               promoteContainer.addChild(declineButton);
               contM.addChild(promoteContainer);
               promoteContainer.visible = false;
               if (isAllowedToAcceptApplications(clanObj, g.me.id) && !isLeader(clanObj, playerId))
               {
                  contM.addEventListener("touch", fMemberTouch(clanObj, promoteContainer, troonContainer, contM));
               }
            });
      }

      private function getMemberRank(param1:Object, param2:String):int
      {
         for each (var _loc3_:* in param1.members)
         {
            if (_loc3_.player == param2)
            {
               return _loc3_.rank;
            }
         }
         return 4;
      }

      public function isAllowedToChangeSettings(param1:Object, param2:String):Boolean
      {
         return getMemberRank(param1, param2) == 1;
      }

      public function isAllowedToPromote(param1:Object, param2:String):Boolean
      {
         return getMemberRank(param1, param2) <= 2;
      }

      public function isAllowedToAcceptApplications(param1:Object, param2:String):Boolean
      {
         return getMemberRank(param1, param2) <= 2;
      }

      public function isLeader(param1:Object, param2:String):Boolean
      {
         return getMemberRank(param1, param2) == 1;
      }

      override public function execute():void
      {
         if (loaded)
         {
            if (keybinds.isEscPressed)
            {
               sm.revertState();
            }
         }
         super.execute();
      }

      override public function exit(param1:Function):void
      {
         ToolTip.disposeType("clan");
         g.updateServiceRoom();
         container.removeChildren(0, -1, true);
         super.exit(param1);
      }
   }
}
