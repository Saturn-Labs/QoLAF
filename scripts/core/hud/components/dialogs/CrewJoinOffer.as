package core.hud.components.dialogs {
	import core.credits.CreditManager;
	import core.hud.components.Box;
	import core.hud.components.Button;
	import core.hud.components.CrewDisplayBox;
	import core.hud.components.Text;
	import core.hud.components.ToolTip;
	import core.player.CrewMember;
	import core.player.Player;
	import core.scene.Game;
	import core.solarSystem.Area;
	import core.solarSystem.Body;
	import data.DataLocator;
	import data.IDataManager;
	import facebook.Action;
	import playerio.Message;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class CrewJoinOffer extends Sprite {
		private static const HEIGHT:int = 128;
		
		private static const WIDTH:int = 112;
		
		private var overlay:Sprite;
		
		private var bgr:Quad;
		
		private var infoBox:Box;
		
		private var infoText:Text;
		
		private var declineButton:Button;
		
		private var acceptButton:Button;
		
		private var laterButton:Button;
		
		private var body:Body;
		
		private var img:Image;
		
		private var g:Game;
		
		private var p:Player;
		
		private var level:int;
		
		private var crewMember:CrewMember;
		
		private var femaleNames:Array;
		
		private var femaleImages:Array;
		
		private var maleNames:Array;
		
		private var maleImages:Array;
		
		private var priceSkill:int;
		
		private var confirmBuyWithFlux:CreditBuyBox;
		
		public function CrewJoinOffer(g:Game, crewMember:CrewMember, body:Body = null, text:String = "") {
			var imgKey:String;
			var textureManager:ITextureManager;
			var fluxCost:Number;
			var fluxButton:Button;
			overlay = new Sprite();
			bgr = new Quad(100,100,0);
			super();
			this.crewMember = crewMember;
			this.body = body;
			this.g = g;
			p = g.me;
			level = p.level;
			g.addChildToOverlay(overlay,true);
			if(this.crewMember.imageKey == null || this.crewMember.name == null) {
				loadCrewData();
				if(Math.random() > 0.5) {
					crewMember.name = getUniqueName(femaleNames);
					imgKey = getUniqueImage(femaleImages);
					crewMember.imageKey = imgKey;
				} else {
					crewMember.name = getUniqueName(maleNames);
					imgKey = getUniqueImage(maleImages);
					crewMember.imageKey = imgKey;
				}
			}
			infoBox = new Box(450,4 * 60,"buy",1,18);
			textureManager = TextureLocator.getService();
			img = new Image(textureManager.getTextureGUIByKey(crewMember.imageKey));
			img.x = 10;
			img.y = 10;
			img.height = 128;
			img.width = 112;
			img.visible = true;
			infoBox.addChild(img);
			infoText = new Text(80 + 112,20);
			infoText.size = 10;
			infoText.wordWrap = true;
			infoText.width = 220;
			if(text == "") {
				infoText.text = crewMember.name + " offers to join your crew and help explore the galaxy.";
			} else {
				while(text.indexOf("[name]") != -1) {
					text = text.replace("[name]",crewMember.name);
				}
				infoText.text = text;
			}
			declineButton = new Button(decline,"Decline","negative");
			declineButton.x = 440 - declineButton.width;
			declineButton.y = 200;
			declineButton.visible = true;
			laterButton = new Button(later,"Later");
			laterButton.x = declineButton.x - 5 - laterButton.width;
			laterButton.y = 200;
			laterButton.visible = true;
			acceptButton = new Button(accept,"Accept","positive");
			acceptButton.x = laterButton.x - 5 - acceptButton.width;
			acceptButton.y = 200;
			acceptButton.visible = body == null ? true : false;
			addSkills(infoBox);
			fluxCost = CreditManager.getCostCrew();
			if(text != "") {
				fluxCost = 0;
			}
			if(p.crewMembers.length >= p.unlockedCrewSlots) {
				fluxCost += CreditManager.getCostCrewSlot(p.unlockedCrewSlots + 1);
			}
			if(fluxCost > 0) {
				fluxButton = new Button(function():void {
					g.creditManager.refresh(function():void {
						confirmBuyWithFlux = new CreditBuyBox(g,fluxCost,"Are you sure you want to buy this crew?");
						g.addChildToOverlay(confirmBuyWithFlux);
						confirmBuyWithFlux.addEventListener("accept",function():void {
							g.rpc("buyCrewWithFlux",buyCrewResult,body.key,crewMember.name,crewMember.imageKey);
							confirmBuyWithFlux.removeEventListeners();
						});
						confirmBuyWithFlux.addEventListener("close",function():void {
							fluxButton.enabled = true;
							confirmBuyWithFlux.removeEventListeners();
							g.removeChildFromOverlay(confirmBuyWithFlux,true);
						});
					});
				},"Buy for " + fluxCost + " Flux","buy");
				fluxButton.x = laterButton.x - 5 - fluxButton.width;
				fluxButton.y = 200;
				infoBox.addChild(fluxButton);
				if(p.crewMembers.length >= 5) {
					fluxButton.enabled = false;
				}
			}
			resize();
			overlay.addChild(bgr);
			overlay.addChild(infoBox);
			infoBox.addChild(infoText);
			if(body != null) {
				infoBox.addChild(laterButton);
				infoBox.addChild(declineButton);
			} else {
				infoBox.addChild(acceptButton);
			}
			g.addResizeListener(resize);
			addEventListener("removedFromStage",clean);
		}
		
		private function loadCrewData() : void {
			var _local2:IDataManager = DataLocator.getService();
			var _local1:Object = _local2.loadKey("CrewData","CrewDataObject1337");
			femaleNames = _local1.femaleNames;
			femaleImages = _local1.femaleImages;
			maleNames = _local1.maleNames;
			maleImages = _local1.maleImages;
		}
		
		private function getUniqueName(names:Array) : String {
			var _local5:int = 0;
			var _local3:String = null;
			var _local2:int = Math.random() * names.length;
			var _local4:int = Math.random() * names.length;
			_local5 = 0;
			while(_local5 < names.length) {
				_local4 = _local5 + _local2;
				if(_local4 >= names.length) {
					_local4 -= names.length;
				}
				_local3 = names[_local4] as String;
				if(!containsName(_local3,p.crewMembers)) {
					return _local3;
				}
				_local5++;
			}
			return names[_local2] as String;
		}
		
		private function getUniqueImage(imgs:Array) : String {
			var _local5:int = 0;
			var _local3:String = null;
			var _local2:int = Math.random() * imgs.length;
			var _local4:int = Math.random() * imgs.length;
			_local5 = 0;
			while(_local5 < imgs.length) {
				_local4 = _local5 + _local2;
				if(_local4 >= imgs.length) {
					_local4 -= imgs.length;
				}
				_local3 = imgs[_local4] as String;
				if(!containsImage(_local3,p.crewMembers)) {
					return _local3;
				}
				_local5++;
			}
			return imgs[_local2] as String;
		}
		
		private function containsName(n:String, v:Vector.<CrewMember>) : Boolean {
			for each(var _local3 in v) {
				if(_local3.name == n) {
					return true;
				}
			}
			return false;
		}
		
		private function containsImage(img:String, v:Vector.<CrewMember>) : Boolean {
			for each(var _local3 in v) {
				if(_local3.imageKey == img) {
					return true;
				}
			}
			return false;
		}
		
		private function addSkills(box:Box) : void {
			var _local6:int = 0;
			var _local7:int = 0;
			var _local11:int = 0;
			var _local9:int = 0;
			var _local3:String = null;
			var _local4:Text = null;
			if(body != null) {
				_local6 = 70;
				_local7 = 90;
			} else {
				_local6 = 160;
				_local7 = 3 * 60;
			}
			var _local8:int = 192;
			var _local10:int = 192;
			var _local5:int = 0;
			var _local2:int = 0;
			_local9 = 0;
			while(_local9 < 9) {
				if((_local9 + 3) % 3 == 0) {
					_local11 = (_local9 + 3) / 3 - 1;
					_local3 = Area.SKILLTYPEHTML[_local11];
					addSkillIcon(box,_local8,_local6,CrewDisplayBox.IMAGES_SKILLS[_local11],Area.SKILLTYPE[_local11]);
					_local4 = new Text(_local8 + 15 + 3,_local6 + 6);
					_local4.color = Area.COLORTYPE[_local11];
					priceSkill += 10 * (crewMember.skills[_local11] * ((level - 1) * 10 + 40) + 1);
					if(crewMember.skills[_local11] >= 0.6) {
						_local5++;
					}
					if(body != null) {
						_local4.htmlText = (crewMember.skills[_local11] * ((level - 1) * 10 + 40) + 1).toFixed(1);
					} else {
						_local4.htmlText = (crewMember.skills[_local11] + 1).toString();
					}
					_local4.size = 11;
					box.addChild(_local4);
					_local8 += 35 + _local4.width;
				}
				if(crewMember.specials[_local9] == 1) {
					_local2++;
					addSkillIcon(box,_local10,_local7,CrewDisplayBox.IMAGES_SPECIALS[_local9],Area.SPECIALTYPE[_local9]);
					_local10 += 22;
				}
				_local9++;
			}
			priceSkill *= Math.pow(2,_local5 - 1);
			priceSkill *= 1 + 0.5 * _local2;
		}
		
		private function addSkillIcon(box:Box, xpos:int, ypos:int, image:String, skilltype:String, gray:Boolean = false) : void {
			var _local9:ITextureManager = TextureLocator.getService();
			var _local7:Image = new Image(_local9.getTextureGUIByTextureName(image));
			_local7.x = xpos + 4;
			_local7.y = ypos + 8;
			var _local8:Sprite = new Sprite();
			_local8.addChild(_local7);
			box.addChild(_local8);
			new ToolTip(g,_local8,skilltype,null,"crewJoin");
		}
		
		private function decline(e:TouchEvent) : void {
			ToolTip.disposeType("crewJoin");
			visible = false;
			g.removeChildFromOverlay(overlay);
		}
		
		private function later(e:TouchEvent) : void {
			ToolTip.disposeType("crewJoin");
			visible = false;
			g.removeChildFromOverlay(overlay);
		}
		
		private function accept(e:TouchEvent) : void {
			acceptButton.enabled = false;
			if(body == null) {
				g.rpc("acceptCrewMember",buyCrewResult,crewMember.name,crewMember.imageKey);
			}
		}
		
		private function buyCrewResult(m:Message) : void {
			var _local3:String = null;
			var _local2:int = 0;
			var _local4:CrewMember = null;
			if(m.getBoolean(0) == true) {
				g.infoMessageDialog(m.getString(1));
				_local3 = m.getString(2);
				_local2 = m.getInt(3);
				if(_local3 != "" && _local2 > 0) {
					g.myCargo.removeMinerals(_local3,_local2);
				}
				if(p.crewMembers.length < 5 && p.unlockedCrewSlots == p.crewMembers.length) {
					p.unlockedCrewSlots++;
				}
				p.initCrewFromMessage(m,4);
				_local4 = p.crewMembers[p.crewMembers.length - 1];
				Action.hire(_local4.imageKey,_local4.name);
				g.creditManager.refresh();
				ToolTip.disposeType("crewJoin");
				visible = false;
				g.removeChildFromOverlay(overlay);
			} else {
				g.showErrorDialog(m.getString(1));
			}
		}
		
		private function resize(e:Event = null) : void {
			bgr.alpha = 0.8;
			bgr.width = g.stage.stageWidth;
			bgr.height = g.stage.stageHeight;
			infoBox.x = g.stage.stageWidth / 2 - infoBox.width / 2;
			infoBox.y = g.stage.stageHeight / 2 - infoBox.height / 2;
		}
		
		private function clean(e:Event) : void {
			removeEventListener("removedFromStage",clean);
			g.removeResizeListener(resize);
		}
	}
}

