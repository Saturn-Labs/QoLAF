package core.parallax {
	import com.greensock.TweenMax;
	import core.scene.SceneBase;
	import data.DataLocator;
	import debug.Console;
	import generics.Random;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.MeshBatch;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class ParallaxManager {
		private static const SIZE:Number = 1.8;
		
		private static const MINI_STARS:int = 70;
		
		private static const STARS:int = 40;
		
		private static const MINI_DUSTS:int = 25;
		
		private var NEBULAS:int = 8;
		
		private var g:SceneBase;
		
		public var stars:Vector.<Quad> = new Vector.<Quad>();
		
		public var miniStars:Vector.<Quad> = new Vector.<Quad>();
		
		public var miniDusts:Vector.<Quad> = new Vector.<Quad>();
		
		public var nebulas:Vector.<Quad> = new Vector.<Quad>();
		
		private var nebulaType:String = "";
		
		private var width:Number;
		
		private var height:Number;
		
		private var halfWidth:Number;
		
		private var halfHeight:Number;
		
		private var isIntro:Boolean;
		
		private var random:Random;
		
		private var target:DisplayObjectContainer;
		
		private var starBatch:MeshBatch = new MeshBatch();
		
		private var nebulaContainer:Sprite = new Sprite();
		
		private var starTxt:Texture;
		
		private var nebulaTxt:Texture;
		
		private var initialized:Boolean = false;
		
		public var cx:Number = -3;
		
		public var cy:Number = -2;
		
		private var nebulaUpdateCount:int;
		
		private var NEBULA_UPDATE_INTERVAL:int = 200;
		
		public var visible:Boolean = true;
		
		private var lastAdjustment:Number = 0;
		
		public function ParallaxManager(g:SceneBase, target:DisplayObjectContainer, isIntro:Boolean = false) {
			super();
			this.g = g;
			this.target = target;
			this.isIntro = isIntro;
			nebulaContainer.blendMode = "none";
			if(!g) {
				return;
			}
			g.addResizeListener(resize);
		}
		
		public function load(solarSystemObj:Object, callback:Function) : void {
			var textureManager:ITextureManager = TextureLocator.getService();
			loadData(solarSystemObj,function(param1:Event):void {
				starTxt = textureManager.getTextureMainByTextureName("star.png");
				var _local2:Object = DataLocator.getService().loadKey("Images",solarSystemObj.background);
				nebulaType = _local2.textureName;
				random = new Random(solarSystemObj.x * solarSystemObj.y + solarSystemObj.x + solarSystemObj.y);
				nebulaTxt = textureManager.getTextureByTextureName(_local2.textureName,_local2.fileName);
				if(solarSystemObj.galaxy == "Rapir System") {
					NEBULAS = 4;
				}
				resize();
				if(callback != null) {
					callback();
				}
			});
		}
		
		private function loadData(solarSystemObj:Object, callback:Function) : void {
			var _local3:Object = DataLocator.getService().loadKey("Images",solarSystemObj.background);
			var _local4:String = _local3.textureName;
			var _local5:ITextureManager = TextureLocator.getService();
			_local5.loadTextures([_local4 + ".xml",_local4 + ".jpg"]);
			_local5.addEventListener("preloadComplete",createLoadComplete(callback));
		}
		
		private function createLoadComplete(callback:Function) : Function {
			return (function():* {
				var lc:Function;
				return lc = function(param1:Event):void {
					callback(param1);
					TextureLocator.getService().removeEventListener("preloadComplete",lc);
				};
			})();
		}
		
		public function refresh() : void {
			var _local2:int = 0;
			var _local3:Image = null;
			var _local1:Image = null;
			if(initialized) {
				clear();
			}
			if(g) {
				visible = SceneBase.settings.showBackground;
			}
			if(!nebulaTxt || !starTxt) {
				Console.write("Parallaxmanager not loaded yet, refreshing");
				TweenMax.delayedCall(0.3,refresh);
				return;
			}
			if(visible) {
				_local2 = 0;
				while(_local2 < NEBULAS) {
					_local3 = new Image(nebulaTxt);
					_local3.blendMode = "add";
					_local3.pivotX = _local3.width / 2;
					_local3.pivotY = _local3.height / 2;
					nebulas.push(_local3);
					if(isIntro) {
						_local3.alpha = 0;
					}
					nebulaContainer.addChild(_local3);
					_local2++;
				}
				nebulaUpdateCount = NEBULA_UPDATE_INTERVAL;
			} else {
				nebulaContainer.removeChildren(0,-1);
			}
			_local2 = 0;
			while(_local2 < 40) {
				_local1 = new Image(starTxt);
				stars.push(_local1);
				_local2++;
			}
			_local2 = 0;
			while(_local2 < 70) {
				_local1 = new Image(starTxt);
				miniStars.push(_local1);
				_local2++;
			}
			_local2 = 0;
			while(_local2 < 25) {
				_local1 = new Image(starTxt);
				miniDusts.push(_local1);
				_local2++;
			}
			target.addChild(nebulaContainer);
			target.addChild(starBatch);
			initialized = true;
			resize();
		}
		
		private function clear() : void {
			if(!initialized) {
				return;
			}
			target.removeChildren(0,-1,true);
			nebulas.length = 0;
			stars.length = 0;
			miniStars.length = 0;
			miniDusts.length = 0;
		}
		
		public function randomize() : void {
			var _local1:Quad = null;
			var _local2:int = 0;
			_local2 = 0;
			while(_local2 < nebulas.length) {
				_local1 = nebulas[_local2];
				if(_local2 == 0) {
					_local1.x = 0;
					_local1.y = 0;
				} else {
					_local1.x = -1500 + 50 * 60 * random.randomNumber();
					_local1.y = -1500 + 50 * 60 * random.randomNumber();
				}
				if(isIntro) {
					_local1.x += 1024;
					_local1.y += 1024;
				}
				_local1.rotation = 3.141592653589793 * 2 * random.randomNumber();
				_local2++;
			}
			nebulaUpdateCount = NEBULA_UPDATE_INTERVAL;
			_local2 = 0;
			while(_local2 < miniStars.length) {
				_local1 = miniStars[_local2];
				if(isIntro) {
					_local1.x = width * Math.random();
					_local1.y = height * Math.random();
				} else {
					_local1.x = -halfWidth + width * Math.random();
					_local1.y = -halfHeight + height * Math.random();
				}
				_local2++;
			}
			_local2 = 0;
			while(_local2 < stars.length) {
				_local1 = stars[_local2];
				if(isIntro) {
					_local1.x = width * Math.random();
					_local1.y = height * Math.random();
				} else {
					_local1.x = -halfWidth + width * Math.random();
					_local1.y = -halfHeight + height * Math.random();
				}
				_local2++;
			}
			_local2 = 0;
			while(_local2 < miniDusts.length) {
				_local1 = miniDusts[_local2];
				if(isIntro) {
					_local1.x = width * Math.random() * 2;
					_local1.y = height * Math.random() * 2;
				} else {
					_local1.x = -halfWidth + width * Math.random();
					_local1.y = -halfHeight + height * Math.random();
				}
				_local2++;
			}
		}
		
		public function update() : void {
			var _local7:int = 0;
			var _local8:int = 0;
			var _local3:Quad = null;
			if(g != null) {
				cx = g.camera.speed.x;
				cy = g.camera.speed.y;
			}
			var _local1:Number = cx / 7;
			var _local10:Number = cy / 7;
			var _local11:Number = cx / 6;
			var _local9:Number = cy / 6;
			var _local5:Number = cx / 4;
			var _local2:Number = cy / 4;
			var _local6:Number = cx / 1.8;
			var _local4:Number = cy / 1.8;
			if(visible) {
				nebulaUpdateCount++;
				if(nebulaUpdateCount > NEBULA_UPDATE_INTERVAL) {
					nebulaUpdateCount = 0;
					_local8 = int(nebulas.length);
					_local7 = 0;
					while(_local7 < _local8) {
						_local3 = nebulas[_local7];
						_local3.x -= _local1 * (_local7 / _local8);
						_local3.y -= _local10 * (_local7 / _local8);
						_local7++;
					}
				}
			}
			starBatch.clear();
			_local8 = int(stars.length);
			_local7 = 0;
			while(_local7 < _local8) {
				_local3 = stars[_local7];
				_local3.x -= _local5;
				_local3.y -= _local2;
				starBatch.addMesh(_local3);
				_local7++;
			}
			_local8 = int(miniStars.length);
			_local7 = 0;
			while(_local7 < _local8) {
				_local3 = miniStars[_local7];
				_local3.x -= _local11;
				_local3.y -= _local9;
				starBatch.addMesh(_local3);
				_local7++;
			}
			_local8 = int(miniDusts.length);
			_local7 = 0;
			while(_local7 < _local8) {
				_local3 = miniDusts[_local7];
				_local3.x -= _local6;
				_local3.y -= _local4;
				starBatch.addMesh(_local3);
				_local7++;
			}
		}
		
		public function draw() : void {
			var _local1:int = 0;
			var _local3:int = 0;
			var _local2:Number = NaN;
			if(g) {
				_local2 = g.time - lastAdjustment;
				if(_local2 < 1000) {
					return;
				}
				lastAdjustment = g.time;
			}
			_local3 = int(stars.length);
			_local1 = 0;
			while(_local1 < _local3) {
				adjustPosition(stars[_local1]);
				_local1++;
			}
			_local3 = int(miniStars.length);
			_local1 = 0;
			while(_local1 < _local3) {
				adjustPosition(miniStars[_local1]);
				_local1++;
			}
			_local3 = int(miniDusts.length);
			_local1 = 0;
			while(_local1 < _local3) {
				adjustPosition(miniDusts[_local1]);
				_local1++;
			}
		}
		
		private function adjustPosition(img:DisplayObject) : void {
			var _local2:Number = img.x;
			var _local3:Number = img.y;
			if(isIntro) {
				if(_local2 > halfWidth * 2) {
					img.x = _local2 - width;
				} else if(_local2 < -halfWidth * 2) {
					img.x = _local2 + width;
				}
				if(_local3 > halfHeight * 2) {
					img.y = _local3 - height;
				} else if(_local3 < -halfHeight * 2) {
					img.y = _local3 + height;
				}
				return;
			}
			if(_local2 > halfWidth) {
				img.x = _local2 - width;
			} else if(_local2 < -halfWidth) {
				img.x = _local2 + width;
			}
			if(_local3 > halfHeight) {
				img.y = _local3 - height;
			} else if(_local3 < -halfHeight) {
				img.y = _local3 + height;
			}
		}
		
		public function glow() : void {
			var _local1:int = 0;
			var _local2:int = 0;
			_local2 = int(nebulas.length);
			_local1 = 0;
			while(_local1 < _local2) {
				nebulas[_local1].rotation = 0;
				nebulas[_local1].width *= 100;
				_local1++;
			}
			_local2 = int(stars.length);
			_local1 = 0;
			while(_local1 < _local2) {
				stars[_local1].scaleY = 0.1;
				stars[_local1].scaleX = 100;
				_local1++;
			}
			_local2 = int(miniStars.length);
			_local1 = 0;
			while(_local1 < _local2) {
				miniStars[_local1].scaleY = 0.3;
				miniStars[_local1].scaleX = 100;
				_local1++;
			}
			_local2 = int(miniDusts.length);
			_local1 = 0;
			while(_local1 < _local2) {
				miniDusts[_local1].scaleY = 0.5;
				miniDusts[_local1].scaleX = 100;
				_local1++;
			}
		}
		
		public function removeGlow() : void {
			var _local1:int = 0;
			var _local2:int = 0;
			_local2 = int(nebulas.length);
			_local1 = 0;
			while(_local1 < _local2) {
				nebulas[_local1].rotation = 0;
				nebulas[_local1].width /= 100;
				_local1++;
			}
			_local2 = int(stars.length);
			_local1 = 0;
			while(_local1 < _local2) {
				stars[_local1].scaleY = 1;
				stars[_local1].scaleX = 1;
				_local1++;
			}
			_local2 = int(miniStars.length);
			_local1 = 0;
			while(_local1 < _local2) {
				miniStars[_local1].scaleY = 1;
				miniStars[_local1].scaleX = 1;
				_local1++;
			}
			_local2 = int(miniDusts.length);
			_local1 = 0;
			while(_local1 < _local2) {
				miniDusts[_local1].scaleY = 1;
				miniDusts[_local1].scaleX = 1;
				_local1++;
			}
		}
		
		private function resize(e:Event = null) : void {
			width = Starling.current.stage.stageWidth * 1.8;
			height = Starling.current.stage.stageHeight * 1.8;
			halfWidth = width / 2;
			halfHeight = height / 2;
			randomize();
		}
	}
}

