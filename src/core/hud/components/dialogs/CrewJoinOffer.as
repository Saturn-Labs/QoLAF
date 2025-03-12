package core.hud.components.dialogs
{
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
	
	public class CrewJoinOffer extends Sprite
	{
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
		
		public function CrewJoinOffer(param1:Game, param2:CrewMember, param3:Body = null, param4:String = "")
		{
			var imgKey:String;
			var textureManager:ITextureManager;
			var fluxCost:Number;
			var fluxButton:Button;
			var g:Game = param1;
			var crewMember:CrewMember = param2;
			var body:Body = param3;
			var text:String = param4;
			overlay = new Sprite();
			bgr = new Quad(100, 100, 0);
			super();
			this.crewMember = crewMember;
			this.body = body;
			this.g = g;
			p = g.me;
			level = p.level;
			g.addChildToOverlay(overlay, true);
			if (this.crewMember.imageKey == null || this.crewMember.name == null)
			{
				loadCrewData();
				if (Math.random() > 0.5)
				{
					crewMember.name = getUniqueName(femaleNames);
					imgKey = getUniqueImage(femaleImages);
					crewMember.imageKey = imgKey;
				}
				else
				{
					crewMember.name = getUniqueName(maleNames);
					imgKey = getUniqueImage(maleImages);
					crewMember.imageKey = imgKey;
				}
			}
			infoBox = new Box(450, 240, "buy", 1, 18);
			textureManager = TextureLocator.getService();
			img = new Image(textureManager.getTextureGUIByKey(crewMember.imageKey));
			img.x = 10;
			img.y = 10;
			img.height = 128;
			img.width = 112;
			img.visible = true;
			infoBox.addChild(img);
			infoText = new Text(80 + 112, 20);
			infoText.size = 10;
			infoText.wordWrap = true;
			infoText.width = 220;
			if (text == "")
			{
				infoText.text = crewMember.name + " offers to join your crew and help explore the galaxy.";
			}
			else
			{
				while (text.indexOf("[name]") != -1)
				{
					text = text.replace("[name]", crewMember.name);
				}
				infoText.text = text;
			}
			declineButton = new Button(decline, "Decline", "negative");
			declineButton.x = 440 - declineButton.width;
			declineButton.y = 200;
			declineButton.visible = true;
			laterButton = new Button(later, "Later");
			laterButton.x = declineButton.x - 5 - laterButton.width;
			laterButton.y = 200;
			laterButton.visible = true;
			acceptButton = new Button(accept, "Accept", "positive");
			acceptButton.x = laterButton.x - 5 - acceptButton.width;
			acceptButton.y = 200;
			acceptButton.visible = body == null ? true : false;
			addSkills(infoBox);
			fluxCost = CreditManager.getCostCrew();
			if (text != "")
			{
				fluxCost = 0;
			}
			if (p.crewMembers.length >= p.unlockedCrewSlots)
			{
				fluxCost += CreditManager.getCostCrewSlot(p.unlockedCrewSlots + 1);
			}
			if (fluxCost > 0)
			{
				fluxButton = new Button(function():void
				{
					g.creditManager.refresh(function():void
					{
						confirmBuyWithFlux = new CreditBuyBox(g, fluxCost, "Are you sure you want to buy this crew?");
						g.addChildToOverlay(confirmBuyWithFlux);
						confirmBuyWithFlux.addEventListener("accept", function():void
						{
							g.rpc("buyCrewWithFlux", buyCrewResult, body.key, crewMember.name, crewMember.imageKey);
							confirmBuyWithFlux.removeEventListeners();
						});
						confirmBuyWithFlux.addEventListener("close", function():void
						{
							fluxButton.enabled = true;
							confirmBuyWithFlux.removeEventListeners();
							g.removeChildFromOverlay(confirmBuyWithFlux, true);
						});
					});
				}, "Buy for " + fluxCost + " Flux", "buy");
				fluxButton.x = laterButton.x - 5 - fluxButton.width;
				fluxButton.y = 200;
				infoBox.addChild(fluxButton);
				if (p.crewMembers.length >= 5)
				{
					fluxButton.enabled = false;
				}
			}
			resize();
			overlay.addChild(bgr);
			overlay.addChild(infoBox);
			infoBox.addChild(infoText);
			if (body != null)
			{
				infoBox.addChild(laterButton);
				infoBox.addChild(declineButton);
			}
			else
			{
				infoBox.addChild(acceptButton);
			}
			g.addResizeListener(resize);
			addEventListener("removedFromStage", clean);
		}
		
		private function loadCrewData():void
		{
			var _loc2_:IDataManager = DataLocator.getService();
			var _loc1_:Object = _loc2_.loadKey("CrewData", "CrewDataObject1337");
			femaleNames = _loc1_.femaleNames;
			femaleImages = _loc1_.femaleImages;
			maleNames = _loc1_.maleNames;
			maleImages = _loc1_.maleImages;
		}
		
		private function getUniqueName(param1:Array):String
		{
			var _loc5_:int = 0;
			var _loc4_:String = null;
			var _loc3_:int = Math.random() * param1.length;
			var _loc2_:int = Math.random() * param1.length;
			_loc5_ = 0;
			while (_loc5_ < param1.length)
			{
				_loc2_ = _loc5_ + _loc3_;
				if (_loc2_ >= param1.length)
				{
					_loc2_ -= param1.length;
				}
				_loc4_ = param1[_loc2_] as String;
				if (!containsName(_loc4_, p.crewMembers))
				{
					return _loc4_;
				}
				_loc5_++;
			}
			return param1[_loc3_] as String;
		}
		
		private function getUniqueImage(param1:Array):String
		{
			var _loc5_:int = 0;
			var _loc4_:String = null;
			var _loc3_:int = Math.random() * param1.length;
			var _loc2_:int = Math.random() * param1.length;
			_loc5_ = 0;
			while (_loc5_ < param1.length)
			{
				_loc2_ = _loc5_ + _loc3_;
				if (_loc2_ >= param1.length)
				{
					_loc2_ -= param1.length;
				}
				_loc4_ = param1[_loc2_] as String;
				if (!containsImage(_loc4_, p.crewMembers))
				{
					return _loc4_;
				}
				_loc5_++;
			}
			return param1[_loc3_] as String;
		}
		
		private function containsName(param1:String, param2:Vector.<CrewMember>):Boolean
		{
			for each (var _loc3_:* in param2)
			{
				if (_loc3_.name == param1)
				{
					return true;
				}
			}
			return false;
		}
		
		private function containsImage(param1:String, param2:Vector.<CrewMember>):Boolean
		{
			for each (var _loc3_:* in param2)
			{
				if (_loc3_.imageKey == param1)
				{
					return true;
				}
			}
			return false;
		}
		
		private function addSkills(param1:Box):void
		{
			var _loc5_:int = 0;
			var _loc6_:int = 0;
			var _loc4_:int = 0;
			var _loc9_:int = 0;
			var _loc3_:String = null;
			var _loc2_:Text = null;
			if (body != null)
			{
				_loc5_ = 70;
				_loc6_ = 90;
			}
			else
			{
				_loc5_ = 160;
				_loc6_ = 180;
			}
			var _loc11_:int = 192;
			var _loc8_:int = 192;
			var _loc7_:int = 0;
			var _loc10_:int = 0;
			_loc9_ = 0;
			while (_loc9_ < 9)
			{
				if ((_loc9_ + 3) % 3 == 0)
				{
					_loc4_ = (_loc9_ + 3) / 3 - 1;
					_loc3_ = Area.SKILLTYPEHTML[_loc4_];
					addSkillIcon(param1, _loc11_, _loc5_, CrewDisplayBox.IMAGES_SKILLS[_loc4_], Area.SKILLTYPE[_loc4_]);
					_loc2_ = new Text(_loc11_ + 15 + 3, _loc5_ + 6);
					_loc2_.color = Area.COLORTYPE[_loc4_];
					priceSkill += 10 * (crewMember.skills[_loc4_] * ((level - 1) * 10 + 40) + 1);
					if (crewMember.skills[_loc4_] >= 0.6)
					{
						_loc7_++;
					}
					if (body != null)
					{
						_loc2_.htmlText = (crewMember.skills[_loc4_] * ((level - 1) * 10 + 40) + 1).toFixed(1);
					}
					else
					{
						_loc2_.htmlText = (crewMember.skills[_loc4_] + 1).toString();
					}
					_loc2_.size = 11;
					param1.addChild(_loc2_);
					_loc11_ += 35 + _loc2_.width;
				}
				if (crewMember.specials[_loc9_] == 1)
				{
					_loc10_++;
					addSkillIcon(param1, _loc8_, _loc6_, CrewDisplayBox.IMAGES_SPECIALS[_loc9_], Area.SPECIALTYPE[_loc9_]);
					_loc8_ += 22;
				}
				_loc9_++;
			}
			priceSkill *= Math.pow(2, _loc7_ - 1);
			priceSkill *= 1 + 0.5 * _loc10_;
		}
		
		private function addSkillIcon(param1:Box, param2:int, param3:int, param4:String, param5:String, param6:Boolean = false):void
		{
			var _loc7_:ITextureManager = TextureLocator.getService();
			var _loc9_:Image = new Image(_loc7_.getTextureGUIByTextureName(param4));
			_loc9_.x = param2 + 4;
			_loc9_.y = param3 + 8;
			var _loc8_:Sprite = new Sprite();
			_loc8_.addChild(_loc9_);
			param1.addChild(_loc8_);
			new ToolTip(g, _loc8_, param5, null, "crewJoin");
		}
		
		private function decline(param1:TouchEvent):void
		{
			ToolTip.disposeType("crewJoin");
			visible = false;
			g.removeChildFromOverlay(overlay);
		}
		
		private function later(param1:TouchEvent):void
		{
			ToolTip.disposeType("crewJoin");
			visible = false;
			g.removeChildFromOverlay(overlay);
		}
		
		private function accept(param1:TouchEvent):void
		{
			acceptButton.enabled = false;
			if (body == null)
			{
				g.rpc("acceptCrewMember", buyCrewResult, crewMember.name, crewMember.imageKey);
			}
		}
		
		private function buyCrewResult(param1:Message):void
		{
			var _loc2_:String = null;
			var _loc3_:int = 0;
			var _loc4_:CrewMember = null;
			if (param1.getBoolean(0) == true)
			{
				g.infoMessageDialog(param1.getString(1));
				_loc2_ = param1.getString(2);
				_loc3_ = param1.getInt(3);
				if (_loc2_ != "" && _loc3_ > 0)
				{
					g.myCargo.removeMinerals(_loc2_, _loc3_);
				}
				if (p.crewMembers.length < 5 && p.unlockedCrewSlots == p.crewMembers.length)
				{
					p.unlockedCrewSlots++;
				}
				p.initCrewFromMessage(param1, 4);
				_loc4_ = p.crewMembers[p.crewMembers.length - 1];
				Action.hire(_loc4_.imageKey, _loc4_.name);
				g.creditManager.refresh();
				ToolTip.disposeType("crewJoin");
				visible = false;
				g.removeChildFromOverlay(overlay);
			}
			else
			{
				g.showErrorDialog(param1.getString(1));
			}
		}
		
		private function resize(param1:Event = null):void
		{
			bgr.alpha = 0.8;
			bgr.width = g.stage.stageWidth;
			bgr.height = g.stage.stageHeight;
			infoBox.x = g.stage.stageWidth / 2 - infoBox.width / 2;
			infoBox.y = g.stage.stageHeight / 2 - infoBox.height / 2;
		}
		
		private function clean(param1:Event):void
		{
			removeEventListener("removedFromStage", clean);
			g.removeResizeListener(resize);
		}
	}
}
