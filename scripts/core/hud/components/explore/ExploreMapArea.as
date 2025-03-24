package core.hud.components.explore {
	import com.greensock.TweenMax;
	import core.hud.components.CrewDisplayBox;
	import core.hud.components.TextBitmap;
	import core.hud.components.ToolTip;
	import core.player.Explore;
	import core.scene.Game;
	import core.solarSystem.Area;
	import extensions.PixelHitArea;
	import extensions.PixelImageTouch;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import sound.SoundLocator;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import starling.filters.ColorMatrixFilter;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class ExploreMapArea extends starling.display.Sprite {
		private static const ALPHA_COMPLETE:Number = 0.6;
		
		private static const ALPHA_START:Number = 0.3;
		
		public var key:String;
		
		public var area:Object;
		
		private var shell:Vector.<Point>;
		
		public var size:int;
		
		private var a:Number;
		
		private var g:Game;
		
		private var color:uint;
		
		private var color_fill:uint;
		
		private var color_fill_done:uint;
		
		private var map:ExploreMap;
		
		private var selected:Boolean;
		
		private var mouseOver:Boolean;
		
		private var x_max:int;
		
		private var fractionText:TextBitmap;
		
		private var kx:Number;
		
		private var ky:Number;
		
		private var x_mid:Number;
		
		private var y_mid:Number;
		
		private var infoBox:starling.display.Sprite;
		
		private var infoBoxBgr:Quad;
		
		public var explore:Explore;
		
		public var fraction:int = 0;
		
		private var areaTexture:Texture;
		
		private var areaImage:PixelImageTouch;
		
		private var tween:TweenMax;
		
		private var needRedraw:Boolean = true;
		
		private var fader:Number = 0.02;
		
		public function ExploreMapArea(g:Game, map:ExploreMap, area:Object, shell:Vector.<Point>, kx:Number, ky:Number, x_max:int) {
			var _local10:int = 0;
			var _local17:int = 0;
			var _local13:ITextureManager = null;
			var _local9:Image = null;
			var _local16:starling.display.Sprite = null;
			var _local11:ToolTip = null;
			var _local18:TextBitmap = null;
			var _local19:TextBitmap = null;
			var _local12:int = 0;
			var _local20:Image = null;
			var _local21:starling.display.Sprite = null;
			var _local15:ToolTip = null;
			super();
			this.g = g;
			this.a = 1;
			this.kx = kx;
			this.ky = ky;
			this.map = map;
			this.area = area;
			this.x_max = x_max;
			this.shell = shell;
			key = area.key;
			size = area.size;
			explore = g.me.getExploreByKey(key);
			if(explore == null) {
				fraction = 0;
			} else if(explore.failTime < g.time && explore.failTime != 0) {
				fraction = 100 * (explore.successfulEvents + 1) / (size + 4 + 1);
			} else {
				fraction = 100 * (g.time - explore.startTime) / (explore.finishTime - explore.startTime);
			}
			var _local8:Array = area.types;
			if(area.majorType == -1) {
				color = 0x333333;
				color_fill = 0;
			} else {
				color = Area.COLORTYPE[area.majorType];
				color_fill = Area.COLORTYPEFILL[area.majorType];
			}
			drawArea();
			if(area.majorType != -1) {
				useHandCursor = true;
				_local10 = 49;
				_local17 = 45;
				if(area.skillLevel > 99 || _local8.length > 1) {
					_local17 = 58;
				}
				infoBox = new starling.display.Sprite();
				infoBoxBgr = new Quad(_local17,_local10,0);
				infoBoxBgr.alpha = 0.5;
				infoBox.addChild(infoBoxBgr);
				infoBox.x = x_mid - 0.5 * infoBox.width;
				infoBox.y = y_mid - 0.5 * infoBox.height;
				infoBox.touchable = false;
				addChild(infoBox);
				fractionText = new TextBitmap(2,2,fraction + "%");
				infoBox.addChild(fractionText);
				_local13 = TextureLocator.getService();
				_local9 = new Image(_local13.getTextureGUIByTextureName(CrewDisplayBox.IMAGES_SKILLS[area.majorType]));
				_local9.x = 4;
				_local9.y = 33;
				_local16 = new starling.display.Sprite();
				_local16.addChild(_local9);
				_local11 = new ToolTip(g,_local16,Area.SKILLTYPEHTML[area.majorType],null,"skill");
				infoBox.addChild(_local16);
				_local18 = new TextBitmap(2,18,"lvl ",11);
				infoBox.addChild(_local18);
				_local19 = new TextBitmap(0,18,area.skillLevel,11);
				_local19.x = _local18.x + _local18.width;
				infoBox.addChild(_local19);
				_local12 = 1;
				for each(var _local14 in _local8) {
					_local12++;
					_local20 = new Image(_local13.getTextureGUIByTextureName(CrewDisplayBox.IMAGES_SPECIALS[_local14]));
					_local20.x = -18 + 20 * _local12;
					_local20.y = 33;
					_local21 = new starling.display.Sprite();
					_local21.addChild(_local20);
					_local15 = new ToolTip(g,_local21,Area.SPECIALTYPEHTML[_local14],null,"skill");
					infoBox.addChild(_local21);
				}
				infoBox.addEventListener("touch",onTouch);
			}
		}
		
		private function drawArea() : void {
			var _local7:int = 0;
			var _local8:Number = 0;
			var _local6:Number = 0;
			x_mid = 0;
			y_mid = 0;
			var _local3:int = 1 + shell.length;
			var _local2:flash.display.Sprite = new flash.display.Sprite();
			_local2.graphics.lineStyle(2,color);
			_local2.graphics.beginFill(color_fill,a);
			_local2.graphics.moveTo(shell[0].x * kx,shell[0].y * ky);
			x_mid += shell[0].x * kx;
			y_mid += shell[0].y * ky;
			_local8 = shell[0].x * kx;
			_local6 = shell[0].y * ky;
			_local7 = 1;
			while(_local7 < shell.length) {
				x_mid += shell[_local7].x * kx;
				y_mid += shell[_local7].y * ky;
				_local8 = Math.min(_local8,shell[_local7].x * kx);
				_local6 = Math.min(_local6,shell[_local7].y * ky);
				_local2.graphics.lineTo(shell[_local7].x * kx,shell[_local7].y * ky);
				_local7++;
			}
			x_mid /= _local3;
			y_mid /= _local3;
			_local2.graphics.endFill();
			var _local1:Rectangle = _local2.getBounds(_local2);
			var _local5:BitmapData = new BitmapData(_local1.width,_local1.height,true,0);
			var _local9:Matrix = new Matrix();
			_local9.translate(-_local1.x,-_local1.y);
			_local5.draw(_local2,_local9);
			var _local4:Bitmap = new Bitmap(_local5);
			areaTexture = Texture.fromBitmap(_local4);
			areaImage = new PixelImageTouch(areaTexture,new PixelHitArea(_local4,1,key),50);
			_local4 = null;
			_local5.dispose();
			_local5 = null;
			_local2.graphics.clear();
			_local2 = null;
			if(area.majorType != -1) {
				areaImage.addEventListener("touch",onTouch);
			}
			areaImage.x = _local8;
			areaImage.y = _local6;
			addChildAt(areaImage,0);
		}
		
		private function onTouch(e:TouchEvent) : void {
			var _local2:DisplayObject = e.currentTarget as DisplayObject;
			if(e.getTouch(_local2,"ended")) {
				onClick(e);
			} else if(e.interactsWith(_local2)) {
				mOver(e);
			} else if(!e.interactsWith(_local2)) {
				mOut(e);
			}
		}
		
		public function shouldBlink() : Boolean {
			if(explore != null && !explore.lootClaimed) {
				return true;
			}
			return false;
		}
		
		public function update() : void {
			if(!needRedraw) {
				return;
			}
			if(area.majorType == -1) {
				return;
			}
			if(explore == null) {
				fraction = 0;
			} else {
				if(explore.failTime < g.time && explore.successfulEvents < area.size + 4) {
					fractionText.text = "Failed!";
					fractionText.format.color = 0xff0000;
					infoBoxBgr.width = fractionText.width + 5;
					if(!explore.lootClaimed) {
						fractionText.text = "Reward!";
						infoBoxBgr.width = fractionText.width + 5;
						startTween();
					}
					return;
				}
				if(explore.failTime >= g.time) {
					fractionText.format.color = 0xffffff;
					fraction = 100 * (g.time - explore.startTime) / (explore.finishTime - explore.startTime);
					fractionText.text = fraction + "%";
				} else if(explore != null && explore.lootClaimed) {
					fractionText.text = "Claimed!";
					fractionText.format.color = 0xffffff;
					infoBoxBgr.width = fractionText.width + 5;
					needRedraw = false;
				} else {
					fractionText.text = "Reward!";
					fractionText.format.color = 0xffffff;
					infoBoxBgr.width = fractionText.width + 5;
					startTween();
				}
			}
		}
		
		public function select() : void {
			selected = true;
			if(areaImage.filter) {
				areaImage.filter.dispose();
				areaImage.filter = null;
			}
			map.moveOnTop(this);
			startTween();
		}
		
		private function startTween() : void {
			if(tween != null) {
				return;
			}
			tween = TweenMax.fromTo(areaImage,0.8,{"alpha":1},{
				"alpha":0.5,
				"yoyo":true,
				"repeat":-1
			});
		}
		
		public function clearSelect() : void {
			selected = false;
			if(tween != null) {
				tween.kill();
				tween = null;
				areaImage.alpha = 1;
			}
		}
		
		public function onClick(e:TouchEvent) : void {
			if(!selected) {
				SoundLocator.getService().play("3hVYqbNNSUWoDGk_pK1BdQ");
				map.clearSelected(this);
				ExploreMap.selectedArea = area;
				select();
			}
		}
		
		public function mOver(e:TouchEvent) : void {
			if(selected) {
				return;
			}
			if(areaImage.filter) {
				return;
			}
			var _local2:ColorMatrixFilter = new ColorMatrixFilter();
			_local2.adjustBrightness(0.2);
			areaImage.filter = _local2;
		}
		
		public function mOut(e:TouchEvent) : void {
			if(areaImage.filter) {
				areaImage.filter.dispose();
				areaImage.filter = null;
			}
		}
		
		override public function dispose() : void {
			if(areaImage.filter) {
				areaImage.filter.dispose();
				areaImage.filter = null;
			}
			if(tween != null) {
				tween.kill();
				tween = null;
			}
			if(areaTexture) {
				removeChild(areaImage,true);
				areaTexture.dispose();
			}
			super.dispose();
		}
	}
}

