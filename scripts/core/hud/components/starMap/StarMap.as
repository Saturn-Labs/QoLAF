package core.hud.components.starMap {
	import com.greensock.TweenMax;
	import core.credits.CreditManager;
	import core.friend.Friend;
	import core.hud.components.Button;
	import core.hud.components.Style;
	import core.hud.components.Text;
	import core.hud.components.credits.FBInviteUnlock;
	import core.hud.components.dialogs.CreditBuyBox;
	import core.player.CrewMember;
	import core.player.Player;
	import core.scene.Game;
	import data.DataLocator;
	import data.IDataManager;
	import debug.Console;
	import facebook.Action;
	import generics.Localize;
	import playerio.Message;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class StarMap extends Sprite {
		public static var selectedSolarSystem:SolarSystem;
		
		private static const PADDING:Number = 30;
		
		public static var friendsInSelectedSystem:Array = [];
		
		private var g:Game;
		
		private var p:Player;
		
		private var dataManager:IDataManager;
		
		private var discoveredSolarSystemsKeys:Array;
		
		private var allSolarSystems:Object;
		
		private var solarSystemIcons:Array;
		
		private var _height:Number;
		
		private var _width:Number;
		
		private var animationTween:TweenMax;
		
		private var textureManager:ITextureManager;
		
		private var container:Sprite;
		
		private var warpPathContainer:Sprite;
		
		private var galaxyText:Text;
		
		private var crewText:Text;
		
		private var crewBullet:Image;
		
		private var friendsInSystem:Sprite;
		
		private var friendsBullet:Image;
		
		private var crewAndFriendContainer:Sprite;
		
		private var _selectedWarpPath:WarpPath;
		
		private var allowBuy:Boolean;
		
		private var _currentSolarSystemKey:String;
		
		private var _currentSolarSystem:SolarSystem;
		
		private var focusSolarSystemKey:String;
		
		private var neighbours:Array;
		
		private var _warpPathLicenses:Array;
		
		private var _warpPaths:Array;
		
		private var confirmBuyWithFlux:CreditBuyBox;
		
		private var aquiredContainer:Sprite;
		
		private var aquiredText:Text;
		
		private var buyContainer:Sprite;
		
		private var buyButton:Button;
		
		private var buyWithFluxButton:Button;
		
		private var buyWithInviteButton:FBInviteUnlock = null;
		
		private var shipImage:MovieClip;
		
		private var orText:Text;
		
		public function StarMap(g:Game, width:Number = 540, height:Number = 240, allowBuy:Boolean = false, focusSolarSystemKey:String = "") {
			var bgr2:Image;
			var obj:Object;
			var obj2:Object;
			container = new Sprite();
			warpPathContainer = new Sprite();
			galaxyText = new Text();
			crewText = new Text();
			friendsInSystem = new Sprite();
			crewAndFriendContainer = new Sprite();
			neighbours = [];
			_warpPathLicenses = [];
			_warpPaths = [];
			aquiredContainer = new Sprite();
			aquiredText = new Text();
			buyContainer = new Sprite();
			super();
			this.g = g;
			this.p = g.me;
			this.allowBuy = allowBuy;
			this.focusSolarSystemKey = focusSolarSystemKey;
			textureManager = TextureLocator.getService();
			dataManager = DataLocator.getService();
			_height = height;
			_width = width;
			solarSystemIcons = [];
			bgr2 = new Image(textureManager.getTextureGUIByTextureName("star_map.jpg"));
			container.addChild(bgr2);
			container.addChild(warpPathContainer);
			container.mask = new Quad(width,height);
			galaxyText.size = 14;
			galaxyText.x = 20;
			galaxyText.y = 15;
			addChild(container);
			addChild(galaxyText);
			buyContainer.x = 500;
			buyContainer.y = 15;
			buyContainer.visible = false;
			crewAndFriendContainer.x = 500;
			crewAndFriendContainer.y = 40;
			crewAndFriendContainer.touchable = false;
			crewText.x = 530;
			crewText.y = 80;
			crewText.size = 10;
			crewText.color = Style.COLOR_CREW;
			crewText.touchable = false;
			addChild(crewText);
			friendsBullet = new Image(textureManager.getTextureGUIByTextureName("bullet_friend"));
			crewBullet = new Image(textureManager.getTextureGUIByTextureName("bullet_crew"));
			crewBullet.x = 520;
			friendsBullet.x = 520;
			crewBullet.visible = false;
			friendsBullet.visible = false;
			crewBullet.pivotX = crewBullet.width / 2;
			crewBullet.pivotY = crewBullet.height / 2;
			crewBullet.color = Style.COLOR_CREW;
			friendsBullet.pivotX = friendsBullet.width / 2;
			friendsBullet.pivotY = friendsBullet.height / 2;
			friendsBullet.color = Style.COLOR_FRIENDS;
			addChild(crewBullet);
			addChild(friendsBullet);
			friendsInSystem.x = 530;
			friendsInSystem.y = 80;
			addChild(friendsInSystem);
			orText = new Text();
			orText.size = 25;
			orText.text = "or";
			orText.visible = false;
			aquiredText.size = 10;
			aquiredText.width = 150;
			aquiredText.height = 80;
			aquiredText.wordWrap = true;
			aquiredText.y = 15;
			aquiredText.x = 10;
			aquiredContainer.visible = true;
			aquiredText.color = Style.COLOR_VALID;
			aquiredText.text = Localize.t("You are here.");
			aquiredContainer.x = 500;
			aquiredContainer.y = 15;
			if(allowBuy) {
				buyButton = new Button(function(param1:TouchEvent):void {
					if(selectedWarpPath != null) {
						if(selectedSolarSystem.dev && !g.me.isDeveloper) {
							g.showErrorDialog(Localize.t("Sorry! This warp path is not yet ready for hyper speed!"));
							return;
						}
						g.rpc("buyWarpPath",boughtWarpPath,selectedWarpPath.key);
					}
				},Localize.t("Buy"),"positive");
				buyButton.name = "buyButton";
				buyContainer.addChild(orText);
				buyContainer.addChild(buyButton);
				buyWithFluxButton = new Button(function():void {
					var warpPathObj:Object;
					var fluxCost:int;
					if(selectedWarpPath == null) {
						return;
					}
					if(selectedSolarSystem.dev && (!g.me.isTester && !g.me.isDeveloper)) {
						g.showErrorDialog(Localize.t("Sorry! This warp path is not yet ready for hyper speed!"));
						return;
					}
					warpPathObj = dataManager.loadKey("WarpPaths",selectedWarpPath.key);
					fluxCost = CreditManager.getCostWarpPathLicense(warpPathObj.payVaultItem);
					g.creditManager.refresh(function():void {
						confirmBuyWithFlux = new CreditBuyBox(g,fluxCost,Localize.t("Are you sure you want to buy the warp path license?"));
						g.addChildToOverlay(confirmBuyWithFlux);
						confirmBuyWithFlux.addEventListener("accept",onAccept);
						confirmBuyWithFlux.addEventListener("close",onClose);
					});
				},Localize.t("Buy with Flux"),"highlight");
				buyContainer.addChild(buyWithFluxButton);
				if(Login.currentState == "facebook") {
					buyWithInviteButton = new FBInviteUnlock(g,Math.ceil(1),function():void {
						if(selectedWarpPath != null) {
							if(selectedSolarSystem.dev && (!g.me.isTester && !g.me.isDeveloper)) {
								g.showErrorDialog(Localize.t("Sorry! This warp path is not yet ready for hyper speed!"));
								return;
							}
							g.rpc("buyWarpPathWithInvites",boughtWarpPath,selectedWarpPath.key);
						}
					},function():void {
						g.showErrorDialog(Localize.t("Insufficient number of invites."));
					});
					buyWithInviteButton.visible = false;
					buyWithInviteButton.enabled = false;
					buyContainer.addChild(buyWithInviteButton);
				}
			}
			obj = dataManager.loadKey("Skins",p.activeSkin);
			obj2 = dataManager.loadKey("Ships",obj.ship);
			shipImage = new MovieClip(textureManager.getTexturesMainByKey(obj2.bitmap));
			shipImage.readjustSize();
			shipImage.scaleX = 0.5;
			shipImage.scaleY = 0.5;
			container.addChild(shipImage);
			aquiredContainer.addChild(aquiredText);
			addChild(aquiredContainer);
			addEventListener("removedFromStage",clean);
		}
		
		public function load(callback:Function = null) : void {
			var systemKey:String;
			var system:Object;
			var dataManager:IDataManager = DataLocator.getService();
			_currentSolarSystemKey = g.solarSystem.key;
			_warpPathLicenses = p.warpPathLicenses;
			discoveredSolarSystemsKeys = [];
			for each(systemKey in p.solarSystemLicenses) {
				system = dataManager.loadKey("SolarSystems",systemKey);
				if(system != null) {
					discoveredSolarSystemsKeys.push(systemKey);
				}
			}
			allSolarSystems = dataManager.loadTable("SolarSystems");
			createMap();
			loadFriends(function():void {
				loadCrew();
				if(focusSolarSystemKey == "") {
					focusSolarSystemKey = currentSolarSystem.key;
				}
				var _local1:SolarSystem = findSolarSystemIcon(focusSolarSystemKey);
				if(_local1 != null) {
					selectedSolarSystem.selected = false;
					selectIcon(_local1);
				}
				if(callback != null) {
					callback();
				}
			});
		}
		
		private function loadFriends(callback:Function) : void {
			g.friendManager.updateOnlineFriends(function():void {
				if(Player.onlineFriends.length == 0) {
					callback();
					return;
				}
				for each(var _local2 in solarSystemIcons) {
					for each(var _local1 in Player.onlineFriends) {
						if(_local1.currentSolarSystem == _local2.key) {
							_local2.hasFriends = true;
						}
					}
				}
				callback();
			});
		}
		
		private function loadCrew() : void {
			var _local1:Vector.<CrewMember> = g.me.crewMembers;
			for each(var _local3 in solarSystemIcons) {
				for each(var _local2 in _local1) {
					if(_local2.solarSystem == _local3.key) {
						_local3.hasCrew = true;
					}
				}
			}
		}
		
		private function createMap() : void {
			var _local1:Object = null;
			var _local4:SolarSystem = null;
			var _local5:Object = null;
			var _local10:SolarSystem = null;
			var _local11:SolarSystem = null;
			var _local3:Boolean = false;
			var _local8:WarpPath = null;
			for(var _local9 in allSolarSystems) {
				_local1 = allSolarSystems[_local9];
				_local4 = new SolarSystem(g,_local1,_local9,isDiscovered(_local9),_currentSolarSystemKey);
				if(!(_local1 == null || !_local1.hasOwnProperty("type") || _local1.type != "regular" && _local1.type != "pvp")) {
					container.addChild(_local4);
					solarSystemIcons.push(_local4);
					if(_local4.isCurrentSolarSystem) {
						updateRect(_local4.x,_local4.y);
						shipImage.x = _local4.x + _local4.size + 5;
						shipImage.y = _local4.y - _local4.size - 20;
						galaxyText.text = _local4.galaxy;
						galaxyText.color = _local4.color;
						_local4.selected = true;
						_currentSolarSystem = _local4;
						selectedSolarSystem = _local4;
					}
					if(!_local4.isDestroyed) {
						_local4.addEventListener("touch",onTouch);
					}
				}
			}
			var _local2:Object = dataManager.loadTable("WarpPaths");
			for(var _local6 in _local2) {
				_local5 = _local2[_local6];
				_local10 = findSolarSystemIcon(_local5.solarSystem1);
				_local11 = findSolarSystemIcon(_local5.solarSystem2);
				if(_local10 == null || _local11 == null) {
					Console.write("Something went wrong, could not find solarSystemIcon in Star Map.");
				} else {
					if(_local10.key == currentSolarSystem.key) {
						neighbours.push(_local11.key);
					} else if(_local11.key == currentSolarSystem.key) {
						neighbours.push(_local10.key);
					}
					_local3 = false;
					for each(var _local7 in _warpPathLicenses) {
						if(_local7 == _local5.key) {
							_local3 = true;
						}
					}
					_local8 = new WarpPath(g,_local5,_local10,_local11,_local3);
					_local8.x = _local10.x;
					_local8.y = _local10.y;
					if(_local8.transit) {
						_local8.addEventListener("transitClick",transitClick);
					}
					_warpPaths.push(_local8);
					warpPathContainer.addChild(_local8);
				}
			}
		}
		
		private function transitClick(e:Event) : void {
			var _local2:* = null;
			var _local3:String = e.data.solarSystemKey;
			for each(_local2 in solarSystemIcons) {
				_local2.selected = false;
				if(_local2.key == _local3) {
					selectIcon(_local2);
				}
			}
		}
		
		private function onTouch(e:TouchEvent) : void {
			var _local3:SolarSystem = e.currentTarget as SolarSystem;
			if(e.getTouch(_local3,"ended")) {
				for each(var _local2 in solarSystemIcons) {
					_local2.selected = false;
				}
				selectIcon(_local3);
			}
		}
		
		private function selectIcon(icon:SolarSystem) : void {
			var _local8:WarpToFriendRow = null;
			icon.selected = true;
			galaxyText.text = icon.galaxy;
			galaxyText.color = icon.color;
			selectedSolarSystem = icon;
			var _local3:String = "<FONT COLOR=\'#666666\'>" + Localize.t("Crew") + "</FONT>\n";
			var _local2:Vector.<CrewMember> = g.me.getCrewMembersBySolarSystem(icon.key);
			if(_local2.length > 0) {
				crewText.visible = true;
				crewBullet.visible = true;
			} else {
				crewText.visible = false;
				crewBullet.visible = false;
			}
			for each(var _local5 in _local2) {
				_local3 += _local5.name + "\n";
			}
			_local3 += "\n\n";
			crewText.htmlText = _local3;
			crewBullet.y = crewText.y + 8;
			var _local6:int = 0;
			friendsInSystem.removeChildren(0,-1,true);
			var _local4:Text = new Text();
			_local4.text = Localize.t("Friends") + ":";
			_local4.color = 0x666666;
			friendsInSystem.addChild(_local4);
			friendsInSelectedSystem = [];
			for each(var _local7 in Player.onlineFriends) {
				if(_local7.currentSolarSystem == icon.key) {
					_local6++;
					_local8 = new WarpToFriendRow(_local7);
					_local8.y = _local6 * 25;
					friendsInSystem.addChild(_local8);
					friendsInSelectedSystem.push(_local7);
				}
			}
			if(_local6 > 0) {
				friendsInSystem.visible = true;
				friendsBullet.visible = true;
			} else {
				friendsInSystem.visible = false;
				friendsBullet.visible = false;
			}
			friendsInSystem.y = crewText.y + crewText.height;
			friendsBullet.y = friendsInSystem.y + 8;
			updateRect(icon.x,icon.y);
			for each(var _local9 in _warpPaths) {
				_local9.selected = false;
			}
			handleWarpJumpAllowance();
		}
		
		private function handleWarpJumpAllowance() : void {
			var _local5:* = null;
			var _local3:* = undefined;
			var _local4:DisplayObject = null;
			var _local7:Sprite = null;
			var _local2:Object = null;
			var _local8:int = 0;
			buyContainer.visible = false;
			aquiredContainer.visible = false;
			_selectedWarpPath = null;
			for each(_local5 in _warpPaths) {
				_local5.selected = false;
			}
			if(selectedSolarSystem == _currentSolarSystem) {
				aquiredContainer.visible = true;
				aquiredText.text = Localize.t("You are here.");
				aquiredText.color = Style.COLOR_VALID;
				aquiredContainer.y = 15;
				dispatchEvent(new Event("disallowWarpJump"));
				return;
			}
			if(allowBuy) {
				_local3 = findClosestPath(selectedSolarSystem.key);
				for each(var _local1 in _local3) {
					for each(_local5 in _warpPaths) {
						if(_local1.parent != null) {
							if(_local5.isConnectedTo(_local1.key,_local1.parent.key)) {
								_local5.selected = true;
							}
						}
					}
				}
				if(_local3 != null && _local3.length > 1) {
					for each(_local5 in _warpPaths) {
						if(_local5.isConnectedTo(_local3[0].key,_local3[1].key)) {
							Console.write("Warp path key: " + _local5.key);
							_selectedWarpPath = _local5;
							_local5.selected = true;
							for each(var _local6 in p.solarSystemLicenses) {
								if(_local6 == selectedSolarSystem.key) {
									_selectedWarpPath.bought = true;
								}
							}
							if(!_selectedWarpPath.bought) {
								aquiredContainer.visible = false;
								buyButton.x = 0;
								buyButton.y = 0;
								_local4 = buyContainer.getChildByName("costContainer");
								if(_local4 != null) {
									buyContainer.removeChild(_local4);
								}
								_local7 = _selectedWarpPath.costContainer;
								_local7.x = 0;
								_local7.y = buyButton.y + buyButton.height + 8;
								_local7.visible = true;
								_local7.name = "costContainer";
								_local7.touchable = false;
								buyContainer.addChild(_local7);
								_local2 = dataManager.loadKey("WarpPaths",_local5.key);
								_local8 = CreditManager.getCostWarpPathLicense(_local2.payVaultItem);
								if(_local8 > 0) {
									orText.visible = true;
									orText.color = 0xaaaaaa;
									orText.x = 5;
									orText.y = _local7.y + _local7.height + 5;
									buyWithFluxButton.text = Localize.t("Buy for [flux] Flux").replace("[flux]",_local8);
									buyWithFluxButton.x = buyButton.x;
									buyWithFluxButton.y = _local7.y + _local7.height + 45;
									buyWithFluxButton.visible = true;
									if(buyWithInviteButton != null) {
										buyWithInviteButton.setNrRequired(Math.max(2,Math.ceil(0.04 * _local8)));
										buyWithInviteButton.visible = true;
										buyWithInviteButton.enabled = true;
										buyWithInviteButton.x = buyWithFluxButton.x;
										buyWithInviteButton.y = buyWithFluxButton.y + buyWithFluxButton.height + 15;
									}
								} else {
									buyWithFluxButton.visible = false;
									if(buyWithInviteButton != null) {
										buyWithInviteButton.visible = false;
										buyWithInviteButton.enabled = false;
									}
								}
								buyContainer.x = 15;
								buyContainer.y = 45;
								addChild(buyContainer);
								buyContainer.visible = true;
								dispatchEvent(new Event("disallowWarpJump"));
								return;
							}
							dispatchEvent(new Event("allowWarpJump"));
							return;
						}
					}
				}
			}
			aquiredContainer.visible = true;
			aquiredText.text = Localize.t("You can\'t warp jump to here.");
			aquiredText.color = Style.COLOR_INVALID;
			aquiredContainer.y = 15;
			dispatchEvent(new Event("disallowWarpJump"));
		}
		
		private function findClosestPath(destinationKey:String) : Vector.<Node> {
			var _local3:Node = new Node(currentSolarSystem.key);
			var _local2:Node = fbs(_local3,destinationKey);
			if(_local2 == null) {
				return null;
			}
			return _local2.getNodePath();
		}
		
		private function fbs(currentNode:Node, destinationKey:String) : Node {
			var _local4:Vector.<Node> = new Vector.<Node>();
			var _local3:Vector.<WarpPath> = new Vector.<WarpPath>();
			_local4.push(currentNode);
			while(currentNode.key != destinationKey) {
				if(_local4.length == 0) {
					return null;
				}
				currentNode = _local4.shift();
				findChildren(currentNode,_local3);
				for each(var _local5 in currentNode.children) {
					_local4.push(_local5);
				}
			}
			return currentNode;
		}
		
		private function findChildren(node:Node, paths:Vector.<WarpPath>) : void {
			var _local4:Node = null;
			for each(var _local3 in _warpPaths) {
				if(paths.indexOf(_local3) == -1) {
					_local4 = null;
					if(node.key == _local3.solarSystem1) {
						_local4 = new Node(_local3.solarSystem2);
					} else if(node.key == _local3.solarSystem2) {
						_local4 = new Node(_local3.solarSystem1);
					}
					if(_local4 != null) {
						node.addChild(_local4);
						paths.push(_local3);
					}
				}
			}
		}
		
		private function isDiscovered(key:String) : Boolean {
			for each(var _local2 in discoveredSolarSystemsKeys) {
				if(_local2 == key) {
					return true;
				}
			}
			return false;
		}
		
		private function findSolarSystemIcon(key:String) : SolarSystem {
			for each(var _local2 in solarSystemIcons) {
				if(_local2.key == key) {
					return _local2;
				}
			}
			return null;
		}
		
		private function updateRect(x:Number, y:Number) : void {
			var rect:DisplayObject = container.mask;
			if(animationTween != null) {
				animationTween.kill();
			}
			animationTween = TweenMax.to(rect,1,{
				"x":x - _width / 2,
				"y":y - _height / 2,
				"onUpdate":function():void {
					container.x = -rect.x;
					container.y = -rect.y;
				}
			});
		}
		
		public function get selectedWarpPath() : WarpPath {
			return _selectedWarpPath;
		}
		
		public function get currentSolarSystem() : SolarSystem {
			return _currentSolarSystem;
		}
		
		private function onAccept(e:Event) : void {
			g.rpc("buyWarpPathWithFlux",boughtWarpPathWithFlux,selectedWarpPath.key);
			confirmBuyWithFlux.removeEventListener("accept",onAccept);
			confirmBuyWithFlux.removeEventListener("close",onClose);
		}
		
		private function boughtWarpPathWithFlux(m:Message) : void {
			var _local2:Object = null;
			var _local3:int = 0;
			if(m.getBoolean(0)) {
				selectedSolarSystem.discovered = true;
				selectedWarpPath.bought = true;
				p.solarSystemLicenses.push(selectedSolarSystem.key);
				p.warpPathLicenses.push(selectedWarpPath.key);
				_local2 = dataManager.loadKey("WarpPaths",selectedWarpPath.key);
				_local3 = CreditManager.getCostWarpPathLicense(_local2.payVaultItem);
				selectIcon(selectedSolarSystem);
				Game.trackEvent("used flux","warp path",selectedWarpPath.name,_local3);
				Action.unlockSystem(selectedSolarSystem.key);
				g.creditManager.refresh();
				animateBuy();
			} else {
				buyWithFluxButton.enabled = true;
				if(m.length > 1) {
					g.showErrorDialog(m.getString(1));
				}
			}
		}
		
		private function onClose(e:Event) : void {
			confirmBuyWithFlux.removeEventListener("accept",onAccept);
			confirmBuyWithFlux.removeEventListener("close",onClose);
			buyWithFluxButton.enabled = true;
		}
		
		private function boughtWarpPath(m:Message) : void {
			if(m.getBoolean(0) && selectedWarpPath != null && selectedSolarSystem != null) {
				selectedSolarSystem.discovered = true;
				selectedWarpPath.bought = true;
				p.solarSystemLicenses.push(selectedSolarSystem.key);
				p.warpPathLicenses.push(selectedWarpPath.key);
				for each(var _local2 in selectedWarpPath.priceItems) {
					g.myCargo.removeMinerals(_local2.item,_local2.amount);
				}
				selectIcon(selectedSolarSystem);
				Action.unlockSystem(selectedSolarSystem.key);
				Console.write("Warp path bought!");
				animateBuy();
			} else {
				buyButton.enabled = true;
				if(m.length > 1) {
					g.showErrorDialog(m.getString(1));
				}
			}
		}
		
		private function animateBuy() : void {
			var soundManager:ISound = SoundLocator.getService();
			soundManager.preCacheSound("7zeIcPFb-UWzgtR_3nrZ8Q",function():void {
				TweenMax.from(selectedSolarSystem,1,{
					"scaleX":8,
					"scaleY":8,
					"alpha":0
				});
				soundManager.play("7zeIcPFb-UWzgtR_3nrZ8Q");
			});
		}
		
		public function clean(e:Event = null) : void {
			Console.write("Clean up warp gate");
			for each(var _local2 in _warpPaths) {
				_local2.removeEventListener("transitClick",transitClick);
			}
			removeEventListener("removedFromStage",clean);
			dispose();
		}
	}
}

import core.friend.Friend;
import core.hud.components.Style;
import core.hud.components.Text;
import starling.display.Sprite;

class Node {
	private var _children:Vector.<Node> = new Vector.<Node>();
	
	public var parent:Node = null;
	
	private var _key:String;
	
	public function Node(key:String) {
		super();
		_key = key;
	}
	
	public function addChild(node:Node) : void {
		node.parent = this;
		_children.push(node);
	}
	
	public function get children() : Vector.<Node> {
		return _children;
	}
	
	public function get key() : String {
		return _key;
	}
	
	public function getNodePath(nodes:Vector.<Node> = null) : Vector.<Node> {
		if(nodes == null) {
			nodes = new Vector.<Node>();
		}
		nodes.push(this);
		if(parent != null) {
			return parent.getNodePath(nodes);
		}
		return nodes;
	}
}

class WarpToFriendRow extends Sprite {
	public function WarpToFriendRow(f:Friend) {
		super();
		var _local2:Text = new Text();
		_local2.color = Style.COLOR_H2;
		_local2.text = f.name;
		addChild(_local2);
	}
}
