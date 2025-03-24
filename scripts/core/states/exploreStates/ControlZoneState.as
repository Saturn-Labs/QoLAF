package core.states.exploreStates {
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import core.GameObject;
	import core.controlZones.ControlZoneManager;
	import core.hud.components.Button;
	import core.hud.components.ButtonExpandableHud;
	import core.hud.components.Style;
	import core.hud.components.Text;
	import core.hud.components.TextBitmap;
	import core.hud.components.TextBitmapNumberAnimation;
	import core.hud.components.ToolTip;
	import core.hud.components.explore.ExploreArea;
	import core.hud.components.explore.ExploreMap;
	import core.particle.Emitter;
	import core.scene.Game;
	import core.solarSystem.Body;
	import core.states.DisplayState;
	import extensions.PixelHitArea;
	import flash.display.Bitmap;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import playerio.Message;
	import starling.display.Image;
	import starling.display.Sprite;
	
	public class ControlZoneState extends DisplayState {
		public static var COLOR:uint = 3225899;
		
		private static var planetExploreAreas:Dictionary = null;
		
		private var min:Number = 0;
		
		private var max:Number = 1;
		
		private var value:Number = 0;
		
		private var _exploring:Boolean = false;
		
		private var exploreEffect:Vector.<Emitter>;
		
		private var effectBackground:Bitmap;
		
		private var effectContainer:Bitmap;
		
		private var effectTarget:GameObject;
		
		private var hasDrawnBody:Boolean = false;
		
		private var exploreText:Text;
		
		private var closeButton:ButtonExpandableHud;
		
		private var timer:Timer = new Timer(1000,1);
		
		private var startTime:Number = 0;
		
		private var finishTime:Number = 0;
		
		private var areaTypes:Dictionary = new Dictionary();
		
		private var areas:Vector.<ExploreArea>;
		
		private var planetGfx:Image;
		
		private var areaBox:Sprite;
		
		private var areasText:Text;
		
		private var exploreMap:ExploreMap;
		
		private var b:Body;
		
		private var hasCollectedReward:Boolean = false;
		
		private var bodyAreas:Array;
		
		private var exploredAreas:Array;
		
		private var message:Message;
		
		public function ControlZoneState(g:Game, b:Body, message:Message = null) {
			super(g,ControlZoneState);
			this.b = b;
			this.message = message;
		}
		
		override public function enter() : void {
			var level:int;
			var troons:int;
			var troonsBonus:int;
			var time:int;
			var timeBonus:int;
			var increaseAnimationTime:Number;
			var troonsPerMinuteValue:int;
			var delay:Number;
			var delayInc:Number;
			var yPos:int;
			var header:TextBitmap;
			var planetReward:TextBitmap;
			var planetRewardAmount:TextBitmapNumberAnimation;
			var levelBonus:TextBitmap;
			var troonImg:Image;
			var levelBonusAmount:TextBitmapNumberAnimation;
			var troonImg2:Image;
			var planetTroonsPerMinute:TextBitmap;
			var planetTroonsPerMinuteAmount:TextBitmapNumberAnimation;
			var troonImg3:Image;
			var ct:ControlTime;
			var nextButton:Button;
			super.enter();
			message = ControlZoneManager.claimData;
			level = int(g.playerManager.me.level <= 100 ? g.playerManager.me.level : 100);
			troons = message.getInt(0);
			troonsBonus = level / 100 * troons;
			time = message.getInt(1);
			timeBonus = level / 100 * time;
			increaseAnimationTime = 0;
			troonsPerMinuteValue = message.getInt(2);
			ControlZoneManager.claimData = null;
			delay = 0;
			delayInc = 0.2;
			yPos = 150;
			header = new TextBitmap(380,yPos,"Control Gained",40);
			header.center();
			header.format.color = Style.COLOR_LIGHT_GREEN;
			header.alpha = 0;
			addChild(header);
			TweenMax.to(header,0.3,{
				"delay":delay,
				"alpha":1
			});
			yPos += 50;
			planetReward = new TextBitmap(430,yPos,"Instant reward:",26);
			planetReward.alignRight();
			planetReward.format.color = Style.COLOR_GRAY_TEXT;
			addChild(planetReward);
			planetReward.alpha = 0;
			delay += delayInc;
			TweenMax.to(planetReward,0.3,{
				"delay":delay,
				"alpha":1
			});
			planetRewardAmount = new TextBitmapNumberAnimation(planetReward.x + 100,planetReward.y,"",26);
			increaseAnimationTime = troons * 1.5;
			TweenMax.delayedCall(delay,function():void {
				planetRewardAmount.animate(0,troons,troons * 1.5,function():void {
					planetRewardAmount.format.color = Style.COLOR_YELLOW;
					troonImg.alpha = 1;
				});
			});
			planetRewardAmount.alignRight();
			addChild(planetRewardAmount);
			planetRewardAmount.alpha = 0;
			TweenMax.to(planetRewardAmount,0.3,{
				"delay":delay,
				"alpha":1
			});
			yPos += 40;
			levelBonus = new TextBitmap(430,yPos,"Level bonus:",26);
			levelBonus.alignRight();
			levelBonus.format.color = Style.COLOR_GRAY_TEXT;
			addChild(levelBonus);
			levelBonus.alpha = 0;
			delay += increaseAnimationTime / 1000 - delayInc;
			TweenMax.to(levelBonus,0.3,{
				"delay":delay,
				"alpha":1,
				"onStart":function():void {
				}
			});
			troonImg = new Image(textureManager.getTextureGUIByTextureName("troon.png"));
			troonImg.x = planetRewardAmount.x + 20;
			troonImg.y = planetRewardAmount.y + 5;
			addChild(troonImg);
			troonImg.alpha = 0;
			levelBonusAmount = new TextBitmapNumberAnimation(planetReward.x + 100,levelBonus.y,"",26);
			increaseAnimationTime = troonsBonus * 1.5;
			TweenMax.delayedCall(delay,function():void {
				levelBonusAmount.animate(0,troonsBonus,troonsBonus * 1.5,function():void {
					levelBonusAmount.format.color = Style.COLOR_YELLOW;
					troonImg2.alpha = 1;
				});
			});
			levelBonusAmount.alignRight();
			addChild(levelBonusAmount);
			levelBonusAmount.alpha = 0;
			delay += delayInc;
			TweenMax.to(levelBonusAmount,0.3,{
				"delay":delay,
				"alpha":1
			});
			troonImg2 = new Image(textureManager.getTextureGUIByTextureName("troon.png"));
			troonImg2.x = levelBonusAmount.x + 20;
			troonImg2.y = levelBonusAmount.y + 5;
			addChild(troonImg2);
			troonImg2.alpha = 0;
			yPos += 40;
			delay += delayInc;
			planetTroonsPerMinute = new TextBitmap(430,yPos,"Troons / min:",26);
			planetTroonsPerMinute.alignRight();
			planetTroonsPerMinute.format.color = Style.COLOR_GRAY_TEXT;
			addChild(planetTroonsPerMinute);
			planetTroonsPerMinute.alpha = 0;
			TweenMax.to(planetTroonsPerMinute,0.3,{
				"delay":delay,
				"alpha":1
			});
			planetTroonsPerMinuteAmount = new TextBitmapNumberAnimation(planetTroonsPerMinute.x + 100,planetTroonsPerMinute.y,"",26);
			increaseAnimationTime = troonsPerMinuteValue * 150;
			TweenMax.delayedCall(delay,function():void {
				planetTroonsPerMinuteAmount.animate(0,troonsPerMinuteValue,troonsPerMinuteValue * 150,function():void {
					planetTroonsPerMinuteAmount.format.color = Style.COLOR_YELLOW;
					troonImg3.alpha = 1;
				});
			});
			planetTroonsPerMinuteAmount.alignRight();
			addChild(planetTroonsPerMinuteAmount);
			planetTroonsPerMinuteAmount.alpha = 0;
			troonImg3 = new Image(textureManager.getTextureGUIByTextureName("troon.png"));
			troonImg3.x = planetTroonsPerMinuteAmount.x + 20;
			troonImg3.y = planetTroonsPerMinuteAmount.y + 5;
			addChild(troonImg3);
			troonImg3.alpha = 0;
			delay += delayInc;
			TweenMax.to(planetTroonsPerMinuteAmount,0.3,{
				"delay":delay,
				"alpha":1
			});
			yPos += 100;
			delay += delayInc * 2 + increaseAnimationTime / 1000;
			ct = new ControlTime(time + timeBonus);
			ct.pivotX = ct.width / 2;
			ct.pivotY = ct.height / 2;
			ct.x = 380;
			ct.y = yPos;
			ct.scaleX = 0;
			ct.scaleY = 0;
			ct.alpha = 0;
			addChild(ct);
			TweenMax.to(ct,0.8,{
				"delay":delay,
				"alpha":1,
				"scaleX":1,
				"scaleY":1,
				"ease":Back.easeOut
			});
			yPos += 80;
			nextButton = new Button(function():void {
				sm.changeState(new ExploreState(g,b));
			},"Next","reward");
			nextButton.x = 350;
			nextButton.y = yPos;
			addChild(nextButton);
			nextButton.alpha = 0;
			delay += delayInc + 0.8;
			TweenMax.to(nextButton,0.3,{
				"delay":delay,
				"alpha":1
			});
			addPlanetData();
		}
		
		private function addPlanetData() : void {
			var _local2:Number = NaN;
			var _local1:TextBitmap = new TextBitmap(140,44,b.name,26);
			addChild(_local1);
			var _local3:TextBitmap = new TextBitmap(_local1.x,_local1.y + _local1.height,"Planet overview");
			_local3.format.color = 0x666666;
			addChild(_local3);
			if(b.texture != null) {
				_local2 = 50 / b.texture.width;
				planetGfx = new Image(b.texture);
				planetGfx.scaleX = _local2;
				planetGfx.scaleY = _local2;
				planetGfx.x = 80;
				planetGfx.y = 45;
				addChild(planetGfx);
				hasDrawnBody = true;
			}
		}
		
		override public function get type() : String {
			return "ControlZoneState";
		}
		
		override public function exit() : void {
			removeChild(areaBox,true);
			PixelHitArea.dispose();
			ToolTip.disposeType("skill");
			super.exit();
		}
	}
}

import core.hud.components.Style;
import core.hud.components.TextBitmap;
import starling.display.Sprite;

class ControlTime extends Sprite {
	public function ControlTime(time:int) {
		super();
		var _local3:TextBitmap = new TextBitmap(0,0,"Control time:",32);
		_local3.format.color = Style.COLOR_GRAY_TEXT;
		addChild(_local3);
		var _local2:TextBitmap = new TextBitmap(_local3.x + _local3.width + 20,0,time + " minutes",32);
		_local2.format.color = Style.COLOR_HIGHLIGHT;
		addChild(_local2);
	}
}
