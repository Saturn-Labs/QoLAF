package core.weapon {
	import core.hud.components.BeamLine;
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import core.solarSystem.Body;
	import core.unit.Unit;
	import flash.geom.Point;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.MeshBatch;
	
	public class Beam extends Weapon {
		private var startEffect:Vector.<Emitter> = new Vector.<Emitter>();
		
		private var startEffect2:Vector.<Emitter> = new Vector.<Emitter>();
		
		private var endEffect:Vector.<Emitter> = new Vector.<Emitter>();
		
		public var startPos:Point = new Point();
		
		public var startPos2:Point = new Point();
		
		public var endPos:Point = new Point();
		
		public var lastPos:Point = new Point();
		
		private var lines:Vector.<BeamLine> = new Vector.<BeamLine>();
		
		private var lineBatch:MeshBatch = new MeshBatch();
		
		private var ready:Boolean = false;
		
		public var nrTargets:int = 0;
		
		public var secondaryTargets:Vector.<Unit> = new Vector.<Unit>();
		
		private var beamColor:uint = 16777215;
		
		private var beamAmplitude:Number = 2;
		
		private var beamThickness:Number = 1;
		
		private var startBeamAlpha:Number = 1;
		
		private var beamAlpha:Number = 1;
		
		private var beams:int = 3;
		
		private var beamNodes:Number = 0;
		
		private var glowColor:uint = 16711680;
		
		private var oldDrawBeam:Boolean;
		
		private var drawBeam:Boolean;
		
		private var targetBody:Body;
		
		private var chargeUpMax:int;
		
		private var chargeUPCurrent:int = 0;
		
		private var chargeUpCounter:int = 0;
		
		private var chargeUpNext:int = 8;
		
		private var chargeUpExpire:Number = 2000;
		
		private var lastDamaged:Number = 0;
		
		private var twin:Boolean = false;
		
		private var twinOffset:Number = 0;
		
		private var obj:Object;
		
		private var effectsInitialized:Boolean = false;
		
		public function Beam(g:Game) {
			super(g);
			lineBatch.blendMode = "add";
		}
		
		override public function init(obj:Object, techLevel:int, eliteTechLevel:int = -1, eliteTech:String = "") : void {
			var _local5:int = 0;
			var _local7:Object = null;
			var _local6:int = 0;
			super.init(obj,techLevel,eliteTechLevel,eliteTech);
			this.obj = obj;
			drawBeam = false;
			if(obj.hasOwnProperty("nrTargets")) {
				nrTargets = obj.nrTargets;
			} else {
				nrTargets = 1;
			}
			if(obj.hasOwnProperty("chargeUp")) {
				chargeUpMax = obj.chargeUp;
			} else {
				chargeUpMax = 0;
			}
			if(obj.hasOwnProperty("twin")) {
				twin = obj.twin;
				twinOffset = obj.twinOffset;
			}
			beamNodes = obj.beamNodes;
			if(techLevel > 0) {
				_local6 = 100;
				_local5 = 0;
				while(_local5 < techLevel) {
					_local7 = obj.techLevels[_local5];
					_local6 += _local7.incInterval;
					if(_local7.hasOwnProperty("incNrTargets")) {
						nrTargets += _local7.incNrTargets;
					}
					if(_local7.hasOwnProperty("incChargeUp")) {
						chargeUpMax += _local7.incChargeUp;
					}
					if(_local5 == techLevel - 1) {
						beamColor = _local7.beamColor;
						beams = _local7.beams;
						beamAmplitude = _local7.beamAmplitude;
						beamThickness = _local7.beamThickness;
						beamAlpha = _local7.beamAlpha;
						startBeamAlpha = beamAlpha;
						glowColor = _local7.glowColor;
					}
					_local5++;
				}
			} else {
				beamColor = obj.beamColor;
				beams = obj.beams;
				beamAmplitude = obj.beamAmplitude;
				beamThickness = obj.beamThickness;
				beamAlpha = obj.beamAlpha;
				startBeamAlpha = beamAlpha;
				glowColor = obj.glowColor;
			}
			ready = true;
		}
		
		private function initEffects() : void {
			var _local4:int = 0;
			var _local3:BeamLine = null;
			startEffect = EmitterFactory.create(obj.fireEffect,g,0,0,null,false);
			endEffect = EmitterFactory.create(obj.hitEffect,g,0,0,null,false);
			var _local2:int = 0;
			var _local1:int = beams;
			_local4 = 0;
			while(_local4 < nrTargets) {
				_local2 += _local1 <= 0 ? 1 : _local1;
				_local1--;
				_local4++;
			}
			if(twin) {
				startEffect2 = EmitterFactory.create(obj.fireEffect,g,0,0,null,false);
				_local2 = 2 * _local2;
			}
			_local4 = 0;
			while(_local4 < _local2) {
				_local3 = g.beamLinePool.getLine();
				_local3.init(beamThickness,beamNodes,beamAmplitude,beamColor,beamAlpha,4,glowColor);
				lines.push(_local3);
				_local4++;
			}
			effectsInitialized = true;
		}
		
		override public function destroy() : void {
			for each(var _local1 in startEffect) {
				_local1.alive = false;
			}
			if(twin) {
				for each(_local1 in startEffect2) {
					_local1.alive = false;
				}
			}
			for each(var _local2 in endEffect) {
				_local2.alive = false;
			}
			fire = false;
			effectsInitialized = false;
			lineBatch.clear();
			g.canvasEffects.removeChild(lineBatch);
			super.destroy();
		}
		
		override protected function shoot() : void {
			var _local8:ISound = null;
			var _local2:PlayerShip = null;
			if(!effectsInitialized) {
				initEffects();
			}
			if(targetBody != null) {
				return;
			}
			if(g.time - lastDamaged > chargeUpExpire) {
				chargeUPCurrent = 0;
			}
			if(drawBeam && !oldDrawBeam) {
				if(fireSound != null && g.camera.isCircleOnScreen(unit.x,unit.y,unit.radius)) {
					_local8 = SoundLocator.getService();
					_local8.play(fireSound);
				}
			}
			oldDrawBeam = drawBeam;
			var _local4:Number = unit.weaponPos.y + positionOffsetY;
			var _local3:Number = unit.weaponPos.x + positionOffsetX;
			var _local9:Number = Math.sqrt(_local3 * _local3 + _local4 * _local4);
			var _local7:Number = Math.atan2(_local4,_local3);
			if(unit.forcedRotation) {
				if(twin) {
					startPos.x = unit.x + Math.cos(_local7 + unit.forcedRotationAngle) * _local9 + Math.cos(_local7 + unit.forcedRotationAngle + 0.5 * 3.141592653589793) * twinOffset;
					startPos.y = unit.y + Math.sin(_local7 + unit.forcedRotationAngle) * _local9 + Math.sin(_local7 + unit.forcedRotationAngle + 0.5 * 3.141592653589793) * twinOffset;
					startPos2.x = unit.x + Math.cos(_local7 + unit.forcedRotationAngle) * _local9 + Math.cos(_local7 + unit.forcedRotationAngle - 0.5 * 3.141592653589793) * twinOffset;
					startPos2.y = unit.y + Math.sin(_local7 + unit.forcedRotationAngle) * _local9 + Math.sin(_local7 + unit.forcedRotationAngle - 0.5 * 3.141592653589793) * twinOffset;
				} else {
					startPos.x = unit.x + Math.cos(_local7 + unit.forcedRotationAngle) * _local9;
					startPos.y = unit.y + Math.sin(_local7 + unit.forcedRotationAngle) * _local9;
				}
			} else if(twin) {
				startPos.x = unit.x + Math.cos(unit.rotation + _local7) * _local9 + Math.cos(unit.rotation + _local7 + 0.5 * 3.141592653589793) * twinOffset;
				startPos.y = unit.y + Math.sin(unit.rotation + _local7) * _local9 + Math.sin(unit.rotation + _local7 + 0.5 * 3.141592653589793) * twinOffset;
				startPos2.x = unit.x + Math.cos(unit.rotation + _local7) * _local9 + Math.cos(unit.rotation + _local7 - 0.5 * 3.141592653589793) * twinOffset;
				startPos2.y = unit.y + Math.sin(unit.rotation + _local7) * _local9 + Math.sin(unit.rotation + _local7 - 0.5 * 3.141592653589793) * twinOffset;
			} else {
				startPos.x = unit.x + Math.cos(unit.rotation + _local7) * _local9;
				startPos.y = unit.y + Math.sin(unit.rotation + _local7) * _local9;
			}
			updateTargetOrder();
			var _local10:Number = unit.rotation;
			for each(var _local5 in startEffect) {
				_local5.posX = startPos.x;
				_local5.posY = startPos.y;
				_local5.angle = _local10;
			}
			if(twin) {
				for each(_local5 in startEffect2) {
					_local5.posX = startPos2.x;
					_local5.posY = startPos2.y;
					_local5.angle = _local10;
				}
			}
			if(target == null || !target.alive) {
				chargeUpCounter = 0;
				target = null;
				beamAlpha = startBeamAlpha / 3;
				endPos.x = unit.x + Math.cos(unit.rotation + _local7) * range;
				endPos.y = unit.y + Math.sin(unit.rotation + _local7) * range;
				for each(var _local11 in endEffect) {
					_local11.posX = endPos.x;
					_local11.posY = endPos.y;
					_local11.angle = _local10 - 3.141592653589793;
				}
				drawBeam = true;
				updateEmitters();
				return;
			}
			beamAlpha = startBeamAlpha;
			lastDamaged = g.time;
			if(fireNextTime < g.time) {
				if(unit is PlayerShip) {
					_local2 = unit as PlayerShip;
					if(!_local2.weaponHeat.canFire(heatCost)) {
						fireNextTime += reloadTime;
						return;
					}
				}
				if(lastFire == 0 || fireNextTime == 0) {
					fireNextTime = g.time + reloadTime - 33;
				} else {
					fireNextTime += reloadTime;
				}
				lastFire = g.time;
				chargeUpCounter++;
				if(chargeUpCounter > chargeUpNext && chargeUPCurrent < chargeUpMax) {
					chargeUpCounter = 0;
					chargeUPCurrent++;
				}
			}
			endPos.x = target.pos.x;
			endPos.y = target.pos.y;
			var _local1:Number = endPos.x - startPos.x;
			var _local6:Number = endPos.y - startPos.y;
			_local10 = Math.atan2(_local6,_local1);
			for each(_local11 in endEffect) {
				_local11.posX = endPos.x;
				_local11.posY = endPos.y;
				_local11.angle = _local10 - 3.141592653589793;
			}
			drawBeam = true;
			updateEmitters();
		}
		
		private function updateTargetOrder() : void {
			var _local1:Unit = null;
			if(target == null || !target.alive) {
				while(secondaryTargets.length > 0) {
					_local1 = secondaryTargets[0];
					secondaryTargets.splice(0,1);
					if(_local1.alive) {
						target = _local1;
						return;
					}
				}
			}
		}
		
		private function updateEmitters() : void {
			if(drawBeam == oldDrawBeam) {
				return;
			}
			if(drawBeam) {
				for each(var _local2 in lines) {
					lineBatch.addMesh(_local2);
				}
				g.canvasEffects.addChild(lineBatch);
				for each(var _local1 in endEffect) {
					_local1.play();
				}
			} else {
				lineBatch.clear();
				g.canvasEffects.removeChild(lineBatch);
				for each(var _local3 in endEffect) {
					_local3.stop();
				}
			}
		}
		
		public function fireAtBody(b:Body) : void {
			var _local9:Number = NaN;
			targetBody = b;
			if(b == null) {
				drawBeam = false;
				fire = false;
				updateEmitters();
				return;
			}
			oldDrawBeam = drawBeam;
			_local9 = unit.rotation;
			var _local4:Number = unit.weaponPos.y;
			var _local3:Number = unit.weaponPos.x;
			var _local8:Number = Math.sqrt(_local3 * _local3 + _local4 * _local4);
			var _local7:Number = Math.atan2(_local4,_local3);
			startPos.x = unit.x + Math.cos(unit.rotation + _local7 + unit.forcedRotationAngle) * _local8;
			startPos.y = unit.y + Math.sin(unit.rotation + _local7 + unit.forcedRotationAngle) * _local8;
			for each(var _local5 in startEffect) {
				_local5.posX = startPos.x;
				_local5.posY = startPos.y;
				_local5.angle = _local9;
			}
			endPos.x = b.pos.x;
			endPos.y = b.pos.y;
			drawBeam = true;
			var _local2:Number = endPos.x - startPos.x;
			var _local6:Number = endPos.y - startPos.y;
			_local8 = Math.sqrt(_local2 * _local2 + _local6 * _local6);
			if(_local8 > 0.6 * b.radius) {
				_local8 = (_local8 - 0.6 * b.radius) / _local8;
			} else {
				_local8 = _local8 * 0.6 / _local8;
			}
			endPos.x = startPos.x + _local2 * _local8;
			endPos.y = startPos.y + _local6 * _local8;
			_local9 = Math.atan2(_local6,_local2);
			for each(var _local10 in endEffect) {
				_local10.posX = endPos.x;
				_local10.posY = endPos.y;
				_local10.angle = _local9 - 3.141592653589793;
			}
			updateEmitters();
		}
		
		private function drawBeamEffect(i:int, sPos:Point, ePos:Point, nrBeams:int) : int {
			var _local9:int = 0;
			var _local7:BeamLine = null;
			var _local5:Number = ePos.x - sPos.x;
			var _local6:Number = ePos.y - sPos.y;
			var _local8:int = _local5 * _local5 + _local6 * _local6;
			if(_local8 < 1 || _local8 > 400 * 60 * 60 || lines.length < 1 || lines.length - 1 < i) {
				return i + 1;
			}
			var _local10:Number = 0;
			_local9 = 0;
			while(_local9 < nrBeams) {
				if(chargeUpMax > 0) {
					_local10 = chargeUPCurrent / chargeUpMax * 1 * beamThickness;
				} else {
					_local10 = 0;
				}
				_local7 = lines[i];
				_local7.x = sPos.x;
				_local7.y = sPos.y;
				_local7.lineTo(ePos.x,ePos.y,_local10);
				_local7.visible = true;
				i += 1;
				_local9++;
			}
			return i;
		}
		
		override public function draw() : void {
			var _local3:BeamLine = null;
			var _local6:int = 0;
			var _local5:Heat = null;
			var _local7:int = 0;
			var _local2:Unit = null;
			if(!drawBeam) {
				return;
			}
			var _local1:Number = 0;
			if(g.me.ship != null) {
				_local5 = g.me.ship.weaponHeat;
				_local1 = _local5.heat / _local5.max * 1.5;
				if(_local1 > 1) {
					_local1 = 1;
				}
			}
			if(_local1 < 0.3) {
				_local1 = 0.3;
			}
			_local6 = 0;
			while(_local6 < lines.length) {
				_local3 = lines[_local6];
				_local3.alpha = _local1 * beamAlpha;
				_local3.visible = false;
				_local6++;
			}
			if(twin) {
				_local6 = drawBeamEffect(0,startPos,endPos,beams);
				_local6 = drawBeamEffect(_local6,startPos2,endPos,beams);
			} else {
				_local6 = drawBeamEffect(0,startPos,endPos,beams);
			}
			lastPos.x = endPos.x;
			lastPos.y = endPos.y;
			var _local4:int = beams;
			_local7 = 0;
			while(_local7 < secondaryTargets.length) {
				_local2 = secondaryTargets[_local7];
				if(_local2.alive) {
					if(_local4 > 1) {
						_local4--;
					}
					_local6 = drawBeamEffect(_local6,lastPos,_local2.pos,_local4);
					lastPos.x = _local2.pos.x;
					lastPos.y = _local2.pos.y;
				}
				_local7++;
			}
			lineBatch.clear();
			_local6 = 0;
			while(_local6 < lines.length) {
				_local3 = lines[_local6];
				if(_local3.visible) {
					lineBatch.addMesh(lines[_local6]);
				}
				_local6++;
			}
			lineBatch.alpha = _local1 * beamAlpha;
		}
		
		override public function set fire(value:Boolean) : void {
			if(targetBody != null || value == _fire) {
				return;
			}
			_fire = value;
			lastFire = 0;
			if(_fire == true) {
				for each(var _local3 in startEffect) {
					_local3.play();
				}
				if(twin) {
					for each(_local3 in startEffect2) {
						_local3.play();
					}
				}
			} else {
				drawBeam = false;
				lineBatch.clear();
				g.canvasEffects.removeChild(lineBatch);
				for each(var _local2 in lines) {
					_local2.clear();
				}
				for each(var _local4 in startEffect) {
					_local4.stop();
				}
				if(twin) {
					for each(_local4 in startEffect2) {
						_local4.stop();
					}
				}
				for each(var _local5 in endEffect) {
					_local5.stop();
				}
			}
		}
	}
}

