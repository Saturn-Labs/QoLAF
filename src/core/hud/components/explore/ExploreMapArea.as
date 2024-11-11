package core.hud.components.explore
{
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

	public class ExploreMapArea extends starling.display.Sprite
	{
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
		public function ExploreMapArea(param1:Game, param2:ExploreMap, param3:Object, param4:Vector.<Point>, param5:Number, param6:Number, param7:int)
		{
			var _loc16_:int = 0;
			var _loc18_:int = 0;
			var _loc19_:ITextureManager = null;
			var _loc14_:Image = null;
			var _loc20_:starling.display.Sprite = null;
			var _loc12_:ToolTip = null;
			var _loc11_:TextBitmap = null;
			var _loc9_:TextBitmap = null;
			var _loc17_:int = 0;
			var _loc8_:Image = null;
			var _loc10_:starling.display.Sprite = null;
			var _loc15_:ToolTip = null;
			super();
			this.g = param1;
			this.a = 1;
			this.kx = param5;
			this.ky = param6;
			this.map = param2;
			this.area = param3;
			this.x_max = param7;
			this.shell = param4;
			key = param3.key;
			size = param3.size;
			explore = param1.me.getExploreByKey(key);
			if (explore == null)
			{
				fraction = 0;
			}
			else if (explore.failTime < param1.time && explore.failTime != 0)
			{
				fraction = 100 * (explore.successfulEvents + 1) / (size + 4 + 1);
			}
			else
			{
				fraction = 100 * (param1.time - explore.startTime) / (explore.finishTime - explore.startTime);
			}
			var _loc21_:Array = param3.types;
			if (param3.majorType == -1)
			{
				color = 3355443;
				color_fill = 0;
			}
			else
			{
				color = Area.COLORTYPE[param3.majorType];
				color_fill = Area.COLORTYPEFILL[param3.majorType];
			}
			drawArea();
			if (param3.majorType != -1)
			{
				useHandCursor = true;
				_loc16_ = 49;
				_loc18_ = 45;
				if (param3.skillLevel > 99 || _loc21_.length > 1)
				{
					_loc18_ = 58;
				}
				infoBox = new starling.display.Sprite();
				infoBoxBgr = new Quad(_loc18_, _loc16_, 0);
				infoBoxBgr.alpha = 0.5;
				infoBox.addChild(infoBoxBgr);
				infoBox.x = x_mid - 0.5 * infoBox.width;
				infoBox.y = y_mid - 0.5 * infoBox.height;
				infoBox.touchable = false;
				addChild(infoBox);
				fractionText = new TextBitmap(2, 2, fraction + "%");
				infoBox.addChild(fractionText);
				_loc19_ = TextureLocator.getService();
				_loc14_ = new Image(_loc19_.getTextureGUIByTextureName(CrewDisplayBox.IMAGES_SKILLS[param3.majorType]));
				_loc14_.x = 4;
				_loc14_.y = 33;
				_loc20_ = new starling.display.Sprite();
				_loc20_.addChild(_loc14_);
				_loc12_ = new ToolTip(param1, _loc20_, Area.SKILLTYPEHTML[param3.majorType], null, "skill");
				infoBox.addChild(_loc20_);
				_loc11_ = new TextBitmap(2, 18, "lvl ", 11);
				infoBox.addChild(_loc11_);
				_loc9_ = new TextBitmap(0, 18, param3.skillLevel, 11);
				_loc9_.x = _loc11_.x + _loc11_.width;
				infoBox.addChild(_loc9_);
				_loc17_ = 1;
				for each (var _loc13_:* in _loc21_)
				{
					_loc17_++;
					_loc8_ = new Image(_loc19_.getTextureGUIByTextureName(CrewDisplayBox.IMAGES_SPECIALS[_loc13_]));
					_loc8_.x = -18 + 20 * _loc17_;
					_loc8_.y = 33;
					_loc10_ = new starling.display.Sprite();
					_loc10_.addChild(_loc8_);
					_loc15_ = new ToolTip(param1, _loc10_, Area.SPECIALTYPEHTML[_loc13_], null, "skill");
					infoBox.addChild(_loc10_);
				}
				infoBox.addEventListener("touch", onTouch);
			}
		}

		private function drawArea():void
		{
			var _loc9_:int = 0;
			var _loc5_:Number = 0;
			var _loc8_:Number = 0;
			x_mid = 0;
			y_mid = 0;
			var _loc6_:int = 1 + shell.length;
			var _loc3_:flash.display.Sprite = new flash.display.Sprite();
			_loc3_.graphics.lineStyle(2, color);
			_loc3_.graphics.beginFill(color_fill, a);
			_loc3_.graphics.moveTo(shell[0].x * kx, shell[0].y * ky);
			x_mid += shell[0].x * kx;
			y_mid += shell[0].y * ky;
			_loc5_ = shell[0].x * kx;
			_loc8_ = shell[0].y * ky;
			_loc9_ = 1;
			while (_loc9_ < shell.length)
			{
				x_mid += shell[_loc9_].x * kx;
				y_mid += shell[_loc9_].y * ky;
				_loc5_ = Math.min(_loc5_, shell[_loc9_].x * kx);
				_loc8_ = Math.min(_loc8_, shell[_loc9_].y * ky);
				_loc3_.graphics.lineTo(shell[_loc9_].x * kx, shell[_loc9_].y * ky);
				_loc9_++;
			}
			x_mid /= _loc6_;
			y_mid /= _loc6_;
			_loc3_.graphics.endFill();
			var _loc7_:Rectangle = _loc3_.getBounds(_loc3_);
			var _loc1_:BitmapData = new BitmapData(_loc7_.width, _loc7_.height, true, 0);
			var _loc4_:Matrix = new Matrix();
			_loc4_.translate(-_loc7_.x, -_loc7_.y);
			_loc1_.draw(_loc3_, _loc4_);
			var _loc2_:Bitmap = new Bitmap(_loc1_);
			areaTexture = Texture.fromBitmap(_loc2_);
			areaImage = new PixelImageTouch(areaTexture, new PixelHitArea(_loc2_, 1, key), 50);
			_loc2_ = null;
			_loc1_.dispose();
			_loc1_ = null;
			_loc3_.graphics.clear();
			_loc3_ = null;
			if (area.majorType != -1)
			{
				areaImage.addEventListener("touch", onTouch);
			}
			areaImage.x = _loc5_;
			areaImage.y = _loc8_;
			addChildAt(areaImage, 0);
		}

		private function onTouch(param1:TouchEvent):void
		{
			var _loc2_:DisplayObject = param1.currentTarget as DisplayObject;
			if (param1.getTouch(_loc2_, "ended"))
			{
				onClick(param1);
			}
			else if (param1.interactsWith(_loc2_))
			{
				mOver(param1);
			}
			else if (!param1.interactsWith(_loc2_))
			{
				mOut(param1);
			}
		}

		public function shouldBlink():Boolean
		{
			if (explore != null && !explore.lootClaimed)
			{
				return true;
			}
			return false;
		}

		public function update():void
		{
			if (!needRedraw)
			{
				return;
			}
			if (area.majorType == -1)
			{
				return;
			}
			if (explore == null)
			{
				fraction = 0;
			}
			else
			{
				if (explore.failTime < g.time && explore.successfulEvents < area.size + 4)
				{
					fractionText.text = "Failed!";
					fractionText.format.color = 16711680;
					infoBoxBgr.width = fractionText.width + 5;
					if (!explore.lootClaimed)
					{
						fractionText.text = "Reward!";
						infoBoxBgr.width = fractionText.width + 5;
						startTween();
					}
					return;
				}
				if (explore.failTime >= g.time)
				{
					fractionText.format.color = 16777215;
					fraction = 100 * (g.time - explore.startTime) / (explore.finishTime - explore.startTime);
					fractionText.text = fraction + "%";
				}
				else if (explore != null && explore.lootClaimed)
				{
					fractionText.text = "Claimed!";
					fractionText.format.color = 16777215;
					infoBoxBgr.width = fractionText.width + 5;
					needRedraw = false;
				}
				else
				{
					fractionText.text = "Reward!";
					fractionText.format.color = 16777215;
					infoBoxBgr.width = fractionText.width + 5;
					startTween();
				}
			}
		}

		public function select():void
		{
			selected = true;
			if (areaImage.filter)
			{
				areaImage.filter.dispose();
				areaImage.filter = null;
			}
			map.moveOnTop(this);
			startTween();
		}

		private function startTween():void
		{
			if (tween != null)
			{
				return;
			}
			tween = TweenMax.fromTo(areaImage, 0.8, {"alpha": 1}, {
						"alpha": 0.5,
						"yoyo": true,
						"repeat": -1
					});
		}

		public function clearSelect():void
		{
			selected = false;
			if (tween != null)
			{
				tween.kill();
				tween = null;
				areaImage.alpha = 1;
			}
		}

		public function onClick(param1:TouchEvent):void
		{
			if (!selected)
			{
				SoundLocator.getService().play("3hVYqbNNSUWoDGk_pK1BdQ");
				map.clearSelected(this);
				ExploreMap.selectedArea = area;
				select();
			}
		}

		public function mOver(param1:TouchEvent):void
		{
			if (selected)
			{
				return;
			}
			if (areaImage.filter)
			{
				return;
			}
			var _loc2_:ColorMatrixFilter = new ColorMatrixFilter();
			_loc2_.adjustBrightness(0.2);
			areaImage.filter = _loc2_;
		}

		public function mOut(param1:TouchEvent):void
		{
			if (areaImage.filter)
			{
				areaImage.filter.dispose();
				areaImage.filter = null;
			}
		}

		override public function dispose():void
		{
			if (areaImage.filter)
			{
				areaImage.filter.dispose();
				areaImage.filter = null;
			}
			if (tween != null)
			{
				tween.kill();
				tween = null;
			}
			if (areaTexture)
			{
				removeChild(areaImage, true);
				areaTexture.dispose();
			}
			super.dispose();
		}
	}
}
