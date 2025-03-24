package core.states.menuStates {
	import core.hud.components.TextBitmap;
	import core.hud.components.ToolTip;
	import core.scene.Game;
	import core.states.DisplayState;
	import data.DataLocator;
	import data.IDataManager;
	import debug.Console;
	import feathers.controls.ScrollContainer;
	import flash.globalization.NumberFormatter;
	import generics.Localize;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.display.Sprite;
	
	public class EncounterState extends DisplayState {
		public static var WIDTH:Number = 658;
		
		public static var PADDING:Number = 31;
		
		private var mainBody:ScrollContainer;
		
		public function EncounterState(g:Game, isRoot:Boolean = false) {
			super(g,HomeState,isRoot);
		}
		
		override public function enter() : void {
			super.enter();
			g.hud.encountersButton.hideHintNew();
			var _local1:TextBitmap = new TextBitmap();
			_local1.size = 24;
			_local1.format.color = 0xffffff;
			_local1.text = Localize.t("Alien Encounters");
			_local1.x = 60;
			_local1.y = 50;
			addChild(_local1);
			mainBody = new ScrollContainer();
			mainBody.width = WIDTH;
			mainBody.height = 450;
			mainBody.x = 60;
			mainBody.y = 95;
			addChild(mainBody);
			load();
		}
		
		private function load() : void {
			var i:int;
			var j:int;
			var dataManager:IDataManager;
			var jsonEnemies:Object;
			var jsonBosses:Object;
			var allEncounterKeys:Vector.<String>;
			var key:Object;
			var encounteredNames:Vector.<String>;
			var occupiedNames:Vector.<String>;
			var encounterKey:String;
			var obj:Object;
			var name:String;
			var totalCount:int;
			var firstBoss:Boolean;
			var s:Sprite;
			var q:Quad;
			var shipObj:Object;
			var imgObj:Object;
			var animationDelay:Number;
			var img:MovieClip;
			var scale:Number;
			var bossIcon:Image;
			var infoText:String;
			var nf:NumberFormatter;
			var percent:TextBitmap;
			var encounterKeys:Vector.<String> = g.me.encounters;
			super.backButton.visible = false;
			i = 0;
			j = 0;
			dataManager = DataLocator.getService();
			jsonEnemies = dataManager.loadTable("Enemies");
			jsonBosses = dataManager.loadTable("Bosses");
			allEncounterKeys = new Vector.<String>();
			for(key in jsonEnemies) {
				allEncounterKeys.push("enemy_" + key);
			}
			for(key in jsonBosses) {
				allEncounterKeys.push("boss_" + key);
			}
			encounteredNames = new Vector.<String>();
			occupiedNames = new Vector.<String>();
			allEncounterKeys.sort(function(param1:String, param2:String):int {
				if(param1 < param2) {
					return 1;
				}
				return -1;
			});
			for each(encounterKey in encounterKeys) {
				if(encounterKey.search("enemy_") != -1) {
					obj = dataManager.loadKey("Enemies",encounterKey.replace("enemy_",""));
				} else if(encounterKey.search("boss_") != -1) {
					obj = dataManager.loadKey("Bosses",encounterKey.replace("boss_",""));
				}
				if(obj != null) {
					name = obj.name;
					name = name.toLowerCase().replace("lvl","_").split("_")[0];
					if(encounteredNames.indexOf(name) == -1) {
						encounteredNames.push(name);
					}
				}
			}
			totalCount = 0;
			firstBoss = true;
			for each(encounterKey in allEncounterKeys) {
				s = new Sprite();
				if(encounterKey.search("enemy_") != -1) {
					obj = dataManager.loadKey("Enemies",encounterKey.replace("enemy_",""));
				} else if(encounterKey.search("boss_") != -1) {
					obj = dataManager.loadKey("Bosses",encounterKey.replace("boss_",""));
				}
				name = obj.name;
				name = name.toLowerCase().replace("lvl","_").split("_")[0];
				if(!obj.excludeFromEnctounter) {
					if(occupiedNames.indexOf(name) == -1) {
						if(!(obj.key == "uT2trotZXE66rIi8deR-Lw" || obj.key == "zbdPnai4Mkq2INZ-HgybTQ")) {
							occupiedNames.push(name);
							q = new Quad(80,80,0);
							s.addChild(q);
							if(encounterKey.search("enemy_") != -1) {
								shipObj = dataManager.loadKey("Ships",obj.ship);
								imgObj = dataManager.loadKey("Images",shipObj.bitmap);
								animationDelay = 12;
								Console.write(encounterKey,imgObj);
								if(imgObj.animate) {
									animationDelay = Number(imgObj.animationDelay == 0 ? 33 : 33 / imgObj.animationDelay);
								}
								img = new MovieClip(textureManager.getTexturesMainByKey(shipObj.bitmap),animationDelay);
							} else if(encounterKey.search("boss_") != -1) {
								img = new MovieClip(textureManager.getTexturesMainByTextureName(name.replace(" ","_").replace("???","qqq") + "_mini"));
							}
							img.x = q.width / 2;
							img.y = q.height / 2;
							img.pivotX = img.width / 2;
							img.pivotY = img.height / 2;
							if(img.width > 75 || img.height > 75) {
								scale = 0;
								scale = img.width > img.height ? 75 / img.width : 75 / img.height;
								img.scaleX = img.scaleY = scale;
								if(imgObj.scale != null && imgObj.scale < img.scaleX) {
									img.scaleX = img.scaleY = imgObj.scale;
								}
							}
							s.x = i * 90;
							s.y = j * 90;
							i++;
							if(i % 7 == 0) {
								j++;
								i = 0;
							}
							s.addChild(img);
							if(encounterKey.search("boss_") != -1) {
								bossIcon = new Image(textureManager.getTextureGUIByTextureName("radar_boss"));
								bossIcon.x = 75 - bossIcon.width;
								bossIcon.y = 5;
								s.addChild(bossIcon);
							}
							mainBody.addChild(s);
							if(encounteredNames.indexOf(name) == -1) {
								img.color = 0;
								q.color = 0x101010;
							} else {
								infoText = "";
								if(encounterKey.search("boss_") == -1) {
									nf = new NumberFormatter("i-default");
									infoText += "\n\n" + Localize.t("Base") + ":" + "\n - <FONT COLOR=\'#88ff88\'>" + Localize.t("Health") + "</FONT> <FONT COLOR=\'#FFFFFF\'>" + nf.formatNumber(shipObj.hp) + "</FONT>" + "\n - <FONT COLOR=\'#88ff88\'>" + Localize.t("Armor") + "</FONT> <FONT COLOR=\'#FFFFFF\'>" + (shipObj.armor == null ? 0 : nf.formatNumber(shipObj.armor)) + "</FONT>" + "\n - <FONT COLOR=\'#8888ff\'>" + Localize.t("Shield") + "</FONT> <FONT COLOR=\'#FFFFFF\'>" + nf.formatNumber(shipObj.shieldHp) + "</FONT>" + "\n - <FONT COLOR=\'#8888ff\'>" + Localize.t("Shield Regen") + "</FONT> <FONT COLOR=\'#FFFFFF\'>" + nf.formatNumber(shipObj.shieldRegen) + "</FONT>";
								}
								infoText += "\n\n" + Localize.t("Resistances") + ": " + "\n - <FONT COLOR=\'#ff8888\'>" + Localize.t("Kinetic") + "</FONT> <FONT COLOR=\'#FFFFFF\'>" + (obj.kineticResist != null ? obj.kineticResist : 0) + "%</FONT>" + "\n - <FONT COLOR=\'#8888ff\'>" + Localize.t("Energy") + "</FONT> <FONT COLOR=\'#FFFFFF\'>" + (obj.energyResist != null ? obj.energyResist : 0) + "%</FONT>" + "\n - <FONT COLOR=\'#88ff88\'>" + Localize.t("Corrosive") + "</FONT> <FONT COLOR=\'#FFFFFF\'>" + (obj.corrosiveResist != null ? obj.corrosiveResist : 0) + "%</FONT>";
								if(obj.kineticAbsorb || obj.energyAbsorb || obj.corrosiveAbsorb) {
									infoText += "\n\n" + Localize.t("Absorbs") + ": " + "\n - <FONT COLOR=\'#ff8888\'>" + Localize.t("Kinetic") + "</FONT> <FONT COLOR=\'#FFFFFF\'>" + (obj.kineticAbsorb != null ? obj.kineticAbsorb : 0) + "%</FONT>" + "\n - <FONT COLOR=\'#8888ff\'>" + Localize.t("Energy") + "</FONT> <FONT COLOR=\'#FFFFFF\'>" + (obj.energyAbsorb != null ? obj.energyAbsorb : 0) + "%</FONT>" + "\n - <FONT COLOR=\'#88ff88\'>" + Localize.t("Corrosive") + "</FONT> <FONT COLOR=\'#FFFFFF\'>" + (obj.corrosiveAbsorb != null ? obj.corrosiveAbsorb : 0) + "%</FONT>";
								}
								new ToolTip(g,s,Localize.t("Name") + ": <FONT COLOR=\'#ffffff\'>" + obj.name.replace("Lvl","lvl").replace("lvl","_").split("_")[0] + " lvl " + obj.level + "</FONT>\n" + Localize.t("Type") + ": <FONT COLOR=\'#FFFFFF\'>" + encounterKey.split("_")[0] + "</FONT>" + infoText,null,"encounters");
								if(imgObj != null && imgObj.animate && imgObj.animateOnStart) {
									Starling.juggler.add(img);
								}
							}
							totalCount++;
						}
					}
				}
			}
			percent = new TextBitmap();
			percent.size = 24;
			percent.format.color = 0x88ff88;
			percent.text = (encounteredNames.length / totalCount * 100).toFixed() + "%";
			percent.x = 630;
			percent.y = 50;
			addChild(percent);
		}
		
		override public function exit() : void {
			ToolTip.disposeType("encounters");
			super.exit();
		}
	}
}

