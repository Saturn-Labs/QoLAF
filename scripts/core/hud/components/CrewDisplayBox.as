package core.hud.components {
	import core.artifact.ArtifactCargoBox;
	import core.hud.components.dialogs.PopupConfirmMessage;
	import core.hud.components.explore.ExploreArea;
	import core.player.CrewMember;
	import core.player.Explore;
	import core.player.Player;
	import core.scene.Game;
	import core.solarSystem.Area;
	import core.states.menuStates.CrewState;
	import playerio.Message;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class CrewDisplayBox extends Sprite {
		private static const HEIGHT:int = 128;
		
		private static const WIDTH:int = 117;
		
		public static const IMAGES_SPECIALS:Vector.<String> = Vector.<String>(["spec_cold.png","spec_heat.png","spec_radiation.png","spec_first_contact.png","spec_trade.png","spec_collaboration.png","spec_kinetic.png","spec_energy.png","spec_bio_weapons.png"]);
		
		public static const IMAGES_SKILLS:Vector.<String> = Vector.<String>(["skill_environment.png","skill_diplomacy.png","skill_combat.png"]);
		
		private var exploreTimer:HudTimer;
		
		private var img:Image;
		
		private var selectedFlash:Quad = new Quad(5 * 60,190,0xffffff);
		
		private var crewMember:CrewMember;
		
		private var area:ExploreArea;
		
		private var injuryTimer:HudTimer;
		
		private var injuryStatus:TextBitmap;
		
		private var upgradeArtifactBox:ArtifactCargoBox;
		
		private var upgradeInstantButton:Button;
		
		private var upgradeArtifactTimer:HudTimer;
		
		private var box:GradientBox;
		
		private var nextY:int = 30;
		
		public var selected:Boolean;
		
		private var g:Game;
		
		private var confirmBox:PopupConfirmMessage;
		
		private var p:Player;
		
		private var crewState:CrewState;
		
		private var inSelectState:Boolean;
		
		private var upgradeStatus:Text = new Text();
		
		private var textY:int = 155;
		
		private var selectButton:Button;
		
		private var inUse:Boolean = false;
		
		public function CrewDisplayBox(g:Game, crewMember:CrewMember, area:ExploreArea, p:Player = null, inSelectState:Boolean = true, crewState:CrewState = null) {
			this.crewMember = crewMember;
			this.crewState = crewState;
			this.area = area;
			this.g = g;
			this.p = p;
			super();
			selectedFlash.alpha = 0.1;
			selectedFlash.blendMode = "add";
			selectedFlash.touchable = false;
			selectedFlash.visible = false;
			selectedFlash.x = -15;
			selectedFlash.y = -15;
			selected = false;
			this.inSelectState = inSelectState;
			var _local10:ITextureManager = TextureLocator.getService();
			img = new Image(_local10.getTextureGUIByKey(crewMember.imageKey));
			img.x = 0;
			img.y = -15;
			img.height = 128;
			img.width = 117;
			img.visible = true;
			img.blendMode = "add";
			var _local9:TextField = new TextField(117,20,crewMember.name,new TextFormat("font13",14,0xffffff));
			_local9.x = 0;
			_local9.y = 117;
			box = new GradientBox(270,125,0,0.2);
			box.load();
			box.addChild(_local9);
			box.addChild(img);
			var _local7:TextBitmap = new TextBitmap(0,-7,crewMember.missions + " missions ");
			_local7.x = 278 - _local7.width;
			_local7.format.color = 0x686868;
			box.addChild(_local7);
			var _local8:TextBitmap = new TextBitmap(0,-7,CrewMember.getRank(crewMember.rank));
			_local8.x = _local7.x - _local8.width - 10;
			_local8.format.color = 16689475;
			box.addChild(_local8);
			addSkills(box);
			addChild(box);
			if(inSelectState) {
				useHandCursor = true;
			}
			addEventListener("touch",onTouch);
			addLocation(box,inSelectState);
			addChild(selectedFlash);
			addEventListener("removedFromStage",clean);
		}
		
		public function get key() : String {
			return crewMember.key;
		}
		
		public function getLevel(i:int) : int {
			return crewMember.skills[i];
		}
		
		public function showLackSpecialSkill() : void {
			var _local1:TextBitmap = new TextBitmap(-15,textY,"Not skilled enough");
			_local1.format.color = 0xff0000;
			addChild(_local1);
		}
		
		public function update() : void {
			var _local1:TextBitmap = null;
			var _local2:TextBitmap = null;
			if(exploreTimer != null) {
				if(exploreTimer.isComplete()) {
					box.removeChild(exploreTimer);
					exploreTimer = null;
					_local1 = new TextBitmap(box.x + 285,textY,"Waiting for pickup");
					_local1.format.color = 0x55ff55;
					_local1.alignRight();
					box.addChild(_local1);
				} else {
					exploreTimer.update();
				}
			}
			if(injuryTimer != null) {
				if(injuryTimer.isComplete()) {
					removeChild(injuryTimer);
					removeChild(injuryStatus);
					injuryTimer = null;
					_local2 = new TextBitmap(box.x + 285,textY,"Onboard ship");
					_local2.format.color = 0x686868;
					_local2.alignRight();
					box.addChild(_local2);
				} else {
					injuryTimer.update();
				}
			}
			if(upgradeArtifactTimer != null) {
				if(upgradeArtifactTimer.isComplete()) {
					upgradeArtifactComplete();
				} else {
					upgradeArtifactTimer.update();
				}
			} else if(crewMember.isUpgrading) {
				addUpgradeTimer();
			}
		}
		
		public function toggleSelected() : Boolean {
			var _local1:String = "ADD";
			if(selected) {
				selected = false;
				selectButton.x = 215;
				selectedFlash.visible = false;
			} else {
				_local1 = "REMOVE";
				selected = true;
				selectButton.x = 185;
				selectedFlash.visible = true;
			}
			if(selectButton != null) {
				selectButton.text = _local1;
			}
			return selected;
		}
		
		public function getChance() : Number {
			return Area.getSuccessChance(area.level,area.type,crewMember,area.specialTypes);
		}
		
		public function getTime() : Number {
			return Area.getTime(area.size,area.level,area.rewardLevel,area.specialTypes,crewMember.skills[area.type]);
		}
		
		private function upgradeArtifactComplete() : void {
			var _local1:TextBitmap = null;
			removeChild(upgradeArtifactTimer);
			removeChild(upgradeArtifactBox);
			removeChild(upgradeInstantButton);
			upgradeArtifactTimer = null;
			_local1 = new TextBitmap(box.x + 285,textY,"Onboard ship");
			_local1.format.color = 0x686868;
			_local1.alignRight();
			box.addChild(_local1);
		}
		
		private function addUpgradeTimer() : void {
			if(crewMember.artifactEnd == 0) {
				return;
			}
			if(crewMember.artifactEnd < g.time) {
				return;
			}
			if(upgradeArtifactTimer != null) {
				return;
			}
			upgradeArtifactTimer = new HudTimer(g,10);
			upgradeArtifactTimer.start(g.time,crewMember.artifactEnd);
			upgradeArtifactTimer.x = box.x + 200;
			upgradeArtifactTimer.y = textY;
			addChild(upgradeArtifactTimer);
			upgradeStatus.x = box.x;
			upgradeStatus.y = textY;
			upgradeStatus.text = "Upgrading";
			addChild(upgradeStatus);
			upgradeArtifactBox = new ArtifactCargoBox(g,g.me.getArtifactById(crewMember.artifact));
			upgradeArtifactBox.scaleX = upgradeArtifactBox.scaleY = 0.75;
			upgradeArtifactBox.x = upgradeStatus.x + upgradeStatus.width + 5;
			upgradeArtifactBox.y = textY;
			addChild(upgradeArtifactBox);
		}
		
		private function instantArtifactUpgrade(m:Message) : void {
			if(m.getBoolean(0)) {
				crewMember.artifactEnd = m.getNumber(1);
				upgradeArtifactComplete();
			} else if(m.length > 1) {
				g.showErrorDialog(m.getString(1),false);
			}
		}
		
		private function addLocation(box:GradientBox, inSelectState:Boolean) : void {
			var _local4:TextBitmap = null;
			var _local6:TextBitmap = null;
			var _local3:TextBitmap = null;
			if(crewMember.fullLocation != null && crewMember.fullLocation != "") {
				_local4 = new TextBitmap(box.x - 15,textY);
				_local4.format.color = 0xffff00;
				_local4.text = crewMember.getCompactFullLocation();
				box.addChild(_local4);
				for each(var _local5 in p.explores) {
					if(_local5.areaKey == crewMember.area) {
						if(_local5.finishTime >= g.time) {
							exploreTimer = new HudTimer(g);
							exploreTimer.start(_local5.startTime,_local5.finishTime);
							exploreTimer.x = box.x + 200;
							exploreTimer.y = textY;
							box.addChild(exploreTimer);
							break;
						}
						_local4 = new TextBitmap(box.x + 285,textY,"Waiting for pickup");
						_local4.format.color = 0x55ff55;
						_local4.alignRight();
						box.addChild(_local4);
					}
				}
			} else if(crewMember.isInjured) {
				injuryStatus = new TextBitmap(-15,textY,"In sick bay, injured");
				injuryStatus.format.color = 0xff0000;
				addChild(injuryStatus);
				injuryTimer = new HudTimer(g);
				injuryTimer.x = box.x + 200;
				injuryTimer.y = textY;
				injuryTimer.start(crewMember.injuryStart,crewMember.injuryEnd);
				addChild(injuryTimer);
			} else if(crewMember.isTraining) {
				if(crewMember.isTrainingComplete) {
					injuryStatus = new TextBitmap(-15,textY,"Training complete");
					injuryStatus.format.color = 0xff00;
					addChild(injuryStatus);
					return;
				}
				injuryStatus = new TextBitmap(-15,textY,"Training");
				injuryStatus.format.color = Style.COLOR_DARK_GREEN;
				addChild(injuryStatus);
				injuryTimer = new HudTimer(g);
				injuryTimer.x = box.x + 200;
				injuryTimer.y = textY;
				injuryTimer.start(g.time,crewMember.trainingEnd);
				addChild(injuryTimer);
			} else if(crewMember.isUpgrading) {
				addUpgradeTimer();
			} else if(inSelectState) {
				_local6 = new TextBitmap(-15,textY,"INJURY RISK: ");
				addChild(_local6);
				_local3 = Area.injuryRiskText(area.level,area.type,area.size,crewMember,area.specialTypes);
				_local3.x = _local6.x + _local6.width + 5;
				_local3.y = textY;
				addChild(_local3);
				selectButton = new Button(null,"ADD");
				selectButton.x = 215;
				selectButton.y = textY;
				selectButton.alignWithText();
				selectButton.autoEnableAfterClick = true;
				addChild(selectButton);
			} else {
				_local6 = new TextBitmap(box.x + 285,textY,"Onboard ship");
				_local6.format.color = 0x686868;
				_local6.alignRight();
				box.addChild(_local6);
			}
		}
		
		override public function get height() : Number {
			return 190;
		}
		
		private function addSkills(box:GradientBox) : void {
			var _local2:int = 160;
			var _local3:int = 30;
			addSkill("Survival",_local2,_local3);
			addSkill("Diplomacy",_local2,_local3 + 30);
			addSkill("Combat",_local2,_local3 + 60);
			addSpecialSkills();
		}
		
		private function addSpecialSkills() : void {
			var _local1:Quad = null;
			var _local5:Quad = null;
			var _local4:int = 0;
			var _local2:int = 115;
			var _local3:int = 110;
			_local4 = 0;
			while(_local4 < 9) {
				_local1 = new Quad(11,2,0x888888);
				if(crewMember.specials[_local4] > 0 && crewMember.specials[_local4] < 1) {
					_local5 = new Quad(11,2,0x88ff88);
					_local5.x = _local2 + 3;
					_local5.y = _local3 + 25;
					_local1.x = _local2 + 3;
					_local1.y = _local3 + 25;
					_local1.width = 11 * crewMember.specials[_local4];
					box.addChild(_local5);
					box.addChild(_local1);
					addSpecialIcon(box,_local4,_local2,_local3,true);
				} else if(crewMember.specials[_local4] == 0) {
					addSpecialIcon(box,_local4,_local2,_local3,true);
				} else if(crewMember.specials[_local4] >= 1) {
					addSpecialIcon(box,_local4,_local2,_local3);
				}
				_local2 += 18;
				_local4++;
			}
		}
		
		private function addSkill(name:String, x:int, y:int) : void {
			var _local4:String = null;
			if(name == "Survival") {
				_local4 = "skill_environment.png";
			} else if(name == "Diplomacy") {
				_local4 = "skill_diplomacy.png";
			} else {
				_local4 = "skill_combat.png";
			}
			var _local8:int = crewMember.getSkillValueByName(name);
			var _local7:TextBitmap = new TextBitmap(x + 20,y - 2,"lvl",14);
			_local7.format.color = 0x4a4a4a;
			box.addChild(_local7);
			var _local10:TextBitmap = new TextBitmap(x + 2 * 60,y - 10,"" + _local8,28);
			_local10.x = x + 2 * 60 - _local10.width;
			_local10.format.color = getSkillColor(_local8);
			box.addChild(_local10);
			var _local9:ITextureManager = TextureLocator.getService();
			var _local5:Image = new Image(_local9.getTextureGUIByTextureName(_local4));
			_local5.x = x;
			_local5.y = y;
			var _local6:Sprite = new Sprite();
			_local6.addChild(_local5);
			new ToolTip(g,_local6,name,null,"crewSkill");
			box.addChild(_local6);
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
		
		private function addSpecialIcon(box:GradientBox, i:int, xpos:int, ypos:int, gray:Boolean = false) : void {
			var _local6:Image = null;
			var _local8:ITextureManager = TextureLocator.getService();
			if(gray) {
				_local6 = new Image(_local8.getTextureGUIByTextureName(IMAGES_SPECIALS[i] + "_inactive"));
			} else {
				_local6 = new Image(_local8.getTextureGUIByTextureName(IMAGES_SPECIALS[i]));
			}
			_local6.x = xpos + 4;
			_local6.y = ypos + 8;
			var _local7:Sprite = new Sprite();
			_local7.addChild(_local6);
			new ToolTip(g,_local7,Area.SPECIALTYPE[i],null,"crewSkill");
			box.addChild(_local7);
		}
		
		private function useTeam(e:TouchEvent = null) : void {
			inUse = !inUse;
			if(crewMember.isInjured) {
				g.showErrorDialog("This crew member is injured.");
				return;
			}
			if(crewMember.isDeployed) {
				g.showErrorDialog("This crew member is already deployed.");
				return;
			}
			dispatchEvent(new Event("teamSelected"));
		}
		
		public function mOver(e:TouchEvent) : void {
			if(inUse) {
				return;
			}
		}
		
		public function mOut(e:TouchEvent) : void {
			if(inUse) {
				return;
			}
		}
		
		public function dismiss(e:TouchEvent) : void {
			confirmBox = new PopupConfirmMessage("Fire","No, don\'t.");
			confirmBox.text = "Are you sure you want to fire " + crewMember.name + " from your crew?";
			g.addChildToOverlay(confirmBox,true);
			confirmBox.addEventListener("accept",onAccept);
			confirmBox.addEventListener("close",onClose);
		}
		
		private function onAccept(e:Event) : void {
			var _local3:CrewMember = null;
			var _local2:int = 0;
			g.removeChildFromOverlay(confirmBox,true);
			confirmBox.removeEventListeners();
			g.send("removeCrewMember",crewMember.key);
			_local2 = 0;
			while(_local2 < p.crewMembers.length) {
				_local3 = p.crewMembers[_local2];
				if(_local3 == crewMember) {
					p.crewMembers.splice(_local2,1);
					break;
				}
				_local2++;
			}
			if(crewState != null) {
				crewState.refresh();
			}
		}
		
		private function onClose(e:Event) : void {
			g.removeChildFromOverlay(confirmBox,true);
			confirmBox.removeEventListeners();
		}
		
		private function onTouch(e:TouchEvent) : void {
			if(!inSelectState) {
				return;
			}
			if(e.getTouch(this,"ended")) {
				useTeam(e);
			} else if(e.interactsWith(this)) {
				mOver(e);
			} else if(!e.interactsWith(this)) {
				mOut(e);
			}
		}
		
		public function clean(e:Event = null) : void {
			ToolTip.disposeType("crewSkill");
			removeEventListener("touch",onTouch);
			removeEventListener("removedFromStage",clean);
		}
	}
}

