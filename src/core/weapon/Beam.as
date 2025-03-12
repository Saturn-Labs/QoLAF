package core.weapon
{
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
	
	public class Beam extends Weapon
	{
		private var startEffect:Vector.<Emitter>;
		
		private var startEffect2:Vector.<Emitter>;
		
		private var endEffect:Vector.<Emitter>;
		
		public var startPos:Point;
		
		public var startPos2:Point;
		
		public var endPos:Point;
		
		public var lastPos:Point;
		
		private var lines:Vector.<BeamLine>;
		
		private var lineBatch:MeshBatch;
		
		private var ready:Boolean = false;
		public var nrTargets:int = 0;
		public var secondaryTargets:Vector.<Unit>;
		
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
		public function Beam(param1:Game)
		{
			startEffect = new Vector.<Emitter>();
			startEffect2 = new Vector.<Emitter>();
			endEffect = new Vector.<Emitter>();
			startPos = new Point();
			startPos2 = new Point();
			endPos = new Point();
			lastPos = new Point();
			lines = new Vector.<BeamLine>();
			lineBatch = new MeshBatch();
			secondaryTargets = new Vector.<Unit>();
			super(param1);
			lineBatch.blendMode = "add";
		}
		
		override public function init(param1:Object, param2:int, param3:int = -1, param4:String = ""):void
		{
			var _loc7_:int = 0;
			var _loc5_:Object = null;
			var _loc6_:int = 0;
			super.init(param1, param2, param3, param4);
			this.obj = param1;
			drawBeam = false;
			if (param1.hasOwnProperty("nrTargets"))
			{
				nrTargets = param1.nrTargets;
			}
			else
			{
				nrTargets = 1;
			}
			if (param1.hasOwnProperty("chargeUp"))
			{
				chargeUpMax = param1.chargeUp;
			}
			else
			{
				chargeUpMax = 0;
			}
			if (param1.hasOwnProperty("twin"))
			{
				twin = param1.twin;
				twinOffset = param1.twinOffset;
			}
			beamNodes = param1.beamNodes;
			if (param2 > 0)
			{
				_loc6_ = 100;
				_loc7_ = 0;
				while (_loc7_ < param2)
				{
					_loc5_ = param1.techLevels[_loc7_];
					_loc6_ += _loc5_.incInterval;
					if (_loc5_.hasOwnProperty("incNrTargets"))
					{
						nrTargets += _loc5_.incNrTargets;
					}
					if (_loc5_.hasOwnProperty("incChargeUp"))
					{
						chargeUpMax += _loc5_.incChargeUp;
					}
					if (_loc7_ == param2 - 1)
					{
						beamColor = _loc5_.beamColor;
						beams = _loc5_.beams;
						beamAmplitude = _loc5_.beamAmplitude;
						beamThickness = _loc5_.beamThickness;
						beamAlpha = _loc5_.beamAlpha;
						startBeamAlpha = beamAlpha;
						glowColor = _loc5_.glowColor;
					}
					_loc7_++;
				}
			}
			else
			{
				beamColor = param1.beamColor;
				beams = param1.beams;
				beamAmplitude = param1.beamAmplitude;
				beamThickness = param1.beamThickness;
				beamAlpha = param1.beamAlpha;
				startBeamAlpha = beamAlpha;
				glowColor = param1.glowColor;
			}
			ready = true;
		}
		
		private function initEffects():void
		{
			var _loc4_:int = 0;
			var _loc1_:BeamLine = null;
			startEffect = EmitterFactory.create(obj.fireEffect, g, 0, 0, null, false);
			endEffect = EmitterFactory.create(obj.hitEffect, g, 0, 0, null, false);
			var _loc2_:int = 0;
			var _loc3_:int = beams;
			_loc4_ = 0;
			while (_loc4_ < nrTargets)
			{
				_loc2_ += _loc3_ <= 0 ? 1 : _loc3_;
				_loc3_--;
				_loc4_++;
			}
			if (twin)
			{
				startEffect2 = EmitterFactory.create(obj.fireEffect, g, 0, 0, null, false);
				_loc2_ = 2 * _loc2_;
			}
			_loc4_ = 0;
			while (_loc4_ < _loc2_)
			{
				_loc1_ = g.beamLinePool.getLine();
				_loc1_.init(beamThickness, beamNodes, beamAmplitude, beamColor, beamAlpha, 4, glowColor);
				lines.push(_loc1_);
				_loc4_++;
			}
			effectsInitialized = true;
		}
		
		override public function destroy():void
		{
			for each (var _loc2_:* in startEffect)
			{
				_loc2_.alive = false;
			}
			if (twin)
			{
				for each (_loc2_ in startEffect2)
				{
					_loc2_.alive = false;
				}
			}
			for each (var _loc1_:* in endEffect)
			{
				_loc1_.alive = false;
			}
			fire = false;
			effectsInitialized = false;
			lineBatch.clear();
			g.canvasEffects.removeChild(lineBatch);
			super.destroy();
		}
		
		override protected function shoot():void
		{
			var _loc10_:ISound = null;
			var _loc3_:PlayerShip = null;
			if (!effectsInitialized)
			{
				initEffects();
			}
			if (targetBody != null)
			{
				return;
			}
			if (g.time - lastDamaged > chargeUpExpire)
			{
				chargeUPCurrent = 0;
			}
			if (drawBeam && !oldDrawBeam)
			{
				if (fireSound != null && g.camera.isCircleOnScreen(unit.x, unit.y, unit.radius))
				{
					_loc10_ = SoundLocator.getService();
					_loc10_.play(fireSound);
				}
			}
			oldDrawBeam = drawBeam;
			var _loc5_:Number = unit.weaponPos.y + positionOffsetY;
			var _loc4_:Number = unit.weaponPos.x + positionOffsetX;
			var _loc7_:Number = Math.sqrt(_loc4_ * _loc4_ + _loc5_ * _loc5_);
			var _loc9_:Number = Math.atan2(_loc5_, _loc4_);
			if (unit.forcedRotation)
			{
				if (twin)
				{
					startPos.x = unit.x + Math.cos(_loc9_ + unit.forcedRotationAngle) * _loc7_ + Math.cos(_loc9_ + unit.forcedRotationAngle + 0.5 * 3.141592653589793) * twinOffset;
					startPos.y = unit.y + Math.sin(_loc9_ + unit.forcedRotationAngle) * _loc7_ + Math.sin(_loc9_ + unit.forcedRotationAngle + 0.5 * 3.141592653589793) * twinOffset;
					startPos2.x = unit.x + Math.cos(_loc9_ + unit.forcedRotationAngle) * _loc7_ + Math.cos(_loc9_ + unit.forcedRotationAngle - 0.5 * 3.141592653589793) * twinOffset;
					startPos2.y = unit.y + Math.sin(_loc9_ + unit.forcedRotationAngle) * _loc7_ + Math.sin(_loc9_ + unit.forcedRotationAngle - 0.5 * 3.141592653589793) * twinOffset;
				}
				else
				{
					startPos.x = unit.x + Math.cos(_loc9_ + unit.forcedRotationAngle) * _loc7_;
					startPos.y = unit.y + Math.sin(_loc9_ + unit.forcedRotationAngle) * _loc7_;
				}
			}
			else if (twin)
			{
				startPos.x = unit.x + Math.cos(unit.rotation + _loc9_) * _loc7_ + Math.cos(unit.rotation + _loc9_ + 0.5 * 3.141592653589793) * twinOffset;
				startPos.y = unit.y + Math.sin(unit.rotation + _loc9_) * _loc7_ + Math.sin(unit.rotation + _loc9_ + 0.5 * 3.141592653589793) * twinOffset;
				startPos2.x = unit.x + Math.cos(unit.rotation + _loc9_) * _loc7_ + Math.cos(unit.rotation + _loc9_ - 0.5 * 3.141592653589793) * twinOffset;
				startPos2.y = unit.y + Math.sin(unit.rotation + _loc9_) * _loc7_ + Math.sin(unit.rotation + _loc9_ - 0.5 * 3.141592653589793) * twinOffset;
			}
			else
			{
				startPos.x = unit.x + Math.cos(unit.rotation + _loc9_) * _loc7_;
				startPos.y = unit.y + Math.sin(unit.rotation + _loc9_) * _loc7_;
			}
			updateTargetOrder();
			var _loc8_:Number = unit.rotation;
			for each (var _loc2_:* in startEffect)
			{
				_loc2_.posX = startPos.x;
				_loc2_.posY = startPos.y;
				_loc2_.angle = _loc8_;
			}
			if (twin)
			{
				for each (_loc2_ in startEffect2)
				{
					_loc2_.posX = startPos2.x;
					_loc2_.posY = startPos2.y;
					_loc2_.angle = _loc8_;
				}
			}
			if (target == null || !target.alive)
			{
				chargeUpCounter = 0;
				target = null;
				beamAlpha = startBeamAlpha / 3;
				endPos.x = unit.x + Math.cos(unit.rotation + _loc9_) * range;
				endPos.y = unit.y + Math.sin(unit.rotation + _loc9_) * range;
				for each (var _loc1_:* in endEffect)
				{
					_loc1_.posX = endPos.x;
					_loc1_.posY = endPos.y;
					_loc1_.angle = _loc8_ - 3.141592653589793;
				}
				drawBeam = true;
				updateEmitters();
				return;
			}
			beamAlpha = startBeamAlpha;
			lastDamaged = g.time;
			if (fireNextTime < g.time)
			{
				if (unit is PlayerShip)
				{
					_loc3_ = unit as PlayerShip;
					if (!_loc3_.weaponHeat.canFire(heatCost))
					{
						fireNextTime += reloadTime;
						return;
					}
				}
				if (lastFire == 0 || fireNextTime == 0)
				{
					fireNextTime = g.time + reloadTime - 33;
				}
				else
				{
					fireNextTime += reloadTime;
				}
				lastFire = g.time;
				chargeUpCounter++;
				if (chargeUpCounter > chargeUpNext && chargeUPCurrent < chargeUpMax)
				{
					chargeUpCounter = 0;
					chargeUPCurrent++;
				}
			}
			endPos.x = target.pos.x;
			endPos.y = target.pos.y;
			var _loc6_:Number = endPos.x - startPos.x;
			var _loc11_:Number = endPos.y - startPos.y;
			_loc8_ = Math.atan2(_loc11_, _loc6_);
			for each (_loc1_ in endEffect)
			{
				_loc1_.posX = endPos.x;
				_loc1_.posY = endPos.y;
				_loc1_.angle = _loc8_ - 3.141592653589793;
			}
			drawBeam = true;
			updateEmitters();
		}
		
		private function updateTargetOrder():void
		{
			var _loc1_:Unit = null;
			if (target == null || !target.alive)
			{
				while (secondaryTargets.length > 0)
				{
					_loc1_ = secondaryTargets[0];
					secondaryTargets.splice(0, 1);
					if (_loc1_.alive)
					{
						target = _loc1_;
						return;
					}
				}
			}
		}
		
		private function updateEmitters():void
		{
			if (drawBeam == oldDrawBeam)
			{
				return;
			}
			if (drawBeam)
			{
				for each (var _loc3_:* in lines)
				{
					lineBatch.addMesh(_loc3_);
				}
				g.canvasEffects.addChild(lineBatch);
				for each (var _loc2_:* in endEffect)
				{
					_loc2_.play();
				}
			}
			else
			{
				lineBatch.clear();
				g.canvasEffects.removeChild(lineBatch);
				for each (var _loc1_:* in endEffect)
				{
					_loc1_.stop();
				}
			}
		}
		
		public function fireAtBody(param1:Body):void
		{
			var _loc9_:Number = NaN;
			targetBody = param1;
			if (param1 == null)
			{
				drawBeam = false;
				fire = false;
				updateEmitters();
				return;
			}
			oldDrawBeam = drawBeam;
			_loc9_ = unit.rotation;
			var _loc5_:Number = unit.weaponPos.y;
			var _loc4_:Number = unit.weaponPos.x;
			var _loc7_:Number = Math.sqrt(_loc4_ * _loc4_ + _loc5_ * _loc5_);
			var _loc8_:Number = Math.atan2(_loc5_, _loc4_);
			startPos.x = unit.x + Math.cos(unit.rotation + _loc8_ + unit.forcedRotationAngle) * _loc7_;
			startPos.y = unit.y + Math.sin(unit.rotation + _loc8_ + unit.forcedRotationAngle) * _loc7_;
			for each (var _loc3_:* in startEffect)
			{
				_loc3_.posX = startPos.x;
				_loc3_.posY = startPos.y;
				_loc3_.angle = _loc9_;
			}
			endPos.x = param1.pos.x;
			endPos.y = param1.pos.y;
			drawBeam = true;
			var _loc6_:Number = endPos.x - startPos.x;
			var _loc10_:Number = endPos.y - startPos.y;
			_loc7_ = Math.sqrt(_loc6_ * _loc6_ + _loc10_ * _loc10_);
			if (_loc7_ > 0.6 * param1.radius)
			{
				_loc7_ = (_loc7_ - 0.6 * param1.radius) / _loc7_;
			}
			else
			{
				_loc7_ = _loc7_ * 0.6 / _loc7_;
			}
			endPos.x = startPos.x + _loc6_ * _loc7_;
			endPos.y = startPos.y + _loc10_ * _loc7_;
			_loc9_ = Math.atan2(_loc10_, _loc6_);
			for each (var _loc2_:* in endEffect)
			{
				_loc2_.posX = endPos.x;
				_loc2_.posY = endPos.y;
				_loc2_.angle = _loc9_ - 3.141592653589793;
			}
			updateEmitters();
		}
		
		private function drawBeamEffect(param1:int, param2:Point, param3:Point, param4:int):int
		{
			var _loc8_:int = 0;
			var _loc7_:BeamLine = null;
			var _loc6_:Number = param3.x - param2.x;
			var _loc10_:Number = param3.y - param2.y;
			var _loc5_:int = _loc6_ * _loc6_ + _loc10_ * _loc10_;
			if (_loc5_ < 1 || _loc5_ > 1440000 || lines.length < 1 || lines.length - 1 < param1)
			{
				return param1 + 1;
			}
			var _loc9_:Number = 0;
			_loc8_ = 0;
			while (_loc8_ < param4)
			{
				if (chargeUpMax > 0)
				{
					_loc9_ = chargeUPCurrent / chargeUpMax * 1 * beamThickness;
				}
				else
				{
					_loc9_ = 0;
				}
				_loc7_ = lines[param1];
				_loc7_.x = param2.x;
				_loc7_.y = param2.y;
				_loc7_.lineTo(param3.x, param3.y, _loc9_);
				_loc7_.visible = true;
				param1 += 1;
				_loc8_++;
			}
			return param1;
		}
		
		override public function draw():void
		{
			var _loc3_:BeamLine = null;
			var _loc7_:int = 0;
			var _loc6_:Heat = null;
			var _loc4_:int = 0;
			var _loc1_:Unit = null;
			if (!drawBeam)
			{
				return;
			}
			var _loc5_:Number = 0;
			if (g.me.ship != null)
			{
				_loc6_ = g.me.ship.weaponHeat;
				_loc5_ = _loc6_.heat / _loc6_.max * 1.5;
				if (_loc5_ > 1)
				{
					_loc5_ = 1;
				}
			}
			if (_loc5_ < 0.3)
			{
				_loc5_ = 0.3;
			}
			_loc7_ = 0;
			while (_loc7_ < lines.length)
			{
				_loc3_ = lines[_loc7_];
				_loc3_.alpha = _loc5_ * beamAlpha;
				_loc3_.visible = false;
				_loc7_++;
			}
			if (twin)
			{
				_loc7_ = drawBeamEffect(0, startPos, endPos, beams);
				_loc7_ = drawBeamEffect(_loc7_, startPos2, endPos, beams);
			}
			else
			{
				_loc7_ = drawBeamEffect(0, startPos, endPos, beams);
			}
			lastPos.x = endPos.x;
			lastPos.y = endPos.y;
			var _loc2_:int = beams;
			_loc4_ = 0;
			while (_loc4_ < secondaryTargets.length)
			{
				_loc1_ = secondaryTargets[_loc4_];
				if (_loc1_.alive)
				{
					if (_loc2_ > 1)
					{
						_loc2_--;
					}
					_loc7_ = drawBeamEffect(_loc7_, lastPos, _loc1_.pos, _loc2_);
					lastPos.x = _loc1_.pos.x;
					lastPos.y = _loc1_.pos.y;
				}
				_loc4_++;
			}
			lineBatch.clear();
			_loc7_ = 0;
			while (_loc7_ < lines.length)
			{
				_loc3_ = lines[_loc7_];
				if (_loc3_.visible)
				{
					lineBatch.addMesh(lines[_loc7_]);
				}
				_loc7_++;
			}
			lineBatch.alpha = _loc5_ * beamAlpha;
		}
		
		override public function set fire(param1:Boolean):void
		{
			if (targetBody != null || param1 == _fire)
			{
				return;
			}
			_fire = param1;
			lastFire = 0;
			if (_fire == true)
			{
				for each (var _loc5_:* in startEffect)
				{
					_loc5_.play();
				}
				if (twin)
				{
					for each (_loc5_ in startEffect2)
					{
						_loc5_.play();
					}
				}
			}
			else
			{
				drawBeam = false;
				lineBatch.clear();
				g.canvasEffects.removeChild(lineBatch);
				for each (var _loc4_:* in lines)
				{
					_loc4_.clear();
				}
				for each (var _loc3_:* in startEffect)
				{
					_loc3_.stop();
				}
				if (twin)
				{
					for each (_loc3_ in startEffect2)
					{
						_loc3_.stop();
					}
				}
				for each (var _loc2_:* in endEffect)
				{
					_loc2_.stop();
				}
			}
		}
	}
}
