package joinRoom {
	import com.adobe.crypto.MD5;
	import core.hud.components.dialogs.PopupMessage;
	import core.hud.components.starMap.StarMap;
	import core.player.Player;
	import core.scene.Game;
	import core.states.SceneStateMachine;
	import data.DataLocator;
	import data.IDataManager;
	import debug.Console;
	import feathers.core.FocusManager;
	import generics.GUID;
	import generics.Localize;
	import playerio.Client;
	import playerio.Connection;
	import playerio.Message;
	import playerio.PlayerIOError;
	import playerio.RoomInfo;
	import starling.display.Sprite;
	import starling.display.Stage;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import startSetup.StartSetup;
	
	public class JoinRoomManager extends EventDispatcher implements IJoinRoomManager {
		private var stage:Stage;
		
		private var client:Client;
		
		private var serviceConnection:Connection;
		
		private var connection:Connection;
		
		private var room:Room;
		
		private var roomStateMachine:SceneStateMachine;
		
		private var dataManager:IDataManager;
		
		private var joinData:Object;
		
		private var playerInfo:Object = {};
		
		private var _desiredRoomId:String = null;
		
		private var _desiredSystemType:String = "friendly";
		
		private var inited:Boolean = false;
		
		private var session:String = GUID.create();
		
		private var login:Login;
		
		public function JoinRoomManager(client:Client, stage:Stage, joinData:Object, login:Login) {
			super();
			this.client = client;
			this.joinData = joinData;
			this.stage = stage;
			this.login = login;
			dataManager = DataLocator.getService();
			roomStateMachine = new SceneStateMachine(stage);
		}
		
		public static function getServiceRoomID(index:int) : String {
			return "Service-1380_" + index;
		}
		
		public function init() : void {
			if(inited) {
				client.errorLog.writeError("Tried to init joinroom more than once.","","",{});
				return;
			}
			Console.write("Joinroom init.");
			inited = true;
			StartSetup.showProgressText(Localize.t("List service room"));
			client.multiplayer.listRooms("service",null,1000,0,handleServiceRooms,function(param1:PlayerIOError):void {
				showErrorDialog("Listing of service room failed.",true);
			});
		}
		
		private function handleServiceRooms(rooms:Array) : void {
			var _local4:String = null;
			var _local5:RoomInfo = null;
			var _local2:Room = new Room();
			_local2.roomType = "service";
			var _local6:Array = [];
			for each(var _local3 in rooms) {
				_local4 = _local3.id.substr(8,4);
				if((int(_local4)) >= 23 * 60) {
					_local2.id = _local3.id;
					_local6.push(_local3);
				}
			}
			StartSetup.showProgressText(Localize.t("Joining service room"));
			if(_local6.length == 0) {
				return joinServiceRoom(getServiceRoomID(0));
			}
			if(_local6.length == 1) {
				_local5 = _local6[0];
				if(_local5.onlineUsers < 950) {
					return joinServiceRoom(_local5.id);
				}
			}
			login.selectServiceRoom(_local6,joinServiceRoom);
		}
		
		public function joinServiceRoom(id:String) : void {
			login.removeEffects();
			client.multiplayer.createJoinRoom(id,"service",true,{},{"client_version":23 * 60},handleJoinServiceRoom,function(param1:PlayerIOError):void {
				if(param1.errorID != 2) {
					showErrorDialog("Join service room failed, please try again later. Contact us on forum.astroflux.org for support.",true,param1);
				}
			});
		}
		
		private function handleJoinServiceRoom(serviceConnection:Connection) : void {
			StartSetup.showProgressText(Localize.t("Joined service room"));
			FocusManager.setEnabledForStage(stage,false);
			this.serviceConnection = serviceConnection;
			serviceConnection.addMessageHandler("error",function(param1:Message):void {
				showErrorDialog(param1.getString(0));
			});
			serviceConnection.addMessageHandler("joined",onJoinedServiceRoom);
		}
		
		private function onJoinedServiceRoom(m:Message) : void {
			serviceConnection.removeMessageHandler("joined",onJoinedServiceRoom);
			var _local2:int = 0;
			playerInfo = {};
			playerInfo.key = m.getString(_local2++);
			playerInfo.level = m.getInt(_local2++);
			playerInfo.split = m.getString(_local2++);
			playerInfo.musicVolume = m.getNumber(_local2++);
			playerInfo.effectVolume = m.getNumber(_local2++);
			playerInfo.xp = m.getInt(_local2++);
			playerInfo.enemyKills = m.getInt(_local2++);
			playerInfo.bossKills = m.getInt(_local2++);
			playerInfo.suicides = m.getInt(_local2++);
			playerInfo.troons = m.getNumber(_local2++);
			playerInfo.enemyEncounters = m.getInt(_local2++);
			playerInfo.bossEncounters = m.getInt(_local2++);
			playerInfo.exploredPlanets = m.getInt(_local2++);
			playerInfo.systemType = m.getString(_local2++);
			playerInfo.currentRoom = m.getString(_local2++);
			playerInfo.currentRoomId = m.getString(_local2++);
			playerInfo.currentSolarSystem = m.getString(_local2++);
			playerInfo.systemType = m.getString(_local2++);
			playerInfo.clan = m.getString(_local2++);
			joinData["client_version"] = 23 * 60;
			joinData["session"] = session;
			joinData["warpJump"] = false;
			joinData["level"] = playerInfo.level > 0 ? playerInfo.level : 1;
			_desiredSystemType = playerInfo.systemType != "" ? playerInfo.systemType : "friendly";
			_desiredRoomId = playerInfo.currentRoomId != "" ? playerInfo.currentRoomId : null;
			dispatchEventWith("joinedServiceRoom",true,playerInfo);
		}
		
		public function rpcServiceRoom(type:String, handler:Function, ... rest) : void {
			var m:Message;
			var i:int;
			var args:Array = rest;
			serviceConnection.addMessageHandler(type,(function():* {
				var rpcHandler:Function;
				return rpcHandler = function(param1:Message):void {
					serviceConnection.removeMessageHandler(type,rpcHandler);
					handler(param1);
				};
			})());
			m = serviceConnection.createMessage(type);
			i = 0;
			while(i < args.length) {
				m.add(args[i]);
				i++;
			}
			serviceConnection.sendMessage(m);
		}
		
		public function joinCurrentSolarSystem() : void {
			var _local1:String = "HrAjOBivt0SHPYtxKyiB_Q";
			if(playerInfo.currentSolarSystem) {
				_local1 = playerInfo.currentSolarSystem;
				if(playerInfo.currentRoomId != "") {
					_desiredRoomId = playerInfo.currentRoomId;
				}
				if(_desiredSystemType == "clan") {
					if(playerInfo.clan != "") {
						_desiredRoomId = MD5.hash(playerInfo.currentSolarSystem + playerInfo.clan);
					} else {
						_desiredSystemType = "friendly";
						_desiredRoomId = null;
					}
				}
				if(_desiredSystemType == "survival" || _local1 == "ic3w-BxdMU6qWhX9t3_EaA") {
					_local1 = "DU6zMqKBIUGnUWA9eVVD-g";
					_desiredSystemType = "friendly";
					_desiredRoomId = null;
				}
			}
			if(dataManager.loadKey("SolarSystems",_local1) == null) {
				_local1 = "HrAjOBivt0SHPYtxKyiB_Q";
			}
			joinGame(_local1,joinData);
		}
		
		public function joinGame(solarSystemKey:String, joinData:Object) : void {
			var roomType:String;
			var dataManager:IDataManager;
			var solarSystemObj:Object;
			var roomData:Object;
			var searchCriteria:Object;
			joinData["client_version"] = 23 * 60;
			joinData["session"] = session;
			roomStateMachine.closeCurrentRoom();
			roomType = "game";
			Console.write("Trying to join " + roomType + " room");
			dataManager = DataLocator.getService();
			solarSystemObj = dataManager.loadKey("SolarSystems",solarSystemKey);
			roomData = {};
			roomData.solarSystemKey = solarSystemKey;
			roomData.service = serviceConnection.roomId;
			roomData.pvpAboveCap = joinData.level > solarSystemObj.pvpLvlCap;
			roomData.systemType = _desiredSystemType;
			Console.write("roomData.systemType " + roomData.systemType);
			room = new Room();
			room.roomType = roomType;
			room.data = roomData;
			room.joinData = joinData;
			if(!_desiredRoomId) {
				searchCriteria = {
					"solarSystemKey":solarSystemKey,
					"service":serviceConnection.roomId
				};
				StartSetup.showProgressText("Getting game rooms");
				client.multiplayer.listRooms(room.roomType,searchCriteria,1000,0,handleRooms,function(param1:PlayerIOError):void {
					Console.write("Error: " + param1);
				});
			} else {
				room.id = _desiredRoomId;
				createJoin();
			}
		}
		
		private function handleRooms(rooms:Array) : void {
			var _local5:* = false;
			var _local2:* = false;
			var _local3:int = 15;
			for each(var _local4 in rooms) {
				if(int(_local4.data.version) >= 23 * 60) {
					if(_local4.data.systemType == room.data.systemType) {
						if(_local4.onlineUsers < _local3) {
							if(_local4.data.modLocked != "true") {
								if(_local4.data.modClosed != "true") {
									if(room.data.systemType == "deathmatch" || room.data.systemType == "domination" || room.data.systemType == "arena") {
										room.id = _local4.id;
										break;
									}
									_local5 = _local4.data.systemType != "hostile";
									if(_local5) {
										room.id = _local4.id;
										break;
									}
									_local2 = _local4.data.pvpAboveCap == "true";
									if(_local2 == room.data.pvpAboveCap) {
										room.id = _local4.id;
										break;
									}
								}
							}
						}
					}
				}
			}
			if(_desiredRoomId) {
				room.id = _desiredRoomId;
			}
			createJoin();
		}
		
		private function createJoin() : void {
			Console.write("Attempting to create/join room.");
			StartSetup.showProgressText("Joining game room");
			client.multiplayer.createJoinRoom(room.id,room.roomType,false,room.data,room.joinData,handleJoin,function(param1:PlayerIOError):void {
			});
		}
		
		private function handleJoin(connection:Connection) : void {
			StartSetup.showProgressText("Joining game room");
			this.connection = connection;
			roomStateMachine.changeRoom(new Game(client,serviceConnection,connection,room));
			Console.write("Sucessfully connected to the multiplayer server");
		}
		
		public function tryWarpJumpToFriend(player:Player, destination:String, successCallback:Function, failedCallback:Function) : void {
			var searchCriteria:Object;
			if(!_desiredRoomId || _desiredSystemType == "clan") {
				successCallback();
				return;
			}
			searchCriteria = {"solarSystemKey":destination};
			client.multiplayer.listRooms("game",searchCriteria,100,0,(function():* {
				var onFound:Function;
				return onFound = function(param1:Array):void {
					var _local3:RoomInfo = null;
					var _local5:int = 0;
					_local5 = 0;
					while(_local5 < param1.length) {
						if(param1[_local5].id == _desiredRoomId) {
							_local3 = param1[_local5];
							break;
						}
						_local5++;
					}
					if(_local3 == null) {
						failedCallback("Friend instance not found");
						return;
					}
					if(_local3.data.systemType == "clan" && _local3.id != MD5.hash(_local3.data.solarSystemKey + player.clanId)) {
						failedCallback("Your friend is in a private clan instance.");
						return;
					}
					var _local6:* = _local3.data.systemType == "hostile";
					if(!_local6) {
						successCallback();
						return;
					}
					if(StarMap.selectedSolarSystem.pvpLvlCap == 0) {
						_desiredSystemType = "hostile";
						successCallback();
						return;
					}
					var _local4:* = _local3.data.pvpAboveCap == "true";
					var _local2:* = player.level > StarMap.selectedSolarSystem.pvpLvlCap;
					if(_local4 == _local2) {
						_desiredSystemType = "hostile";
						successCallback();
						return;
					}
					if(_local4) {
						failedCallback("This room only allows players over level " + (StarMap.selectedSolarSystem.pvpLvlCap + 1));
					} else {
						failedCallback("This room only allows players under level " + StarMap.selectedSolarSystem.pvpLvlCap);
					}
				};
			})(),(function():* {
				var onError:Function;
				return onError = function(param1:PlayerIOError):void {
				};
			})());
		}
		
		private function showErrorDialog(m:String, sendToErrorLog:Boolean = false, e:PlayerIOError = null, closeCallback:Function = null, hideButton:Boolean = false) : void {
			var s:String;
			var prop:String;
			var dialog:PopupMessage = new PopupMessage();
			if(hideButton) {
				dialog.closeButton.visible = false;
			}
			dialog.text = m;
			stage.addChild(dialog);
			dialog.addEventListener("close",function(param1:Event):void {
				dialogClose(param1);
				if(closeCallback != null) {
					closeCallback();
				}
			});
			s = "";
			if(e != null && e.message != null) {
				s = e.name + ": " + e.message;
			}
			for(prop in joinData) {
				s += "[" + prop + "=" + joinData[prop] + "],";
			}
			if(sendToErrorLog) {
				client.errorLog.writeError(m,s,"",{});
			}
		}
		
		private function dialogClose(e:Event) : void {
			var _local2:Sprite = e.target as Sprite;
			if(stage != null && stage.contains(_local2)) {
				stage.removeChild(_local2);
			}
		}
		
		public function set desiredRoomId(value:String) : void {
			_desiredRoomId = value;
		}
		
		public function get desiredRoomId() : String {
			return _desiredRoomId;
		}
		
		public function set desiredSystemType(value:String) : void {
			_desiredSystemType = value;
		}
		
		public function get desiredSystemType() : String {
			return _desiredSystemType;
		}
	}
}

