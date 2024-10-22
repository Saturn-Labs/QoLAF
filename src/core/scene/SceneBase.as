package core.scene
{
   import Clock;
   import camerafocus.StarlingCameraFocus;
   import com.greensock.TweenMax;
   import core.hud.components.ToolTip;
   import core.hud.components.cargo.Cargo;
   import core.hud.components.chat.MessageLog;
   import core.hud.components.dialogs.PopupConfirmMessage;
   import core.hud.components.dialogs.PopupMessage;
   import core.particle.Emitter;
   import core.states.ISceneState;
   import core.states.SceneStateMachine;
   import data.Settings;
   import debug.Console;
   import flash.display.Bitmap;
   import flash.errors.IllegalOperationError;
   import flash.utils.Dictionary;
   import joinRoom.Room;
   import playerio.Client;
   import playerio.Connection;
   import playerio.Message;
   import playerio.PlayerIOError;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.display.Sprite;
   import starling.events.Event;
   import startSetup.StartSetup;

   public class SceneBase extends DisplayObjectContainer implements ISceneState
   {
      public static var settings:Settings;

      public var myCargo:Cargo;

      private var clockInitComplete:Boolean;

      private var userJoinedComplete:Boolean;

      public var room:Room;

      public var client:Client;

      private var connection:Connection;

      protected var roomId:String;

      protected var serviceRoomId:String;

      public var serviceConnection:Connection;

      protected var clock:Clock;

      public var canvas:Sprite;

      private var hud:Sprite;

      private var menu:Sprite;

      private var overlay:Sprite;

      public const CANVAS_BACKGROUND:String = "canvasBackground";

      public const CANVAS_BODIES:String = "canvasBodies";

      public const CANVAS_DROPS:String = "canvasDrops";

      public const CANVAS_SPAWNERS:String = "canvasSpawmers";

      public const CANVAS_TURRETS:String = "canvasTurrets";

      public const CANVAS_BOSSES:String = "canvasBosses";

      public const CANVAS_ENEMY_SHIPS:String = "canvasEnemyShip";

      public const CANVAS_PLAYER_SHIPS:String = "canvasPlayerShip";

      public const CANVAS_PROJECTILES:String = "canvasProjectiles";

      public const CANVAS_EFFECTS:String = "canvasEffects";

      public const CANVAS_TEXTS:String = "canvasTexts";

      public var canvasBackground:DisplayObjectContainer;

      public var canvasBodies:Sprite;

      public var canvasDrops:Sprite;

      public var canvasSpawners:Sprite;

      public var canvasTurrets:Sprite;

      public var canvasBosses:Sprite;

      public var canvasEnemyShips:Sprite;

      public var canvasPlayerShips:Sprite;

      public var canvasProjectiles:Sprite;

      public var canvasEffects:Sprite;

      public var canvasTexts:Sprite;

      private var layersInfo:Array;

      private var connectionHandlers:Dictionary;

      private var serviceHandlers:Dictionary;

      protected var _stateMachine:SceneStateMachine;

      protected var _leaving:Boolean;

      public var blockHotkeys:Boolean = false;

      public var camera:StarlingCameraFocus;

      private var resizeCallbacks:Array;

      public var time:Number = 0;

      public var messageCounter:Dictionary;

      public function SceneBase(param1:Client, param2:Connection, param3:Connection, param4:Room)
      {
         canvas = new Sprite();
         hud = new Sprite();
         menu = new Sprite();
         overlay = new Sprite();
         canvasBackground = new Sprite();
         canvasBodies = new Sprite();
         canvasDrops = new Sprite();
         canvasSpawners = new Sprite();
         canvasTurrets = new Sprite();
         canvasBosses = new Sprite();
         canvasEnemyShips = new Sprite();
         canvasPlayerShips = new Sprite();
         canvasProjectiles = new Sprite();
         canvasEffects = new Sprite();
         canvasTexts = new Sprite();
         connectionHandlers = new Dictionary();
         serviceHandlers = new Dictionary();
         resizeCallbacks = [];
         messageCounter = new Dictionary();
         this.client = param1;
         this.serviceConnection = param2;
         this.serviceRoomId = param2.roomId;
         this.connection = param3;
         this.room = param4;
         super();
         this.alpha = 0.999;
         super.addChildAt(canvas, 0);
         super.addChildAt(hud, 1);
         super.addChildAt(menu, 2);
         super.addChildAt(overlay, 3);
         canvas.addChild(canvasBackground);
         canvas.addChild(canvasBodies);
         canvas.addChild(canvasSpawners);
         canvas.addChild(canvasTurrets);
         canvas.addChild(canvasBosses);
         canvas.addChild(canvasEnemyShips);
         canvas.addChild(canvasDrops);
         canvas.addChild(canvasPlayerShips);
         canvas.addChild(canvasProjectiles);
         canvas.addChild(canvasEffects);
         canvas.addChild(canvasTexts);
         Login.fadeScreen.repositionScreen(overlay);
         canvas.touchable = false;
         layersInfo = [ {
                  "name": "canvasBackground",
                  "instance": this.canvasBackground,
                  "ratio": 1
               }, {
                  "name": "canvasBodies",
                  "instance": this.canvasBodies,
                  "ratio": 0
               }, {
                  "name": "canvasSpawmers",
                  "instance": this.canvasSpawners,
                  "ratio": 0
               }, {
                  "name": "canvasTurrets",
                  "instance": this.canvasTurrets,
                  "ratio": 0
               }, {
                  "name": "canvasBosses",
                  "instance": this.canvasBosses,
                  "ratio": 0
               }, {
                  "name": "canvasEnemyShip",
                  "instance": this.canvasEnemyShips,
                  "ratio": 0
               }, {
                  "name": "canvasDrops",
                  "instance": this.canvasDrops,
                  "ratio": 0
               }, {
                  "name": "canvasPlayerShip",
                  "instance": this.canvasPlayerShips,
                  "ratio": 0
               }, {
                  "name": "canvasProjectiles",
                  "instance": this.canvasProjectiles,
                  "ratio": 0
               }, {
                  "name": "canvasEffects",
                  "instance": this.canvasEffects,
                  "ratio": 0
               }, {
                  "name": "canvasTexts",
                  "instance": this.canvasTexts,
                  "ratio": 0
               }];
         initConnection(param3);
      }

      private function initConnection(param1:Connection):void
      {
         this.connection = param1;
         addMessageHandler("joined", joined);
         addMessageHandler("userJoined", userJoined);
         addMessageHandler("userLeft", userLeft);
         addMessageHandler("duplicateLogin", duplicateLogin);
         addMessageHandler("error", errorFromServer);
         addMessageHandler("message", message);
         addMessageHandler("debug", debugMessage);
         addMessageHandler("*", anyMessage);
         initClock();
      }

      public function traceDisplayObjectCounts():void
      {
         var _loc1_:int = 0;
         _loc1_ += canvasBackground.numChildren;
         _loc1_ += canvasBodies.numChildren;
         _loc1_ += canvasDrops.numChildren;
         _loc1_ += canvasSpawners.numChildren;
         _loc1_ += canvasTurrets.numChildren;
         _loc1_ += canvasBosses.numChildren;
         _loc1_ += canvasEnemyShips.numChildren;
         _loc1_ += canvasPlayerShips.numChildren;
         _loc1_ += canvasProjectiles.numChildren;
         _loc1_ += canvasEffects.numChildren;
         _loc1_ += canvasTexts.numChildren;
         _loc1_ += hud.numChildren;
         _loc1_ += menu.numChildren;
         _loc1_ += overlay.numChildren;
         MessageLog.writeChatMsg("system", "Background: " + canvasBackground.numChildren, null, "");
         MessageLog.writeChatMsg("system", "Bodies: " + canvasBodies.numChildren, null, "");
         MessageLog.writeChatMsg("system", "Drops: " + canvasDrops.numChildren, null, "");
         MessageLog.writeChatMsg("system", "Spawners: " + canvasSpawners.numChildren, null, "");
         MessageLog.writeChatMsg("system", "Turrets: " + canvasTurrets.numChildren, null, "");
         MessageLog.writeChatMsg("system", "Bosses: " + canvasBosses.numChildren, null, "");
         MessageLog.writeChatMsg("system", "EnemyShips: " + canvasEnemyShips.numChildren, null, "");
         MessageLog.writeChatMsg("system", "PlayerShips: " + canvasPlayerShips.numChildren, null, "");
         MessageLog.writeChatMsg("system", "Projectiles: " + canvasProjectiles.numChildren, null, "");
         MessageLog.writeChatMsg("system", "Effects: " + canvasEffects.numChildren, null, "");
         MessageLog.writeChatMsg("system", "Texts: " + canvasTexts.numChildren, null, "");
         MessageLog.writeChatMsg("system", "Hud: " + hud.numChildren, null, "");
         MessageLog.writeChatMsg("system", "Menu: " + menu.numChildren, null, "");
         MessageLog.writeChatMsg("system", "Overlay: " + overlay.numChildren, null, "");
         MessageLog.writeChatMsg("system", "Total: " + _loc1_, null, "");
         TweenMax.delayedCall(1, traceDisplayObjectCounts);
      }

      public function toggleRoamingCanvases(param1:Boolean):void
      {
         canvasEffects.visible = param1;
         canvasDrops.visible = param1;
         canvasBackground.visible = param1;
         canvasProjectiles.visible = param1;
         canvasBodies.visible = param1;
         canvasSpawners.visible = param1;
         canvasTurrets.visible = param1;
         canvasBosses.visible = param1;
         canvasEnemyShips.visible = param1;
         canvasTexts.visible = param1;
         hud.visible = param1;
      }

      public function enter():void
      {
         if (stage)
         {
            init();
         }
         else
         {
            addEventListener("addedToStage", init);
         }
      }

      protected function init(param1:Event = null):void
      {
         StartSetup.showProgressText("Init game room");
         removeEventListener("addedToStage", init);
         _leaving = false;
         Console.write("Init Camera...");
         camera = new StarlingCameraFocus(stage, canvas, new Sprite(), layersInfo, false);
         camera.start();
         camera.update();
         stage.addEventListener("resize", resize);
      }

      protected function resize(param1:Event):void
      {
         for each (var _loc2_:* in resizeCallbacks)
         {
            _loc2_(param1);
         }
         if (camera != null)
         {
            camera.setFocusPosition(stage.stageWidth / 2, stage.stageHeight / 2);
         }
      }

      private function joined(param1:Message):void
      {
         Console.write("joined ...");
         roomId = param1.getString(0);
         userJoinedComplete = true;
         joinReady();
      }

      public function execute():void
      {
      }

      protected function handleDisconnect():void
      {
         Console.write("Disconnected from server");
      }

      private function handleError(param1:PlayerIOError):void
      {
         Console.write(param1);
      }

      private function initClock():void
      {
         StartSetup.showProgressText("Synchronizing");
         Console.write("Synchronising ...");
         clock = new Clock(connection, client);
         clock.start();
         clock.addEventListener("clockReady", onClockReady);
      }

      private function onClockReady(param1:Event):void
      {
         clock.removeEventListener("clockReady", onClockReady);
         Console.write("latency: " + clock.latency);
         MessageLog.write("Latency: " + clock.latency);
         StartSetup.showProgressText("Optimizing latency");
         clockInitComplete = true;
         joinReady();
      }

      private function joinReady():void
      {
         Console.write("joinReady");
         if (clockInitComplete && userJoinedComplete)
         {
            Console.write("clockinit and userjoined");
            onJoinAndClockSynched();
            connection.addDisconnectHandler(handleDisconnect);
            serviceConnection.addDisconnectHandler(handleDisconnect);
         }
      }

      protected function onJoinAndClockSynched(param1:Event = null):void
      {
         StartSetup.showProgressText("Joined and synched game room");
         removeEventListener("addedToStage", onJoinAndClockSynched);
         time = clock.time;
      }

      public function exit():void
      {
         _leaving = true;
         camera = null;
         settings = null;
         myCargo.dispose();
         myCargo = null;
         canvas.removeChild(canvasBackground, true);
         canvas.removeChild(canvasBodies, true);
         canvas.removeChild(canvasBosses, true);
         canvas.removeChild(canvasDrops, true);
         canvas.removeChild(canvasEffects, true);
         canvas.removeChild(canvasEnemyShips, true);
         canvas.removeChild(canvasPlayerShips, true);
         canvas.removeChild(canvasProjectiles, true);
         canvas.removeChild(canvasSpawners, true);
         canvas.removeChild(canvasTexts, true);
         canvas.removeChild(canvasTurrets, true);
         canvasBackground = null;
         canvasBodies = null;
         canvasBosses = null;
         canvasDrops = null;
         canvasEffects = null;
         canvasEnemyShips = null;
         canvasPlayerShips = null;
         canvasProjectiles = null;
         canvasSpawners = null;
         canvasTexts = null;
         canvasTurrets = null;
         Login.fadeScreen.repositionScreen(stage);
         removeChild(canvas, true);
         removeChild(hud, true);
         removeChild(menu, true);
         removeChild(overlay, true);
         canvas = null;
         menu = null;
         hud = null;
         overlay = null;
         for (var _loc2_:* in connectionHandlers)
         {
            removeMessageHandler(_loc2_, connectionHandlers[_loc2_]);
         }
         for (_loc2_ in serviceHandlers)
         {
            removeServiceMessageHandler(_loc2_, serviceHandlers[_loc2_]);
         }
         if (connection)
         {
            connection.removeDisconnectHandler(handleDisconnect);
         }
         if (serviceConnection)
         {
            serviceConnection.removeDisconnectHandler(handleDisconnect);
         }
         TweenMax.killAll();
         ToolTip.disposeAll();
         Starling.juggler.purge();
         stage.removeEventListener("resize", resize);
         for each (var _loc1_:* in resizeCallbacks)
         {
            stage.removeEventListener("resize", _loc1_);
         }
         removeEventListeners();
         removeChildren(0, -1, true);
      }

      public function addChildToBackground(param1:DisplayObject):void
      {
         canvasBackground.addChild(param1);
      }

      public function addChildToBackgroundAt(param1:DisplayObject, param2:int):void
      {
         canvasBackground.addChildAt(param1, param2);
      }

      public function removeChildFromBackground(param1:DisplayObject, param2:Boolean = false):void
      {
         if (!canvasBackground.contains(param1))
         {
            return;
         }
         canvasBackground.removeChild(param1, param2);
      }

      public function addChildToCanvas(param1:DisplayObject):void
      {
         canvas.addChild(param1);
      }

      public function addChildToCanvasAt(param1:DisplayObject, param2:int):void
      {
         canvas.addChildAt(param1, param2);
      }

      public function removeChildFromCanvas(param1:DisplayObject, param2:Boolean = false):void
      {
         if (!canvas.contains(param1))
         {
            return;
         }
         canvas.removeChild(param1, param2);
      }

      override public function addChild(param1:DisplayObject):DisplayObject
      {
         return hud.addChild(param1);
      }

      override public function addChildAt(param1:DisplayObject, param2:int):DisplayObject
      {
         return hud.addChildAt(param1, param2);
      }

      override public function removeChild(param1:DisplayObject, param2:Boolean = false):DisplayObject
      {
         if (!hud.contains(param1))
         {
            return null;
         }
         return hud.removeChild(param1, param2);
      }

      public function addChildToMenu(param1:DisplayObject):void
      {
         menu.addChild(param1);
      }

      public function addChildToMenuAt(param1:DisplayObject, param2:int):void
      {
         menu.addChildAt(param1, param2);
      }

      public function removeChildFromMenu(param1:DisplayObject, param2:Boolean = false):void
      {
         if (!menu.contains(param1))
         {
            return;
         }
         menu.removeChild(param1, param2);
      }

      public function addChildToHud(param1:DisplayObject):void
      {
         hud.addChild(param1);
      }

      public function removeChildFromHud(param1:DisplayObject, param2:Boolean = false):void
      {
         if (!hud.contains(param1))
         {
            return;
         }
         hud.removeChild(param1, param2);
      }

      public function addChildToOverlay(param1:DisplayObject, param2:Boolean = false):void
      {
         if (!this.blockHotkeys && param2)
         {
            this.blockHotkeys = true;
         }
         overlay.addChild(param1);
      }

      public function addChildToOverlayAt(param1:DisplayObject, param2:int):void
      {
         if (param2 >= overlay.numChildren)
         {
            param2 = overlay.numChildren - 1;
         }
         overlay.addChildAt(param1, param2);
      }

      public function removeChildFromOverlay(param1:DisplayObject, param2:Boolean = false):void
      {
         this.blockHotkeys = false;
         if (overlay == null || !overlay.contains(param1))
         {
            return;
         }
         overlay.removeChild(param1, param2);
      }

      public function addToCanvasLayer(param1:String, param2:DisplayObject):void
      {
         var _loc6_:int = 0;
         var _loc3_:Object = null;
         var _loc5_:Sprite = null;
         var _loc4_:int = int(layersInfo.length);
         _loc6_ = 0;
         while (_loc6_ < _loc4_)
         {
            _loc3_ = layersInfo[_loc6_];
            if (param1 == _loc3_.name)
            {
               _loc5_ = _loc3_.instance;
               _loc5_.addChild(param2);
            }
            _loc6_++;
         }
      }

      public function removeFromCanvasLayer(param1:String, param2:DisplayObject):void
      {
         var _loc6_:int = 0;
         var _loc3_:Object = null;
         var _loc5_:Sprite = null;
         var _loc4_:int = int(layersInfo.length);
         _loc6_ = 0;
         while (_loc6_ < _loc4_)
         {
            _loc3_ = layersInfo[_loc6_];
            if (param1 == _loc3_.name)
            {
               _loc5_ = _loc3_.instance;
               _loc5_.removeChild(param2);
            }
            _loc6_++;
         }
      }

      public function set stateMachine(param1:SceneStateMachine):void
      {
         _stateMachine = param1;
      }

      protected function getServerTime():Number
      {
         if (clock != null)
         {
            time = clock.getServerTime();
            return time;
         }
         return 0;
      }

      public function rpc(param1:String, param2:Function, ...rest):void
      {
         var m:Message;
         var i:int;
         var type:String = param1;
         var handler:Function = param2;
         var args:Array = rest;
         connection.addMessageHandler(type, (function():*
               {
                  var rpcHandler:Function;
                  return rpcHandler = function(param1:Message):void
                  {
                     connection.removeMessageHandler(type, rpcHandler);
                     handler(param1);
                  };
               })());
         m = connection.createMessage(type);
         i = 0;
         while (i < args.length)
         {
            m.add(args[i]);
            i++;
         }
         connection.sendMessage(m);
      }

      public function rpcMessage(param1:Message, param2:Function):void
      {
         var mess:Message = param1;
         var handler:Function = param2;
         connection.addMessageHandler(mess.type, (function():*
               {
                  var rpcHandler:Function;
                  return rpcHandler = function(param1:Message):void
                  {
                     connection.removeMessageHandler(param1.type, rpcHandler);
                     handler(param1);
                  };
               })());
         connection.sendMessage(mess);
      }

      public function addMessageHandler(param1:String, param2:Function):void
      {
         connectionHandlers[param1] = param2;
         connection.addMessageHandler(param1, param2);
      }

      public function removeMessageHandler(param1:String, param2:Function):void
      {
         if (connectionHandlers.hasOwnProperty(param1))
         {
            delete connectionHandlers[param1];
         }
         if (connection)
         {
            connection.removeMessageHandler(param1, param2);
         }
      }

      public function increaseMessageCounter(param1:String):void
      {
         if (param1 == "msgPack")
         {
            return;
         }
         if (messageCounter[param1] == null)
         {
            messageCounter[param1] = 0;
         }
         var _loc2_:* = param1;
         var _loc3_:* = messageCounter[_loc2_] + 1;
         messageCounter[_loc2_] = _loc3_;
      }

      public function traceMessageCount():void
      {
         var _loc3_:Array = [];
         for (var _loc2_:* in messageCounter)
         {
            if (messageCounter[_loc2_] != 0)
            {
               _loc3_.push( {
                        "type":_loc2_,
                        "count":messageCounter[_loc2_]
                     });
            }
         }
         _loc3_.sortOn("count", 0x10 | 2);
         for each (var _loc1_:* in _loc3_)
         {
            Console.write(_loc1_.type + ": " + _loc1_.count);
         }
      }

      public function send(param1:String, ...rest):void
      {
         var _loc4_:int = 0;
         var _loc3_:Message = connection.createMessage(param1);
         if (rest.length > 0)
         {
            _loc4_ = 0;
            while (_loc4_ < rest.length)
            {
               _loc3_.add(rest[_loc4_]);
               _loc4_++;
            }
            sendMessage(_loc3_);
         }
         else
         {
            sendMessage(_loc3_);
         }
      }

      public function sendToServiceRoom(param1:String, ...rest):void
      {
         var _loc4_:int = 0;
         var _loc3_:Message = serviceConnection.createMessage(param1);
         if (rest.length > 0)
         {
            _loc4_ = 0;
            while (_loc4_ < rest.length)
            {
               _loc3_.add(rest[_loc4_]);
               _loc4_++;
            }
            sendMessageToServiceRoom(_loc3_);
         }
         else
         {
            sendMessageToServiceRoom(_loc3_);
         }
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

      public function addServiceMessageHandler(param1:String, param2:Function):void
      {
         serviceHandlers[param1] = param2;
         serviceConnection.addMessageHandler(param1, param2);
      }

      public function removeServiceMessageHandler(param1:String, param2:Function):void
      {
         if (serviceHandlers.hasOwnProperty(param1))
         {
            delete serviceHandlers[param1];
         }
         serviceConnection.removeMessageHandler(param1, param2);
      }

      public function sendMessageToServiceRoom(param1:Message):void
      {
         serviceConnection.sendMessage(param1);
      }

      public function sendMessage(param1:Message):void
      {
         connection.sendMessage(param1);
      }

      public function createMessage(param1:String, ...rest):Message
      {
         var _loc4_:int = 0;
         var _loc3_:Message = connection.createMessage(param1);
         _loc4_ = 0;
         while (_loc4_ < rest.length)
         {
            _loc3_.add(rest[_loc4_]);
            _loc4_++;
         }
         return _loc3_;
      }

      protected function userJoined(param1:Message):void
      {
         Console.write("User joined");
      }

      protected function userLeft(param1:Message):void
      {
         Console.write("User left");
      }

      public function showErrorDialog(param1:String, param2:Boolean = false, param3:Function = null):void
      {
         var m:String = param1;
         var sendToErrorLog:Boolean = param2;
         var callback:Function = param3;
         var dialog:PopupMessage = new PopupMessage();
         dialog.text = m;
         if (isLeaving)
         {
            return;
         }
         addChildToOverlay(dialog);
         if (sendToErrorLog)
         {
            client.errorLog.writeError(m, "", "", {});
         }
         dialog.addEventListener("close", function(param1:Event):void
            {
               dialogClose(param1);
               if (callback != null)
               {
                  callback();
               }
            });
      }

      public function showConfirmDialog(param1:String, param2:Function = null, param3:Function = null):void
      {
         var m:String = param1;
         var callback:Function = param2;
         var closeCallback:Function = param3;
         var dialog:PopupMessage = new PopupConfirmMessage();
         dialog.text = m;
         addChildToOverlay(dialog);
         dialog.addEventListener("close", function(param1:Event):void
            {
               dialogClose(param1);
               if (closeCallback != null)
               {
                  closeCallback();
               }
            });
         dialog.addEventListener("accept", function(param1:Event):void
            {
               dialogClose(param1);
               if (callback != null)
               {
                  callback();
               }
            });
      }

      public function showMessageDialog(param1:String, param2:Function = null):void
      {
         var m:String = param1;
         var callback:Function = param2;
         var dialog:PopupMessage = new PopupMessage();
         dialog.text = m;
         addChildToOverlay(dialog);
         dialog.addEventListener("close", function(param1:Event):void
            {
               dialogClose(param1);
               if (callback != null)
               {
                  callback();
               }
            });
      }

      private function errorFromServer(param1:Message):void
      {
         showErrorDialog(param1.getString(0));
      }

      public function infoMessageDialog(param1:String):void
      {
         var _loc2_:PopupMessage = new PopupMessage();
         _loc2_.text = param1;
         addChildToOverlay(_loc2_);
         _loc2_.addEventListener("close", dialogClose);
      }

      private function dialogClose(param1:Event):void
      {
         var _loc2_:Sprite = param1.target as Sprite;
         if (_loc2_ == null)
         {
            return;
         }
         if (overlay != null && overlay.contains(_loc2_))
         {
            removeChildFromOverlay(_loc2_);
         }
         _loc2_.removeEventListeners();
         _loc2_.dispose();
      }

      private function message(param1:Message):void
      {
         showErrorDialog(param1.getString(0));
      }

      private function anyMessage(param1:Message):void
      {
      }

      private function duplicateLogin(param1:Message):void
      {
         showErrorDialog("You were disconnected because you signed in from another place.");
         exit();
      }

      public function get connected():Boolean
      {
         if (connection != null && connection.connected)
         {
            return true;
         }
         return false;
      }

      public function get isLeaving():Boolean
      {
         return _leaving;
      }

      public function disconnect():void
      {
         if (connection)
         {
            connection.disconnect();
         }
      }

      public function draw():void
      {
         throw new IllegalOperationError("Subclasses of RoomBase has to override draw().");
      }

      public function drawGUIEffect(param1:Bitmap, param2:Vector.<Emitter>):void
      {
         throw new IllegalOperationError("Subclasses of RoomBase has to override drawGUIEffect().");
      }

      public function refreshClock():void
      {
         clock.start();
         clock.addEventListener("clockReady", onRefreshClockReady);
      }

      private function onRefreshClockReady(param1:Event):void
      {
         clock.removeEventListener("clockReady", onRefreshClockReady);
         if (settings.showLatency)
         {
            MessageLog.write("Latency: " + Math.round(clock.latency) + " ms");
         }
      }

      public function addResizeListener(param1:Function):void
      {
         resizeCallbacks.push(param1);
      }

      public function removeResizeListener(param1:Function):void
      {
         resizeCallbacks.splice(resizeCallbacks.indexOf(param1), 1);
      }

      private function debugMessage(param1:Message):void
      {
         var _loc2_:String = null;
         var _loc4_:int = 0;
         var _loc3_:String = param1.getString(0);
         if (_loc3_ == "update")
         {
            _loc2_ = "";
            _loc4_ = 1;
            while (_loc4_ < param1.length)
            {
               _loc2_ += param1.getInt(_loc4_) + ", ";
               if (_loc4_ % 10 == 0)
               {
                  MessageLog.write("update times: " + _loc2_);
                  _loc2_ = "";
               }
               _loc4_++;
            }
         }
      }

      public function set touchableCanvas(param1:Boolean):void
      {
         canvas.touchable = param1;
      }

      public function isSystemTypeClan():Boolean
      {
         return room.data.systemType == "clan";
      }

      public function isSystemTypeSurvival():Boolean
      {
         return room.data.systemType == "survival";
      }

      public function isSystemTypeHostile():Boolean
      {
         return room.data.systemType == "hostile";
      }

      public function isSystemTypeDomination():Boolean
      {
         return room.data.systemType == "domination";
      }

      public function isSystemTypeDeathMatch():Boolean
      {
         return room.data.systemType == "deathmatch";
      }

      public function isSystemPvPEnabled():Boolean
      {
         var _loc1_:String = room.data.systemType;
         return _loc1_ == "hostile" || _loc1_ == "deathmatch" || _loc1_ == "domination" || _loc1_ == "clan" || _loc1_ == "arena";
      }
   }
}
