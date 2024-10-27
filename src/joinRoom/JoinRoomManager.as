package joinRoom
{
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

   public class JoinRoomManager extends EventDispatcher implements IJoinRoomManager
   {
      private var stage:Stage;

      private var client:Client;

      private var serviceConnection:Connection;

      private var connection:Connection;

      private var room:Room;

      private var roomStateMachine:SceneStateMachine;

      private var dataManager:IDataManager;

      private var joinData:Object;

      private var playerInfo:Object;

      private var _desiredRoomId:String = null;

      private var _desiredSystemType:String = "friendly";

      private var inited:Boolean = false;

      private var session:String;

      private var login:Login;

      public function JoinRoomManager(param1:Client, param2:Stage, param3:Object, param4:Login)
      {
         playerInfo = {};
         session = GUID.create();
         super();
         this.client = param1;
         this.joinData = param3;
         this.stage = param2;
         this.login = param4;
         dataManager = DataLocator.getService();
         roomStateMachine = new SceneStateMachine(param2);
      }

      public static function getServiceRoomID(param1:int):String
      {
         return "Service-1379_" + param1;
      }

      public function init():void
      {
         if (inited)
         {
            client.errorLog.writeError("Tried to init joinroom more than once.", "", "", {});
            return;
         }
         Console.write("Joinroom init.");
         inited = true;
         StartSetup.showProgressText(Localize.t("List service room"));
         client.multiplayer.listRooms("service", null, 1000, 0, handleServiceRooms, function(param1:PlayerIOError):void
            {
               showErrorDialog("Listing of service room failed.", true);
            });
      }

      private function handleServiceRooms(param1:Array):void
      {
         var _loc6_:String = null;
         var _loc5_:RoomInfo = null;
         var _loc4_:Room = new Room();
         _loc4_.roomType = "service";
         var _loc2_:Array = [];
         for each (var _loc3_:* in param1)
         {
            _loc6_ = _loc3_.id.substr(8, 4);
            if ((int(_loc6_)) >= 1379)
            {
               _loc4_.id = _loc3_.id;
               _loc2_.push(_loc3_);
            }
         }
         StartSetup.showProgressText(Localize.t("Joining service room"));
         if (_loc2_.length == 0)
         {
            return joinServiceRoom(getServiceRoomID(0));
         }
         if (_loc2_.length == 1)
         {
            _loc5_ = _loc2_[0];
            if (_loc5_.onlineUsers < 950)
            {
               return joinServiceRoom(_loc5_.id);
            }
         }
         login.selectServiceRoom(_loc2_, joinServiceRoom);
      }

      public function joinServiceRoom(param1:String):void
      {
         var id:String = param1;
         login.removeEffects();
         client.multiplayer.createJoinRoom(id, "service", true, {}, {"client_version": 1379}, handleJoinServiceRoom, function(param1:PlayerIOError):void
            {
               if (param1.errorID != 2)
               {
                  showErrorDialog("Join service room failed, please try again later. Contact us on forum.astroflux.org for support.", true, param1);
               }
            });
      }

      private function handleJoinServiceRoom(param1:Connection):void
      {
         var serviceConnection:Connection = param1;
         StartSetup.showProgressText(Localize.t("Joined service room"));
         FocusManager.setEnabledForStage(stage, false);
         this.serviceConnection = serviceConnection;
         serviceConnection.addMessageHandler("error", function(param1:Message):void
            {
               showErrorDialog(param1.getString(0));
            });
         serviceConnection.addMessageHandler("joined", onJoinedServiceRoom);
      }

      private function onJoinedServiceRoom(param1:Message):void
      {
         serviceConnection.removeMessageHandler("joined", onJoinedServiceRoom);
         var _loc2_:int = 0;
         playerInfo = {};
         playerInfo.key = param1.getString(_loc2_++ );
         playerInfo.level = param1.getInt(_loc2_++ );
         playerInfo.split = param1.getString(_loc2_++ );
         playerInfo.musicVolume = param1.getNumber(_loc2_++ );
         playerInfo.effectVolume = param1.getNumber(_loc2_++ );
         playerInfo.xp = param1.getInt(_loc2_++ );
         playerInfo.enemyKills = param1.getInt(_loc2_++ );
         playerInfo.bossKills = param1.getInt(_loc2_++ );
         playerInfo.suicides = param1.getInt(_loc2_++ );
         playerInfo.troons = param1.getNumber(_loc2_++ );
         playerInfo.enemyEncounters = param1.getInt(_loc2_++ );
         playerInfo.bossEncounters = param1.getInt(_loc2_++ );
         playerInfo.exploredPlanets = param1.getInt(_loc2_++ );
         playerInfo.systemType = param1.getString(_loc2_++ );
         playerInfo.currentRoom = param1.getString(_loc2_++ );
         playerInfo.currentRoomId = param1.getString(_loc2_++ );
         playerInfo.currentSolarSystem = param1.getString(_loc2_++ );
         playerInfo.systemType = param1.getString(_loc2_++ );
         playerInfo.clan = param1.getString(_loc2_++ );
         joinData["client_version"] = 1379;
         joinData["session"] = session;
         joinData["warpJump"] = false;
         joinData["level"] = playerInfo.level > 0 ? playerInfo.level : 1;
         _desiredSystemType = playerInfo.systemType != "" ? playerInfo.systemType : "friendly";
         _desiredRoomId = playerInfo.currentRoomId != "" ? playerInfo.currentRoomId : null;
         dispatchEventWith("joinedServiceRoom", true, playerInfo);
      }

      public function rpcServiceRoom(param1:String, param2:Function, ...rest):void
      {
         var m:Message;
         var i:int;
         var type:String = param1;
         var handler:Function = param2;
         var args:Array = rest;
         serviceConnection.addMessageHandler(type, (function():*
               {
                  var rpcHandler:Function;
                  return rpcHandler = function(param1:Message):void
                  {
                     serviceConnection.removeMessageHandler(type, rpcHandler);
                     handler(param1);
                  };
               })());
         m = serviceConnection.createMessage(type);
         i = 0;
         while (i < args.length)
         {
            m.add(args[i]);
            i++;
         }
         serviceConnection.sendMessage(m);
      }

      public function joinCurrentSolarSystem():void
      {
         var _loc1_:String = "HrAjOBivt0SHPYtxKyiB_Q";
         if (playerInfo.currentSolarSystem)
         {
            _loc1_ = playerInfo.currentSolarSystem;
            if (playerInfo.currentRoomId != "")
            {
               _desiredRoomId = playerInfo.currentRoomId;
            }
            if (_desiredSystemType == "clan")
            {
               if (playerInfo.clan != "")
               {
                  _desiredRoomId = com.adobe.crypto.MD5.hash(playerInfo.currentSolarSystem + playerInfo.clan);
               }
               else
               {
                  _desiredSystemType = "friendly";
                  _desiredRoomId = null;
               }
            }
            if (_desiredSystemType == "survival" || _loc1_ == "ic3w-BxdMU6qWhX9t3_EaA")
            {
               _loc1_ = "DU6zMqKBIUGnUWA9eVVD-g";
               _desiredSystemType = "friendly";
               _desiredRoomId = null;
            }
         }
         if (dataManager.loadKey("SolarSystems", _loc1_) == null)
         {
            _loc1_ = "HrAjOBivt0SHPYtxKyiB_Q";
         }
         joinGame(_loc1_, joinData);
      }

      public function joinGame(param1:String, param2:Object):void
      {
         var roomType:String;
         var dataManager:IDataManager;
         var solarSystemObj:Object;
         var roomData:Object;
         var searchCriteria:Object;
         var solarSystemKey:String = param1;
         var joinData:Object = param2;
         joinData["client_version"] = 1379;
         joinData["session"] = session;
         roomStateMachine.closeCurrentRoom();
         roomType = "game";
         Console.write("Trying to join " + roomType + " room");
         dataManager = DataLocator.getService();
         solarSystemObj = dataManager.loadKey("SolarSystems", solarSystemKey);
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
         if (!_desiredRoomId)
         {
            searchCriteria = {
                  "solarSystemKey": solarSystemKey,
                  "service": serviceConnection.roomId
               };
            StartSetup.showProgressText("Getting game rooms");
            client.multiplayer.listRooms(room.roomType, searchCriteria, 1000, 0, handleRooms, function(param1:PlayerIOError):void
               {
                  Console.write("Error: " + param1);
               });
         }
         else
         {
            room.id = _desiredRoomId;
            createJoin();
         }
      }

      private function handleRooms(param1:Array):void
      {
         var _loc2_:* = false;
         var _loc5_:* = false;
         var _loc4_:int = 15;
         for each (var _loc3_:* in param1)
         {
            if (int(_loc3_.data.version) >= 1379)
            {
               if (_loc3_.data.systemType == room.data.systemType)
               {
                  if (_loc3_.onlineUsers < _loc4_)
                  {
                     if (_loc3_.data.modLocked != "true")
                     {
                        if (_loc3_.data.modClosed != "true")
                        {
                           if (room.data.systemType == "deathmatch" || room.data.systemType == "domination" || room.data.systemType == "arena")
                           {
                              room.id = _loc3_.id;
                              break;
                           }
                           _loc2_ = _loc3_.data.systemType != "hostile";
                           if (_loc2_)
                           {
                              room.id = _loc3_.id;
                              break;
                           }
                           _loc5_ = _loc3_.data.pvpAboveCap == "true";
                           if (_loc5_ == room.data.pvpAboveCap)
                           {
                              room.id = _loc3_.id;
                              break;
                           }
                        }
                     }
                  }
               }
            }
         }
         if (_desiredRoomId)
         {
            room.id = _desiredRoomId;
         }
         createJoin();
      }

      private function createJoin():void
      {
         Console.write("Attempting to create/join room.");
         StartSetup.showProgressText("Joining game room");
         client.multiplayer.createJoinRoom(room.id, room.roomType, false, room.data, room.joinData, handleJoin, function(param1:PlayerIOError):void
            {
            });
      }

      private function handleJoin(param1:Connection):void
      {
         StartSetup.showProgressText("Joining game room");
         this.connection = param1;
         roomStateMachine.changeRoom(new Game(client, serviceConnection, param1, room));
         Console.write("Sucessfully connected to the multiplayer server");
      }

      public function tryWarpJumpToFriend(param1:Player, param2:String, param3:Function, param4:Function):void
      {
         var searchCriteria:Object;
         var player:Player = param1;
         var destination:String = param2;
         var successCallback:Function = param3;
         var failedCallback:Function = param4;
         if (!_desiredRoomId || _desiredSystemType == "clan")
         {
            successCallback();
            return;
         }
         searchCriteria = {"solarSystemKey": destination};
         client.multiplayer.listRooms("game", searchCriteria, 100, 0, (function():*
               {
                  var onFound:Function;
                  return onFound = function(param1:Array):void
                  {
                     var _loc3_:RoomInfo = null;
                     var _loc6_:int = 0;
                     _loc6_ = 0;
                     while (_loc6_ < param1.length)
                     {
                        if (param1[_loc6_].id == _desiredRoomId)
                        {
                           _loc3_ = param1[_loc6_];
                           break;
                        }
                        _loc6_++;
                     }
                     if (_loc3_ == null)
                     {
                        failedCallback("Friend instance not found");
                        return;
                     }
                     if (_loc3_.data.systemType == "clan" && _loc3_.id != MD5.hash(_loc3_.data.solarSystemKey + player.clanId))
                     {
                        failedCallback("Your friend is in a private clan instance.");
                        return;
                     }
                     var _loc2_:* = _loc3_.data.systemType == "hostile";
                     if (!_loc2_)
                     {
                        successCallback();
                        return;
                     }
                     if (StarMap.selectedSolarSystem.pvpLvlCap == 0)
                     {
                        _desiredSystemType = "hostile";
                        successCallback();
                        return;
                     }
                     var _loc5_:* = _loc3_.data.pvpAboveCap == "true";
                     var _loc4_:* = player.level > StarMap.selectedSolarSystem.pvpLvlCap;
                     if (_loc5_ == _loc4_)
                     {
                        _desiredSystemType = "hostile";
                        successCallback();
                        return;
                     }
                     if (_loc5_)
                     {
                        failedCallback("This room only allows players over level " + (StarMap.selectedSolarSystem.pvpLvlCap + 1));
                     }
                     else
                     {
                        failedCallback("This room only allows players under level " + StarMap.selectedSolarSystem.pvpLvlCap);
                     }
                  };
               })(), function(param1:PlayerIOError):void
                  {
                  });
      }

      private function showErrorDialog(param1:String, param2:Boolean = false, param3:PlayerIOError = null, param4:Function = null, param5:Boolean = false):void
      {
         var s:String;
         var prop:String;
         var m:String = param1;
         var sendToErrorLog:Boolean = param2;
         var e:PlayerIOError = param3;
         var closeCallback:Function = param4;
         var hideButton:Boolean = param5;
         var dialog:PopupMessage = new PopupMessage();
         if (hideButton)
         {
            dialog.closeButton.visible = false;
         }
         dialog.text = m;
         stage.addChild(dialog);
         dialog.addEventListener("close", function(param1:Event):void
            {
               dialogClose(param1);
               if (closeCallback != null)
               {
                  closeCallback();
               }
            });
         s = "";
         if (e != null && e.message != null)
         {
            s = e.name + ": " + e.message;
         }
         for (prop in joinData)
         {
            s += "[" + prop + "=" + joinData[prop] + "],";
         }
         if (sendToErrorLog)
         {
            client.errorLog.writeError(m, s, "", {});
         }
      }

      private function dialogClose(param1:Event):void
      {
         var _loc2_:Sprite = param1.target as Sprite;
         if (stage != null && stage.contains(_loc2_))
         {
            stage.removeChild(_loc2_);
         }
      }

      public function set desiredRoomId(param1:String):void
      {
         _desiredRoomId = param1;
      }

      public function get desiredRoomId():String
      {
         return _desiredRoomId;
      }

      public function set desiredSystemType(param1:String):void
      {
         _desiredSystemType = param1;
      }

      public function get desiredSystemType():String
      {
         return _desiredSystemType;
      }
   }
}
