package core.hud.components
{
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
	
	public class CrewDisplayBox extends Sprite
	{
		private static const HEIGHT:int = 128;
		
		private static const WIDTH:int = 117;
		
		public static const IMAGES_SPECIALS:Vector.<String> = Vector.<String>(["spec_cold.png", "spec_heat.png", "spec_radiation.png", "spec_first_contact.png", "spec_trade.png", "spec_collaboration.png", "spec_kinetic.png", "spec_energy.png", "spec_bio_weapons.png"]);
		
		public static const IMAGES_SKILLS:Vector.<String> = Vector.<String>(["skill_environment.png", "skill_diplomacy.png", "skill_combat.png"]);
		
		private var exploreTimer:HudTimer;
		
		private var img:Image;
		
		private var selectedFlash:Quad;
		
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
		
		private var upgradeStatus:Text;
		
		private var textY:int = 155;
		
		private var selectButton:Button;
		
		private var inUse:Boolean = false;
		
		public function CrewDisplayBox(param1:Game, param2:CrewMember, param3:ExploreArea, param4:Player = null, param5:Boolean = true, param6:CrewState = null)
		{
			selectedFlash = new Quad(300, 190, 16777215);
			upgradeStatus = new Text();
			this.crewMember = param2;
			this.crewState = param6;
			this.area = param3;
			this.g = param1;
			this.p = param4;
			super();
			selectedFlash.alpha = 0.1;
			selectedFlash.blendMode = "add";
			selectedFlash.touchable = false;
			selectedFlash.visible = false;
			selectedFlash.x = -15;
			selectedFlash.y = -15;
			selected = false;
			this.inSelectState = param5;
			var _loc7_:ITextureManager = TextureLocator.getService();
			img = new Image(_loc7_.getTextureGUIByKey(param2.imageKey));
			img.x = 0;
			img.y = -15;
			img.height = 128;
			img.width = 117;
			img.visible = true;
			img.blendMode = "add";
			var _loc9_:TextField = new TextField(117, 20, param2.name, new TextFormat("font13", 14, 16777215));
			_loc9_.x = 0;
			_loc9_.y = 117;
			box = new GradientBox(270, 125, 0, 0.2);
			box.load();
			box.addChild(_loc9_);
			box.addChild(img);
			var _loc10_:TextBitmap = new TextBitmap(0, -7, param2.missions + " missions ");
			_loc10_.x = 278 - _loc10_.width;
			_loc10_.format.color = 6842472;
			box.addChild(_loc10_);
			var _loc8_:TextBitmap = new TextBitmap(0, -7, CrewMember.getRank(param2.rank));
			_loc8_.x = _loc10_.x - _loc8_.width - 10;
			_loc8_.format.color = 16689475;
			box.addChild(_loc8_);
			addSkills(box);
			addChild(box);
			if (param5)
			{
				useHandCursor = true;
			}
			addEventListener("touch", onTouch);
			addLocation(box, param5);
			addChild(selectedFlash);
			addEventListener("removedFromStage", clean);
		}
		
		public function get key():String
		{
			return crewMember.key;
		}
		
		public function getLevel(param1:int):int
		{
			return crewMember.skills[param1];
		}
		
		public function showLackSpecialSkill():void
		{
			var _loc1_:TextBitmap = new TextBitmap(-15, textY, "Not skilled enough");
			_loc1_.format.color = 16711680;
			addChild(_loc1_);
		}
		
		public function update():void
		{
			var _loc2_:TextBitmap = null;
			var _loc1_:TextBitmap = null;
			if (exploreTimer != null)
			{
				if (exploreTimer.isComplete())
				{
					box.removeChild(exploreTimer);
					exploreTimer = null;
					_loc2_ = new TextBitmap(box.x + 285, textY, "Waiting for pickup");
					_loc2_.format.color = 5635925;
					_loc2_.alignRight();
					box.addChild(_loc2_);
				}
				else
				{
					exploreTimer.update();
				}
			}
			if (injuryTimer != null)
			{
				if (injuryTimer.isComplete())
				{
					removeChild(injuryTimer);
					removeChild(injuryStatus);
					injuryTimer = null;
					_loc1_ = new TextBitmap(box.x + 285, textY, "Onboard ship");
					_loc1_.format.color = 6842472;
					_loc1_.alignRight();
					box.addChild(_loc1_);
				}
				else
				{
					injuryTimer.update();
				}
			}
			if (upgradeArtifactTimer != null)
			{
				if (upgradeArtifactTimer.isComplete())
				{
					upgradeArtifactComplete();
				}
				else
				{
					upgradeArtifactTimer.update();
				}
			}
			else if (crewMember.isUpgrading)
			{
				addUpgradeTimer();
			}
		}
		
		public function toggleSelected():Boolean
		{
			var _loc1_:String = "ADD";
			if (selected)
			{
				selected = false;
				selectButton.x = 215;
				selectedFlash.visible = false;
			}
			else
			{
				_loc1_ = "REMOVE";
				selected = true;
				selectButton.x = 185;
				selectedFlash.visible = true;
			}
			if (selectButton != null)
			{
				selectButton.text = _loc1_;
			}
			return selected;
		}
		
		public function getChance():Number
		{
			return Area.getSuccessChance(area.level, area.type, crewMember, area.specialTypes);
		}
		
		public function getTime():Number
		{
			return Area.getTime(area.size, area.level, area.rewardLevel, area.specialTypes, crewMember.skills[area.type]);
		}
		
		private function upgradeArtifactComplete():void
		{
			var _loc1_:TextBitmap = null;
			removeChild(upgradeArtifactTimer);
			removeChild(upgradeArtifactBox);
			removeChild(upgradeInstantButton);
			upgradeArtifactTimer = null;
			_loc1_ = new TextBitmap(box.x + 285, textY, "Onboard ship");
			_loc1_.format.color = 6842472;
			_loc1_.alignRight();
			box.addChild(_loc1_);
		}
		
		private function addUpgradeTimer():void
		{
			if (crewMember.artifactEnd == 0)
			{
				return;
			}
			if (crewMember.artifactEnd < g.time)
			{
				return;
			}
			if (upgradeArtifactTimer != null)
			{
				return;
			}
			upgradeArtifactTimer = new HudTimer(g, 10);
			upgradeArtifactTimer.start(g.time, crewMember.artifactEnd);
			upgradeArtifactTimer.x = box.x + 200;
			upgradeArtifactTimer.y = textY;
			addChild(upgradeArtifactTimer);
			upgradeStatus.x = box.x;
			upgradeStatus.y = textY;
			upgradeStatus.text = "Upgrading";
			addChild(upgradeStatus);
			upgradeArtifactBox = new ArtifactCargoBox(g, g.me.getArtifactById(crewMember.artifact));
			upgradeArtifactBox.scaleX = upgradeArtifactBox.scaleY = 0.75;
			upgradeArtifactBox.x = upgradeStatus.x + upgradeStatus.width + 5;
			upgradeArtifactBox.y = textY;
			addChild(upgradeArtifactBox);
		}
		
		private function instantArtifactUpgrade(param1:Message):void
		{
			if (param1.getBoolean(0))
			{
				crewMember.artifactEnd = param1.getNumber(1);
				upgradeArtifactComplete();
			}
			else if (param1.length > 1)
			{
				g.showErrorDialog(param1.getString(1), false);
			}
		}
		
		private function addLocation(param1:GradientBox, param2:Boolean):void
		{
			var _loc4_:TextBitmap = null;
			var _loc5_:TextBitmap = null;
			var _loc6_:TextBitmap = null;
			if (crewMember.fullLocation != null && crewMember.fullLocation != "")
			{
				_loc4_ = new TextBitmap(param1.x - 15, textY);
				_loc4_.format.color = 16776960;
				_loc4_.text = crewMember.getCompactFullLocation();
				param1.addChild(_loc4_);
				for each (var _loc3_:* in p.explores)
				{
					if (_loc3_.areaKey == crewMember.area)
					{
						if (_loc3_.finishTime >= g.time)
						{
							exploreTimer = new HudTimer(g);
							exploreTimer.start(_loc3_.startTime, _loc3_.finishTime);
							exploreTimer.x = param1.x + 200;
							exploreTimer.y = textY;
							param1.addChild(exploreTimer);
							break;
						}
						_loc4_ = new TextBitmap(param1.x + 285, textY, "Waiting for pickup");
						_loc4_.format.color = 5635925;
						_loc4_.alignRight();
						param1.addChild(_loc4_);
					}
				}
			}
			else if (crewMember.isInjured)
			{
				injuryStatus = new TextBitmap(-15, textY, "In sick bay, injured");
				injuryStatus.format.color = 16711680;
				addChild(injuryStatus);
				injuryTimer = new HudTimer(g);
				injuryTimer.x = param1.x + 200;
				injuryTimer.y = textY;
				injuryTimer.start(crewMember.injuryStart, crewMember.injuryEnd);
				addChild(injuryTimer);
			}
			else if (crewMember.isTraining)
			{
				if (crewMember.isTrainingComplete)
				{
					injuryStatus = new TextBitmap(-15, textY, "Training complete");
					injuryStatus.format.color = 65280;
					addChild(injuryStatus);
					return;
				}
				injuryStatus = new TextBitmap(-15, textY, "Training");
				injuryStatus.format.color = Style.COLOR_DARK_GREEN;
				addChild(injuryStatus);
				injuryTimer = new HudTimer(g);
				injuryTimer.x = param1.x + 200;
				injuryTimer.y = textY;
				injuryTimer.start(g.time, crewMember.trainingEnd);
				addChild(injuryTimer);
			}
			else if (crewMember.isUpgrading)
			{
				addUpgradeTimer();
			}
			else if (param2)
			{
				_loc5_ = new TextBitmap(-15, textY, "INJURY RISK: ");
				addChild(_loc5_);
				_loc6_ = Area.injuryRiskText(area.level, area.type, area.size, crewMember, area.specialTypes);
				_loc6_.x = _loc5_.x + _loc5_.width + 5;
				_loc6_.y = textY;
				addChild(_loc6_);
				selectButton = new Button(null, "ADD");
				selectButton.x = 215;
				selectButton.y = textY;
				selectButton.alignWithText();
				selectButton.autoEnableAfterClick = true;
				addChild(selectButton);
			}
			else
			{
				_loc5_ = new TextBitmap(param1.x + 285, textY, "Onboard ship");
				_loc5_.format.color = 6842472;
				_loc5_.alignRight();
				param1.addChild(_loc5_);
			}
		}
		
		override public function get height():Number
		{
			return 190;
		}
		
		private function addSkills(param1:GradientBox):void
		{
			var _loc3_:int = 160;
			var _loc2_:int = 30;
			addSkill("Survival", _loc3_, _loc2_);
			addSkill("Diplomacy", _loc3_, _loc2_ + 30);
			addSkill("Combat", _loc3_, _loc2_ + 60);
			addSpecialSkills();
		}
		
		private function addSpecialSkills():void
		{
			var _loc2_:Quad = null;
			var _loc1_:Quad = null;
			var _loc5_:int = 0;
			var _loc3_:int = 115;
			var _loc4_:int = 110;
			_loc5_ = 0;
			while (_loc5_ < 9)
			{
				_loc2_ = new Quad(11, 2, 8947848);
				if (crewMember.specials[_loc5_] > 0 && crewMember.specials[_loc5_] < 1)
				{
					_loc1_ = new Quad(11, 2, 8978312);
					_loc1_.x = _loc3_ + 3;
					_loc1_.y = _loc4_ + 25;
					_loc2_.x = _loc3_ + 3;
					_loc2_.y = _loc4_ + 25;
					_loc2_.width = 11 * crewMember.specials[_loc5_];
					box.addChild(_loc1_);
					box.addChild(_loc2_);
					addSpecialIcon(box, _loc5_, _loc3_, _loc4_, true);
				}
				else if (crewMember.specials[_loc5_] == 0)
				{
					addSpecialIcon(box, _loc5_, _loc3_, _loc4_, true);
				}
				else if (crewMember.specials[_loc5_] >= 1)
				{
					addSpecialIcon(box, _loc5_, _loc3_, _loc4_);
				}
				_loc3_ += 18;
				_loc5_++;
			}
		}
		
		private function addSkill(param1:String, param2:int, param3:int):void
		{
			var _loc9_:String = null;
			if (param1 == "Survival")
			{
				_loc9_ = "skill_environment.png";
			}
			else if (param1 == "Diplomacy")
			{
				_loc9_ = "skill_diplomacy.png";
			}
			else
			{
				_loc9_ = "skill_combat.png";
			}
			var _loc7_:int = crewMember.getSkillValueByName(param1);
			var _loc6_:TextBitmap = new TextBitmap(param2 + 20, param3 - 2, "lvl", 14);
			_loc6_.format.color = 4868682;
			box.addChild(_loc6_);
			var _loc5_:TextBitmap = new TextBitmap(param2 + 120, param3 - 10, "" + _loc7_, 28);
			_loc5_.x = param2 + 120 - _loc5_.width;
			_loc5_.format.color = getSkillColor(_loc7_);
			box.addChild(_loc5_);
			var _loc4_:ITextureManager = TextureLocator.getService();
			var _loc10_:Image = new Image(_loc4_.getTextureGUIByTextureName(_loc9_));
			_loc10_.x = param2;
			_loc10_.y = param3;
			var _loc8_:Sprite = new Sprite();
			_loc8_.addChild(_loc10_);
			new ToolTip(g, _loc8_, param1, null, "crewSkill");
			box.addChild(_loc8_);
		}
		
		private function getSkillColor(param1:int):uint
		{
			var _loc4_:int = 0;
			var _loc3_:int = 0;
			var _loc2_:int = 0;
			_loc4_ = 0;
			while (_loc4_ < crewMember.skills.length)
			{
				_loc3_ = int(crewMember.skills[_loc4_]);
				if (param1 > _loc3_)
				{
					_loc2_++;
				}
				_loc4_++;
			}
			if (_loc2_ == 2)
			{
				return 16777215;
			}
			if (_loc2_ == 1)
			{
				return 11382189;
			}
			return 4868682;
		}
		
		private function addSpecialIcon(param1:GradientBox, param2:int, param3:int, param4:int, param5:Boolean = false):void
		{
			var _loc8_:Image = null;
			var _loc6_:ITextureManager = TextureLocator.getService();
			if (param5)
			{
				_loc8_ = new Image(_loc6_.getTextureGUIByTextureName(IMAGES_SPECIALS[param2] + "_inactive"));
			}
			else
			{
				_loc8_ = new Image(_loc6_.getTextureGUIByTextureName(IMAGES_SPECIALS[param2]));
			}
			_loc8_.x = param3 + 4;
			_loc8_.y = param4 + 8;
			var _loc7_:Sprite = new Sprite();
			_loc7_.addChild(_loc8_);
			new ToolTip(g, _loc7_, Area.SPECIALTYPE[param2], null, "crewSkill");
			param1.addChild(_loc7_);
		}
		
		private function useTeam(param1:TouchEvent = null):void
		{
			inUse = !inUse;
			if (crewMember.isInjured)
			{
				g.showErrorDialog("This crew member is injured.");
				return;
			}
			if (crewMember.isDeployed)
			{
				g.showErrorDialog("This crew member is already deployed.");
				return;
			}
			dispatchEvent(new Event("teamSelected"));
		}
		
		public function mOver(param1:TouchEvent):void
		{
			if (inUse)
			{
				return;
			}
		}
		
		public function mOut(param1:TouchEvent):void
		{
			if (inUse)
			{
				return;
			}
		}
		
		public function dismiss(param1:TouchEvent):void
		{
			confirmBox = new PopupConfirmMessage("Fire", "No, don't.");
			confirmBox.text = "Are you sure you want to fire " + crewMember.name + " from your crew?";
			g.addChildToOverlay(confirmBox, true);
			confirmBox.addEventListener("accept", onAccept);
			confirmBox.addEventListener("close", onClose);
		}
		
		private function onAccept(param1:Event):void
		{
			var _loc2_:CrewMember = null;
			var _loc3_:int = 0;
			g.removeChildFromOverlay(confirmBox, true);
			confirmBox.removeEventListeners();
			g.send("removeCrewMember", crewMember.key);
			_loc3_ = 0;
			while (_loc3_ < p.crewMembers.length)
			{
				_loc2_ = p.crewMembers[_loc3_];
				if (_loc2_ == crewMember)
				{
					p.crewMembers.splice(_loc3_, 1);
					break;
				}
				_loc3_++;
			}
			if (crewState != null)
			{
				crewState.refresh();
			}
		}
		
		private function onClose(param1:Event):void
		{
			g.removeChildFromOverlay(confirmBox, true);
			confirmBox.removeEventListeners();
		}
		
		private function onTouch(param1:TouchEvent):void
		{
			if (!inSelectState)
			{
				return;
			}
			if (param1.getTouch(this, "ended"))
			{
				useTeam(param1);
			}
			else if (param1.interactsWith(this))
			{
				mOver(param1);
			}
			else if (!param1.interactsWith(this))
			{
				mOut(param1);
			}
		}
		
		public function clean(param1:Event = null):void
		{
			ToolTip.disposeType("crewSkill");
			removeEventListener("touch", onTouch);
			removeEventListener("removedFromStage", clean);
		}
	}
}
