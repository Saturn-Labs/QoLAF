package core.hud.components.chat
{
   import core.player.Player;
   import core.player.PlayerManager;
   import core.scene.Game;
   import feathers.controls.TabBar;
   import feathers.controls.TextInput;
   import feathers.data.ListCollection;
   import flash.ui.Mouse;
   import sound.Playlist;
   import starling.core.Starling;
   import starling.display.Sprite;
   import starling.events.Event;

   public class ChatInputText extends Sprite
   {
      private static const SPAM_TIME_LIMIT:int = 1000;

      private static const SPAM_TIME_LIMIT_GLOBAL:int = 30000;

      private var g:Game;

      private var history:Vector.<String>;

      private var nextRdySendTime:Number = 0;

      private var nextGlobalRdySendTime:Number = 0;

      public var chatMode:String = "local";

      private var savedPrivateTarget:String = "";

      public var lastPrivateReceived:String = "";

      private var input:TextInput;

      private var tabs:TabBar;

      public function ChatInputText(param1:Game, param2:int, param3:int, param4:int, param5:int)
      {
         history = new Vector.<String>();
         tabs = new TabBar();
         super();
         this.g = param1;
         visible = false;
         this.x = param2;
         this.y = param3;
         var _loc6_:ListCollection = new ListCollection([ {
                     "label": "Local",
                     "chatMode": "local"
                  }, {
                     "label": "Global",
                     "chatMode": "global"
                  }, {
                     "label": "Clan",
                     "chatMode": "clan"
                  }, {
                     "label": "Group",
                     "chatMode": "group"
                  }]);
         if (param1.me.isModerator || param1.me.isDeveloper)
         {
            _loc6_.addItem( {
                     "label": "Mod",
                     "chatMode": "modchat"
                  });
         }
         tabs.dataProvider = _loc6_;
         tabs.styleNameList.add("chat_tabs");
         tabs.addEventListener("change", onTabChange);
         tabs.selectedIndex = 0;
         tabs.width = param4;
         input = new TextInput();
         input.styleName = "chat";
         input.y = 24;
         input.width = param4;
         input.height = param5;
         addChild(input);
      }

      private function onTabChange(param1:Event):void
      {
         if (tabs.selectedIndex != -1)
         {
            chatMode = tabs.selectedItem.chatMode;
            input.setFocus();
         }
      }

      private function updateTab():void
      {
         var _loc2_:int = 0;
         var _loc1_:Object = null;
         _loc2_ = 0;
         while (_loc2_ < tabs.dataProvider.length)
         {
            _loc1_ = tabs.dataProvider.getItemAt(_loc2_);
            if (_loc1_.chatMode === chatMode)
            {
               tabs.selectedIndex = _loc2_;
               return;
            }
            _loc2_++;
         }
         tabs.selectedIndex = 0;
      }

      public function closeChat():void
      {
         if (g == null)
         {
            return;
         }
         if (isActive())
         {
            input.text = "";
            visible = false;
            Starling.current.nativeStage.focus = null;
            Mouse.cursor = "arrow";
         }
      }

      public function toggleChatMode():void
      {
         if (g == null)
         {
            return;
         }
         if (!contains(tabs))
         {
            addChild(tabs);
         }
         visible = !visible;
         if (visible)
         {
            input.setFocus();
         }
         else
         {
            sendMessage();
            Starling.current.nativeStage.focus = null;
            Mouse.cursor = "arrow";
            visible = false;
         }
      }

      public function isActive():Boolean
      {
         return visible;
      }

      public function setText(param1:String):void
      {
         var message:String = param1;
         if (!visible)
         {
            toggleChatMode();
         }
         input.text = message;
         Starling.juggler.delayCall(function():void
            {
               input.selectRange(input.text.length);
            }, 0.2);
      }

      private function parseCommand(param1:String):Vector.<String>
      {
         var _loc3_:int = 0;
         var _loc2_:Vector.<String> = new Vector.<String>();
         if (param1.length >= 2 && param1.charAt(0) == "/")
         {
            _loc3_ = 1;
            while (_loc3_ < param1.length && param1.charAt(_loc3_) != " ")
            {
               _loc3_++;
            }
            _loc2_.push(param1.substring(1, _loc3_));
            if (_loc2_[0] == "")
            {
               _loc2_[0] = chatMode;
            }
            if (param1.length > _loc3_)
            {
               _loc2_.push(param1.substring(_loc3_ + 1));
            }
            return _loc2_;
         }
         _loc2_.push(chatMode);
         _loc2_.push(param1);
         return _loc2_;
      }

      private function sendMessage():void
      {
         var output:Vector.<String>;
         var tmp:Array;
         var q:int;
         var text:String = input.text;
         if (text == "")
         {
            return;
         }
         output = parseCommand(text);
         switch (output[0])
         {
            case "y":
            case "yes":
               sendConfirmInviteGroup();
               break;
            case "i":
            case "inv":
            case "invite":
               if (output.length == 2)
               {
                  sendInvite(output[1]);
               }
               break;
            case "g":
            case "grp":
            case "group":
               chatMode = "group";
               if (output.length == 2)
               {
                  sendGroup(output[1]);
               }
               break;
            case "go":
               sendChatMessageMod(output[1]);
               break;
            case "m":
            case "w":
            case "whisper":
            case "t":
            case "tell":
            case "private":
               if (output.length == 2)
               {
                  chatMode = "privateSaved";
                  tmp = output[1].split(" ", 1);
                  sendPrivate(output[1].replace(tmp[0] + " ", ""), tmp[0]);
               }
               break;
            case "privateSaved":
               sendPrivate(output[1], savedPrivateTarget);
               break;
            case "r":
            case "reply":
               if (output.length == 2)
               {
                  sendPrivate(output[1], lastPrivateReceived);
               }
               break;
            case "l":
            case "local":
               chatMode = "local";
               if (output.length == 2)
               {
                  sendLocal(output[1]);
               }
               break;
            case "global":
               if (output.length == 2)
               {
                  sendGlobal(output[1]);
               }
               break;
            case "c":
            case "clan":
               chatMode = "clan";
               if (output.length == 2)
               {
                  sendLocal(output[1], "clan");
               }
               break;
            case "modchat":
               chatMode = "modchat";
               if (output.length == 2 && (g.me.isModerator || g.me.isDeveloper))
               {
                  sendLocal(output[1], "modchat");
               }
               break;
            case "leave":
               sendLeave();
               break;
            case "help":
            case "commands":
            case "command":
               listCommands();
               break;
            case "list":
               listPlayers();
               break;
            case "msgstats":
               getMsgStats();
               break;
            case "ignore":
            case "mute":
            case "unignore":
            case "ban":
            case "unban":
            case "kick":
            case "getId":
            case "warpToId":
            case "silence":
            case "silenceall":
            case "sil":
            case "silall":
            case "showbans":
            case "showbanhistory":
            case "onlinestats":
            case "eventurl":
            case "eventimage":
            case "unmute":
               sendSettingMsg(output);
               break;
            case "lowerfps":
               RymdenRunt.s.nativeStage.frameRate = 3;
               break;
            case "stats":
               g.traceDisplayObjectCounts();
               break;
            case "report":
               if (output.length == 2)
               {
                  reportPlayer(output[1]);
               }
               break;
            case "showquality":
               g.showQuality();
               break;
            case "setquality":
               q = parseInt(output[1]);
               g.setQuality(q);
               break;
            case "reloadtexts":
               g.reloadTexts();
               break;
            case "myid":
               Starling.juggler.delayCall(function():void
                  {
                     setText(g.me.id);
                  }, 0.2);
               break;
            case "profile":
               MessageLog.write(Starling.current.profile);
               break;
            case "next":
               Playlist.next();
               break;
            default:
               MessageLog.write("invalid command, type /help for valid commands");
         }
         input.text = "";
         updateTab();
      }

      private function reportPlayer(param1:String):void
      {
         var _loc3_:Array = param1.split(" ", 2);
         if (_loc3_.length == 0)
         {
            return;
         }
         var _loc4_:Boolean = false;
         for each (var _loc2_:* in g.playerManager.players)
         {
            if (_loc2_.name == _loc3_[0])
            {
               _loc4_ = true;
            }
         }
         if (_loc4_ == false)
         {
            return;
         }
         if (_loc3_.length > 1)
         {
            param1 = param1.replace(_loc3_[0] + " ", "");
            Game.trackEvent("reportedPlayers", _loc3_[0], param1 + " (" + g.me.name + ")", 1);
         }
         else if (_loc3_.length > 0)
         {
            Game.trackEvent("reportedPlayers", _loc3_[0], "no reason (" + g.me.name + ")", 1);
         }
      }

      private function listCommands():void
      {
         MessageLog.write("''/i, /inv, /invite PlayerName'' to send a group invite");
         MessageLog.write("''/leave'' to leave your group");
         MessageLog.write("''/l, /local, msg'' sends a msg to all");
         MessageLog.write("''/c, /clan, msg'' sends a msg to your clan");
         MessageLog.write("''/g, /grp, /group msg'' sends a msg to your group");
         MessageLog.write("''/w, /whisper, /m, /t, /tell, /private PlayerName msg'' sends a msg to that player");
         MessageLog.write("''/r, /reply msg'' to reply to last private msg");
         MessageLog.write("''/list'' lists all players in the system");
         MessageLog.write("''/ignore name'' ignore a player");
         MessageLog.write("''/unignore name'' remove ignore");
      }

      private function getMsgStats():void
      {
         g.send("getMsgStats");
      }

      private function listPlayers():void
      {
         if (g != null && g.playerManager != null)
         {
            g.playerManager.listAll();
         }
      }

      private function sendSettingMsg(param1:Vector.<String>):void
      {
         if (param1.length == 2)
         {
            g.sendToServiceRoom("chatMsg", param1[0], param1[1]);
            g.send("chatMsg", param1[0], param1[1]);
         }
         else
         {
            g.sendToServiceRoom("chatMsg", param1[0]);
         }
      }

      private function sendPrivate(param1:String, param2:String):void
      {
         if (PlayerManager.banMinutes && PlayerManager.isAllChannels)
         {
            MessageLog.write("You are banned from private chat for " + PlayerManager.banMinutes + " more minutes.");
            return;
         }
         savedPrivateTarget = param2;
         var _loc4_:int = tabs.dataProvider.length;
         var _loc3_:Object = tabs.dataProvider.getItemAt(_loc4_ - 1);
         if (_loc3_.chatMode == "privateSaved")
         {
            _loc3_.label = param2;
         }
         else
         {
            _loc3_ = {
                  "label": param2,
                  "chatMode": "privateSaved"
               };
            tabs.dataProvider.addItem(_loc3_);
         }
         tabs.invalidate();
         g.sendToServiceRoom("chatMsg", "private", param2, param1);
      }

      private function sendLocal(param1:String, param2:String = "local"):void
      {
         if (PlayerManager.banMinutes > 0 && PlayerManager.isAllChannels && param2 != "clan")
         {
            MessageLog.write("You are banned from local chat for " + PlayerManager.banMinutes + " more minutes.");
            return;
         }
         if (nextRdySendTime > g.time)
         {
            MessageLog.write("Hold your horses cowboy.");
            return;
         }
         if (g.messageLog.isMuted("local"))
         {
            MessageLog.write("[error] You have muted local chat", "error");
            return;
         }
         history.push(param1);
         nextRdySendTime = g.time + 1000;
         if (chatMode == "local")
         {
            g.sendToServiceRoom("chatMsg", param2, param1);
         }
         else
         {
            g.sendToServiceRoom("chatMsg", param2, param1);
         }
      }

      private function sendGroup(param1:String):void
      {
         var keys:Array;
         var msg:String = param1;
         if (msg.replace(" ", "") === "")
         {
            return;
         }
         if (PlayerManager.banMinutes > 0 && PlayerManager.isAllChannels)
         {
            MessageLog.write("You are banned from group chat for " + PlayerManager.banMinutes + " more minutes.");
            return;
         }
         if (g.messageLog.isMuted("group"))
         {
            MessageLog.write("[error] You have muted local chat", "error");
            return;
         }
         keys = [];
         g.me.group.players.forEach(function(param1:Player, param2:int, param3:Vector.<Player>):void
            {
               keys.push(param1.id);
            });
         g.sendToServiceRoom("chatMsg", "group", keys.join(), msg);
      }

      private function sendGlobal(param1:String):void
      {
         if (PlayerManager.banMinutes > 0)
         {
            MessageLog.write("You are banned from global chat for " + PlayerManager.banMinutes + " more minutes.");
            return;
         }
         if (g.messageLog.isMuted("global"))
         {
            MessageLog.write("[error] You have muted global chat", "error");
            return;
         }
         if (nextGlobalRdySendTime < g.time || g.me.isDeveloper || g.me.isModerator)
         {
            history.push(param1);
            nextGlobalRdySendTime = g.time + 30000;
            g.sendToServiceRoom("chatMsg", "global", param1);
            g.chatInput.chatMode = "local";
         }
         else if (nextGlobalRdySendTime > g.time)
         {
            MessageLog.write("You have to wait " + Math.round((nextGlobalRdySendTime - g.time) / 1000) + " seconds.");
         }
      }

      private function sendChatMessageMod(param1:String):void
      {
         if (nextRdySendTime < g.time)
         {
            history.push(param1);
            nextRdySendTime = g.time + 1000;
            g.send("devMsg", "mod", param1);
         }
         else if (nextRdySendTime > g.time)
         {
            MessageLog.write("Hold your horses cowboy.");
         }
      }

      private function sendConfirmInviteGroup():void
      {
         if (g != null)
         {
            g.groupManager.acceptGroupInvite();
         }
      }

      private function sendInvite(param1:String):void
      {
         if (param1 != "")
         {
            for each (var _loc2_:* in g.playerManager.players)
            {
               if (param1 == _loc2_.name)
               {
                  g.groupManager.invitePlayer(_loc2_);
               }
            }
         }
      }

      private function sendLeave():void
      {
         g.groupManager.leaveGroup();
      }

      public function previous():void
      {
         if (history.length > 0)
         {
            input.text = history.pop();
            history.unshift(input.text);
         }
      }

      public function next():void
      {
         if (history.length > 0)
         {
            input.text = history.shift();
            history.push(input.text);
         }
      }
   }
}
