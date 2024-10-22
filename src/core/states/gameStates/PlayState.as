package core.states.gameStates
{
   import core.scene.Game;
   import core.scene.SceneBase;
   import core.ship.PlayerShip;
   import core.weapon.Weapon;
   import flash.geom.Point;
   import generics.Util;
   import io.InputLocator;
   import movement.Heading;
   import sound.SoundLocator;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.Event;
   import textures.TextureLocator;

   public class PlayState extends GameState
   {
      private static var autoCruise:Boolean = false;

      private static var mouseBlocked:Boolean = false;

      private static var mouseIntegrator:int = 0;

      private static var oldMouseX:int = 0;

      private static var oldMouseY:int = 0;

      protected var container:Sprite;

      private var isInHostileZone:Boolean = false;

      private var blackBackground:Quad;

      private var fireWithHotkeys:Boolean = false;

      public function PlayState(param1:Game)
      {
         container = new Sprite();
         blackBackground = new Quad(10, 10, 0);
         super(param1);
         param1.messageLog.visible = false;
         input = InputLocator.getService();
         textureManager = TextureLocator.getService();
         soundManager = SoundLocator.getService();
         blackBackground.alpha = 0.8;
         container.addChild(blackBackground);
         blackBackground.visible = false;
      }

      override public function enter():void
      {
         isInHostileZone = !g.hud.radar.inHostileZone();
         g.addChildToMenu(container);
         resize();
         g.addResizeListener(resize);
      }

      public function resize(param1:Event = null):void
      {
         container.x = g.stage.stageWidth / 2 - 380;
         container.y = g.stage.stageHeight / 2 - 300;
         if (blackBackground.visible)
         {
            drawBlackBackground();
         }
      }

      override public function loadCompleted():void
      {
         Login.fadeScreen.fadeOut();
         _loaded = true;
      }

      override public function execute():void
      {
         if (!g.isLeaving)
         {
            g.draw();
         }
      }

      override public function exit(param1:Function):void
      {
         g.removeChildFromMenu(container);
         g.removeResizeListener(resize);
         unloadCompleted();
         param1();
      }

      override public function tickUpdate():void
      {
         super.tickUpdate();
      }

      protected function addChild(param1:DisplayObject):void
      {
         container.addChild(param1);
      }

      private function updateMouseIntegrator():void
      {
         var _loc2_:int = Starling.current.nativeOverlay.mouseX;
         var _loc1_:int = Starling.current.nativeOverlay.mouseY;
         if (oldMouseX != 0 && oldMouseY != 0)
         {
            mouseIntegrator += (_loc2_ - oldMouseX) * (_loc2_ - oldMouseX) + (_loc1_ - oldMouseY) * (_loc1_ - oldMouseY);
         }
         if (mouseIntegrator > 100000)
         {
            mouseBlocked = false;
            mouseIntegrator = 0;
            oldMouseX = 0;
            oldMouseY = 0;
         }
         oldMouseX = _loc2_;
         oldMouseY = _loc1_;
         mouseIntegrator -= 350;
         if (mouseIntegrator < 0)
         {
            mouseIntegrator = 0;
         }
      }

      public function updateMouseAim():void
      {
         var ship:PlayerShip = me.ship;
         var heading:Heading = ship.course;
         var globalPosition:Point = ship.getGlobalPos();
         var globalX:Number = globalPosition.x;
         var globalY:Number = globalPosition.y;
         var rotationSnap:Number = ship.engine.rotationSpeed / 33;
         var angle:Number = Math.atan2(Starling.current.nativeOverlay.mouseY - globalY, Starling.current.nativeOverlay.mouseX - globalX);
         var angleDiff:Number = Util.angleDifference(ship.rotation, angle);
         if (angleDiff < rotationSnap && angleDiff > -rotationSnap)
         {
            if (heading.rotateLeft)
            {
               sendCommand(1, false);
            }
            if (heading.rotateRight)
            {
               sendCommand(2, false);
            }
         }
         else if (angleDiff > rotationSnap)
         {
            if (heading.rotateRight)
            {
               sendCommand(2, false);
            }
            else if (!heading.rotateLeft)
            {
               sendCommand(1, true);
            }
         }
         else if (angleDiff < -rotationSnap)
         {
            if (heading.rotateLeft)
            {
               sendCommand(1, false);
            }
            else if (!heading.rotateRight)
            {
               sendCommand(2, true);
            }
         }
      }

      public function checkAccelerate(param1:Boolean = false):void
      {
         if (!me.commandable)
         {
            return;
         }
         if (!_loaded)
         {
            return;
         }
         var _loc3_:PlayerShip = me.ship;
         var _loc2_:Heading = _loc3_.course;
         if (keybinds.isInputPressed(26))
         {
            autoCruise = autoCruise ? false : true;
         }
         if (keybinds.isInputPressed(11) || keybinds.isInputPressed(12))
         {
            autoCruise = false;
         }
         if ((!_loc2_.accelerate || _loc3_.boostEndedLastTick) && !param1 && !_loc3_.usingBoost && keybinds.isInputDown(11) || !_loc2_.accelerate && autoCruise)
         {
            _loc3_.boostEndedLastTick = false;
            sendCommand(0, true);
            g.camera.zoomFocus(0.85, 100);
         }
         if ((_loc2_.accelerate || _loc3_.boostEndedLastTick) && !_loc3_.usingBoost && keybinds.isInputUp(11) && !autoCruise)
         {
            _loc3_.boostEndedLastTick = false;
            sendCommand(0, false);
            g.camera.zoomFocus(1, 100);
         }
         if (!_loc2_.accelerate && !_loc2_.deaccelerate && !param1 && !_loc3_.usingBoost && keybinds.isInputDown(12))
         {
            sendCommand(8, true);
            g.camera.zoomFocus(1, 100);
         }
         if (_loc2_.deaccelerate && !_loc3_.usingBoost && keybinds.isInputUp(12))
         {
            sendCommand(8, false);
            g.camera.zoomFocus(1, 100);
         }
      }

      public function updateCommands():void
      {
         if (!me.commandable)
         {
            return;
         }
         if (!_loaded)
         {
            return;
         }
         var _loc1_:PlayerShip = me.ship;
         if (_loc1_.channelingEnd > g.time)
         {
            _loc1_.course.rotateLeft = false;
            _loc1_.course.rotateRight = false;
            _loc1_.course.accelerate = false;
            return;
         }
         checkBoost();
         checkShield();
         checkConvert();
         checkPower();
         checkAccelerate();
         if (!_loc1_.isTeleporting && !_loc1_.usingBoost)
         {
            handleTurn();
         }
         handleWeaponFire();
         if (g.me.isDeveloper)
         {
            handleDeathlines();
         }
      }

      private function handleTurn():void
      {
         if (keybinds.isInputDown(13) || keybinds.isInputDown(14))
         {
            mouseBlocked = true;
            mouseIntegrator = 0;
         }
         if (SceneBase.settings.mouseAim && !mouseBlocked)
         {
            return updateMouseAim();
         }
         var _loc1_:Heading = me.ship.course;
         if (!_loc1_.rotateLeft && keybinds.isInputDown(13))
         {
            sendCommand(1, true);
         }
         else if (_loc1_.rotateLeft && keybinds.isInputUp(13))
         {
            sendCommand(1, false);
         }
         if (!_loc1_.rotateRight && keybinds.isInputDown(14))
         {
            sendCommand(2, true);
         }
         else if (_loc1_.rotateRight && keybinds.isInputUp(14))
         {
            sendCommand(2, false);
         }
         if (SceneBase.settings.mouseAim)
         {
            updateMouseIntegrator();
         }
      }

      private function handleWeaponFire():void
      {
         var _loc2_:PlayerShip = me.ship;
         fireWithHotkeys = false;
         var _loc3_:int = 0;
         if (keybinds.isInputDown(20))
         {
            _loc3_ = 1;
         }
         else if (keybinds.isInputDown(21))
         {
            _loc3_ = 2;
         }
         else if (keybinds.isInputDown(22))
         {
            _loc3_ = 3;
         }
         else if (keybinds.isInputDown(23))
         {
            _loc3_ = 4;
         }
         else if (keybinds.isInputDown(24))
         {
            _loc3_ = 5;
         }
         if (_loc3_ > 0 && _loc3_ < 6)
         {
            if (g.hud.weaponHotkeys.selectedHotkey == null || _loc3_ != g.hud.weaponHotkeys.selectedHotkey.key && !_loc2_.weaponIsChanging)
            {
               g.me.sendChangeWeapon(_loc3_);
            }
            if (SceneBase.settings.fireWithHotkeys)
            {
               fireWithHotkeys = true;
            }
         }
         if (!_loc2_.isShooting && (keybinds.isInputDown(19) || fireWithHotkeys))
         {
            sendCommand(3, true);
         }
         else if (_loc2_.isShooting && keybinds.isInputUp(19) && !fireWithHotkeys)
         {
            for each (var _loc1_:* in _loc2_.weapons)
            {
               _loc1_.fire = false;
            }
            sendCommand(3, false);
         }
      }

      private function handleDeathlines():void
      {
         var _loc1_:PlayerShip = me.ship;
         if (input.isKeyPressed(89))
         {
            g.deathLineManager.addCoord(_loc1_.pos.x, _loc1_.pos.y);
         }
         if (input.isKeyPressed(75))
         {
            g.deathLineManager.cut();
         }
         if (input.isKeyPressed(85))
         {
            g.deathLineManager.undo(true);
         }
         if (input.isKeyPressed(8))
         {
            g.deathLineManager.deleteSelected("", true);
         }
         if (input.isKeyPressed(112))
         {
            g.deathLineManager.save();
            g.textManager.createBossSpawnedText("Death lines saved!");
         }
         if (input.isKeyPressed(74))
         {
            g.deathLineManager.clear(true);
         }
      }

      private function checkPower():void
      {
         if (keybinds.isInputPressed(18))
         {
            g.commandManager.addDmgBoostCommand();
         }
      }

      private function checkConvert():void
      {
         if (keybinds.isInputPressed(17))
         {
            g.commandManager.addShieldConvertCommand();
         }
      }

      private function checkShield():void
      {
         if (keybinds.isInputPressed(16))
         {
            g.commandManager.addHardenedShieldCommand();
         }
      }

      private function checkBoost():void
      {
         if (keybinds.isInputPressed(15))
         {
            g.commandManager.addBoostCommand();
            if (me.ship.usingBoost)
            {
               g.camera.zoomFocus(0.75, 80);
            }
         }
      }

      private function sendCommand(param1:int, param2:Boolean):void
      {
         g.commandManager.addCommand(param1, param2);
      }

      protected function drawBlackBackground(param1:Event = null):void
      {
         blackBackground.x = -container.x;
         blackBackground.y = -container.y;
         blackBackground.width = g.stage.stageWidth;
         blackBackground.height = g.stage.stageHeight;
         blackBackground.visible = true;
      }

      protected function clearBackground(param1:Event = null):void
      {
         blackBackground.visible = false;
      }
   }
}
