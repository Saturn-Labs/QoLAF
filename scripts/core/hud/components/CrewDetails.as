package core.hud.components {
	import com.greensock.TweenMax;
	import com.greensock.easing.Circ;
	import com.greensock.easing.Sine;
	import core.credits.CreditManager;
	import core.hud.components.dialogs.CreditBuyBox;
	import core.hud.components.dialogs.PopupConfirmMessage;
	import core.player.CrewMember;
	import core.scene.Game;
	import core.solarSystem.Area;
	import facebook.Action;
	import flash.utils.Dictionary;
	import generics.Localize;
	import generics.Util;
	import playerio.Message;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class CrewDetails extends Sprite {
		private static const HEIGHT:int = 58;
		
		private static const WIDTH:int = 52;
		
		private static const textX1:int = 60;
		
		private static const textX2:int = 175;
		
		private static const textY1:int = 7;
		
		private static const textY2:int = 30;
		
		public static const MODE_SHIP:int = 0;
		
		public static const MODE_CANTINA:int = 1;
		
		public static const MODE_REPORT:int = 2;
		
		public static const IMAGES_SPECIALS:Vector.<String> = Vector.<String>(["spec_cold.png","spec_heat.png","spec_radiation.png","spec_first_contact.png","spec_trade.png","spec_collaboration.png","spec_kinetic.png","spec_energy.png","spec_bio_weapons.png"]);
		
		public static const IMAGES_SKILLS:Vector.<String> = Vector.<String>(["skill_environment.png","skill_diplomacy.png","skill_combat.png"]);
		
		private var exploreTimer:HudTimer;
		
		private var img:Image;
		
		public var crewMember:CrewMember;
		
		private var injuryTimer:HudTimer;
		
		private var injuryStatus:Text;
		
		private var g:Game;
		
		private var bgColor:uint = 1717572;
		
		private var requestReloadCallback:Function;
		
		public var requestRemovalCallback:Function;
		
		private var raiseButtons:Array;
		
		private var dismissButton:Button;
		
		private var trainButton:Button;
		
		public var mode:int;
		
		private var statusTween:TweenMax;
		
		private var skillPointsText:Text;
		
		private var skillPointsValue:Text;
		
		private var skillPointsValueTween1:TweenMax;
		
		private var skillPointsValueTween2:TweenMax;
		
		private var nextY:int = 0;
		
		private var specialSkillsHolder:Sprite;
		
		private var specialSkills:Dictionary;
		
		private var acceptButton:Button;
		
		private var confirmBuyWithFlux:CreditBuyBox;
		
		private var confirmTraining:PopupConfirmMessage;
		
		private var confirmDismiss:PopupConfirmMessage;
		
		public function CrewDetails(g:Game, crewMember:CrewMember, requestReloadCallback:Function = null, showTraining:Boolean = true, mode:int = 0) {
			var _local7:Text = null;
			raiseButtons = [];
			specialSkillsHolder = new Sprite();
			specialSkills = new Dictionary();
			this.crewMember = crewMember;
			this.g = g;
			this.requestReloadCallback = requestReloadCallback;
			this.mode = mode;
			super();
			if(crewMember == null) {
				_local7 = new Text(15,72,true);
				_local7.text = Localize.t("You can unlock another crew slot in the ship overview.");
				_local7.size = 14;
				_local7.width = 310;
				addChild(_local7);
				return;
			}
			var _local11:ITextureManager = TextureLocator.getService();
			img = new Image(_local11.getTextureGUIByKey(crewMember.imageKey));
			img.x = 4 * 60;
			addChild(img);
			var _local10:Text = new Text(0,0);
			_local10.text = crewMember.name;
			_local10.color = 16623682;
			_local10.size = 26;
			var _local9:Text = new Text(0,35);
			_local9.text = CrewMember.getRank(crewMember.rank);
			_local9.color = 16689475;
			addChild(_local9);
			var _local8:TextBitmap = new TextBitmap(0,_local9.y + 15,crewMember.missions + " " + Localize.t("missions"));
			_local8.format.color = 0x686868;
			addChild(_local8);
			addChild(_local10);
			addChild(img);
			addSkills();
			addDismiss();
			addBuy();
			if(showTraining) {
				addTrain();
			}
			addSkillPoints();
			addCurrentStatus();
			if(crewMember.skillPoints < 1) {
				for each(var _local6 in raiseButtons) {
					_local6.visible = false;
				}
			}
			addEventListener("removedFromStage",clean);
		}
		
		public function get key() : String {
			return crewMember.key;
		}
		
		public function getLevel(i:int) : int {
			return crewMember.skills[i];
		}
		
		private function addCurrentStatus() : void {
			if(crewMember.isIdle()) {
				return;
			}
			var _local1:Sprite = new Sprite();
			var _local2:Text = new Text();
			if(crewMember.isDeployed) {
				if(crewMember.isWaitingForPickup) {
					_local2.text = Localize.t("Awaiting pickup");
					_local2.size = 16;
				} else {
					_local2.text = Localize.t("Exploring [location]").replace("[location]",crewMember.getCompactFullLocation());
				}
			} else if(crewMember.isTrainingComplete && crewMember.isTraining) {
				_local2.text = Localize.t("Training complete");
				_local2.size = 16;
				addClaimTraining(_local1);
			} else if(crewMember.isTraining) {
				_local2.size = 16;
				_local2.text = Localize.t("Training...");
			} else if(crewMember.isInjured) {
				_local2.size = 16;
				_local2.color = Style.COLOR_INJURED;
				_local2.text = Localize.t("Injured...");
			}
			_local1.addChild(_local2);
			_local1.y = 455;
			statusTween = TweenMax.to(_local2,1,{
				"alpha":0.5,
				"yoyo":true,
				"repeat":-1
			});
			addChild(_local1);
		}
		
		private function addClaimTraining(s:Sprite) : void {
			var _local2:Button = new Button(requestCompleteTraining,Localize.t("Collect"),"reward");
			_local2.x = 230;
			_local2.y = -2;
			s.addChild(_local2);
		}
		
		private function requestCompleteTraining(e:TouchEvent) : void {
			g.rpc("completeTraining",function(param1:Message):void {
				var _local2:Boolean = param1.getBoolean(0);
				if(!_local2) {
					g.showErrorDialog(param1.getString(1));
					return;
				}
				var _local3:int = param1.getInt(1);
				var _local4:int = _local3 - crewMember.skillPoints;
				crewMember.completeTraining(_local3);
				g.showMessageDialog(Localize.t("[name] got [diff] new skill points!").replace("[name]",crewMember.name).replace("[diff]",_local4),requestReload);
			},crewMember.key);
		}
		
		private function requestReload() : void {
			if(requestReloadCallback == null) {
				return;
			}
			requestReloadCallback();
		}
		
		private function addSkillPoints() : void {
			skillPointsText = new Text(0,92);
			skillPointsText.size = 16;
			skillPointsText.text = Localize.t("Skill points") + ":";
			skillPointsText.color = 0xffffff;
			addChild(skillPointsText);
			updateSkillPoints();
		}
		
		private function updateSkillPoints() : void {
			var rb:ButtonHud;
			if(crewMember.skillPoints < 1) {
				removeChild(skillPointsText);
				if(skillPointsValue) {
					removeChild(skillPointsValue);
				}
				for each(rb in raiseButtons) {
					TweenMax.to(rb,0.3,{
						"alpha":0,
						"ease":Circ.easeOut
					});
				}
				return;
			}
			if(!skillPointsValue) {
				skillPointsValue = new Text(0,skillPointsText.y + 12);
				addChild(skillPointsValue);
			}
			skillPointsValue.size = 26;
			skillPointsValue.alpha = 0;
			skillPointsValue.text = "" + crewMember.skillPoints;
			skillPointsValue.centerPivot();
			skillPointsValue.x = skillPointsText.width + skillPointsValue.width / 2 + 7;
			skillPointsValue.color = 3205134;
			skillPointsValue.scaleX = 5;
			skillPointsValue.scaleY = 5;
			if(skillPointsValueTween1) {
				skillPointsValueTween1.kill();
				skillPointsValueTween2.kill();
			}
			TweenMax.to(skillPointsValue,0.5,{
				"scaleX":1,
				"scaleY":1,
				"alpha":1,
				"ease":Circ.easeOut,
				"onComplete":function():void {
					skillPointsValueTween1 = TweenMax.to(skillPointsValue,0.6,{
						"yoyo":true,
						"scaleX":1.05,
						"repeat":-1,
						"alpha":0.8,
						"ease":Sine.easeInOut
					});
					skillPointsValueTween2 = TweenMax.to(skillPointsValue,0.6,{
						"yoyo":true,
						"scaleY":1.05,
						"delay":0.3,
						"repeat":-1,
						"ease":Sine.easeInOut
					});
				}
			});
		}
		
		private function addText(xPos:int, yPos:int, text:String, color:uint) : Text {
			var _local5:Text = new Text(xPos,yPos);
			_local5.size = 11;
			_local5.font = "Verdana";
			_local5.text = text;
			_local5.color = color;
			addChild(_local5);
			return _local5;
		}
		
		private function addSkills() : void {
			nextY = 170;
			addSkill("Survival");
			addSkill("Diplomacy");
			addSkill("Combat");
			addSpecialSkills();
		}
		
		private function addSpecialSkills() : void {
			var _local2:Sprite = null;
			var _local3:int = 0;
			if(specialSkillsHolder.numChildren > 0) {
				removeChild(specialSkillsHolder,true);
			}
			specialSkillsHolder.y = 5 * 60;
			var _local1:Text = new Text(0,0);
			_local1.text = Localize.t("Special skills") + ":";
			_local1.color = 16689475;
			specialSkillsHolder.addChild(_local1);
			nextY = 25;
			_local3 = 0;
			while(_local3 < 9) {
				_local2 = addOrUpdateSpecialSkill(_local3);
				if(_local3 == 5) {
					nextY -= 125;
				}
				_local2.y = nextY;
				nextY += 25;
				if(_local3 > 4) {
					_local2.x = 3 * 60;
				}
				_local3++;
			}
			addChild(specialSkillsHolder);
			nextY += specialSkillsHolder.height;
		}
		
		private function addOrUpdateSpecialSkill(i:int, value:Number = -1) : Sprite {
			var oldSkills:Sprite;
			var unlocked:Boolean;
			var known:Boolean;
			var barWidth:int;
			var bar:Quad;
			var barXPos:int;
			var raiseButton:ButtonHud;
			var img:Image;
			var t:Text;
			var s:Sprite = new Sprite();
			var oldBarWidth:int = 0;
			if(specialSkills[i] != null) {
				oldSkills = specialSkills[i];
				s.x = oldSkills.x;
				s.y = oldSkills.y;
				oldBarWidth = oldSkills.getChildAt(0).width;
				oldSkills.visible = false;
				oldSkills.dispose();
				oldSkills = null;
			}
			if(value == -1) {
				value = Number(crewMember.specials[i]);
			}
			unlocked = value >= 1;
			known = isSpecialVisible(i) || unlocked;
			barWidth = 105;
			barXPos = 17;
			if(known && !unlocked && value > 0) {
				bar = new Quad(barWidth * value,17,3205134);
				bar.x = barXPos;
				bar.y = 2;
				TweenMax.to(bar,0.3,{"alpha":0.5});
				s.addChild(bar);
			}
			if(known && !unlocked && crewMember.isIdleOrInjured()) {
				raiseButton = new ButtonHud(function():void {
					raiseSpecialSkill(i);
				},"button_pay.png");
				raiseButtons.push(raiseButton);
				raiseButton.x = barXPos + barWidth + 5;
				raiseButton.y = 2;
				s.addChild(raiseButton);
			}
			img = getSpecialIcon(i,!unlocked);
			img.x = 0;
			img.y = 3;
			s.addChild(img);
			t = new Text(18,3);
			t.font = "Verdana";
			t.text = Area.SPECIALTYPE[i];
			t.color = 0xffffff;
			s.addChild(t);
			if(!known) {
				t.text = Localize.t("Unknown");
				t.color = 0xaaaaaa;
				addSpecialUnlockHint(t,s,Area.SPECIALTYPE[i]);
			} else if(unlocked) {
				t.color = 3205134;
			}
			specialSkills[i] = s;
			specialSkillsHolder.addChild(s);
			return s;
		}
		
		private function addSpecialUnlockHint(text:Text, s:Sprite, special:String) : void {
			if(special == "Cold") {
				text.text = Localize.t("Locked (+ Survival)");
				new ToolTip(g,s,Localize.t("Requires level 20 Survival skill."),null,"crewSkill");
			}
			if(special == "Heat") {
				text.text = Localize.t("Locked (+ Cold)");
				new ToolTip(g,s,Localize.t("Requires Cold specialty skill."),null,"crewSkill");
			}
			if(special == "Radiation") {
				text.text = Localize.t("Locked (+ Heat)");
				new ToolTip(g,s,Localize.t("Requires Heat specialty skill."),null,"crewSkill");
			}
			if(special == "First Contact") {
				text.text = Localize.t("Locked (+ Diplomacy)");
				new ToolTip(g,s,Localize.t("Requires level 20 Diplomacy skill."),null,"crewSkill");
			}
			if(special == "Trade") {
				text.text = Localize.t("Locked (+ First Contact)");
				new ToolTip(g,s,Localize.t("Requires First Contact specialty skill."),null,"crewSkill");
			}
			if(special == "Collaboration") {
				text.text = Localize.t("Locked (+ Trade)");
				new ToolTip(g,s,Localize.t("Requires Trade specialty skill."),null,"crewSkill");
			}
			if(special == "Kinetic Weapons") {
				text.text = Localize.t("Locked (+ Combat)");
				new ToolTip(g,s,Localize.t("Requires level 20 Combat skill."),null,"crewSkill");
			}
			if(special == "Energy Weapons") {
				text.text = Localize.t("Locked (+ Kinetic Weapons)");
				new ToolTip(g,s,Localize.t("Requires Kinetic Weapons specialty skill."),null,"crewSkill");
			}
			if(special == "Bio Weapons") {
				text.text = Localize.t("Locked (+ Energy Weapons)");
				new ToolTip(g,s,Localize.t("Requires Energy Weapons specialty skill."),null,"crewSkill");
			}
		}
		
		private function isSpecialVisible(i:int) : Boolean {
			var _local3:String = Area.SPECIALTYPE[i];
			var _local4:int = crewMember.getSkillValueByName("Survival");
			var _local2:int = crewMember.getSkillValueByName("Diplomacy");
			var _local5:int = crewMember.getSkillValueByName("Combat");
			if(_local3 == "Cold" && _local4 >= 20) {
				return true;
			}
			if(_local3 == "Heat" && crewMember.hasUnlockedSpecialSkill("Cold")) {
				return true;
			}
			if(_local3 == "Radiation" && crewMember.hasUnlockedSpecialSkill("Heat")) {
				return true;
			}
			if(_local3 == "First Contact" && _local2 >= 20) {
				return true;
			}
			if(_local3 == "Trade" && crewMember.hasUnlockedSpecialSkill("First Contact")) {
				return true;
			}
			if(_local3 == "Collaboration" && crewMember.hasUnlockedSpecialSkill("Trade")) {
				return true;
			}
			if(_local3 == "Kinetic Weapons" && _local5 >= 20) {
				return true;
			}
			if(_local3 == "Energy Weapons" && crewMember.hasUnlockedSpecialSkill("Kinetic Weapons")) {
				return true;
			}
			if(_local3 == "Bio Weapons" && crewMember.hasUnlockedSpecialSkill("Energy Weapons")) {
				return true;
			}
			return false;
		}
		
		private function addSkill(name:String) : void {
			var skillImg:String;
			var skillValue:int;
			var t:Text;
			var t2:Text;
			var textureManager:ITextureManager;
			var img:Image;
			var s:Sprite;
			var raiseButton:ButtonHud;
			if(name == "Survival") {
				skillImg = "skill_environment_large.png";
			} else if(name == "Diplomacy") {
				skillImg = "skill_diplomacy_large.png";
			} else {
				skillImg = "skill_combat_large.png";
			}
			skillValue = crewMember.getSkillValueByName(name);
			t = new Text(35,nextY - 4);
			t.size = 14;
			t.text = Localize.t(name);
			t.color = 0x4a4a4a;
			addChild(t);
			t2 = new Text(330,nextY - 20);
			t2.text = "" + skillValue;
			t2.size = 38;
			t2.alignRight();
			t2.color = getSkillColor(skillValue);
			addChild(t2);
			textureManager = TextureLocator.getService();
			img = new Image(textureManager.getTextureGUIByTextureName(skillImg));
			img.y = nextY - 7;
			img.x = 1;
			s = new Sprite();
			s.addChild(img);
			new ToolTip(g,s,name,null,"crewSkill");
			addChild(s);
			if(crewMember.isIdleOrInjured()) {
				raiseButton = new ButtonHud(function():void {
					raiseSkill(name,t2);
				},"button_pay.png");
				raiseButtons.push(raiseButton);
				raiseButton.x = t2.x + 10;
				raiseButton.y = t2.y + 18;
				addChild(raiseButton);
			}
			nextY += 45;
		}
		
		private function raiseSpecialSkill(type:int) : void {
			if(crewMember.skillPoints < 1) {
				return;
			}
			crewMember.skillPoints--;
			updateSkillPoints();
			g.rpc("raiseCrewSpecialty",function(param1:Message):void {
				var _local2:int = param1.getInt(0);
				var _local3:Number = param1.getNumber(1);
				crewMember.specials[_local2] = _local3;
				addOrUpdateSpecialSkill(_local2,_local3);
				if(_local3 >= 1) {
					playSkillUnlockAnimation(_local2,"aquired!");
				}
				updateSkillPoints();
			},crewMember.key,type);
		}
		
		private function playSkillUnlockAnimation(type:int, text:String, isAccuired:Boolean = true) : void {
			var soundManager:ISound = SoundLocator.getService();
			soundManager.preCacheSound("7zeIcPFb-UWzgtR_3nrZ8Q",function():void {
				var t:Text = new Text();
				t.size = 26;
				t.alpha = 0;
				t.scaleX = 20;
				t.scaleY = 20;
				if(isAccuired) {
					t.color = 0xff00;
				} else {
					t.color = 0xffffff;
				}
				t.glow = true;
				t.text = Localize.t(Area.SPECIALTYPE[type]) + " " + Localize.t(text);
				t.x = width / 2;
				if(mode == 0) {
					t.x -= 150;
				}
				t.y = 230;
				t.centerPivot();
				addChild(t);
				TweenMax.to(t,0.5,{
					"alpha":1,
					"scaleX":1,
					"scaleY":1,
					"onComplete":function():void {
						soundManager.play("7zeIcPFb-UWzgtR_3nrZ8Q");
						TweenMax.to(t,3,{
							"y":t.y - 50,
							"alpha":0.2,
							"onComplete":function():void {
								TweenMax.to(t,2,{
									"alpha":0,
									"scaleX":20,
									"scaleY":20,
									"onComplete":function():void {
										removeChild(t);
										t = null;
									}
								});
							}
						});
					},
					"ease":Circ.easeIn
				});
				if(isAccuired) {
					TweenMax.delayedCall(1.5,function():void {
						if((type + 1) % 3 == 0) {
							return;
						}
						playSkillUnlockAnimation(type + 1,"unlocked!",false);
						addSpecialSkills();
					});
				}
			});
		}
		
		private function raiseSkill(name:String, t:Text) : void {
			if(crewMember.skillPoints < 1) {
				return;
			}
			crewMember.skillPoints--;
			updateSkillPoints();
			var _local4:int = parseInt(t.text);
			_local4++;
			t.text = "" + _local4;
			var _local3:int = crewMember.getSkillIndexByName(name);
			crewMember.skills[_local3]++;
			if(_local4 == 20) {
				if(name == "Survival") {
					playSkillUnlockAnimation(Area.getSpecialIndex("Cold"),"unlocked!",false);
				} else if(name == "Diplomacy") {
					playSkillUnlockAnimation(Area.getSpecialIndex("First Contact"),"unlocked!",false);
				} else if(name == "Combat") {
					playSkillUnlockAnimation(Area.getSpecialIndex("Kinetic Weapons"),"unlocked!",false);
				}
				addSpecialSkills();
			}
			g.send("raiseCrewSkill",crewMember.key,_local3);
		}
		
		private function addDismiss() : void {
			if(mode != 0) {
				return;
			}
			if(!crewMember.isIdle()) {
				return;
			}
			dismissButton = new Button(dismiss,Localize.t("Dismiss"),"negative");
			dismissButton.x = img.x;
			dismissButton.y = 460;
			dismissButton.visible = true;
			if(g.me.crewMembers.length > 3) {
				addChild(dismissButton);
			}
			if(crewMember.isInjured) {
				dismissButton.visible = false;
			}
		}
		
		private function addBuy() : void {
			if(mode != 1) {
				return;
			}
			acceptButton = new Button(accept,Localize.t("Joins your crew for [flux] flux").replace("[flux]",CreditManager.getCostCrew()),"positive");
			acceptButton.x = img.x - 150;
			acceptButton.y = 460;
			addChild(acceptButton);
		}
		
		private function accept(e:TouchEvent) : void {
			var fluxCost:Number = CreditManager.getCostCrew();
			g.creditManager.refresh(function():void {
				confirmBuyWithFlux = new CreditBuyBox(g,fluxCost,Localize.t("Are you sure you want [name] to join your crew?").replace("[name]",crewMember.name));
				g.addChildToOverlay(confirmBuyWithFlux);
				confirmBuyWithFlux.addEventListener("accept",function():void {
					g.rpc("buyCantinaCrew",buyCrewResult,crewMember.seed);
					confirmBuyWithFlux.removeEventListeners();
				});
				confirmBuyWithFlux.addEventListener("close",function():void {
					acceptButton.enabled = true;
					confirmBuyWithFlux.removeEventListeners();
					g.removeChildFromOverlay(confirmBuyWithFlux,true);
				});
			});
		}
		
		private function buyCrewResult(m:Message) : void {
			var _local2:CrewMember = null;
			if(m.getBoolean(0) == true) {
				g.infoMessageDialog(m.getString(1));
				g.me.initCrewFromMessage(m,4);
				_local2 = g.me.crewMembers[g.me.crewMembers.length - 1];
				Action.hire(_local2.imageKey,_local2.name);
				g.creditManager.refresh();
				requestRemovalCallback(this);
			} else {
				g.showErrorDialog(m.getString(1));
			}
		}
		
		private function addTrain() : void {
			if(!crewMember.isIdle()) {
				return;
			}
			trainButton = new Button(showStartTraining,"Train","positive");
			trainButton.x = 0;
			trainButton.y = 460;
			addChild(trainButton);
			if(crewMember.isInjured) {
				trainButton.visible = false;
			}
		}
		
		private function showStartTraining(e:TouchEvent) : void {
			confirmTraining = new PopupConfirmMessage(Localize.t("Start training?"));
			var _local2:String = Util.getFormattedTime(crewMember.getTrainingTime());
			confirmTraining.text = Localize.t("Send [name] to training? It will take: [time]").replace("[name]",crewMember.name).replace("[time]",_local2);
			g.addChildToOverlay(confirmTraining,true);
			confirmTraining.addEventListener("accept",onAcceptTraining);
			confirmTraining.addEventListener("close",onCancelStartTraining);
		}
		
		private function onAcceptTraining(e:Event) : void {
			g.removeChildFromOverlay(confirmTraining);
			confirmTraining.removeEventListeners();
			g.rpc("startTraining",function(param1:Message):void {
				var _local2:Boolean = param1.getBoolean(0);
				if(!_local2) {
					g.showErrorDialog(param1.getString(1),true);
					return;
				}
				var _local5:int = param1.getInt(1);
				var _local4:Number = param1.getNumber(2);
				var _local3:Number = param1.getNumber(3);
				crewMember.trainingType = _local5;
				crewMember.trainingEnd = _local3;
				requestReload();
			},crewMember.key,1);
		}
		
		private function onCancelStartTraining(e:Event) : void {
			trainButton.enabled = true;
			g.removeChildFromOverlay(confirmTraining);
			confirmTraining.removeEventListeners();
		}
		
		private function dismiss(e:TouchEvent) : void {
			confirmDismiss = new PopupConfirmMessage(Localize.t("Fire"),Localize.t("No, don\'t."));
			confirmDismiss.text = Localize.t("Are you sure you want to fire [name] from your crew?").replace("[name]",crewMember.name);
			g.addChildToOverlay(confirmDismiss,true);
			confirmDismiss.addEventListener("accept",onAcceptDismiss);
			confirmDismiss.addEventListener("close",onCancelDismiss);
		}
		
		private function onAcceptDismiss(e:Event) : void {
			var cm:CrewMember;
			var i:int;
			g.removeChildFromOverlay(confirmDismiss);
			confirmDismiss.removeEventListeners();
			g.send("removeCrewMember",crewMember.key);
			i = 0;
			while(i < g.me.crewMembers.length) {
				cm = g.me.crewMembers[i];
				if(cm == crewMember) {
					g.me.crewMembers.splice(i,1);
					g.showMessageDialog(Localize.t("[name] has left your ship.").replace("[name]",cm.name),function():void {
						requestReloadCallback(true);
					});
					break;
				}
				i++;
			}
		}
		
		private function onCancelDismiss(e:Event) : void {
			dismissButton.enabled = true;
			g.removeChildFromOverlay(confirmDismiss);
			confirmDismiss.removeEventListeners();
		}
		
		private function getSkillColor(skillValue:int) : uint {
			var _local3:int = 0;
			var _local4:int = 0;
			var _local2:int = 0;
			_local3 = 0;
			while(_local3 < crewMember.skills.length) {
				_local4 = int(crewMember.skills[_local3]);
				if(skillValue > _local4) {
					_local2++;
				}
				_local3++;
			}
			if(_local2 == 2) {
				return 0xffffff;
			}
			if(_local2 == 1) {
				return 0xadadad;
			}
			return 0x4a4a4a;
		}
		
		private function getSpecialIcon(i:int, gray:Boolean = false) : Image {
			var _local3:Image = null;
			var _local4:ITextureManager = TextureLocator.getService();
			if(gray) {
				_local3 = new Image(_local4.getTextureGUIByTextureName(IMAGES_SPECIALS[i] + "_inactive"));
			} else {
				_local3 = new Image(_local4.getTextureGUIByTextureName(IMAGES_SPECIALS[i]));
			}
			return _local3;
		}
		
		public function clean(e:Event = null) : void {
			ToolTip.disposeType("crewSkill");
			removeEventListener("removedFromStage",clean);
			if(skillPointsValueTween1) {
				skillPointsValueTween1.kill();
				skillPointsValueTween1 = null;
				skillPointsValueTween2.kill();
				skillPointsValueTween2 = null;
			}
			if(statusTween) {
				statusTween.kill();
				statusTween = null;
			}
		}
	}
}

