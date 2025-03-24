package core.states.exploreStates {
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
	
	public class ReportState extends DisplayState {
		private var area:ExploreArea;
		
		private var loadText:TextBitmap = new TextBitmap();
		
		private var levelUpHeading:TextBitmap = new TextBitmap();
		
		private var firstStepContainer:Sprite = new Sprite();
		
		private var crewStepContainers:Vector.<Sprite> = new Vector.<Sprite>();
		
		private var rewardStepContainer:Sprite = new Sprite();
		
		private var nextButton:Button;
		
		private var rewardTweens:Vector.<TweenMax> = new Vector.<TweenMax>();
		
		private var crewTweens:Vector.<Vector.<TweenMax>> = new Vector.<Vector.<TweenMax>>();
		
		private var currentCrewIndex:int;
		
		private var crewMembers:Array = [];
		
		public function ReportState(g:Game, area:ExploreArea) {
			super(g,ExploreState);
			this.area = area;
		}
		
		override public function enter() : void {
			super.enter();
			backButton.visible = false;
			loadText.text = "Loading explore report...";
			loadText.size = 28;
			loadText.x = 760 / 2;
			loadText.y = 10 * 60 / 2;
			loadText.center();
			addChild(loadText);
			g.rpc("getExploreReport",reportArrived,area.areaKey);
		}
		
		private function reportArrived(m:Message) : void {
			var _local6:int = 0;
			var _local18:String = null;
			var _local3:String = null;
			var _local4:Number = NaN;
			var _local15:LootItem = null;
			var _local16:String = null;
			var _local12:ArtifactBox = null;
			loadText.visible = false;
			area.updateState(true);
			var _local5:Text = new Text();
			_local5.size = 12;
			_local5.color = 0x666666;
			_local5.x = 760 / 2;
			_local5.y = 200;
			_local5.center();
			var _local2:String = area.body.name + ", " + area.name + ", ";
			for each(var _local13 in area.specialTypes) {
				_local2 += Area.SPECIALTYPEHTML[_local13] + " ";
			}
			_local5.htmlText = _local2;
			var _local14:TextBitmap = new TextBitmap();
			_local14.x = 760 / 2;
			_local14.size = 30;
			_local14.y = _local5.y + _local5.height + 20;
			if(area.success) {
				_local14.format.color = Style.COLOR_VALID;
				_local14.text = "SUCCESS!";
				_local14.center();
				TweenMax.fromTo(_local14,1,{
					"scaleX":2,
					"scaleY":2,
					"rotation":2
				},{
					"scaleX":1,
					"scaleY":1,
					"rotation":0
				});
				SoundLocator.getService().play("7zeIcPFb-UWzgtR_3nrZ8Q");
			} else {
				_local14.format.color = Style.COLOR_INVALID;
				_local14.text = "FAILED!";
				_local14.center();
				TweenMax.fromTo(_local14,1,{
					"scaleX":2,
					"scaleY":2,
					"rotation":-2
				},{
					"scaleX":1,
					"scaleY":1,
					"rotation":0
				});
				SoundLocator.getService().play("14BaNTN3tEmfQKMGWfEE6w");
			}
			var _local7:TextBitmap = new TextBitmap();
			_local7.size = 18;
			_local7.text = Util.formatDecimal(area.failedValue * 100,1).toString() + "% explored";
			_local7.x = 760 / 2;
			_local7.y = _local14.y + 50 + 20;
			_local7.center();
			nextButton = new Button(initiateCrewStep,"Next","highlight");
			setNextButtonPosition();
			firstStepContainer.addChild(nextButton);
			firstStepContainer.addChild(_local14);
			firstStepContainer.addChild(_local5);
			firstStepContainer.addChild(_local7);
			addChild(firstStepContainer);
			var _local11:int = m.getInt(0);
			var _local8:int = 0;
			var _local10:int = 0;
			_local6 = 1;
			while(_local6 < _local11) {
				_local18 = m.getString(_local6);
				_local3 = m.getString(_local6 + 1);
				_local4 = m.getInt(_local6 + 2);
				g.myCargo.addItem(_local18,_local3,_local4);
				_local15 = new LootItem(_local18,_local3,_local4);
				_local15.x = 760 / 2 - _local15.width / 2;
				_local15.y = 310 + _local10 * (_local15.height + 5);
				rewardTweens.push(TweenMax.from(_local15,1,{
					"alpha":0,
					"paused":true
				}));
				rewardStepContainer.addChild(_local15);
				if(_local4 > 0) {
					_local8 += 1;
				}
				_local6 += 3;
				_local10++;
			}
			_local11 = m.getInt(_local6);
			_local8 = 0;
			_local6 += 1;
			var _local9:* = _local11;
			var _local17:Text = new Text();
			_local17.size = 36;
			_local17.text = Area.getRewardAction(area.type);
			_local17.color = Area.COLORTYPE[area.type];
			_local17.x = 760 / 2;
			_local17.y = 105;
			_local17.center();
			rewardTweens.push(TweenMax.from(_local17,1.4,{
				"alpha":0,
				"scaleX":4,
				"scaleY":4,
				"paused":true
			}));
			rewardStepContainer.addChild(_local17);
			_local8;
			while(_local8 < 3) {
				if(_local8 < _local11) {
					_local16 = m.getString(_local6);
					ArtifactFactory.createArtifact(_local16,g,g.me,createArtifactFunction(_local9,_local8,_local16));
					_local6++;
				} else {
					_local12 = new ArtifactBox(g,null);
					_local12.update();
					_local12.y = 200;
					_local12.x = 760 / 2 - 3 * (_local12.width + 15) / 2 + (_local12.width + 15) * _local8;
					rewardTweens.push(TweenMax.from(_local12,1 + _local8,{
						"alpha":0,
						"scaleX":2,
						"scaleY":2,
						"paused":true
					}));
					rewardStepContainer.addChild(_local12);
				}
				_local8++;
			}
			levelUp(m,_local6);
		}
		
		private function createArtifactFunction(artifactCount:int, i:int, id:String) : Function {
			return function(param1:Artifact):void {
				if(param1 == null) {
					g.client.errorLog.writeError("Error #1009","explore artifact is null: " + id,"",null);
					return;
				}
				var _local2:ArtifactBox = new ArtifactBox(g,param1);
				_local2.update();
				_local2.y = 200;
				_local2.x = 760 / 2 - 3 * (_local2.width + 15) / 2 + (_local2.width + 15) * i;
				rewardTweens.push(TweenMax.from(_local2,1 + i,{
					"alpha":0,
					"scaleX":2,
					"scaleY":2,
					"paused":true
				}));
				rewardStepContainer.addChild(_local2);
				g.me.artifacts.push(param1);
			};
		}
		
		private function setNextButtonPosition() : void {
			nextButton.size = 13;
			nextButton.x = 760 - nextButton.width - 73;
			nextButton.y = 500;
		}
		
		private function initiateCrewStep(e:TouchEvent) : void {
			firstStepContainer.visible = false;
			nextCrewStep();
		}
		
		private function nextCrewStep(i:int = 0) : void {
			var tween:TweenMax;
			SoundLocator.getService().play("7zeIcPFb-UWzgtR_3nrZ8Q");
			currentCrewIndex = i;
			if(i > 0) {
				crewStepContainers[i - 1].visible = false;
			}
			if(i >= crewStepContainers.length) {
				initiateRewardStep();
				return;
			}
			for each(tween in crewTweens[i]) {
				tween.play();
			}
			nextButton = new Button(null,"next");
			setNextButtonPosition();
			nextButton.callback = function(param1:TouchEvent):void {
				nextCrewStep(i + 1);
			};
			crewStepContainers[i].addChild(nextButton);
			addChild(crewStepContainers[i]);
		}
		
		private function initiateRewardStep() : void {
			var tween:TweenMax;
			rewardStepContainer.visible = true;
			SoundLocator.getService().play("7zeIcPFb-UWzgtR_3nrZ8Q");
			nextButton = new Button(null,"Close Report");
			nextButton.size = 12;
			nextButton.y = 8 * 60;
			nextButton.callback = function(param1:TouchEvent):void {
				sm.changeState(new ExploreState(g,area.body));
			};
			g.tutorial.showArtifactFound(area);
			nextButton.x = 760 / 2 - nextButton.width / 2;
			rewardStepContainer.addChild(nextButton);
			for each(tween in rewardTweens) {
				tween.play();
			}
			addChild(rewardStepContainer);
		}
		
		override public function get type() : String {
			return "ReportState";
		}
		
		private function placeCrewSkills(e:Event) : void {
			var _local6:int = 0;
			var _local2:DisplayObject = null;
			var _local4:Sprite = crewStepContainers[currentCrewIndex];
			_local6 = 0;
			while(_local6 < _local4.numChildren - 1) {
				_local2 = _local4.getChildAt(_local6);
				_local2.visible = false;
				_local6++;
			}
			nextButton.visible = true;
			var _local5:CrewMember = crewMembers[currentCrewIndex];
			var _local3:CrewDetails = new CrewDetails(g,_local5,null,false,2);
			_local3.x = 200;
			_local3.y = 80;
			_local4.addChild(_local3);
		}
		
		private function levelUp(m:Message, i:int) : void {
			var _local3:Array = null;
			var _local11:* = undefined;
			var _local15:Sprite = null;
			var _local19:String = null;
			var _local16:CrewMember = null;
			var _local13:int = 0;
			var _local12:String = null;
			var _local4:Number = NaN;
			var _local5:Number = NaN;
			var _local6:Number = NaN;
			var _local7:Image = null;
			var _local8:TextBitmap = null;
			var _local10:Text = null;
			var _local17:Button = null;
			var _local18:Text = null;
			var _local9:int = 0;
			var _local14:Text = null;
			i;
			while(i < m.length) {
				_local3 = [];
				_local11 = new Vector.<TweenMax>();
				crewTweens.push(_local11);
				_local15 = new Sprite();
				_local19 = m.getString(i);
				_local16 = g.me.getCrewMember(_local19);
				_local16.missions++;
				crewMembers.push(_local16);
				if(_local16 == null) {
					Console.write("Error: CrewMember is null!");
					return;
				}
				_local13 = m.getInt(i + 1);
				_local12 = Area.getSkillTypeHtml(_local13);
				_local4 = m.getNumber(i + 2);
				_local5 = m.getNumber(i + 3);
				_local6 = m.getNumber(i + 4);
				_local16.skillPoints += _local4;
				_local16.injuryEnd = _local6;
				_local16.injuryStart = _local5;
				_local16.fullLocation = "";
				_local16.body = "";
				_local16.area = "";
				_local16.solarSystem = "";
				_local7 = new Image(textureManager.getTextureGUIByKey(_local16.imageKey));
				_local7.x = 760 / 2 - _local7.width / 2;
				_local7.y = 100;
				_local11.push(TweenMax.from(_local7,1,{
					"alpha":0,
					"paused":true
				}));
				_local15.addChild(_local7);
				_local8 = new TextBitmap(760 / 2,_local7.y + _local7.height + 20);
				_local8.size = 18;
				_local8.text = _local16.name;
				_local8.center();
				_local11.push(TweenMax.from(_local8,1,{
					"alpha":0,
					"paused":true
				}));
				_local15.addChild(_local8);
				_local10 = new Text(100,_local8.y + _local8.height + 20);
				_local10.size = 20;
				_local10.text = "New skill points: " + _local4;
				_local10.color = 0xffffff;
				_local11.push(TweenMax.from(_local10,0.5,{
					"scaleX":1.2,
					"scaleY":1.2,
					"paused":true
				}));
				_local3.push(_local10);
				_local17 = new Button(placeCrewSkills,"Place skill points","reward");
				_local17.x = 760 / 2 - _local17.width / 2;
				_local17.y = 500;
				_local15.addChild(_local17);
				if(_local16.injuryTime > 0) {
					_local18 = new Text(550,_local8.y + _local8.height + 20);
					_local18.size = 18;
					_local18.color = Style.COLOR_INJURED;
					_local18.text = "Injured " + Util.formatDecimal(_local16.injuryTime / 1000 / (60),1) + " min ";
					_local3.push(_local18);
					_local11.push(TweenMax.fromTo(_local18,1,{
						"scaleX":2,
						"scaleY":2,
						"rotation":-2
					},{
						"paused":true,
						"scaleX":1,
						"scaleY":1,
						"rotation":0
					}));
				}
				_local9 = 0;
				while(_local9 < _local3.length) {
					_local14 = _local3[_local9];
					_local14.x = 760 / 2;
					_local14.y = _local8.y + _local8.height + 20 + _local9 * (_local14.size + 10);
					_local14.center();
					_local15.addChild(_local14);
					_local9++;
				}
				crewStepContainers.push(_local15);
				i += 5;
			}
		}
	}
}

