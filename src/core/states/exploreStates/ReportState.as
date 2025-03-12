package core.states.exploreStates
{
	import com.greensock.TweenMax;
	import core.artifact.Artifact;
	import core.artifact.ArtifactBox;
	import core.artifact.ArtifactFactory;
	import core.hud.components.Button;
	import core.hud.components.CrewDetails;
	import core.hud.components.LootItem;
	import core.hud.components.Style;
	import core.hud.components.Text;
	import core.hud.components.TextBitmap;
	import core.hud.components.explore.ExploreArea;
	import core.player.CrewMember;
	import core.scene.Game;
	import core.solarSystem.Area;
	import core.states.DisplayState;
	import debug.Console;
	import generics.Util;
	import playerio.Message;
	import sound.SoundLocator;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	
	public class ReportState extends DisplayState
	{
		private var area:ExploreArea;
		
		private var loadText:TextBitmap;
		
		private var levelUpHeading:TextBitmap;
		
		private var firstStepContainer:Sprite;
		
		private var crewStepContainers:Vector.<Sprite>;
		
		private var rewardStepContainer:Sprite;
		
		private var nextButton:Button;
		
		private var rewardTweens:Vector.<TweenMax>;
		
		private var crewTweens:Vector.<Vector.<TweenMax>>;
		
		private var currentCrewIndex:int;
		
		private var crewMembers:Array;
		
		public function ReportState(param1:Game, param2:ExploreArea)
		{
			loadText = new TextBitmap();
			levelUpHeading = new TextBitmap();
			firstStepContainer = new Sprite();
			crewStepContainers = new Vector.<Sprite>();
			rewardStepContainer = new Sprite();
			rewardTweens = new Vector.<TweenMax>();
			crewTweens = new Vector.<Vector.<TweenMax>>();
			crewMembers = [];
			super(param1, ExploreState);
			this.area = param2;
		}
		
		override public function enter():void
		{
			super.enter();
			backButton.visible = false;
			loadText.text = "Loading explore report...";
			loadText.size = 28;
			loadText.x = 760 / 2;
			loadText.y = 600 / 2;
			loadText.center();
			addChild(loadText);
			g.rpc("getExploreReport", reportArrived, area.areaKey);
		}
		
		private function reportArrived(param1:Message):void
		{
			var _loc11_:int = 0;
			var _loc6_:String = null;
			var _loc16_:String = null;
			var _loc14_:Number = NaN;
			var _loc4_:LootItem = null;
			var _loc12_:String = null;
			var _loc10_:ArtifactBox = null;
			loadText.visible = false;
			area.updateState(true);
			var _loc15_:Text = new Text();
			_loc15_.size = 12;
			_loc15_.color = 6710886;
			_loc15_.x = 760 / 2;
			_loc15_.y = 200;
			_loc15_.center();
			var _loc2_:String = area.body.name + ", " + area.name + ", ";
			for each (var _loc3_:* in area.specialTypes)
			{
				_loc2_ += Area.SPECIALTYPEHTML[_loc3_] + " ";
			}
			_loc15_.htmlText = _loc2_;
			var _loc9_:TextBitmap = new TextBitmap();
			_loc9_.x = 760 / 2;
			_loc9_.size = 30;
			_loc9_.y = _loc15_.y + _loc15_.height + 20;
			if (area.success)
			{
				_loc9_.format.color = Style.COLOR_VALID;
				_loc9_.text = "SUCCESS!";
				_loc9_.center();
				TweenMax.fromTo(_loc9_, 1, {"scaleX": 2, "scaleY": 2, "rotation": 2}, {"scaleX": 1, "scaleY": 1, "rotation": 0});
				SoundLocator.getService().play("7zeIcPFb-UWzgtR_3nrZ8Q");
			}
			else
			{
				_loc9_.format.color = Style.COLOR_INVALID;
				_loc9_.text = "FAILED!";
				_loc9_.center();
				TweenMax.fromTo(_loc9_, 1, {"scaleX": 2, "scaleY": 2, "rotation": -2}, {"scaleX": 1, "scaleY": 1, "rotation": 0});
				SoundLocator.getService().play("14BaNTN3tEmfQKMGWfEE6w");
			}
			var _loc17_:TextBitmap = new TextBitmap();
			_loc17_.size = 18;
			_loc17_.text = Util.formatDecimal(area.failedValue * 100, 1).toString() + "% explored";
			_loc17_.x = 760 / 2;
			_loc17_.y = _loc9_.y + 50 + 20;
			_loc17_.center();
			nextButton = new Button(initiateCrewStep, "Next", "highlight");
			setNextButtonPosition();
			firstStepContainer.addChild(nextButton);
			firstStepContainer.addChild(_loc9_);
			firstStepContainer.addChild(_loc15_);
			firstStepContainer.addChild(_loc17_);
			addChild(firstStepContainer);
			var _loc5_:int = param1.getInt(0);
			var _loc7_:int = 0;
			var _loc8_:int = 0;
			_loc11_ = 1;
			while (_loc11_ < _loc5_)
			{
				_loc6_ = param1.getString(_loc11_);
				_loc16_ = param1.getString(_loc11_ + 1);
				_loc14_ = param1.getInt(_loc11_ + 2);
				g.myCargo.addItem(_loc6_, _loc16_, _loc14_);
				_loc4_ = new LootItem(_loc6_, _loc16_, _loc14_);
				_loc4_.x = 760 / 2 - _loc4_.width / 2;
				_loc4_.y = 310 + _loc8_ * (_loc4_.height + 5);
				rewardTweens.push(TweenMax.from(_loc4_, 1, {"alpha": 0, "paused": true}));
				rewardStepContainer.addChild(_loc4_);
				if (_loc14_ > 0)
				{
					_loc7_ += 1;
				}
				_loc11_ += 3;
				_loc8_++;
			}
			_loc5_ = param1.getInt(_loc11_);
			_loc7_ = 0;
			_loc11_ += 1;
			var _loc13_:* = _loc5_;
			var _loc18_:Text = new Text();
			_loc18_.size = 36;
			_loc18_.text = Area.getRewardAction(area.type);
			_loc18_.color = Area.COLORTYPE[area.type];
			_loc18_.x = 760 / 2;
			_loc18_.y = 105;
			_loc18_.center();
			rewardTweens.push(TweenMax.from(_loc18_, 1.4, {"alpha": 0, "scaleX": 4, "scaleY": 4, "paused": true}));
			rewardStepContainer.addChild(_loc18_);
			_loc7_;
			while (_loc7_ < 3)
			{
				if (_loc7_ < _loc5_)
				{
					_loc12_ = param1.getString(_loc11_);
					ArtifactFactory.createArtifact(_loc12_, g, g.me, createArtifactFunction(_loc13_, _loc7_, _loc12_));
					_loc11_++;
				}
				else
				{
					_loc10_ = new ArtifactBox(g, null);
					_loc10_.update();
					_loc10_.y = 200;
					_loc10_.x = 760 / 2 - 3 * (_loc10_.width + 15) / 2 + (_loc10_.width + 15) * _loc7_;
					rewardTweens.push(TweenMax.from(_loc10_, 1 + _loc7_, {"alpha": 0, "scaleX": 2, "scaleY": 2, "paused": true}));
					rewardStepContainer.addChild(_loc10_);
				}
				_loc7_++;
			}
			levelUp(param1, _loc11_);
		}
		
		private function createArtifactFunction(param1:int, param2:int, param3:String):Function
		{
			var artifactCount:int = param1;
			var i:int = param2;
			var id:String = param3;
			return function(param1:Artifact):void
			{
				if (param1 == null)
				{
					g.client.errorLog.writeError("Error #1009", "explore artifact is null: " + id, "", null);
					return;
				}
				var _loc2_:ArtifactBox = new ArtifactBox(g, param1);
				_loc2_.update();
				_loc2_.y = 200;
				_loc2_.x = 760 / 2 - 3 * (_loc2_.width + 15) / 2 + (_loc2_.width + 15) * i;
				rewardTweens.push(TweenMax.from(_loc2_, 1 + i, {"alpha": 0, "scaleX": 2, "scaleY": 2, "paused": true}));
				rewardStepContainer.addChild(_loc2_);
				g.me.artifacts.push(param1);
			};
		}
		
		private function setNextButtonPosition():void
		{
			nextButton.size = 13;
			nextButton.x = 760 - nextButton.width - 73;
			nextButton.y = 500;
		}
		
		private function initiateCrewStep(param1:TouchEvent):void
		{
			firstStepContainer.visible = false;
			nextCrewStep();
		}
		
		private function nextCrewStep(param1:int = 0):void
		{
			var tween:TweenMax;
			var i:int = param1;
			SoundLocator.getService().play("7zeIcPFb-UWzgtR_3nrZ8Q");
			currentCrewIndex = i;
			if (i > 0)
			{
				crewStepContainers[i - 1].visible = false;
			}
			if (i >= crewStepContainers.length)
			{
				initiateRewardStep();
				return;
			}
			for each (tween in crewTweens[i])
			{
				tween.play();
			}
			nextButton = new Button(null, "next");
			setNextButtonPosition();
			nextButton.callback = function(param1:TouchEvent):void
			{
				nextCrewStep(i + 1);
			};
			crewStepContainers[i].addChild(nextButton);
			addChild(crewStepContainers[i]);
		}
		
		private function initiateRewardStep():void
		{
			var tween:TweenMax;
			rewardStepContainer.visible = true;
			SoundLocator.getService().play("7zeIcPFb-UWzgtR_3nrZ8Q");
			nextButton = new Button(null, "Close Report");
			nextButton.size = 12;
			nextButton.y = 480;
			nextButton.callback = function(param1:TouchEvent):void
			{
				sm.changeState(new ExploreState(g, area.body));
			};
			g.tutorial.showArtifactFound(area);
			nextButton.x = 760 / 2 - nextButton.width / 2;
			rewardStepContainer.addChild(nextButton);
			for each (tween in rewardTweens)
			{
				tween.play();
			}
			addChild(rewardStepContainer);
		}
		
		override public function get type():String
		{
			return "ReportState";
		}
		
		private function placeCrewSkills(param1:Event):void
		{
			var _loc6_:int = 0;
			var _loc2_:DisplayObject = null;
			var _loc4_:Sprite = crewStepContainers[currentCrewIndex];
			_loc6_ = 0;
			while (_loc6_ < _loc4_.numChildren - 1)
			{
				_loc2_ = _loc4_.getChildAt(_loc6_);
				_loc2_.visible = false;
				_loc6_++;
			}
			nextButton.visible = true;
			var _loc5_:CrewMember = crewMembers[currentCrewIndex];
			var _loc3_:CrewDetails = new CrewDetails(g, _loc5_, null, false, 2);
			_loc3_.x = 200;
			_loc3_.y = 80;
			_loc4_.addChild(_loc3_);
		}
		
		private function levelUp(param1:Message, param2:int):void
		{
			var _loc9_:Array = null;
			var _loc3_:* = undefined;
			var _loc18_:Sprite = null;
			var _loc19_:String = null;
			var _loc10_:CrewMember = null;
			var _loc7_:int = 0;
			var _loc11_:String = null;
			var _loc6_:Number = NaN;
			var _loc4_:Number = NaN;
			var _loc17_:Number = NaN;
			var _loc15_:Image = null;
			var _loc5_:TextBitmap = null;
			var _loc14_:Text = null;
			var _loc12_:Button = null;
			var _loc16_:Text = null;
			var _loc8_:int = 0;
			var _loc13_:Text = null;
			param2;
			while (param2 < param1.length)
			{
				_loc9_ = [];
				_loc3_ = new Vector.<TweenMax>();
				crewTweens.push(_loc3_);
				_loc18_ = new Sprite();
				_loc19_ = param1.getString(param2);
				_loc10_ = g.me.getCrewMember(_loc19_);
				_loc10_.missions++;
				crewMembers.push(_loc10_);
				if (_loc10_ == null)
				{
					Console.write("Error: CrewMember is null!");
					return;
				}
				_loc7_ = param1.getInt(param2 + 1);
				_loc11_ = Area.getSkillTypeHtml(_loc7_);
				_loc6_ = param1.getNumber(param2 + 2);
				_loc4_ = param1.getNumber(param2 + 3);
				_loc17_ = param1.getNumber(param2 + 4);
				_loc10_.skillPoints += _loc6_;
				_loc10_.injuryEnd = _loc17_;
				_loc10_.injuryStart = _loc4_;
				_loc10_.fullLocation = "";
				_loc10_.body = "";
				_loc10_.area = "";
				_loc10_.solarSystem = "";
				_loc15_ = new Image(textureManager.getTextureGUIByKey(_loc10_.imageKey));
				_loc15_.x = 760 / 2 - _loc15_.width / 2;
				_loc15_.y = 100;
				_loc3_.push(TweenMax.from(_loc15_, 1, {"alpha": 0, "paused": true}));
				_loc18_.addChild(_loc15_);
				_loc5_ = new TextBitmap(760 / 2, _loc15_.y + _loc15_.height + 20);
				_loc5_.size = 18;
				_loc5_.text = _loc10_.name;
				_loc5_.center();
				_loc3_.push(TweenMax.from(_loc5_, 1, {"alpha": 0, "paused": true}));
				_loc18_.addChild(_loc5_);
				_loc14_ = new Text(100, _loc5_.y + _loc5_.height + 20);
				_loc14_.size = 20;
				_loc14_.text = "New skill points: " + _loc6_;
				_loc14_.color = 16777215;
				_loc3_.push(TweenMax.from(_loc14_, 0.5, {"scaleX": 1.2, "scaleY": 1.2, "paused": true}));
				_loc9_.push(_loc14_);
				_loc12_ = new Button(placeCrewSkills, "Place skill points", "reward");
				_loc12_.x = 760 / 2 - _loc12_.width / 2;
				_loc12_.y = 500;
				_loc18_.addChild(_loc12_);
				if (_loc10_.injuryTime > 0)
				{
					_loc16_ = new Text(550, _loc5_.y + _loc5_.height + 20);
					_loc16_.size = 18;
					_loc16_.color = Style.COLOR_INJURED;
					_loc16_.text = "Injured " + Util.formatDecimal(_loc10_.injuryTime / 1000 / 60, 1) + " min ";
					_loc9_.push(_loc16_);
					_loc3_.push(TweenMax.fromTo(_loc16_, 1, {"scaleX": 2, "scaleY": 2, "rotation": -2}, {"paused": true, "scaleX": 1, "scaleY": 1, "rotation": 0}));
				}
				_loc8_ = 0;
				while (_loc8_ < _loc9_.length)
				{
					_loc13_ = _loc9_[_loc8_];
					_loc13_.x = 760 / 2;
					_loc13_.y = _loc5_.y + _loc5_.height + 20 + _loc8_ * (_loc13_.size + 10);
					_loc13_.center();
					_loc18_.addChild(_loc13_);
					_loc8_++;
				}
				crewStepContainers.push(_loc18_);
				param2 += 5;
			}
		}
	}
}
