package core.hud.components.explore
{
	import core.scene.Game;
	import core.solarSystem.Body;
	import debug.Console;
	import flash.display.Sprite;
	import flash.geom.Point;
	import generics.Random;
	import playerio.DatabaseObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import textures.ITextureManager;
	import textures.TextureLocator;
	import textures.TextureManager;

	public class ExploreMap extends starling.display.Sprite
	{
		public static var selectedArea:Object = null;
		public static var forceSelectAreaKey:String = null;
		private static const X_SIZE:int = 130;

		private static const Y_SIZE:int = 45;

		private static const FINAL_X_SIZE:int = 660;

		private static const FINAL_Y_SIZE:int = 660;

		private static const STEPS_OF_POSTPROCCESSING:int = 0;

		private static const directions:Vector.<Vector.<int>> = Vector.<Vector.<int>>([Vector.<int>([0, 1]), Vector.<int>([1, 1]), Vector.<int>([1, 0]), Vector.<int>([1, -1]), Vector.<int>([0, -1]), Vector.<int>([-1, -1]), Vector.<int>([-1, 0]), Vector.<int>([-1, 1])]);

		public var areas:Array;
		private var explored:Array;
		private var done:Boolean;
		private var seed:Number;
		private var g:Game;
		private var r:Random;
		private var m:Vector.<Vector.<int>>;

		public var shell:Vector.<Vector.<Point>>;

		private var grid:Vector.<Vector.<Point>>;

		private var lastPos:int;
		private var raw_areas:Array;
		private var extraAreas:int;
		private var area_key_index:int = 0;
		private var map_areas:Vector.<ExploreMapArea>;

		private var x_chance:int = 35;
		private var y_chance:int = 25;
		private var fraction_cover:Number = 0.1;
		public function ExploreMap(param1:Game, param2:Array, param3:Array, param4:Body)
		{
			super();
			this.raw_areas = param2;
			this.extraAreas = param4.extraAreas;
			this.explored = param3;
			this.seed = param4.seed;
			this.g = param1;
			if (!param4.generatedAreas || !param4.generatedShells)
			{
				generateMap();
				param4.generatedAreas = areas;
				param4.generatedShells = shell;
			}
			else
			{
				areas = param4.generatedAreas;
				shell = param4.generatedShells;
			}
			drawMap();
		}

		public function getMapArea(param1:String):ExploreMapArea
		{
			if (map_areas != null)
			{
				for each (var _loc2_:* in map_areas)
				{
					if (_loc2_.key != null && _loc2_.key == param1)
					{
						return _loc2_;
					}
				}
			}
			return null;
		}

		private function drawMap():void
		{
			var _loc2_:* = null;
			var _loc4_:Number = 5.076923076923077;
			var _loc5_:Number = 5.076923076923077;
			var _loc3_:ITextureManager = TextureLocator.getService();
			addChild(new Image(_loc3_.getTextureGUIByTextureName("grid.png")));
			var _loc10_:int = 0;
			map_areas = new Vector.<ExploreMapArea>();
			for each (var _loc1_:* in shell)
			{
				_loc2_ = null;
				for each (var _loc6_:* in explored)
				{
					if (_loc6_.area == areas[_loc10_].key)
					{
						_loc2_ = _loc6_;
					}
				}
				map_areas.push(new ExploreMapArea(g, this, areas[_loc10_], _loc1_, _loc4_, _loc5_, 130));
				_loc10_++;
			}
			_loc10_ = 10;
			while (_loc10_ > 0)
			{
				for each (var _loc8_:* in map_areas)
				{
					if (_loc8_.size == _loc10_)
					{
						addChild(_loc8_);
					}
				}
				_loc10_--;
			}
			selectEasiest();
			var _loc9_:Quad = new Quad(660, 80, 0);
			_loc9_.y = 65;
			var _loc7_:Quad = new Quad(660, 80, 0);
			_loc7_.y = 490;
			addChild(_loc7_);
		}

		private function generateGrid(param1:int, param2:int):void
		{
			var _loc5_:int = 0;
			var _loc3_:* = undefined;
			var _loc4_:int = 0;
			grid = new Vector.<Vector.<Point>>();
			_loc5_ = 8;
			while (_loc5_ < param1 - 6)
			{
				_loc3_ = new Vector.<Point>();
				_loc4_ = 1;
				while (_loc4_ < param2 + 1)
				{
					_loc3_.push(new Point(_loc4_ / param1 * 130, _loc5_ / param2 * 130));
					_loc4_++;
				}
				grid.push(_loc3_);
				_loc5_++;
			}
			_loc4_ = 1;
			while (_loc4_ < param1 + 1)
			{
				_loc3_ = new Vector.<Point>();
				_loc5_ = 8;
				while (_loc5_ < param2 - 6)
				{
					_loc3_.push(new Point(_loc4_ / param1 * 130, _loc5_ / param2 * 130));
					_loc5_++;
				}
				grid.push(_loc3_);
				_loc4_++;
			}
		}

		private function drawGrid(param1:Number, param2:Number):void
		{
			var _loc5_:int = 0;
			var _loc4_:flash.display.Sprite = new flash.display.Sprite();
			_loc4_.graphics.lineStyle(2, 2293538, 0.2);
			for each (var _loc3_:* in grid)
			{
				_loc4_.graphics.moveTo(_loc3_[0].x * param1, _loc3_[0].y * param2);
				_loc5_ = 1;
				while (_loc5_ < _loc3_.length)
				{
					_loc4_.graphics.lineTo(_loc3_[_loc5_].x * param1, _loc3_[_loc5_].y * param2);
					_loc5_++;
				}
			}
			_loc4_.graphics.endFill();
			addChild(TextureManager.imageFromSprite(_loc4_, "planetGrid"));
		}

		private function transformMap():void
		{
			var _loc5_:Number = NaN;
			var _loc6_:Number = NaN;
			var _loc7_:Number = NaN;
			var _loc3_:Number = 65;
			var _loc1_:Number = 65;
			for each (var _loc2_:* in grid)
			{
				for each (var _loc4_:* in _loc2_)
				{
					_loc5_ = _loc4_.x - _loc3_;
					_loc6_ = _loc4_.y - _loc1_;
					_loc7_ = Math.sin(0.5 * 3.141592653589793 * _loc5_ / _loc3_ + 0.5 * 3.141592653589793) * Math.sin(0.5 * 3.141592653589793 * _loc6_ / _loc3_ - 0.5 * 3.141592653589793) * _loc3_;
					_loc4_.x = Math.cos(0.5 * 3.141592653589793 * _loc5_ / _loc3_ + 0.5 * 3.141592653589793) * Math.sin(0.5 * 3.141592653589793 * _loc6_ / _loc3_ - 0.5 * 3.141592653589793) * _loc3_ + _loc3_ + _loc7_ * 0.1;
					_loc4_.y = Math.cos(0.5 * 3.141592653589793 * _loc6_ / _loc3_ - 0.5 * 3.141592653589793) * _loc3_ + _loc3_ + _loc7_ * 0.1;
				}
			}
			for each (_loc2_ in shell)
			{
				for each (_loc4_ in _loc2_)
				{
					_loc4_.y += 42.5;
					_loc5_ = _loc4_.x - _loc3_;
					_loc6_ = _loc4_.y - _loc1_;
					_loc7_ = Math.sin(0.5 * 3.141592653589793 * _loc5_ / _loc3_ + 0.5 * 3.141592653589793) * Math.sin(0.5 * 3.141592653589793 * _loc6_ / _loc3_ - 0.5 * 3.141592653589793) * _loc3_;
					_loc4_.x = Math.cos(0.5 * 3.141592653589793 * _loc5_ / _loc3_ + 0.5 * 3.141592653589793) * Math.sin(0.5 * 3.141592653589793 * _loc6_ / _loc3_ - 0.5 * 3.141592653589793) * _loc3_ + _loc3_ + _loc7_ * 0.1;
					_loc4_.y = Math.cos(0.5 * 3.141592653589793 * _loc6_ / _loc3_ - 0.5 * 3.141592653589793) * _loc3_ + _loc3_ + _loc7_ * 0.1;
				}
			}
		}

		private function transformMap3():void
		{
			var _loc7_:Number = NaN;
			var _loc8_:Number = NaN;
			var _loc6_:Number = NaN;
			var _loc4_:Number = NaN;
			var _loc3_:Number = 65;
			var _loc1_:Number = 65;
			for each (var _loc2_:* in grid)
			{
				for each (var _loc5_:* in _loc2_)
				{
					_loc7_ = _loc5_.x - _loc3_;
					_loc8_ = _loc5_.y - _loc1_;
					_loc4_ = Math.sqrt(_loc7_ * _loc7_ + _loc8_ * _loc8_) / _loc3_;
					_loc6_ = Math.atan2(_loc8_, _loc7_);
					if (_loc4_ <= 1)
					{
						_loc4_ = Math.sqrt(_loc4_);
					}
					_loc5_.x = Math.cos(_loc6_) * _loc4_ * _loc3_ + _loc3_;
					_loc5_.y = Math.sin(_loc6_) * _loc4_ * _loc3_ + _loc1_;
				}
			}
			for each (_loc2_ in shell)
			{
				for each (_loc5_ in _loc2_)
				{
					_loc5_.y += 42.5;
					_loc7_ = _loc5_.x - _loc3_;
					_loc8_ = _loc5_.y - _loc1_;
					_loc4_ = Math.sqrt(_loc7_ * _loc7_ + _loc8_ * _loc8_) / _loc3_;
					_loc6_ = Math.atan2(_loc8_, _loc7_);
					if (_loc4_ < 1)
					{
						_loc4_ = Math.sqrt(_loc4_);
					}
					_loc5_.x = Math.cos(_loc6_) * _loc4_ * _loc3_ + _loc3_;
					_loc5_.y = Math.sin(_loc6_) * _loc4_ * _loc3_ + _loc1_;
				}
			}
		}

		private function transformMap2():void
		{
			var _loc2_:Number = NaN;
			var _loc8_:Number = NaN;
			var _loc3_:Number = 130;
			var _loc6_:Number = 65;
			var _loc5_:Number = 130;
			var _loc4_:Number = 65;
			var _loc9_:Number = 0.5;
			for each (var _loc1_:* in shell)
			{
				for each (var _loc7_:* in _loc1_)
				{
					_loc7_.y += 42.5;
					_loc2_ = _loc7_.x;
					_loc8_ = _loc7_.y;
					_loc7_.x = (Math.sin(3.141592653589793 * (_loc2_ - _loc6_) / _loc6_) * _loc6_ + _loc6_) * (Math.sin(3.141592653589793 * _loc8_ / _loc5_) * _loc9_ + (1 - _loc9_)) + (1 - Math.sin(3.141592653589793 * _loc8_ / _loc5_)) * 0.5 * _loc9_ * _loc3_;
					_loc2_ = _loc7_.x;
					_loc8_ = _loc7_.y;
					_loc7_.y = (Math.sin(3.141592653589793 * (_loc8_ - _loc4_) / _loc4_) * _loc4_ + _loc4_) * (Math.sin(3.141592653589793 * _loc2_ / _loc3_) * (1 - _loc9_) + _loc9_) + (1 - Math.sin(3.141592653589793 * _loc2_ / _loc3_)) * 0.5 * (1 - _loc9_) * _loc5_;
				}
			}
			for each (_loc1_ in grid)
			{
				for each (_loc7_ in _loc1_)
				{
					_loc2_ = Number(_loc7_.x);
					_loc8_ = _loc7_.y;
					_loc7_.x = (Math.sin(3.141592653589793 * (_loc2_ - _loc6_) / _loc6_) * _loc6_ + _loc6_) * (Math.sin(3.141592653589793 * _loc8_ / _loc5_) * _loc9_ + (1 - _loc9_)) + (1 - Math.sin(3.141592653589793 * _loc8_ / _loc5_)) * 0.5 * _loc9_ * _loc3_;
					_loc2_ = _loc7_.x;
					_loc8_ = _loc7_.y;
					_loc7_.y = (Math.sin(3.141592653589793 * (_loc8_ - _loc4_) / _loc4_) * _loc4_ + _loc4_) * (Math.sin(3.141592653589793 * _loc2_ / _loc3_) * (1 - _loc9_) + _loc9_) + (1 - Math.sin(3.141592653589793 * _loc2_ / _loc3_)) * 0.5 * (1 - _loc9_) * _loc5_;
				}
			}
		}

		private function selectEasiest():void
		{
			var _loc4_:int = 10000;
			var _loc2_:* = null;
			var _loc3_:* = null;
			var _loc5_:* = null;
			for each (var _loc1_:* in map_areas)
			{
				_loc1_.clearSelect();
				if (!(_loc1_.explore != null && _loc1_.explore.finished && _loc1_.explore.lootClaimed))
				{
					if (_loc4_ > _loc1_.area.skillLevel)
					{
						if (ExploreMap.forceSelectAreaKey != null)
						{
							if (ExploreMap.forceSelectAreaKey == _loc1_.key)
							{
								_loc5_ = _loc1_;
							}
						}
						else if (_loc1_.shouldBlink())
						{
							_loc5_ = _loc1_;
						}
						else if (_loc1_.fraction < 100)
						{
							_loc4_ = int(_loc1_.area.skillLevel);
							_loc3_ = _loc1_;
						}
						else
						{
							_loc2_ = _loc1_;
						}
					}
				}
			}
			if (_loc5_ != null)
			{
				_loc5_.select();
				selectedArea = _loc5_.area;
			}
			else if (_loc3_ != null && _loc5_ == null)
			{
				_loc3_.select();
				selectedArea = _loc3_.area;
			}
			else if (_loc2_ != null && _loc3_ != null && _loc5_ != null)
			{
				_loc2_.select();
				selectedArea = _loc2_.area;
			}
		}

		public function moveOnTop(param1:ExploreMapArea):void
		{
			addChild(param1);
		}

		public function clearSelected(param1:ExploreMapArea):void
		{
			for each (var _loc2_:* in map_areas)
			{
				if (_loc2_ != param1)
				{
					_loc2_.clearSelect();
				}
			}
		}

		private function generateMap():void
		{
			done = false;
			while (!done)
			{
				r = new Random(seed);
				done = tryGenerateMap();
				if (!done)
				{
					Console.write("Error: invalid seed!");
					seed += 0.12341;
					if (seed > 1)
					{
						seed /= 2;
					}
				}
			}
		}

		private function tryGenerateMap():Boolean
		{
			var _loc7_:int = 0;
			var _loc5_:Object = null;
			areas = [];
			_loc7_ = 0;
			while (_loc7_ < raw_areas.length)
			{
				areas.push(raw_areas[_loc7_]);
				_loc7_++;
			}
			_loc7_ = 0;
			while (_loc7_ < extraAreas)
			{
				_loc5_ = {};
				_loc5_.size = r.random(4) + 7;
				_loc5_.majorType = -1;
				_loc5_.key = area_key_index++;
				areas.splice(r.random(areas.length), 0, _loc5_);
				_loc7_++;
			}
			var _loc4_:Number = 0;
			var _loc2_:int = int(areas.length);
			for each (var _loc3_:* in areas)
			{
				if (_loc3_.size < 7)
				{
					_loc4_ += 0.5 * _loc3_.size;
				}
				else
				{
					_loc4_ += _loc3_.size;
				}
			}
			var _loc6_:int = r.random(_loc2_ - 1) + 1;
			var _loc1_:int = 0;
			fraction_cover = 0.1;
			fraction_cover += 0.01 * r.random(6) * _loc2_;
			if (fraction_cover > 0.4)
			{
				fraction_cover = 0.4;
			}
			fraction_cover += 0.005 * r.random(50);
			m = createMatrix(130, 45);
			_loc7_ = 1;
			while (_loc7_ <= _loc6_)
			{
				x_chance = 10 + r.random(50);
				y_chance = 10 + r.random(50);
				if (_loc3_.size < 7)
				{
					_loc1_ = Math.ceil(fraction_cover * (0.5 * areas[_loc7_ - 1].size) * 130 * 45 / _loc4_);
				}
				else
				{
					_loc1_ = Math.ceil(fraction_cover * areas[_loc7_ - 1].size * 130 * 45 / _loc4_);
				}
				if (!startNewGroup(_loc7_))
				{
					return false;
				}
				if (!addSquaresToGroup(_loc7_, _loc1_))
				{
					return false;
				}
				_loc7_++;
			}
			_loc7_ = _loc6_ + 1;
			while (_loc7_ <= _loc2_)
			{
				x_chance = 10 + r.random(50);
				y_chance = 10 + r.random(50);
				if (_loc3_.size < 7)
				{
					_loc1_ = Math.ceil(fraction_cover * (0.5 * areas[_loc7_ - 1].size) * 130 * 45 / _loc4_);
				}
				else
				{
					_loc1_ = Math.ceil(fraction_cover * areas[_loc7_ - 1].size * 130 * 45 / _loc4_);
				}
				if (!joinOldGroup(_loc7_))
				{
					return false;
				}
				if (!addSquaresToGroup(_loc7_, _loc1_))
				{
					return false;
				}
				_loc7_++;
			}
			removeInterior();
			shell = createShells(_loc2_);
			if (shell == null)
			{
				return false;
			}
			Console.write("explore area map done");
			return true;
		}

		private function startNewGroup(param1:int):Boolean
		{
			var _loc2_:Vector.<int> = getRandomPosList();
			for each (var _loc3_:* in _loc2_)
			{
				if (canAddNew(_loc3_, param1))
				{
					lastPos = _loc3_;
					return true;
				}
			}
			return false;
		}

		private function joinOldGroup(param1:int):Boolean
		{
			var _loc2_:Vector.<int> = getRandomPosList();
			for each (var _loc3_:* in _loc2_)
			{
				if (canJoinOld(_loc3_, param1))
				{
					lastPos = _loc3_;
					return true;
				}
			}
			return false;
		}

		private function addSquaresToGroup(param1:int, param2:int):Boolean
		{
			var _loc9_:int = 0;
			var _loc8_:int = 0;
			var _loc5_:int = 0;
			var _loc4_:* = 0;
			var _loc3_:Boolean = false;
			var _loc6_:int = 0;
			var _loc7_:int = 0;
			while (_loc5_ < param2)
			{
				_loc3_ = false;
				_loc9_ = 0;
				while (_loc9_ < 130)
				{
					_loc8_ = 0;
					while (_loc8_ < 45)
					{
						_loc4_ = _loc5_;
						_loc5_ += tryAddNeighbours(_loc9_, _loc8_, param1, param2 - _loc5_, _loc7_);
						if (_loc5_ != _loc4_)
						{
							_loc3_ = true;
							_loc7_ = 0;
						}
						_loc8_++;
					}
					_loc9_++;
				}
				if (_loc3_ == false)
				{
					_loc6_++;
					_loc7_ += 20;
				}
				if (_loc6_ > 5)
				{
					Console.write("error: no space left for area " + param1 + ", added " + _loc5_ + " of " + param2);
					return false;
				}
			}
			return true;
		}

		private function getRandomPosList():Vector.<int>
		{
			var _loc2_:int = 0;
			var _loc1_:Vector.<int> = new Vector.<int>();
			_loc2_ = 0;
			while (_loc2_ < 130 * 45)
			{
				_loc1_.splice(r.random(_loc1_.length), 0, _loc2_);
				_loc2_++;
			}
			return _loc1_;
		}

		private function enoughNrNeighbours(param1:int, param2:int, param3:int):Boolean
		{
			var _loc8_:int = 0;
			var _loc4_:int = 0;
			var _loc7_:int = 0;
			var _loc9_:int = lastPos % 130;
			var _loc6_:int = (lastPos - _loc9_) / 130;
			var _loc5_:int = 0;
			if (param1 == _loc9_ && param2 == _loc6_)
			{
				return true;
			}
			_loc7_ = 0;
			while (_loc7_ < 8)
			{
				_loc8_ = param1 + directions[_loc7_][0];
				_loc4_ = param2 + directions[_loc7_][1];
				if (_loc8_ >= 0 && _loc8_ < 130 && m[_loc8_][_loc4_] == param3)
				{
					_loc5_++;
				}
				else if (_loc8_ == -1 && m[130 - 1][_loc4_] == param3)
				{
					_loc5_++;
				}
				else if (_loc8_ == 130 && m[0][_loc4_] == param3)
				{
					_loc5_++;
				}
				_loc7_++;
			}
			if (_loc5_ >= 2)
			{
				return true;
			}
			return false;
		}

		private function tryAddNeighbours(param1:int, param2:int, param3:int, param4:int, param5:int):int
		{
			if (m[param1][param2] != param3)
			{
				return 0;
			}
			var _loc6_:int = 0;
			if (param2 > 0 && param2 < 45 - 1 && enoughNrNeighbours(param1, param2, param3))
			{
				if (param4 > 0 && param1 + 1 < 130 && m[param1 + 1][param2] == 0 && r.random(100) < x_chance + param5)
				{
					m[param1 + 1][param2] = param3;
					param4--;
					_loc6_++;
				}
				if (param4 > 0 && param1 - 1 >= 0 && m[param1 - 1][param2] == 0 && r.random(100) < x_chance + param5)
				{
					m[param1 - 1][param2] = param3;
					param4--;
					_loc6_++;
				}
				if (param4 > 0 && param2 + 1 < 45 && m[param1][param2 + 1] == 0 && r.random(100) < y_chance + param5)
				{
					m[param1][param2 + 1] = param3;
					param4--;
					_loc6_++;
				}
				if (param4 > 0 && param2 - 1 >= 0 && m[param1][param2 - 1] == 0 && r.random(100) < y_chance + param5)
				{
					m[param1][param2 - 1] = param3;
					param4--;
					_loc6_++;
				}
			}
			return _loc6_;
		}

		private function canJoinOld(param1:int, param2:int):Boolean
		{
			var _loc4_:int = 0;
			var _loc3_:int = 0;
			_loc4_ = param1 % 130;
			_loc3_ = (param1 - _loc4_) / 130;
			if (_loc3_ < 0.2 * 45 || _loc3_ > 0.8 * 45)
			{
				return false;
			}
			if (_loc4_ < 0.2 * 130 || _loc4_ > 0.8 * 130)
			{
				return false;
			}
			if (_loc3_ < 0.2 * 45 || _loc3_ > 0.8 * 45)
			{
				return false;
			}
			if (m[_loc4_][_loc3_] == 0 && (_loc4_ - 1 >= 0 && m[_loc4_ - 1][_loc3_] != 0 || _loc4_ + 1 < 130 && m[_loc4_ + 1][_loc3_] != 0 || _loc3_ - 1 >= 0 && m[_loc4_][_loc3_ - 1] != 0 || _loc3_ + 1 < 45 && m[_loc4_][_loc3_ + 1] != 0))
			{
				m[_loc4_][_loc3_] = param2;
				return true;
			}
			return false;
		}

		private function getMinDist(param1:int, param2:int):int
		{
			var _loc6_:int = 0;
			var _loc4_:int = 0;
			var _loc5_:* = 130;
			var _loc3_:int = 0;
			_loc6_ = 0;
			while (_loc6_ < 130)
			{
				_loc4_ = 0;
				while (_loc4_ < 45)
				{
					if (m[_loc6_][_loc4_] > 0)
					{
						_loc3_ = dist2(param1, param2, _loc6_, _loc4_);
						if (_loc3_ < _loc5_)
						{
							_loc5_ = _loc3_;
						}
					}
					_loc4_++;
				}
				_loc6_++;
			}
			return _loc5_;
		}

		private function canAddNew(param1:int, param2:int):Boolean
		{
			var _loc4_:int = 0;
			var _loc3_:int = 0;
			_loc4_ = param1 % 130;
			_loc3_ = (param1 - _loc4_) / 130;
			if (_loc3_ < 0.2 * 45 || _loc3_ > 0.8 * 45)
			{
				return false;
			}
			if (_loc4_ < 0.25 * 130 || _loc4_ > 0.75 * 130)
			{
				return false;
			}
			if (m[_loc4_][_loc3_] == 0 && (_loc4_ - 1 >= 0 && m[_loc4_ - 1][_loc3_] == 0) && (_loc4_ + 1 < 130 && m[_loc4_ + 1][_loc3_] == 0) && (_loc3_ - 1 >= 0 && m[_loc4_][_loc3_ - 1] == 0) && (_loc3_ + 1 < 45 && m[_loc4_][_loc3_ + 1] == 0))
			{
				m[_loc4_][_loc3_] = param2;
				return true;
			}
			return false;
		}

		private function removeInterior():void
		{
			var _loc3_:int = 0;
			var _loc2_:int = 0;
			var _loc1_:int = 0;
			_loc2_ = 0;
			while (_loc2_ < 130)
			{
				_loc1_ = 0;
				while (_loc1_ < 45)
				{
					if (_loc1_ + 1 < 45)
					{
						_loc3_ = m[_loc2_][_loc1_ + 1];
						if (m[_loc2_][_loc1_] == 0 && _loc3_ != 0 && (_loc2_ - 1 >= 0 && m[_loc2_ - 1][_loc1_] != 0 || _loc2_ - 1 == -1 && m[130 - 1][_loc1_] != 0) && (_loc2_ + 1 < 130 && m[_loc2_ + 1][_loc1_] != 0 || _loc2_ + 1 == 130 && m[0][_loc1_] != 0) && (_loc1_ - 1 >= 0 && m[_loc2_][_loc1_ - 1] != 0) && (_loc1_ + 1 < 45 && m[_loc2_][_loc1_ + 1] != 0))
						{
							m[_loc2_][_loc1_] = _loc3_;
						}
					}
					_loc1_++;
				}
				_loc2_++;
			}
			_loc2_ = 0;
			while (_loc2_ < 130)
			{
				if (_loc2_ + 1 < 130)
				{
					_loc3_ = m[_loc2_ + 1][0];
					if (m[_loc2_][0] == 0 && _loc3_ != 0 && (_loc2_ - 1 >= 0 && m[_loc2_ - 1][0] != 0 || _loc2_ - 1 == -1 && m[130 - 1][0] != 0) && (_loc2_ + 1 < 130 && m[_loc2_ + 1][0] != 0 || _loc2_ + 1 == 130 && m[0][0] != 0) && m[_loc2_][1] != 0)
					{
						m[_loc2_][0] = _loc3_;
					}
					_loc3_ = m[_loc2_ + 1][45 - 1];
					if (m[_loc2_][45 - 1] == 0 && _loc3_ != 0 && (_loc2_ - 1 >= 0 && m[_loc2_ - 1][45 - 1] != 0 || _loc2_ - 1 == -1 && m[130 - 1][45 - 1] != 0) && (_loc2_ + 1 < 130 && m[_loc2_ + 1][45 - 1] != 0 || _loc2_ + 1 == 130 && m[0][45 - 1] != 0) && m[_loc2_][45 - 2] != 0)
					{
						m[_loc2_][45 - 1] = _loc3_;
					}
				}
				_loc2_++;
			}
			_loc2_ = 0;
			while (_loc2_ < 130)
			{
				_loc1_ = 0;
				while (_loc1_ < 45)
				{
					_loc3_ = m[_loc2_][_loc1_];
					if (_loc3_ > 0 && (_loc2_ - 1 >= 0 && (m[_loc2_ - 1][_loc1_] == _loc3_ || m[_loc2_ - 1][_loc1_] == -_loc3_) || _loc2_ - 1 == -1 && (m[130 - 1][_loc1_] == _loc3_ || m[130 - 1][_loc1_] == -_loc3_)) && (_loc2_ + 1 < 130 && (m[_loc2_ + 1][_loc1_] == _loc3_ || m[_loc2_ + 1][_loc1_] == -_loc3_) || _loc2_ + 1 == 130 && (m[0][_loc1_] == _loc3_ || m[0][_loc1_] == -_loc3_)) && (_loc1_ - 1 >= 0 && (m[_loc2_][_loc1_ - 1] == _loc3_ || m[_loc2_][_loc1_ - 1] == -_loc3_)) && (_loc1_ + 1 < 45 && (m[_loc2_][_loc1_ + 1] == _loc3_ || m[_loc2_][_loc1_ + 1] == -_loc3_)))
					{
						m[_loc2_][_loc1_] = -_loc3_;
					}
					_loc1_++;
				}
				_loc2_++;
			}
		}

		private function createShells(param1:int):Vector.<Vector.<Point>>
		{
			var _loc3_:int = 0;
			var _loc2_:Vector.<Vector.<Point>> = new Vector.<Vector.<Point>>();
			_loc3_ = 1;
			while (_loc3_ <= param1)
			{
				_loc2_.push(createShell(_loc3_));
				if (_loc2_[_loc2_.length - 1] == null)
				{
					return null;
				}
				_loc3_++;
			}
			return _loc2_;
		}

		private function getStartPoint(param1:Vector.<Point>, param2:int, param3:int = 0, param4:int = 0):void
		{
			if (param3 != 0)
			{
				param3 += 1;
			}
			if (param4 != 0)
			{
				param4 += 1;
			}
			param3 = 0;
			while (param3 < 130)
			{
				param4 = 0;
				while (param4 < 45)
				{
					if (m[param3][param4] == param2)
					{
						if (param1 == null)
						{
							return;
						}
						param1.push(new Point(param3, param4));
						return;
					}
					param4++;
				}
				param3++;
			}
		}

		private function createShell(param1:int, param2:Vector.<Point> = null):Vector.<Point>
		{
			var _loc5_:Point = null;
			var _loc9_:int = 0;
			var _loc8_:int = 0;
			var _loc6_:int = 0;
			var _loc7_:int = 0;
			var _loc3_:Vector.<Point> = new Vector.<Point>();
			var _loc4_:int = 0;
			if (param2 != null)
			{
				_loc9_ = 0;
				_loc8_ = 0;
				for each (_loc5_ in param2)
				{
					if (_loc5_.x > _loc9_)
					{
						_loc9_ = _loc5_.x;
					}
					if (_loc5_.y > _loc8_)
					{
						_loc8_ = _loc5_.y;
					}
				}
				getStartPoint(_loc3_, param1, _loc9_, _loc8_);
				if (_loc3_.length == 0)
				{
					return null;
				}
			}
			else
			{
				getStartPoint(_loc3_, param1);
			}
			while (!isDone(_loc3_))
			{
				_loc5_ = _loc3_[_loc3_.length - 1];
				_loc4_ = getDirection(_loc3_);
				_loc3_.push(getNextPoint(_loc5_.x, _loc5_.y, param1, _loc4_));
				_loc6_ = m[_loc5_.x][_loc5_.y];
			}
			if (_loc3_.length < 10)
			{
				return null;
			}
			_loc7_ = 0;
			while (_loc7_ < 3)
			{
				removeNarrows(_loc3_);
				_loc7_++;
			}
			postProccessEdge(_loc3_);
			return _loc3_;
		}

		private function getNextPoint(param1:int, param2:int, param3:int, param4:int):Point
		{
			var _loc8_:int = 0;
			var _loc6_:int = 0;
			var _loc7_:int = 0;
			var _loc5_:int = param4 - 1;
			_loc7_ = 0;
			while (_loc7_ < 8)
			{
				if (_loc5_ < 0)
				{
					_loc5_ = 7;
				}
				_loc8_ = param1 + directions[_loc5_][0];
				_loc6_ = param2 + directions[_loc5_][1];
				if (_loc8_ < 0)
				{
					_loc8_ = 130 - 1;
				}
				if (_loc8_ >= 130)
				{
					_loc8_ = 0;
				}
				if (_loc6_ >= 0 && _loc6_ < 45 && m[_loc8_][_loc6_] == param3)
				{
					return new Point(_loc8_, _loc6_);
				}
				_loc5_--;
				_loc7_++;
			}
			return null;
		}

		private function getDirection(param1:Vector.<Point>):int
		{
			var _loc4_:int = 0;
			var _loc3_:int = 0;
			var _loc6_:int = 0;
			var _loc2_:int = 0;
			var _loc5_:int = 0;
			if (param1.length < 2)
			{
				_loc6_ = param1[param1.length - 1].x;
				_loc2_ = param1[param1.length - 1].y;
				_loc5_ = 0;
				while (_loc5_ < 8)
				{
					if (_loc6_ + directions[_loc5_][0] >= 0 && _loc6_ + directions[_loc5_][0] < 130 && _loc2_ + directions[_loc5_][1] >= 0 && _loc2_ + directions[_loc5_][1] < 45 && m[_loc6_ + directions[_loc5_][0]][_loc2_ + directions[_loc5_][1]] < 0)
					{
						return _loc5_;
					}
					_loc5_++;
				}
				_loc5_ = 0;
				while (_loc5_ < 8)
				{
					if (_loc6_ + directions[_loc5_][0] >= 0 && _loc6_ + directions[_loc5_][0] < 130 && _loc2_ + directions[_loc5_][1] >= 0 && _loc2_ + directions[_loc5_][1] < 45 && m[_loc6_ + directions[_loc5_][0]][_loc2_ + directions[_loc5_][1]] == 0)
					{
						_loc5_ -= 4;
						if (_loc5_ < 0)
						{
							_loc5_ = 8 + _loc5_;
						}
						return _loc5_;
					}
					_loc5_++;
				}
			}
			else
			{
				_loc4_ = param1[param1.length - 1].x;
				_loc3_ = param1[param1.length - 1].y;
				_loc6_ = param1[param1.length - 2].x;
				_loc2_ = param1[param1.length - 2].y;
				if (_loc4_ == 0 && _loc6_ == 130 - 1)
				{
					_loc6_ = -1;
				}
				if (_loc4_ == 130 - 1 && _loc6_ == 0)
				{
					_loc6_ = 130;
				}
				if (_loc6_ == 0 && _loc4_ == 130 - 1)
				{
					_loc4_ = -1;
				}
				if (_loc6_ == 130 - 1 && _loc4_ == 0)
				{
					_loc4_ = 130;
				}
				_loc5_ = 0;
				while (_loc5_ < 8)
				{
					if (_loc6_ == _loc4_ + directions[_loc5_][0] && _loc2_ == _loc3_ + directions[_loc5_][1])
					{
						return _loc5_;
					}
					_loc5_++;
				}
			}
			return 0;
		}

		private function isDone(param1:Vector.<Point>):Boolean
		{
			if (param1.length <= 2)
			{
				return false;
			}
			if (param1[0].x == param1[param1.length - 1].x && param1[0].y == param1[param1.length - 1].y)
			{
				return true;
			}
			return false;
		}

		private function removeNarrows(param1:Vector.<Point>):void
		{
			var _loc3_:int = 0;
			var _loc2_:int = 0;
			var _loc4_:int = 0;
			_loc4_ = param1.length - 1;
			while (_loc4_ > -1)
			{
				_loc3_ = _loc4_ - 1;
				_loc2_ = _loc4_ + 1;
				if (_loc3_ < 0)
				{
					_loc3_ = param1.length + _loc3_;
				}
				if (_loc2_ >= param1.length)
				{
					_loc2_ -= param1.length;
				}
				if (param1[_loc3_].x == param1[_loc2_].x && param1[_loc3_].y == param1[_loc2_].y)
				{
					param1.splice(_loc4_, 1);
				}
				_loc4_--;
			}
		}

		private function postProccessEdge(param1:Vector.<Point>):void
		{
			var _loc2_:int = 0;
			var _loc4_:Boolean = false;
			var _loc6_:int = 0;
			var _loc3_:Vector.<int> = Vector.<int>([1, 3, 5, 7, 0, 2, 4, 6]);
			_loc6_ = 1;
			while (_loc6_ < param1.length - 1)
			{
				if (param1[_loc6_].x != 0 && param1[_loc6_].x != 130 - 1)
				{
					_loc4_ = false;
					for each (var _loc5_:* in _loc3_)
					{
						if (param1[_loc6_].y == 45 - 1 || param1[_loc6_].y == 0)
						{
							param1[_loc6_].x += 0.01 * (-40 + r.random(80));
							param1[_loc6_].y += 0.01 * (-40 + r.random(80));
							_loc4_ = true;
						}
						else if (!_loc4_ && m[param1[_loc6_].x + directions[_loc5_][0]][param1[_loc6_].y + directions[_loc5_][1]] == 0)
						{
							param1[_loc6_].x += 0.01 * directions[_loc5_][0] * (10 + r.random(30)) + 0.01 * (-10 + r.random(20));
							param1[_loc6_].y += 0.01 * directions[_loc5_][1] * (10 + r.random(30)) + 0.01 * (-10 + r.random(20));
							_loc4_ = true;
						}
						else if (!_loc4_ && m[param1[_loc6_].x + directions[_loc5_][0]][param1[_loc6_].y + directions[_loc5_][1]] != m[param1[_loc6_].x][param1[_loc6_].y] && m[param1[_loc6_].x + directions[_loc5_][0]][param1[_loc6_].y + directions[_loc5_][1]] > 0)
						{
							param1[_loc6_].x += 0.01 * directions[_loc5_][0] * (30 + r.random(0));
							param1[_loc6_].y += 0.01 * directions[_loc5_][1] * (30 + r.random(0));
							_loc4_ = true;
						}
					}
				}
				_loc6_++;
			}
		}

		private function dist2(param1:int, param2:int, param3:int, param4:int):int
		{
			return Math.max(Math.abs(param1 - param3), Math.abs(param2 - param4));
		}

		private function dist(param1:Point, param2:Point):Number
		{
			return (param1.x - param2.x) * (param1.x - param2.x) + (param1.y - param2.y) * (param1.y - param2.y);
		}

		private function findClosesPoint(param1:Point, param2:Vector.<Point>):Point
		{
			var _loc3_:Number = NaN;
			var _loc7_:* = 16900;
			var _loc6_:* = null;
			for each (var _loc5_:* in shell)
			{
				if (_loc5_ != param2)
				{
					for each (var _loc4_:* in _loc5_)
					{
						if (_loc4_.x != 0 && _loc4_.y != 0 && _loc4_.x != 130 - 1 && _loc4_.y != 45 - 1)
						{
							_loc3_ = dist(param1, _loc4_);
							if (_loc3_ < _loc7_)
							{
								_loc7_ = _loc3_;
								_loc6_ = _loc4_;
							}
						}
					}
				}
			}
			return _loc6_;
		}

		private function postProccessShells(param1:Number):void
		{
			var _loc3_:* = null;
			for each (var _loc2_:* in shell)
			{
				for each (var _loc4_:* in _loc2_)
				{
					if (_loc4_.x != 0 && _loc4_.y != 0 && _loc4_.x != 130 - 1 && _loc4_.y != 45 - 1)
					{
						_loc3_ = findClosesPoint(_loc4_, _loc2_);
						if (dist(_loc4_, _loc3_) < param1)
						{
							_loc4_.x = (_loc4_.x + _loc3_.x) / 2;
							_loc4_.y = (_loc4_.y + _loc3_.y) / 2;
							_loc3_ = _loc4_;
						}
					}
				}
			}
			for each (_loc2_ in shell)
			{
				removeNarrows(_loc2_);
			}
		}

		private function createMatrix(param1:int, param2:int):Vector.<Vector.<int>>
		{
			var _loc3_:* = undefined;
			var _loc6_:int = 0;
			var _loc5_:int = 0;
			var _loc4_:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();
			_loc6_ = 0;
			while (_loc6_ < param1)
			{
				_loc3_ = new Vector.<int>();
				_loc5_ = 0;
				while (_loc5_ < param2)
				{
					_loc3_.push(0);
					_loc5_++;
				}
				_loc4_.push(_loc3_);
				_loc6_++;
			}
			return _loc4_;
		}
	}
}
