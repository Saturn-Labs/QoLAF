package core.hud.components.chat {
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
	
	public class ChatInputText extends Sprite {
		private static const SPAM_TIME_LIMIT:int = 1000;
		
		private static const SPAM_TIME_LIMIT_GLOBAL:int = 30000;
		
		private var g:Game;
		
		private var history:Vector.<String> = new Vector.<String>();
		
		private var nextRdySendTime:Number = 0;
		
		private var nextGlobalRdySendTime:Number = 0;
		
		public var chatMode:String = "local";
		
		private var savedPrivateTarget:String = "";
		
		public var lastPrivateReceived:String = "";
		
		private var input:TextInput;
		
		private var tabs:TabBar = new TabBar();
		
		public function ChatInputText(g:Game, x:int, y:int, w:int, h:int) {
			super();
			this.g = g;
			visible = false;
			this.x = x;
			this.y = y;
			var _local6:ListCollection = new ListCollection([{
				"label":"Local",
				"chatMode":"local"
			},{
				"label":"Global",
				"chatMode":"global"
			},{
				"label":"Clan",
				"chatMode":"clan"
			},{
				"label":"Group",
				"chatMode":"group"
			}]);
			if(g.me.isModerator || g.me.isDeveloper) {
				_local6.addItem({
					"label":"Mod",
					"chatMode":"modchat"
				});
			}
			tabs.dataProvider = _local6;
			tabs.styleNameList.add("chat_tabs");
			tabs.addEventListener("change",onTabChange);
			tabs.selectedIndex = 0;
			tabs.width = w;
			input = new TextInput();
			input.styleName = "chat";
			input.y = 24;
			input.width = w;
			input.height = h;
			input.restrict = "^<>=&#[]{}";
			addChild(input);
		}
		
		private function onTabChange(e:Event) : void {
			if(tabs.selectedIndex != -1) {
				chatMode = tabs.selectedItem.chatMode;
				input.setFocus();
			}
		}
		
		private function updateTab() : void {
			var _local2:int = 0;
			var _local1:Object = null;
			_local2 = 0;
			while(_local2 < tabs.dataProvider.length) {
				_local1 = tabs.dataProvider.getItemAt(_local2);
				if(_local1.chatMode === chatMode) {
					tabs.selectedIndex = _local2;
					return;
				}
				_local2++;
			}
			tabs.selectedIndex = 0;
		}
		
		public function closeChat() : void {
			if(g == null) {
				return;
			}
			if(isActive()) {
				input.text = "";
				visible = false;
				Starling.current.nativeStage.focus = null;
				Mouse.cursor = "arrow";
			}
		}
		
		public function toggleChatMode() : void {
			if(g == null) {
				return;
			}
			if(!contains(tabs)) {
				addChild(tabs);
			}
			visible = !visible;
			if(visible) {
				input.setFocus();
			} else {
				sendMessage();
				Starling.current.nativeStage.focus = null;
				Mouse.cursor = "arrow";
				visible = false;
			}
		}
		
		public function isActive() : Boolean {
			return visible;
		}
		
		public function setText(message:String) : void {
			if(!visible) {
				toggleChatMode();
			}
			input.text = message;
			Starling.juggler.delayCall(function():void {
				input.selectRange(input.text.length);
			},0.2);
		}
		
		private function parseCommand(input:String) : Vector.<String> {
			var _local3:int = 0;
			var _local2:Vector.<String> = new Vector.<String>();
			if(input.length >= 2 && input.charAt(0) == "/") {
				_local3 = 1;
				while(_local3 < input.length && input.charAt(_local3) != " ") {
					_local3++;
				}
				_local2.push(input.substring(1,_local3));
				if(_local2[0] == "") {
					_local2[0] = chatMode;
				}
				if(input.length > _local3) {
					_local2.push(input.substring(_local3 + 1));
				}
				return _local2;
			}
			_local2.push(chatMode);
			_local2.push(input);
			return _local2;
		}
		
		private function sendMessage() : void {
			var output:Vector.<String>;
			var tmp:Array;
			var q:int;
			var text:String = input.text;
			if(text == "") {
				return;
			}
			output = parseCommand(text);
			switch(output[0]) {
				case "y":
				case "yes":
					sendConfirmInviteGroup();
					break;
				case "i":
				case "inv":
				case "invite":
					if(output.length == 2) {
						sendInvite(output[1]);
					}
					break;
				case "g":
				case "grp":
				case "group":
					chatMode = "group";
					if(output.length == 2) {
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
					if(output.length == 2) {
						chatMode = "privateSaved";
						tmp = output[1].split(" ",1);
						sendPrivate(output[1].replace(tmp[0] + " ",""),tmp[0]);
					}
					break;
				case "privateSaved":
					sendPrivate(output[1],savedPrivateTarget);
					break;
				case "r":
				case "reply":
					if(output.length == 2) {
						sendPrivate(output[1],lastPrivateReceived);
					}
					break;
				case "l":
				case "local":
					chatMode = "local";
					if(output.length == 2) {
						sendLocal(output[1]);
					}
					break;
				case "global":
					if(output.length == 2) {
						sendGlobal(output[1]);
					}
					break;
				case "c":
				case "clan":
					chatMode = "clan";
					if(output.length == 2) {
						sendLocal(output[1],"clan");
					}
					break;
				case "modchat":
					chatMode = "modchat";
					if(output.length == 2 && (g.me.isModerator || g.me.isDeveloper)) {
						sendLocal(output[1],"modchat");
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
					if(output.length == 2) {
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
					Starling.juggler.delayCall(function():void {
						setText(g.me.id);
					},0.2);
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
		
		private function reportPlayer(s:String) : void {
			var _local3:Array = s.split(" ",2);
			if(_local3.length == 0) {
				return;
			}
			var _local4:Boolean = false;
			for each(var _local2 in g.playerManager.players) {
				if(_local2.name == _local3[0]) {
					_local4 = true;
				}
			}
			if(_local4 == false) {
				return;
			}
			if(_local3.length > 1) {
				s = s.replace(_local3[0] + " ","");
				Game.trackEvent("reportedPlayers",_local3[0],s + " (" + g.me.name + ")",1);
			} else if(_local3.length > 0) {
				Game.trackEvent("reportedPlayers",_local3[0],"no reason (" + g.me.name + ")",1);
			}
		}
		
		private function listCommands() : void {
			MessageLog.write("\'\'/i, /inv, /invite PlayerName\'\' to send a group invite");
			MessageLog.write("\'\'/leave\'\' to leave your group");
			MessageLog.write("\'\'/l, /local, msg\'\' sends a msg to all");
			MessageLog.write("\'\'/c, /clan, msg\'\' sends a msg to your clan");
			MessageLog.write("\'\'/g, /grp, /group msg\'\' sends a msg to your group");
			MessageLog.write("\'\'/w, /whisper, /m, /t, /tell, /private PlayerName msg\'\' sends a msg to that player");
			MessageLog.write("\'\'/r, /reply msg\'\' to reply to last private msg");
			MessageLog.write("\'\'/list\'\' lists all players in the system");
			MessageLog.write("\'\'/ignore name\'\' ignore a player");
			MessageLog.write("\'\'/unignore name\'\' remove ignore");
		}
		
		private function getMsgStats() : void {
			g.send("getMsgStats");
		}
		
		private function listPlayers() : void {
			if(g != null && g.playerManager != null) {
				g.playerManager.listAll();
			}
		}
		
		private function sendSettingMsg(output:Vector.<String>) : void {
			if(output.length == 2) {
				g.sendToServiceRoom("chatMsg",output[0],output[1]);
				g.send("chatMsg",output[0],output[1]);
			} else {
				g.sendToServiceRoom("chatMsg",output[0]);
			}
		}
		
		private function sendPrivate(msg:String, target:String) : void {
			if(PlayerManager.banMinutes && PlayerManager.isAllChannels) {
				MessageLog.write("You are banned from private chat for " + PlayerManager.banMinutes + " more minutes.");
				return;
			}
			savedPrivateTarget = target;
			var _local4:int = tabs.dataProvider.length;
			var _local3:Object = tabs.dataProvider.getItemAt(_local4 - 1);
			if(_local3.chatMode == "privateSaved") {
				_local3.label = target;
			} else {
				_local3 = {
					"label":target,
					"chatMode":"privateSaved"
				};
				tabs.dataProvider.addItem(_local3);
			}
			tabs.invalidate();
			g.sendToServiceRoom("chatMsg","private",target,msg);
		}
		
		private function sendLocal(input:String, msgType:String = "local") : void {
			if(PlayerManager.banMinutes > 0 && PlayerManager.isAllChannels && msgType != "clan") {
				MessageLog.write("You are banned from local chat for " + PlayerManager.banMinutes + " more minutes.");
				return;
			}
			if(nextRdySendTime > g.time) {
				MessageLog.write("Hold your horses cowboy.");
				return;
			}
			if(g.messageLog.isMuted("local")) {
				MessageLog.write("[error] You have muted local chat","error");
				return;
			}
			history.push(input);
			nextRdySendTime = g.time + 1000;
			if(chatMode == "local") {
				g.sendToServiceRoom("chatMsg",msgType,input);
			} else {
				g.sendToServiceRoom("chatMsg",msgType,input);
			}
		}
		
		private function sendGroup(msg:String) : void {
			var keys:Array;
			if(msg.replace(" ","") === "") {
				return;
			}
			if(PlayerManager.banMinutes > 0 && PlayerManager.isAllChannels) {
				MessageLog.write("You are banned from group chat for " + PlayerManager.banMinutes + " more minutes.");
				return;
			}
			if(g.messageLog.isMuted("group")) {
				MessageLog.write("[error] You have muted local chat","error");
				return;
			}
			keys = [];
			g.me.group.players.forEach(function(param1:Player, param2:int, param3:Vector.<Player>):void {
				keys.push(param1.id);
			});
			g.sendToServiceRoom("chatMsg","group",keys.join(),msg);
		}
		
		private function sendGlobal(input:String) : void {
			if(PlayerManager.banMinutes > 0) {
				MessageLog.write("You are banned from global chat for " + PlayerManager.banMinutes + " more minutes.");
				return;
			}
			if(g.messageLog.isMuted("global")) {
				MessageLog.write("[error] You have muted global chat","error");
				return;
			}
			if(nextGlobalRdySendTime < g.time || g.me.isDeveloper || g.me.isModerator) {
				history.push(input);
				nextGlobalRdySendTime = g.time + 500 * 60;
				g.sendToServiceRoom("chatMsg","global",input);
				g.chatInput.chatMode = "local";
			} else if(nextGlobalRdySendTime > g.time) {
				MessageLog.write("You have to wait " + Math.round((nextGlobalRdySendTime - g.time) / 1000) + " seconds.");
			}
		}
		
		private function sendChatMessageMod(input:String) : void {
			if(nextRdySendTime < g.time) {
				history.push(input);
				nextRdySendTime = g.time + 1000;
				g.send("devMsg","mod",input);
			} else if(nextRdySendTime > g.time) {
				MessageLog.write("Hold your horses cowboy.");
			}
		}
		
		private function sendConfirmInviteGroup() : void {
			if(g != null) {
				g.groupManager.acceptGroupInvite();
			}
		}
		
		private function sendInvite(input:String) : void {
			if(input != "") {
				for each(var _local2 in g.playerManager.players) {
					if(input == _local2.name) {
						g.groupManager.invitePlayer(_local2);
					}
				}
			}
		}
		
		private function sendLeave() : void {
			g.groupManager.leaveGroup();
		}
		
		public function previous() : void {
			if(history.length > 0) {
				input.text = history.pop();
				history.unshift(input.text);
			}
		}
		
		public function next() : void {
			if(history.length > 0) {
				input.text = history.shift();
				history.push(input.text);
			}
		}
	}
}

