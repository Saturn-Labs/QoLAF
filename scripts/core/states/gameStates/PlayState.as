package core.states.gameStates {
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
	
	public class PlayState extends GameState {
		private static var autoCruise:Boolean = false;
		
		private static var mouseBlocked:Boolean = false;
		
		private static var mouseIntegrator:int = 0;
		
		private static var oldMouseX:int = 0;
		
		private static var oldMouseY:int = 0;
		
		protected var container:Sprite = new Sprite();
		
		private var isInHostileZone:Boolean = false;
		
		private var blackBackground:Quad = new Quad(10,10,0);
		
		private var fireWithHotkeys:Boolean = false;
		
		public function PlayState(g:Game) {
			super(g);
			g.messageLog.visible = false;
			input = InputLocator.getService();
			textureManager = TextureLocator.getService();
			soundManager = SoundLocator.getService();
			blackBackground.alpha = 0.8;
			container.addChild(blackBackground);
			blackBackground.visible = false;
		}
		
		override public function enter() : void {
			isInHostileZone = !g.hud.radar.inHostileZone();
			g.addChildToMenu(container);
			resize();
			g.addResizeListener(resize);
		}
		
		public function resize(e:Event = null) : void {
			container.x = g.stage.stageWidth / 2 - 380;
			container.y = g.stage.stageHeight / 2 - 5 * 60;
			if(blackBackground.visible) {
				drawBlackBackground();
			}
		}
		
		override public function loadCompleted() : void {
			Login.fadeScreen.fadeOut();
			_loaded = true;
		}
		
		override public function execute() : void {
			if(!g.isLeaving) {
				g.draw();
			}
		}
		
		override public function exit(callback:Function) : void {
			g.removeChildFromMenu(container);
			g.removeResizeListener(resize);
			unloadCompleted();
			callback();
		}
		
		override public function tickUpdate() : void {
			super.tickUpdate();
		}
		
		protected function addChild(child:DisplayObject) : void {
			container.addChild(child);
		}
		
		private function updateMouseIntegrator() : void {
			var _local1:int = Starling.current.nativeOverlay.mouseX;
			var _local2:int = Starling.current.nativeOverlay.mouseY;
			if(oldMouseX != 0 && oldMouseY != 0) {
				mouseIntegrator += (_local1 - oldMouseX) * (_local1 - oldMouseX) + (_local2 - oldMouseY) * (_local2 - oldMouseY);
			}
			if(mouseIntegrator > 100000) {
				mouseBlocked = false;
				mouseIntegrator = 0;
				oldMouseX = 0;
				oldMouseY = 0;
			}
			oldMouseX = _local1;
			oldMouseY = _local2;
			mouseIntegrator -= 350;
			if(mouseIntegrator < 0) {
				mouseIntegrator = 0;
			}
		}
		
		public function updateMouseAim() : void {
			var _local3:PlayerShip = me.ship;
			var _local4:Heading = _local3.course;
			var _local6:Point = _local3.getGlobalPos();
			var _local7:Number = _local6.x;
			var _local8:Number = _local6.y;
			var _local5:Number = _local3.engine.rotationSpeed / 33;
			var _local1:Number = Math.atan2(Starling.current.nativeOverlay.mouseY - _local8,Starling.current.nativeOverlay.mouseX - _local7);
			var _local2:Number = Util.angleDifference(_local3.rotation,_local1);
			if(_local2 < _local5 && _local2 > -_local5) {
				if(_local4.rotateLeft) {
					sendCommand(1,false);
				}
				if(_local4.rotateRight) {
					sendCommand(2,false);
				}
			} else if(_local2 > _local5) {
				if(_local4.rotateRight) {
					sendCommand(2,false);
				} else if(!_local4.rotateLeft) {
					sendCommand(1,true);
				}
			} else if(_local2 < -_local5) {
				if(_local4.rotateLeft) {
					sendCommand(1,false);
				} else if(!_local4.rotateRight) {
					sendCommand(2,true);
				}
			}
		}
		
		public function checkAccelerate(menuIsActive:Boolean = false) : void {
			if(!me.commandable) {
				return;
			}
			if(!_loaded) {
				return;
			}
			var _local2:PlayerShip = me.ship;
			var _local3:Heading = _local2.course;
			if(keybinds.isInputPressed(26)) {
				autoCruise = autoCruise ? false : true;
			}
			if(keybinds.isInputPressed(11) || keybinds.isInputPressed(12)) {
				autoCruise = false;
			}
			if((!_local3.accelerate || _local2.boostEndedLastTick) && !menuIsActive && !_local2.usingBoost && keybinds.isInputDown(11) || !_local3.accelerate && autoCruise) {
				_local2.boostEndedLastTick = false;
				sendCommand(0,true);
				g.camera.zoomFocus(0.85,100);
			}
			if((_local3.accelerate || _local2.boostEndedLastTick) && !_local2.usingBoost && keybinds.isInputUp(11) && !autoCruise) {
				_local2.boostEndedLastTick = false;
				sendCommand(0,false);
				g.camera.zoomFocus(1,100);
			}
			if(!_local3.accelerate && !_local3.deaccelerate && !menuIsActive && !_local2.usingBoost && keybinds.isInputDown(12)) {
				sendCommand(8,true);
				g.camera.zoomFocus(1,100);
			}
			if(_local3.deaccelerate && !_local2.usingBoost && keybinds.isInputUp(12)) {
				sendCommand(8,false);
				g.camera.zoomFocus(1,100);
			}
		}
		
		public function updateCommands() : void {
			if(!me.commandable) {
				return;
			}
			if(!_loaded) {
				return;
			}
			var _local1:PlayerShip = me.ship;
			if(_local1.channelingEnd > g.time) {
				_local1.course.rotateLeft = false;
				_local1.course.rotateRight = false;
				_local1.course.accelerate = false;
				return;
			}
			checkBoost();
			checkShield();
			checkConvert();
			checkPower();
			checkAccelerate();
			if(!_local1.isTeleporting && !_local1.usingBoost) {
				handleTurn();
			}
			handleWeaponFire();
			if(g.me.isDeveloper) {
				handleDeathlines();
			}
		}
		
		private function handleTurn() : void {
			if(keybinds.isInputDown(13) || keybinds.isInputDown(14)) {
				mouseBlocked = true;
				mouseIntegrator = 0;
			}
			if(SceneBase.settings.mouseAim && !mouseBlocked) {
				return updateMouseAim();
			}
			var _local1:Heading = me.ship.course;
			if(!_local1.rotateLeft && keybinds.isInputDown(13)) {
				sendCommand(1,true);
			} else if(_local1.rotateLeft && keybinds.isInputUp(13)) {
				sendCommand(1,false);
			}
			if(!_local1.rotateRight && keybinds.isInputDown(14)) {
				sendCommand(2,true);
			} else if(_local1.rotateRight && keybinds.isInputUp(14)) {
				sendCommand(2,false);
			}
			if(SceneBase.settings.mouseAim) {
				updateMouseIntegrator();
			}
		}
		
		private function handleWeaponFire() : void {
			var _local3:PlayerShip = me.ship;
			fireWithHotkeys = false;
			var _local1:int = 0;
			if(keybinds.isInputDown(20)) {
				_local1 = 1;
			} else if(keybinds.isInputDown(21)) {
				_local1 = 2;
			} else if(keybinds.isInputDown(22)) {
				_local1 = 3;
			} else if(keybinds.isInputDown(23)) {
				_local1 = 4;
			} else if(keybinds.isInputDown(24)) {
				_local1 = 5;
			}
			if(_local1 > 0 && _local1 < 6) {
				if(g.hud.weaponHotkeys.selectedHotkey == null || _local1 != g.hud.weaponHotkeys.selectedHotkey.key && !_local3.weaponIsChanging) {
					g.me.sendChangeWeapon(_local1);
				}
				if(SceneBase.settings.fireWithHotkeys) {
					fireWithHotkeys = true;
				}
			}
			if(!_local3.isShooting && (keybinds.isInputDown(19) || fireWithHotkeys)) {
				sendCommand(3,true);
			} else if(_local3.isShooting && keybinds.isInputUp(19) && !fireWithHotkeys) {
				for each(var _local2 in _local3.weapons) {
					_local2.fire = false;
				}
				sendCommand(3,false);
			}
		}
		
		private function handleDeathlines() : void {
			var _local1:PlayerShip = me.ship;
			if(input.isKeyPressed(89)) {
				g.deathLineManager.addCoord(_local1.pos.x,_local1.pos.y);
			}
			if(input.isKeyPressed(75)) {
				g.deathLineManager.cut();
			}
			if(input.isKeyPressed(85)) {
				g.deathLineManager.undo(true);
			}
			if(input.isKeyPressed(8)) {
				g.deathLineManager.deleteSelected("",true);
			}
			if(input.isKeyPressed(112)) {
				g.deathLineManager.save();
				g.textManager.createBossSpawnedText("Death lines saved!");
			}
			if(input.isKeyPressed(74)) {
				g.deathLineManager.clear(true);
			}
		}
		
		private function checkPower() : void {
			if(keybinds.isInputPressed(18)) {
				g.commandManager.addDmgBoostCommand();
			}
		}
		
		private function checkConvert() : void {
			if(keybinds.isInputPressed(17)) {
				g.commandManager.addShieldConvertCommand();
			}
		}
		
		private function checkShield() : void {
			if(keybinds.isInputPressed(16)) {
				g.commandManager.addHardenedShieldCommand();
			}
		}
		
		private function checkBoost() : void {
			if(keybinds.isInputPressed(15)) {
				g.commandManager.addBoostCommand();
				if(me.ship.usingBoost) {
					g.camera.zoomFocus(0.75,80);
				}
			}
		}
		
		private function sendCommand(type:int, active:Boolean) : void {
			g.commandManager.addCommand(type,active);
		}
		
		protected function drawBlackBackground(e:Event = null) : void {
			blackBackground.x = -container.x;
			blackBackground.y = -container.y;
			blackBackground.width = g.stage.stageWidth;
			blackBackground.height = g.stage.stageHeight;
			blackBackground.visible = true;
		}
		
		protected function clearBackground(e:Event = null) : void {
			blackBackground.visible = false;
		}
	}
}

