package core.hud.components.cargo {
	import com.greensock.TweenMax;
	import core.credits.CreditManager;
	import core.hud.components.Button;
	import core.hud.components.ButtonCargo;
	import core.hud.components.PriceCommodities;
	import core.hud.components.TextBitmap;
	import core.hud.components.ToolTip;
	import core.hud.components.dialogs.PopupBuyMessage;
	import core.hud.components.dialogs.PopupConfirmMessage;
	import core.scene.Game;
	import data.DataLocator;
	import data.IDataManager;
	import feathers.controls.ScrollContainer;
	import feathers.layout.VerticalLayout;
	import generics.Localize;
	import playerio.Message;
	import sound.SoundLocator;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.filters.ColorMatrixFilter;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class Cargo extends Sprite {
		private static const TYPE_MINERAL:String = "mineral";
		
		private static const TYPE_SPACE_JUNK:String = "spaceJunk";
		
		private static const TYPE_DATA_ITEM:String = "dataItem";
		
		private static const upgradeCosts:Array = new Array({"9PxxP960kkejxGFHhy608A":0},{"9PxxP960kkejxGFHhy608A":20},{
			"h2-67R6yGEmPpWkPHATIeQ":20,
			"lmPr7d35rkq0Ev6RQRJGVw":1
		},{
			"hZ2FpZBh-kmRldjIi3rEwg":30,
			"Q-4DCSknqkaIGa1016-ggA":1,
			"K0RisGHC2UqZks1UVcYFOA":1
		},{
			"-1XaRBMHpEyTJxGsUtxGXw":35,
			"fPujzCjldEeJflK-PnPvBQ":2,
			"Q-4DCSknqkaIGa1016-ggA":1
		},{
			"1c46ec4C1UyRzxzv8hRqvw":80,
			"-1XaRBMHpEyTJxGsUtxGXw":35,
			"K0RisGHC2UqZks1UVcYFOA":10,
			"lmPr7d35rkq0Ev6RQRJGVw":5
		},{
			"1c46ec4C1UyRzxzv8hRqvw":100,
			"Q-4DCSknqkaIGa1016-ggA":20,
			"fPujzCjldEeJflK-PnPvBQ":20,
			"K0RisGHC2UqZks1UVcYFOA":20,
			"lmPr7d35rkq0Ev6RQRJGVw":15
		});
		
		private var _commodities:Vector.<CargoItem> = new Vector.<CargoItem>();
		
		private var _spaceJunk:Vector.<CargoItem> = new Vector.<CargoItem>();
		
		private var _dataItems:Vector.<CargoItem> = new Vector.<CargoItem>();
		
		private var _minerals:Vector.<CargoItem> = new Vector.<CargoItem>();
		
		private var playerId:String;
		
		private var g:Game;
		
		private var container:ScrollContainer = new ScrollContainer();
		
		private var confirmBox:PopupConfirmMessage = null;
		
		private var upgradeNames:Array = new Array("Compressor 1a","Compressor 5V","Compressor 5V-S","Compressor 7z","Shrinker X2k","Shrinker 85-5k","Shrinker X10k");
		
		public var compressorCapacities:Array = new Array(100,200,500,1000,2000,5000,10000);
		
		public var spaceJunkCount:int = 0;
		
		public function Cargo(g:Game, playerId:String) {
			super();
			this.g = g;
			this.playerId = playerId;
			g.addMessageHandler("cargoIsFull",handleServerSaysCargoIsFull);
		}
		
		private function handleServerSaysCargoIsFull(m:Message) : void {
			ButtonCargo.serverSaysCargoIsFull = true;
			g.hud.cargoButton.update();
		}
		
		public function reloadCargoView(callback:Function = null) : void {
			reloadCargoFromServer(function():void {
				draw();
				if(callback != null) {
					callback();
				}
			});
		}
		
		public function reloadCargoFromServer(callback:Function = null) : void {
			g.rpc("getCargo",function(param1:Message):void {
				cargoRecieved(param1);
				if(callback != null) {
					callback();
				}
			},playerId,"Commodities");
		}
		
		private function cargoRecieved(m:Message) : void {
			var table:String;
			var item:String;
			var type:String;
			var amount:int;
			var ci:CargoItem;
			var ci2:CargoItem;
			spaceJunkCount = 0;
			_commodities = new Vector.<CargoItem>();
			_minerals = new Vector.<CargoItem>();
			_spaceJunk = new Vector.<CargoItem>();
			_dataItems = new Vector.<CargoItem>();
			var i:int = 0;
			while(i < m.length) {
				table = m.getString(i);
				item = m.getString(i + 1);
				type = m.getString(i + 2);
				amount = m.getInt(i + 3);
				ci = new CargoItem(g,table,item,type,amount);
				if(type == "spaceJunk") {
					_spaceJunk.push(ci);
				}
				if(type == "mineral") {
					_minerals.push(ci);
				}
				if(type == "dataItem") {
					_dataItems.push(ci);
				}
				_commodities.push(ci);
				i += 4;
			}
			_spaceJunk.sort(function(param1:CargoItem, param2:CargoItem):int {
				if(param1.amount > param2.amount) {
					return -1;
				}
				return 1;
			});
			for each(ci2 in spaceJunk) {
				spaceJunkCount += ci2.amount;
			}
		}
		
		public function get commoditites() : Vector.<CargoItem> {
			return _commodities;
		}
		
		public function get spaceJunk() : Vector.<CargoItem> {
			return _spaceJunk;
		}
		
		public function get minerals() : Vector.<CargoItem> {
			return _minerals;
		}
		
		public function get dataItems() : Vector.<CargoItem> {
			return _dataItems;
		}
		
		public function hasMinerals(item:String, amount:int) : Boolean {
			for each(var _local3 in _minerals) {
				if(_local3.item == item && _local3.amount >= amount) {
					return true;
				}
			}
			return false;
		}
		
		public function hasCommodities(item:String, amount:int) : Boolean {
			for each(var _local3 in _commodities) {
				if(_local3.item == item && _local3.amount >= amount) {
					return true;
				}
			}
			return false;
		}
		
		private function draw(tween:Boolean = false) : void {
			var junkCapacityBar:Quad;
			var junkCapacityBarBgr:Quad;
			var perc:Number;
			var junkPercText:TextBitmap;
			var capacityHeadline:TextBitmap;
			var ejectButton:Button;
			var button:Button;
			var textureManager:ITextureManager;
			var compressorBoxTexture:Texture;
			var compressorArrowTexture:Texture;
			var i:int;
			var s:Sprite;
			var compressorBox:Image;
			var compressorArrow:Image;
			var compressor:Image;
			var cmf:ColorMatrixFilter;
			var cmf2:ColorMatrixFilter;
			var cmf3:ColorMatrixFilter;
			var junkHeadline:TextBitmap;
			var compressorHeadline:TextBitmap;
			var layout:VerticalLayout;
			var ci:CargoItem;
			this.removeChildren(0,-1,true);
			ToolTip.disposeType("compressor");
			junkCapacityBar = new Quad(40,4 * 60,0x44ff44);
			junkCapacityBarBgr = new Quad(40,4 * 60,0x222222);
			junkCapacityBar.x = 8 * 60;
			junkCapacityBarBgr.x = junkCapacityBar.x;
			junkCapacityBar.y = 30;
			junkCapacityBarBgr.y = junkCapacityBar.y;
			perc = spaceJunkCount / compressorCapacities[g.me.compressorLevel];
			perc = perc > 1 ? 1 : perc;
			if(perc < 0.5) {
				junkCapacityBar.color = 0x44ff44;
			} else if(perc < 0.75) {
				junkCapacityBar.color = 0xffff44;
			} else {
				junkCapacityBar.color = 0xff4444;
			}
			junkCapacityBar.height = perc * junkCapacityBarBgr.height;
			junkCapacityBar.y = junkCapacityBarBgr.y + junkCapacityBarBgr.height - junkCapacityBar.height;
			addChild(junkCapacityBarBgr);
			addChild(junkCapacityBar);
			junkPercText = new TextBitmap(0,0,"%",26);
			junkPercText.text = int(perc * 100) + "%";
			junkPercText.x = junkCapacityBarBgr.x + junkCapacityBarBgr.width / 2 - junkPercText.width / 2;
			junkPercText.y = junkCapacityBarBgr.y + junkCapacityBarBgr.height + 10;
			addChild(junkPercText);
			capacityHeadline = new TextBitmap(0,0,Localize.t("compression load"),13);
			capacityHeadline.x = junkCapacityBarBgr.x + junkCapacityBarBgr.width / 2 - capacityHeadline.width / 2;
			capacityHeadline.y = junkPercText.y + junkPercText.height + 5;
			addChild(capacityHeadline);
			ejectButton = new Button(function():void {
				confirmBox = new PopupConfirmMessage(Localize.t("Yes, do it!"),Localize.t("No!"));
				confirmBox.text = Localize.t("Are you really sure you want to drop ALL of your cargo?");
				g.addChildToOverlay(confirmBox,true);
				confirmBox.addEventListener("accept",onAccept);
				confirmBox.addEventListener("close",onClose);
			},Localize.t("Eject Cargo"),"negative");
			ejectButton.x = 525;
			ejectButton.y = -33;
			addChild(ejectButton);
			button = new Button(function():void {
				var fluxCost:int;
				var costs:Object;
				var type:String;
				var newlevel:int = g.me.compressorLevel + 1;
				var buyBox:PopupBuyMessage = new PopupBuyMessage(g);
				buyBox.text = Localize.t("Upgrade Compressor");
				fluxCost = CreditManager.getCostCompressor(newlevel);
				costs = upgradeCosts[newlevel];
				for(type in costs) {
					buyBox.addCost(new PriceCommodities(g,type,costs[type]));
				}
				if(fluxCost > 0) {
					buyBox.addBuyForFluxButton(fluxCost,newlevel,"upgradeCompressorWithFlux",Localize.t("Are you sure you want to upgrade your compressor?"));
					buyBox.addEventListener("fluxBuy",function(param1:Event):void {
						SoundLocator.getService().play("7zeIcPFb-UWzgtR_3nrZ8Q");
						g.me.compressorLevel = newlevel;
						g.removeChildFromOverlay(buyBox,true);
						draw(true);
						Game.trackEvent("used flux","upgrade cargo","level " + newlevel,fluxCost);
					});
				}
				buyBox.addEventListener("accept",function(param1:Event):void {
					var e:Event = param1;
					g.rpc("upgradeCompressor",function(param1:Message):void {
						if(param1.getBoolean(0)) {
							SoundLocator.getService().play("7zeIcPFb-UWzgtR_3nrZ8Q");
							g.me.compressorLevel = newlevel;
							for(var _local2 in costs) {
								removeJunk(_local2,costs[_local2]);
							}
							draw(true);
							ButtonCargo.serverSaysCargoIsFull = false;
						} else {
							g.showErrorDialog(param1.getString(1),true);
						}
						g.removeChildFromOverlay(buyBox,true);
					});
				});
				buyBox.addEventListener("close",function(param1:Event):void {
					g.removeChildFromOverlay(buyBox,true);
				});
				g.addChildToOverlay(buyBox);
			},Localize.t("Upgrade"),"buy");
			button.autoEnableAfterClick = true;
			button.x = 568;
			button.y = 415;
			button.pivotX = button.width / 2;
			addChild(button);
			if(g.me.compressorLevel >= upgradeCosts.length - 1) {
				button.visible = false;
			}
			textureManager = TextureLocator.getService();
			compressorBoxTexture = textureManager.getTextureGUIByTextureName("compressor_box");
			compressorArrowTexture = textureManager.getTextureGUIByTextureName("compressor_arrow");
			i = 0;
			while(i < upgradeCosts.length) {
				s = new Sprite();
				compressorBox = new Image(compressorBoxTexture);
				s.addChild(compressorBox);
				compressorArrow = new Image(compressorArrowTexture);
				s.addChild(compressorArrow);
				compressor = new Image(textureManager.getTextureGUIByTextureName("compressor" + i));
				s.addChild(compressor);
				compressor.x = Math.round(compressorBox.x + compressorBox.width / 2);
				compressor.y = Math.round(compressorBox.y + compressorBox.height / 2);
				compressor.pivotX = Math.round(compressor.width / 2);
				compressor.pivotY = Math.round(compressor.height / 2);
				compressorArrow.x = compressorBox.x + compressorBox.width;
				compressorArrow.y = 20;
				s.x = i * 70;
				s.y = 400;
				if(i == g.me.compressorLevel) {
					if(tween) {
						TweenMax.fromTo(compressor,1,{
							"scaleX":10,
							"scaleY":10
						},{
							"scaleX":1,
							"scaleY":1
						});
					}
					cmf = new ColorMatrixFilter();
					cmf.adjustContrast(2);
					compressorBox.filter = cmf;
					compressorBox.filter.cache();
					cmf2 = new ColorMatrixFilter();
					cmf.adjustContrast(2);
					compressorArrow.filter = cmf2;
					compressorArrow.filter.cache();
					cmf3 = new ColorMatrixFilter();
					cmf3.adjustBrightness(0.1);
					compressor.blendMode = "add";
					compressor.filter = cmf3;
					compressor.filter.cache();
				} else if(i > g.me.compressorLevel) {
					s.alpha = 0.1;
				}
				addChild(s);
				new ToolTip(g,s,upgradeNames[i] + ", " + Localize.t("capacity") + ": <FONT COLOR=\'#FFFFFF\'>" + compressorCapacities[i] + "</FONT>",null,"compressor");
				i++;
			}
			if(container != null) {
				removeChild(container);
				container = new ScrollContainer();
				container.y = 30;
			}
			junkHeadline = new TextBitmap();
			junkHeadline.text = Localize.t("Space Junk");
			junkHeadline.format.color = 11180632;
			junkHeadline.x = 0;
			junkHeadline.y = 1;
			addChild(junkHeadline);
			compressorHeadline = new TextBitmap();
			compressorHeadline.text = Localize.t("Compressor Level");
			compressorHeadline.format.color = 11180632;
			compressorHeadline.x = 0;
			compressorHeadline.y = 371;
			addChild(compressorHeadline);
			layout = new VerticalLayout();
			layout.gap = 10;
			container.layout = layout;
			i = 0;
			while(i < spaceJunk.length) {
				ci = spaceJunk[i];
				ci.draw();
				ci.x = 0;
				container.addChild(ci);
				i++;
			}
			i = 0;
			while(i < dataItems.length) {
				ci = dataItems[i];
				ci.draw();
				ci.x = 0;
				container.addChild(ci);
				i++;
			}
			container.width = 6 * 60;
			container.height = 5 * 60;
			addChild(container);
		}
		
		private function onAccept(e:Event) : void {
			g.removeChildFromOverlay(confirmBox,true);
			confirmBox.removeEventListeners();
			g.send("dropJunk");
			removeAllJunk();
		}
		
		private function onClose(e:Event) : void {
			g.removeChildFromOverlay(confirmBox,true);
			confirmBox.removeEventListeners();
		}
		
		public function getCommoditiesAmount(item:String) : int {
			for each(var _local2 in commoditites) {
				if(_local2.item == item) {
					return _local2.amount;
				}
			}
			return 0;
		}
		
		public function removeMinerals(mineral:String, amount:int) : void {
			for each(var _local3 in _minerals) {
				if(_local3.item == mineral && _local3.amount >= amount) {
					_local3.amount -= amount;
				}
			}
		}
		
		public function removeJunk(junk:String, amount:int) : void {
			for each(var _local3 in _spaceJunk) {
				if(_local3.item == junk && _local3.amount >= amount) {
					_local3.amount -= amount;
				}
			}
			spaceJunkCount -= amount;
		}
		
		public function removeAllJunk() : void {
			for each(var _local1 in _spaceJunk) {
				_local1.amount = 0;
			}
			spaceJunkCount = 0;
		}
		
		public function addItem(table:String, item:String, amount:int) : void {
			var _local5:* = null;
			var _local7:IDataManager = DataLocator.getService();
			var _local4:Object = _local7.loadKey(table,item);
			if(_local4 == null) {
				return;
			}
			if(_local4.type == "spaceJunk") {
				spaceJunkCount += amount;
				_local5 = null;
				for each(var _local6 in _spaceJunk) {
					if(_local6.item == item) {
						_local5 = _local6;
						break;
					}
				}
			} else {
				if(_local4.type != "mineral") {
					return;
				}
				_local5 = null;
				for each(_local6 in _minerals) {
					if(_local6.item == item) {
						_local5 = _local6;
						break;
					}
				}
			}
			if(_local5 != null) {
				_local5.amount += amount;
			} else {
				_local5 = new CargoItem(g,table,item,_local4.type,amount);
				if(_local4.type == "spaceJunk") {
					_spaceJunk.push(_local5);
				}
				if(_local4.type == "mineral") {
					_minerals.push(_local5);
				}
			}
		}
		
		public function redraw(callback:Function = null) : void {
			draw();
			if(callback != null) {
				callback();
			}
		}
		
		public function get isFull() : Boolean {
			return spaceJunkCount >= compressorCapacities[g.me.compressorLevel];
		}
	}
}

