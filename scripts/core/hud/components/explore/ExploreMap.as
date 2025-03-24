package core.hud.components.explore {
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
	
	public class ExploreMap extends starling.display.Sprite {
		public static var selectedArea:Object = null;
		
		public static var forceSelectAreaKey:String = null;
		
		private static const X_SIZE:int = 130;
		
		private static const Y_SIZE:int = 45;
		
		private static const FINAL_X_SIZE:int = 660;
		
		private static const FINAL_Y_SIZE:int = 660;
		
		private static const STEPS_OF_POSTPROCCESSING:int = 0;
		
		private static const directions:Vector.<Vector.<int>> = Vector.<Vector.<int>>([Vector.<int>([0,1]),Vector.<int>([1,1]),Vector.<int>([1,0]),Vector.<int>([1,-1]),Vector.<int>([0,-1]),Vector.<int>([-1,-1]),Vector.<int>([-1,0]),Vector.<int>([-1,1])]);
		
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
		
		public function ExploreMap(g:Game, bodyAreas:Array, explored:Array, b:Body) {
			super();
			this.raw_areas = bodyAreas;
			this.extraAreas = b.extraAreas;
			this.explored = explored;
			this.seed = b.seed;
			this.g = g;
			if(!b.generatedAreas || !b.generatedShells) {
				generateMap();
				b.generatedAreas = areas;
				b.generatedShells = shell;
			} else {
				areas = b.generatedAreas;
				shell = b.generatedShells;
			}
			drawMap();
		}
		
		public function getMapArea(key:String) : ExploreMapArea {
			if(map_areas != null) {
				for each(var _local2 in map_areas) {
					if(_local2.key != null && _local2.key == key) {
						return _local2;
					}
				}
			}
			return null;
		}
		
		private function drawMap() : void {
			var _local8:* = null;
			var _local9:Number = 5.076923076923077;
			var _local10:Number = 5.076923076923077;
			var _local7:ITextureManager = TextureLocator.getService();
			addChild(new Image(_local7.getTextureGUIByTextureName("grid.png")));
			var _local6:int = 0;
			map_areas = new Vector.<ExploreMapArea>();
			for each(var _local5 in shell) {
				_local8 = null;
				for each(var _local4 in explored) {
					if(_local4.area == areas[_local6].key) {
						_local8 = _local4;
					}
				}
				map_areas.push(new ExploreMapArea(g,this,areas[_local6],_local5,_local9,_local10,130));
				_local6++;
			}
			_local6 = 10;
			while(_local6 > 0) {
				for each(var _local3 in map_areas) {
					if(_local3.size == _local6) {
						addChild(_local3);
					}
				}
				_local6--;
			}
			selectEasiest();
			var _local1:Quad = new Quad(11 * 60,80,0);
			_local1.y = 65;
			var _local2:Quad = new Quad(11 * 60,80,0);
			_local2.y = 490;
			addChild(_local2);
		}
		
		private function generateGrid(nrX:int, nrY:int) : void {
			var _local4:int = 0;
			var _local3:* = undefined;
			var _local5:int = 0;
			grid = new Vector.<Vector.<Point>>();
			_local4 = 8;
			while(_local4 < nrX - 6) {
				_local3 = new Vector.<Point>();
				_local5 = 1;
				while(_local5 < nrY + 1) {
					_local3.push(new Point(_local5 / nrX * 130,_local4 / nrY * 130));
					_local5++;
				}
				grid.push(_local3);
				_local4++;
			}
			_local5 = 1;
			while(_local5 < nrX + 1) {
				_local3 = new Vector.<Point>();
				_local4 = 8;
				while(_local4 < nrY - 6) {
					_local3.push(new Point(_local5 / nrX * 130,_local4 / nrY * 130));
					_local4++;
				}
				grid.push(_local3);
				_local5++;
			}
		}
		
		private function drawGrid(kx:Number, ky:Number) : void {
			var _local5:int = 0;
			var _local3:flash.display.Sprite = new flash.display.Sprite();
			_local3.graphics.lineStyle(2,0x22ff22,0.2);
			for each(var _local4 in grid) {
				_local3.graphics.moveTo(_local4[0].x * kx,_local4[0].y * ky);
				_local5 = 1;
				while(_local5 < _local4.length) {
					_local3.graphics.lineTo(_local4[_local5].x * kx,_local4[_local5].y * ky);
					_local5++;
				}
			}
			_local3.graphics.endFill();
			addChild(TextureManager.imageFromSprite(_local3,"planetGrid"));
		}
		
		private function transformMap() : void {
			var _local5:Number = NaN;
			var _local4:Number = NaN;
			var _local7:Number = NaN;
			var _local3:Number = 65;
			var _local2:Number = 65;
			for each(var _local6 in grid) {
				for each(var _local1 in _local6) {
					_local5 = _local1.x - _local3;
					_local4 = _local1.y - _local2;
					_local7 = Math.sin(0.5 * 3.141592653589793 * _local5 / _local3 + 0.5 * 3.141592653589793) * Math.sin(0.5 * 3.141592653589793 * _local4 / _local3 - 0.5 * 3.141592653589793) * _local3;
					_local1.x = Math.cos(0.5 * 3.141592653589793 * _local5 / _local3 + 0.5 * 3.141592653589793) * Math.sin(0.5 * 3.141592653589793 * _local4 / _local3 - 0.5 * 3.141592653589793) * _local3 + _local3 + _local7 * 0.1;
					_local1.y = Math.cos(0.5 * 3.141592653589793 * _local4 / _local3 - 0.5 * 3.141592653589793) * _local3 + _local3 + _local7 * 0.1;
				}
			}
			for each(_local6 in shell) {
				for each(_local1 in _local6) {
					_local1.y += 42.5;
					_local5 = _local1.x - _local3;
					_local4 = _local1.y - _local2;
					_local7 = Math.sin(0.5 * 3.141592653589793 * _local5 / _local3 + 0.5 * 3.141592653589793) * Math.sin(0.5 * 3.141592653589793 * _local4 / _local3 - 0.5 * 3.141592653589793) * _local3;
					_local1.x = Math.cos(0.5 * 3.141592653589793 * _local5 / _local3 + 0.5 * 3.141592653589793) * Math.sin(0.5 * 3.141592653589793 * _local4 / _local3 - 0.5 * 3.141592653589793) * _local3 + _local3 + _local7 * 0.1;
					_local1.y = Math.cos(0.5 * 3.141592653589793 * _local4 / _local3 - 0.5 * 3.141592653589793) * _local3 + _local3 + _local7 * 0.1;
				}
			}
		}
		
		private function transformMap3() : void {
			var _local7:Number = NaN;
			var _local5:Number = NaN;
			var _local2:Number = NaN;
			var _local6:Number = NaN;
			var _local4:Number = 65;
			var _local3:Number = 65;
			for each(var _local8 in grid) {
				for each(var _local1 in _local8) {
					_local7 = _local1.x - _local4;
					_local5 = _local1.y - _local3;
					_local6 = Math.sqrt(_local7 * _local7 + _local5 * _local5) / _local4;
					_local2 = Math.atan2(_local5,_local7);
					if(_local6 <= 1) {
						_local6 = Math.sqrt(_local6);
					}
					_local1.x = Math.cos(_local2) * _local6 * _local4 + _local4;
					_local1.y = Math.sin(_local2) * _local6 * _local4 + _local3;
				}
			}
			for each(_local8 in shell) {
				for each(_local1 in _local8) {
					_local1.y += 42.5;
					_local7 = _local1.x - _local4;
					_local5 = _local1.y - _local3;
					_local6 = Math.sqrt(_local7 * _local7 + _local5 * _local5) / _local4;
					_local2 = Math.atan2(_local5,_local7);
					if(_local6 < 1) {
						_local6 = Math.sqrt(_local6);
					}
					_local1.x = Math.cos(_local2) * _local6 * _local4 + _local4;
					_local1.y = Math.sin(_local2) * _local6 * _local4 + _local3;
				}
			}
		}
		
		private function transformMap2() : void {
			var _local6:Number = NaN;
			var _local4:Number = NaN;
			var _local8:Number = 130;
			var _local3:Number = 65;
			var _local5:Number = 130;
			var _local2:Number = 65;
			var _local9:Number = 0.5;
			for each(var _local7 in shell) {
				for each(var _local1 in _local7) {
					_local1.y += 42.5;
					_local6 = _local1.x;
					_local4 = _local1.y;
					_local1.x = (Math.sin(3.141592653589793 * (_local6 - _local3) / _local3) * _local3 + _local3) * (Math.sin(3.141592653589793 * _local4 / _local5) * _local9 + (1 - _local9)) + (1 - Math.sin(3.141592653589793 * _local4 / _local5)) * 0.5 * _local9 * _local8;
					_local6 = _local1.x;
					_local4 = _local1.y;
					_local1.y = (Math.sin(3.141592653589793 * (_local4 - _local2) / _local2) * _local2 + _local2) * (Math.sin(3.141592653589793 * _local6 / _local8) * (1 - _local9) + _local9) + (1 - Math.sin(3.141592653589793 * _local6 / _local8)) * 0.5 * (1 - _local9) * _local5;
				}
			}
			for each(_local7 in grid) {
				for each(_local1 in _local7) {
					_local6 = _local1.x;
					_local4 = _local1.y;
					_local1.x = (Math.sin(3.141592653589793 * (_local6 - _local3) / _local3) * _local3 + _local3) * (Math.sin(3.141592653589793 * _local4 / _local5) * _local9 + (1 - _local9)) + (1 - Math.sin(3.141592653589793 * _local4 / _local5)) * 0.5 * _local9 * _local8;
					_local6 = _local1.x;
					_local4 = _local1.y;
					_local1.y = (Math.sin(3.141592653589793 * (_local4 - _local2) / _local2) * _local2 + _local2) * (Math.sin(3.141592653589793 * _local6 / _local8) * (1 - _local9) + _local9) + (1 - Math.sin(3.141592653589793 * _local6 / _local8)) * 0.5 * (1 - _local9) * _local5;
				}
			}
		}
		
		private function selectEasiest() : void {
			var _local4:int = 10000;
			var _local5:* = null;
			var _local2:* = null;
			var _local3:* = null;
			for each(var _local1 in map_areas) {
				_local1.clearSelect();
				if(!(_local1.explore != null && _local1.explore.finished && _local1.explore.lootClaimed)) {
					if(_local4 > _local1.area.skillLevel) {
						if(ExploreMap.forceSelectAreaKey != null) {
							if(ExploreMap.forceSelectAreaKey == _local1.key) {
								_local3 = _local1;
							}
						} else if(_local1.shouldBlink()) {
							_local3 = _local1;
						} else if(_local1.fraction < 100) {
							_local4 = int(_local1.area.skillLevel);
							_local2 = _local1;
						} else {
							_local5 = _local1;
						}
					}
				}
			}
			if(_local3 != null) {
				_local3.select();
				selectedArea = _local3.area;
			} else if(_local2 != null && _local3 == null) {
				_local2.select();
				selectedArea = _local2.area;
			} else if(_local5 != null && _local2 != null && _local3 != null) {
				_local5.select();
				selectedArea = _local5.area;
			}
		}
		
		public function moveOnTop(area:ExploreMapArea) : void {
			addChild(area);
		}
		
		public function clearSelected(area:ExploreMapArea) : void {
			for each(var _local2 in map_areas) {
				if(_local2 != area) {
					_local2.clearSelect();
				}
			}
		}
		
		private function generateMap() : void {
			done = false;
			while(!done) {
				r = new Random(seed);
				done = tryGenerateMap();
				if(!done) {
					Console.write("Error: invalid seed!");
					seed += 0.12341;
					if(seed > 1) {
						seed /= 2;
					}
				}
			}
		}
		
		private function tryGenerateMap() : Boolean {
			var _local5:int = 0;
			var _local3:Object = null;
			areas = [];
			_local5 = 0;
			while(_local5 < raw_areas.length) {
				areas.push(raw_areas[_local5]);
				_local5++;
			}
			_local5 = 0;
			while(_local5 < extraAreas) {
				_local3 = {};
				_local3.size = r.random(4) + 7;
				_local3.majorType = -1;
				_local3.key = area_key_index++;
				areas.splice(r.random(areas.length),0,_local3);
				_local5++;
			}
			var _local6:Number = 0;
			var _local7:int = int(areas.length);
			for each(var _local1 in areas) {
				if(_local1.size < 7) {
					_local6 += 0.5 * _local1.size;
				} else {
					_local6 += _local1.size;
				}
			}
			var _local2:int = r.random(_local7 - 1) + 1;
			var _local4:int = 0;
			fraction_cover = 0.1;
			fraction_cover += 0.01 * r.random(6) * _local7;
			if(fraction_cover > 0.4) {
				fraction_cover = 0.4;
			}
			fraction_cover += 0.005 * r.random(50);
			m = createMatrix(130,45);
			_local5 = 1;
			while(_local5 <= _local2) {
				x_chance = 10 + r.random(50);
				y_chance = 10 + r.random(50);
				if(_local1.size < 7) {
					_local4 = Math.ceil(fraction_cover * (0.5 * areas[_local5 - 1].size) * 130 * 45 / _local6);
				} else {
					_local4 = Math.ceil(fraction_cover * areas[_local5 - 1].size * 130 * 45 / _local6);
				}
				if(!startNewGroup(_local5)) {
					return false;
				}
				if(!addSquaresToGroup(_local5,_local4)) {
					return false;
				}
				_local5++;
			}
			_local5 = _local2 + 1;
			while(_local5 <= _local7) {
				x_chance = 10 + r.random(50);
				y_chance = 10 + r.random(50);
				if(_local1.size < 7) {
					_local4 = Math.ceil(fraction_cover * (0.5 * areas[_local5 - 1].size) * 130 * 45 / _local6);
				} else {
					_local4 = Math.ceil(fraction_cover * areas[_local5 - 1].size * 130 * 45 / _local6);
				}
				if(!joinOldGroup(_local5)) {
					return false;
				}
				if(!addSquaresToGroup(_local5,_local4)) {
					return false;
				}
				_local5++;
			}
			removeInterior();
			shell = createShells(_local7);
			if(shell == null) {
				return false;
			}
			Console.write("explore area map done");
			return true;
		}
		
		private function startNewGroup(i:int) : Boolean {
			var _local3:Vector.<int> = getRandomPosList();
			for each(var _local2 in _local3) {
				if(canAddNew(_local2,i)) {
					lastPos = _local2;
					return true;
				}
			}
			return false;
		}
		
		private function joinOldGroup(i:int) : Boolean {
			var _local3:Vector.<int> = getRandomPosList();
			for each(var _local2 in _local3) {
				if(canJoinOld(_local2,i)) {
					lastPos = _local2;
					return true;
				}
			}
			return false;
		}
		
		private function addSquaresToGroup(i:int, nrSquares:int) : Boolean {
			var _local7:int = 0;
			var _local8:int = 0;
			var _local4:int = 0;
			var _local3:* = 0;
			var _local6:Boolean = false;
			var _local5:int = 0;
			var _local9:int = 0;
			while(_local4 < nrSquares) {
				_local6 = false;
				_local7 = 0;
				while(_local7 < 130) {
					_local8 = 0;
					while(_local8 < 45) {
						_local3 = _local4;
						_local4 += tryAddNeighbours(_local7,_local8,i,nrSquares - _local4,_local9);
						if(_local4 != _local3) {
							_local6 = true;
							_local9 = 0;
						}
						_local8++;
					}
					_local7++;
				}
				if(_local6 == false) {
					_local5++;
					_local9 += 20;
				}
				if(_local5 > 5) {
					Console.write("error: no space left for area " + i + ", added " + _local4 + " of " + nrSquares);
					return false;
				}
			}
			return true;
		}
		
		private function getRandomPosList() : Vector.<int> {
			var _local1:int = 0;
			var _local2:Vector.<int> = new Vector.<int>();
			_local1 = 0;
			while(_local1 < 130 * 45) {
				_local2.splice(r.random(_local2.length),0,_local1);
				_local1++;
			}
			return _local2;
		}
		
		private function enoughNrNeighbours(x:int, y:int, i:int) : Boolean {
			var _local8:int = 0;
			var _local7:int = 0;
			var _local9:int = 0;
			var _local4:int = lastPos % 130;
			var _local6:int = (lastPos - _local4) / 130;
			var _local5:int = 0;
			if(x == _local4 && y == _local6) {
				return true;
			}
			_local9 = 0;
			while(_local9 < 8) {
				_local8 = x + directions[_local9][0];
				_local7 = y + directions[_local9][1];
				if(_local8 >= 0 && _local8 < 130 && m[_local8][_local7] == i) {
					_local5++;
				} else if(_local8 == -1 && m[130 - 1][_local7] == i) {
					_local5++;
				} else if(_local8 == 130 && m[0][_local7] == i) {
					_local5++;
				}
				_local9++;
			}
			if(_local5 >= 2) {
				return true;
			}
			return false;
		}
		
		private function tryAddNeighbours(x:int, y:int, i:int, nrLeft:int, psr:int) : int {
			if(m[x][y] != i) {
				return 0;
			}
			var _local6:int = 0;
			if(y > 0 && y < 45 - 1 && enoughNrNeighbours(x,y,i)) {
				if(nrLeft > 0 && x + 1 < 130 && m[x + 1][y] == 0 && r.random(100) < x_chance + psr) {
					m[x + 1][y] = i;
					nrLeft--;
					_local6++;
				}
				if(nrLeft > 0 && x - 1 >= 0 && m[x - 1][y] == 0 && r.random(100) < x_chance + psr) {
					m[x - 1][y] = i;
					nrLeft--;
					_local6++;
				}
				if(nrLeft > 0 && y + 1 < 45 && m[x][y + 1] == 0 && r.random(100) < y_chance + psr) {
					m[x][y + 1] = i;
					nrLeft--;
					_local6++;
				}
				if(nrLeft > 0 && y - 1 >= 0 && m[x][y - 1] == 0 && r.random(100) < y_chance + psr) {
					m[x][y - 1] = i;
					nrLeft--;
					_local6++;
				}
			}
			return _local6;
		}
		
		private function canJoinOld(pos:int, i:int) : Boolean {
			var _local3:int = 0;
			var _local4:int = 0;
			_local3 = pos % 130;
			_local4 = (pos - _local3) / 130;
			if(_local4 < 0.2 * 45 || _local4 > 0.8 * 45) {
				return false;
			}
			if(_local3 < 0.2 * 130 || _local3 > 0.8 * 130) {
				return false;
			}
			if(_local4 < 0.2 * 45 || _local4 > 0.8 * 45) {
				return false;
			}
			if(m[_local3][_local4] == 0 && (_local3 - 1 >= 0 && m[_local3 - 1][_local4] != 0 || _local3 + 1 < 130 && m[_local3 + 1][_local4] != 0 || _local4 - 1 >= 0 && m[_local3][_local4 - 1] != 0 || _local4 + 1 < 45 && m[_local3][_local4 + 1] != 0)) {
				m[_local3][_local4] = i;
				return true;
			}
			return false;
		}
		
		private function getMinDist(x:int, y:int) : int {
			var _local5:int = 0;
			var _local4:int = 0;
			var _local6:* = 130;
			var _local3:int = 0;
			_local5 = 0;
			while(_local5 < 130) {
				_local4 = 0;
				while(_local4 < 45) {
					if(m[_local5][_local4] > 0) {
						_local3 = dist2(x,y,_local5,_local4);
						if(_local3 < _local6) {
							_local6 = _local3;
						}
					}
					_local4++;
				}
				_local5++;
			}
			return _local6;
		}
		
		private function canAddNew(pos:int, i:int) : Boolean {
			var _local3:int = 0;
			var _local4:int = 0;
			_local3 = pos % 130;
			_local4 = (pos - _local3) / 130;
			if(_local4 < 0.2 * 45 || _local4 > 0.8 * 45) {
				return false;
			}
			if(_local3 < 0.25 * 130 || _local3 > 0.75 * 130) {
				return false;
			}
			if(m[_local3][_local4] == 0 && (_local3 - 1 >= 0 && m[_local3 - 1][_local4] == 0) && (_local3 + 1 < 130 && m[_local3 + 1][_local4] == 0) && (_local4 - 1 >= 0 && m[_local3][_local4 - 1] == 0) && (_local4 + 1 < 45 && m[_local3][_local4 + 1] == 0)) {
				m[_local3][_local4] = i;
				return true;
			}
			return false;
		}
		
		private function removeInterior() : void {
			var _local2:int = 0;
			var _local1:int = 0;
			var _local3:int = 0;
			_local1 = 0;
			while(_local1 < 130) {
				_local3 = 0;
				while(_local3 < 45) {
					if(_local3 + 1 < 45) {
						_local2 = m[_local1][_local3 + 1];
						if(m[_local1][_local3] == 0 && _local2 != 0 && (_local1 - 1 >= 0 && m[_local1 - 1][_local3] != 0 || _local1 - 1 == -1 && m[130 - 1][_local3] != 0) && (_local1 + 1 < 130 && m[_local1 + 1][_local3] != 0 || _local1 + 1 == 130 && m[0][_local3] != 0) && (_local3 - 1 >= 0 && m[_local1][_local3 - 1] != 0) && (_local3 + 1 < 45 && m[_local1][_local3 + 1] != 0)) {
							m[_local1][_local3] = _local2;
						}
					}
					_local3++;
				}
				_local1++;
			}
			_local1 = 0;
			while(_local1 < 130) {
				if(_local1 + 1 < 130) {
					_local2 = m[_local1 + 1][0];
					if(m[_local1][0] == 0 && _local2 != 0 && (_local1 - 1 >= 0 && m[_local1 - 1][0] != 0 || _local1 - 1 == -1 && m[130 - 1][0] != 0) && (_local1 + 1 < 130 && m[_local1 + 1][0] != 0 || _local1 + 1 == 130 && m[0][0] != 0) && m[_local1][1] != 0) {
						m[_local1][0] = _local2;
					}
					_local2 = m[_local1 + 1][45 - 1];
					if(m[_local1][45 - 1] == 0 && _local2 != 0 && (_local1 - 1 >= 0 && m[_local1 - 1][45 - 1] != 0 || _local1 - 1 == -1 && m[130 - 1][45 - 1] != 0) && (_local1 + 1 < 130 && m[_local1 + 1][45 - 1] != 0 || _local1 + 1 == 130 && m[0][45 - 1] != 0) && m[_local1][45 - 2] != 0) {
						m[_local1][45 - 1] = _local2;
					}
				}
				_local1++;
			}
			_local1 = 0;
			while(_local1 < 130) {
				_local3 = 0;
				while(_local3 < 45) {
					_local2 = m[_local1][_local3];
					if(_local2 > 0 && (_local1 - 1 >= 0 && (m[_local1 - 1][_local3] == _local2 || m[_local1 - 1][_local3] == -_local2) || _local1 - 1 == -1 && (m[130 - 1][_local3] == _local2 || m[130 - 1][_local3] == -_local2)) && (_local1 + 1 < 130 && (m[_local1 + 1][_local3] == _local2 || m[_local1 + 1][_local3] == -_local2) || _local1 + 1 == 130 && (m[0][_local3] == _local2 || m[0][_local3] == -_local2)) && (_local3 - 1 >= 0 && (m[_local1][_local3 - 1] == _local2 || m[_local1][_local3 - 1] == -_local2)) && (_local3 + 1 < 45 && (m[_local1][_local3 + 1] == _local2 || m[_local1][_local3 + 1] == -_local2))) {
						m[_local1][_local3] = -_local2;
					}
					_local3++;
				}
				_local1++;
			}
		}
		
		private function createShells(nrAreas:int) : Vector.<Vector.<Point>> {
			var _local3:int = 0;
			var _local2:Vector.<Vector.<Point>> = new Vector.<Vector.<Point>>();
			_local3 = 1;
			while(_local3 <= nrAreas) {
				_local2.push(createShell(_local3));
				if(_local2[_local2.length - 1] == null) {
					return null;
				}
				_local3++;
			}
			return _local2;
		}
		
		private function getStartPoint(v:Vector.<Point>, i:int, x:int = 0, y:int = 0) : void {
			if(x != 0) {
				x += 1;
			}
			if(y != 0) {
				y += 1;
			}
			x = 0;
			while(x < 130) {
				y = 0;
				while(y < 45) {
					if(m[x][y] == i) {
						if(v == null) {
							return;
						}
						v.push(new Point(x,y));
						return;
					}
					y++;
				}
				x++;
			}
		}
		
		private function createShell(i:int, old_v:Vector.<Point> = null) : Vector.<Point> {
			var _local3:Point = null;
			var _local6:int = 0;
			var _local7:int = 0;
			var _local5:int = 0;
			var _local8:int = 0;
			var _local4:Vector.<Point> = new Vector.<Point>();
			var _local9:int = 0;
			if(old_v != null) {
				_local6 = 0;
				_local7 = 0;
				for each(_local3 in old_v) {
					if(_local3.x > _local6) {
						_local6 = _local3.x;
					}
					if(_local3.y > _local7) {
						_local7 = _local3.y;
					}
				}
				getStartPoint(_local4,i,_local6,_local7);
				if(_local4.length == 0) {
					return null;
				}
			} else {
				getStartPoint(_local4,i);
			}
			while(!isDone(_local4)) {
				_local3 = _local4[_local4.length - 1];
				_local9 = getDirection(_local4);
				_local4.push(getNextPoint(_local3.x,_local3.y,i,_local9));
				_local5 = m[_local3.x][_local3.y];
			}
			if(_local4.length < 10) {
				return null;
			}
			_local8 = 0;
			while(_local8 < 3) {
				removeNarrows(_local4);
				_local8++;
			}
			postProccessEdge(_local4);
			return _local4;
		}
		
		private function getNextPoint(x:int, y:int, i:int, direction:int) : Point {
			var _local7:int = 0;
			var _local6:int = 0;
			var _local8:int = 0;
			var _local5:int = direction - 1;
			_local8 = 0;
			while(_local8 < 8) {
				if(_local5 < 0) {
					_local5 = 7;
				}
				_local7 = x + directions[_local5][0];
				_local6 = y + directions[_local5][1];
				if(_local7 < 0) {
					_local7 = 130 - 1;
				}
				if(_local7 >= 130) {
					_local7 = 0;
				}
				if(_local6 >= 0 && _local6 < 45 && m[_local7][_local6] == i) {
					return new Point(_local7,_local6);
				}
				_local5--;
				_local8++;
			}
			return null;
		}
		
		private function getDirection(v:Vector.<Point>) : int {
			var _local6:int = 0;
			var _local3:int = 0;
			var _local4:int = 0;
			var _local2:int = 0;
			var _local5:int = 0;
			if(v.length < 2) {
				_local4 = v[v.length - 1].x;
				_local2 = v[v.length - 1].y;
				_local5 = 0;
				while(_local5 < 8) {
					if(_local4 + directions[_local5][0] >= 0 && _local4 + directions[_local5][0] < 130 && _local2 + directions[_local5][1] >= 0 && _local2 + directions[_local5][1] < 45 && m[_local4 + directions[_local5][0]][_local2 + directions[_local5][1]] < 0) {
						return _local5;
					}
					_local5++;
				}
				_local5 = 0;
				while(_local5 < 8) {
					if(_local4 + directions[_local5][0] >= 0 && _local4 + directions[_local5][0] < 130 && _local2 + directions[_local5][1] >= 0 && _local2 + directions[_local5][1] < 45 && m[_local4 + directions[_local5][0]][_local2 + directions[_local5][1]] == 0) {
						_local5 -= 4;
						if(_local5 < 0) {
							_local5 = 8 + _local5;
						}
						return _local5;
					}
					_local5++;
				}
			} else {
				_local6 = v[v.length - 1].x;
				_local3 = v[v.length - 1].y;
				_local4 = v[v.length - 2].x;
				_local2 = v[v.length - 2].y;
				if(_local6 == 0 && _local4 == 130 - 1) {
					_local4 = -1;
				}
				if(_local6 == 130 - 1 && _local4 == 0) {
					_local4 = 130;
				}
				if(_local4 == 0 && _local6 == 130 - 1) {
					_local6 = -1;
				}
				if(_local4 == 130 - 1 && _local6 == 0) {
					_local6 = 130;
				}
				_local5 = 0;
				while(_local5 < 8) {
					if(_local4 == _local6 + directions[_local5][0] && _local2 == _local3 + directions[_local5][1]) {
						return _local5;
					}
					_local5++;
				}
			}
			return 0;
		}
		
		private function isDone(v:Vector.<Point>) : Boolean {
			if(v.length <= 2) {
				return false;
			}
			if(v[0].x == v[v.length - 1].x && v[0].y == v[v.length - 1].y) {
				return true;
			}
			return false;
		}
		
		private function removeNarrows(v:Vector.<Point>) : void {
			var _local2:int = 0;
			var _local3:int = 0;
			var _local4:int = 0;
			_local4 = v.length - 1;
			while(_local4 > -1) {
				_local2 = _local4 - 1;
				_local3 = _local4 + 1;
				if(_local2 < 0) {
					_local2 = v.length + _local2;
				}
				if(_local3 >= v.length) {
					_local3 -= v.length;
				}
				if(v[_local2].x == v[_local3].x && v[_local2].y == v[_local3].y) {
					v.splice(_local4,1);
				}
				_local4--;
			}
		}
		
		private function postProccessEdge(v:Vector.<Point>) : void {
			var _local2:int = 0;
			var _local5:Boolean = false;
			var _local3:int = 0;
			var _local6:Vector.<int> = Vector.<int>([1,3,5,7,0,2,4,6]);
			_local3 = 1;
			while(_local3 < v.length - 1) {
				if(v[_local3].x != 0 && v[_local3].x != 130 - 1) {
					_local5 = false;
					for each(var _local4 in _local6) {
						if(v[_local3].y == 45 - 1 || v[_local3].y == 0) {
							v[_local3].x += 0.01 * (-40 + r.random(80));
							v[_local3].y += 0.01 * (-40 + r.random(80));
							_local5 = true;
						} else if(!_local5 && m[v[_local3].x + directions[_local4][0]][v[_local3].y + directions[_local4][1]] == 0) {
							v[_local3].x += 0.01 * directions[_local4][0] * (10 + r.random(30)) + 0.01 * (-10 + r.random(20));
							v[_local3].y += 0.01 * directions[_local4][1] * (10 + r.random(30)) + 0.01 * (-10 + r.random(20));
							_local5 = true;
						} else if(!_local5 && m[v[_local3].x + directions[_local4][0]][v[_local3].y + directions[_local4][1]] != m[v[_local3].x][v[_local3].y] && m[v[_local3].x + directions[_local4][0]][v[_local3].y + directions[_local4][1]] > 0) {
							v[_local3].x += 0.01 * directions[_local4][0] * (30 + r.random(0));
							v[_local3].y += 0.01 * directions[_local4][1] * (30 + r.random(0));
							_local5 = true;
						}
					}
				}
				_local3++;
			}
		}
		
		private function dist2(x1:int, y1:int, x2:int, y2:int) : int {
			return Math.max(Math.abs(x1 - x2),Math.abs(y1 - y2));
		}
		
		private function dist(p1:Point, p2:Point) : Number {
			return (p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y);
		}
		
		private function findClosesPoint(p1:Point, v1:Vector.<Point>) : Point {
			var _local4:Number = NaN;
			var _local7:* = 16900;
			var _local5:* = null;
			for each(var _local6 in shell) {
				if(_local6 != v1) {
					for each(var _local3 in _local6) {
						if(_local3.x != 0 && _local3.y != 0 && _local3.x != 130 - 1 && _local3.y != 45 - 1) {
							_local4 = dist(p1,_local3);
							if(_local4 < _local7) {
								_local7 = _local4;
								_local5 = _local3;
							}
						}
					}
				}
			}
			return _local5;
		}
		
		private function postProccessShells(treshhold:Number) : void {
			var _local3:* = null;
			for each(var _local4 in shell) {
				for each(var _local2 in _local4) {
					if(_local2.x != 0 && _local2.y != 0 && _local2.x != 130 - 1 && _local2.y != 45 - 1) {
						_local3 = findClosesPoint(_local2,_local4);
						if(dist(_local2,_local3) < treshhold) {
							_local2.x = (_local2.x + _local3.x) / 2;
							_local2.y = (_local2.y + _local3.y) / 2;
							_local3 = _local2;
						}
					}
				}
			}
			for each(_local4 in shell) {
				removeNarrows(_local4);
			}
		}
		
		private function createMatrix(n:int, m:int) : Vector.<Vector.<int>> {
			var _local6:* = undefined;
			var _local3:int = 0;
			var _local4:int = 0;
			var _local5:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();
			_local3 = 0;
			while(_local3 < n) {
				_local6 = new Vector.<int>();
				_local4 = 0;
				while(_local4 < m) {
					_local6.push(0);
					_local4++;
				}
				_local5.push(_local6);
				_local3++;
			}
			return _local5;
		}
	}
}

