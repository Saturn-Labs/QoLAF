package core.hud.components.playerList
{
	import core.clan.PlayerClanLogo;
	import core.credits.CreditManager;
	import core.group.Group;
	import core.hud.components.Button;
	import core.hud.components.Style;
	import core.hud.components.TextBitmap;
	import core.hud.components.ToolTip;
	import core.hud.components.dialogs.CreditBuyBox;
	import core.player.FleetObj;
	import core.player.Invite;
	import core.player.Player;
	import core.scene.Game;
	import core.ship.ShipFactory;
	import data.DataLocator;
	import data.IDataManager;
	import generics.Localize;
	import generics.Util;
	import playerio.Message;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.display.Sprite;
	import textures.ITextureManager;
	import textures.TextureLocator;

	public class PlayerListItem extends Sprite
	{
		public var player:Player;
		private var inviteButton:Button;
		private var leaveButton:Button;
		private var joinButton:Button;
		private var declineButton:Button;
		private var addFriendButton:Button;
		private var acceptFriendButton:Button;
		private var teleportToFriendButton:Button;
		private var _width:Number = 0;
		private var _height:Number = 0;
		private var clanLogo:Image;
		private var g:Game;
		public function PlayerListItem(param1:Game, param2:Player, param3:Number, param4:Number)
		{
			var textureManager:ITextureManager;
			var dataManager:IDataManager;
			var bgr:Quad;
			var clanLogo:PlayerClanLogo;
			var skinObj:Object;
			var obj:Object;
			var obj2:Object;
			var fleetObj:FleetObj;
			var preview:MovieClip;
			var shipHue:Number;
			var shipBrightness:Number;
			var engineHue:Number;
			var xx:int;
			var supporterImage:Image;
			var playerName:TextBitmap;
			var troons:TextBitmap;
			var levelString:String;
			var level:TextBitmap;
			var troonImg:Image;
			var tooltipText:String;
			var rating:TextBitmap;
			var ratingImg:Image;
			var rank:TextBitmap;
			var buttonWidth:int;
			var g:Game = param1;
			var player:Player = param2;
			var width:Number = param3;
			var height:Number = param4;
			super();
			this.g = g;
			this.player = player;
			textureManager = TextureLocator.getService();
			dataManager = DataLocator.getService();
			_width = width;
			_height = height;
			bgr = new Quad(640, 40, 921102);
			bgr.alpha = 0;
			addChild(bgr);
			clanLogo = new PlayerClanLogo(g, player, function(param1:Boolean = true):void
				{
					var _loc2_:TextBitmap = new TextBitmap(50, 12, Localize.t("Freelancer"), 13);
					_loc2_.x = playerName.x;
					_loc2_.y = playerName.y + 24;
					if (param1)
					{
						_loc2_.text = Localize.t("[rank] in [clan]").replace("[rank]", player.clanRankName).replace("[clan]", player.clanName);
						_loc2_.format.color = player.clanLogoColor;
					}
					else
					{
						_loc2_.format.color = 16777215;
						_loc2_.alpha = 0.5;
					}
					while (_loc2_.width > 200)
					{
						_loc2_.size--;
					}
					addChild(_loc2_);
				});
			clanLogo.x = 8;
			clanLogo.y = 8;
			addChild(clanLogo);
			skinObj = dataManager.loadKey("Skins", player.activeSkin);
			obj = dataManager.loadKey("Ships", skinObj.ship);
			obj2 = dataManager.loadKey("Images", obj.bitmap);
			fleetObj = player.getActiveFleetObj();
			preview = new MovieClip(textureManager.getTexturesMainByKey(obj.bitmap));
			preview.pivotX = preview.width / 2;
			preview.pivotY = preview.height / 2;
			if (preview.width > 40)
			{
				preview.scaleX = preview.scaleY = 40 / preview.width;
			}
			preview.x = 40 + preview.width / 2;
			preview.y = 16;
			addChild(preview);
			shipHue = !!fleetObj.shipHue ? fleetObj.shipHue : 0;
			shipBrightness = !!fleetObj.shipBrightness ? fleetObj.shipBrightness : 0;
			engineHue = !!fleetObj.engineHue ? fleetObj.engineHue : 0;
			if (shipHue != 0 || shipBrightness != 0)
			{
				preview.filter = ShipFactory.createPlayerShipColorMatrixFilter(fleetObj);
			}
			xx = 80;
			if (player.hasSupporter())
			{
				supporterImage = new Image(textureManager.getTextureGUIByTextureName("icon_supporter.png"));
				supporterImage.x = preview.x + preview.width / 2 + 5;
				supporterImage.y = 8;
				addChild(supporterImage);
				xx = 95;
			}
			playerName = new TextBitmap(xx, 2, player.name, 20);
			playerName.format.color = player.isHostile ? Style.COLOR_HOSTILE : 16777215;
			while (playerName.width > 220)
			{
				playerName.size -= 1;
			}
			addChild(playerName);
			troons = new TextBitmap();
			troons.text = Util.formatAmount(player.troons);
			troons.x = 280;
			troons.y = 2;
			troons.size = 20;
			troons.format.color = 15985920;
			addChild(troons);
			levelString = Localize.t("lvl") + " " + player.level.toString();
			level = new TextBitmap(50, 12, levelString, 13);
			level.format.color = 16777215;
			level.x = troons.x;
			level.y = troons.y + 24;
			if (player.isDeveloper)
			{
				level.text = Localize.t("developer");
				level.format.color = 14129151;
			}
			else if (player.isModerator)
			{
				level.text = Localize.t("mod") + " " + level.text;
				level.format.color = 16755268;
			}
			level.alpha = 0.5;
			addChild(level);
			troonImg = new Image(textureManager.getTextureGUIByTextureName("troon.png"));
			troonImg.x = troons.x + troons.width + 10;
			troonImg.y = troons.y - 1;
			addChild(troonImg);
			tooltipText = Localize.t("Troons give bonus stats to your ship if its above <FONT COLOR='#FFFFFF'>200 000</FONT>.");
			new ToolTip(g, troonImg, tooltipText, null, "playerListItem");
			rating = new TextBitmap();
			rating.text = Util.formatAmount(player.rating);
			rating.x = troons.x + 120;
			rating.y = 2;
			rating.size = 20;
			rating.format.color = 15985920;
			addChild(rating);
			ratingImg = new Image(textureManager.getTextureGUIByTextureName("clan_logo3.png"));
			ratingImg.y = y + 21;
			ratingImg.color = 16711680;
			ratingImg.x = rating.x + rating.width + 10;
			ratingImg.scaleX = ratingImg.scaleY = 0.25;
			ratingImg.rotation = -0.5 * 3.141592653589793;
			addChild(ratingImg);
			rank = new TextBitmap(50, 12, "Rank " + player.ranking.toString(), 13);
			rank.format.color = 16777215;
			rank.x = rating.x;
			rank.y = rating.y + 24;
			addChild(rank);
			buttonWidth = 140;
			inviteButton = new Button(function():void
				{
					inviteButton.enabled = false;
					g.groupManager.invitePlayer(player);
				}, Localize.t("add to group"));
			inviteButton.scaleX = inviteButton.scaleY = 0.9;
			inviteButton.x = 530;
			inviteButton.y = -2;
			inviteButton.width = buttonWidth;
			leaveButton = new Button(function():void
				{
					g.groupManager.leaveGroup();
				}, Localize.t("leave group"));
			leaveButton.scaleX = leaveButton.scaleY = 0.9;
			leaveButton.x = 530;
			leaveButton.y = inviteButton.y;
			leaveButton.width = buttonWidth;
			joinButton = new Button(function():void
				{
					toggleFriendButtons(true);
					var _loc1_:Invite = g.groupManager.findInvite(player.group.id, g.me);
					joinButton.visible = false;
					declineButton.visible = false;
					if (!_loc1_)
					{
						return;
					}
					g.groupManager.acceptGroupInvite(_loc1_.id);
				}, Localize.t("join group"), "positive");
			joinButton.scaleX = joinButton.scaleY = 0.9;
			joinButton.x = 530;
			joinButton.y = inviteButton.y;
			joinButton.width = buttonWidth;
			addFriendButton = new Button(function():void
				{
					addFriendButton.enabled = false;
					g.friendManager.sendFriendRequest(player);
				}, Localize.t("add friend"));
			addFriendButton.scaleX = addFriendButton.scaleY = 0.9;
			addFriendButton.x = 530;
			addFriendButton.y = inviteButton.y + inviteButton.height + 5;
			addFriendButton.width = buttonWidth;
			declineButton = new Button(function():void
				{
					toggleFriendButtons(true);
					joinButton.visible = false;
					declineButton.visible = false;
					addChild(inviteButton);
					var _loc1_:Invite = g.groupManager.findInvite(player.group.id, g.me);
					if (!_loc1_)
					{
						return;
					}
					g.groupManager.cancelGroupInvite(_loc1_.id);
				}, Localize.t("decline"), "negative");
			declineButton.scaleX = declineButton.scaleY = 0.9;
			declineButton.x = 530;
			declineButton.y = addFriendButton.y;
			declineButton.width = buttonWidth;
			acceptFriendButton = new Button(function():void
				{
					acceptFriendButton.enabled = false;
					g.friendManager.sendFriendConfirm(player);
				}, Localize.t("accept request"), "positive");
			acceptFriendButton.scaleX = acceptFriendButton.scaleY = 0.9;
			acceptFriendButton.x = 530;
			acceptFriendButton.y = addFriendButton.y;
			acceptFriendButton.width = buttonWidth;
			teleportToFriendButton = new Button(function():void
				{
					g.creditManager.refresh(function():void
						{
							var confirmBuyWithFlux:CreditBuyBox = new CreditBuyBox(g, CreditManager.getCostTeleportToFriend(), Localize.t("Are you sure you want to teleport to [playerName]?").replace("[playerName]", player.name));
							g.addChildToOverlay(confirmBuyWithFlux);
							confirmBuyWithFlux.addEventListener("accept", function():void
								{
									g.rpc("buyTeleportToFriend", teleport, player.id);
									confirmBuyWithFlux.removeEventListeners();
									g.removeChildFromOverlay(confirmBuyWithFlux, true);
								});
							confirmBuyWithFlux.addEventListener("close", function():void
								{
									teleportToFriendButton.enabled = true;
									confirmBuyWithFlux.removeEventListeners();
									g.removeChildFromOverlay(confirmBuyWithFlux, true);
								});
						});
				}, Localize.t("teleport"), "buy");
			teleportToFriendButton.scaleX = teleportToFriendButton.scaleY = 0.9;
			teleportToFriendButton.x = 530;
			teleportToFriendButton.y = addFriendButton.y;
			if (player.isMe)
			{
				addChild(leaveButton);
			}
			else
			{
				if (g.friendManager.pendingRequest(player))
				{
					addChild(acceptFriendButton);
				}
				else if (!g.me.isFriendWith(player))
				{
					addChild(addFriendButton);
				}
				else if (g.solarSystem.type != "pvp")
				{
					addChild(teleportToFriendButton);
				}
				if (g.groupManager.findInvite(player.group.id, g.me) != null)
				{
					addChild(joinButton);
					addChild(declineButton);
					toggleFriendButtons(false);
				}
				else
				{
					addChild(inviteButton);
				}
			}
			update();
		}

		private function toggleFriendButtons(param1:Boolean):void
		{
			addFriendButton.visible = param1;
			acceptFriendButton.visible = param1;
		}

		private function teleport(param1:Message):void
		{
			if (param1.getBoolean(0))
			{
				teleportToFriendButton.enabled = false;
				dispatchEventWith("close", true);
				Game.trackEvent("used flux", "teleport", "teleport to friend", CreditManager.getCostTeleportToFriend());
			}
			else
			{
				teleportToFriendButton.enabled = true;
				g.showErrorDialog(param1.getString(1));
			}
		}

		public function update():void
		{
			var _loc3_:* = 0;
			var _loc2_:* = 0;
			if (g.me == null)
			{
				return;
			}
			var _loc4_:Group = player.group;
			var _loc1_:Group = g.me.group;
			if (_loc1_ == _loc4_ || _loc4_.length > 1)
			{
				inviteButton.visible = false;
			}
			if (_loc1_.length > 1 && player.isMe)
			{
				leaveButton.visible = true;
			}
			else
			{
				leaveButton.visible = false;
			}
			if (_loc1_ == _loc4_)
			{
				_loc3_ = Style.COLOR_GROUP;
				_loc2_ = 11206570;
			}
			else if (player.isHostile)
			{
				_loc3_ = Style.COLOR_HOSTILE;
				_loc2_ = 16755370;
			}
			else
			{
				_loc3_ = Style.COLOR_FRIENDLY;
				_loc2_ = 11206570;
			}
		}

		override public function dispose():void
		{
			ToolTip.disposeType("playerListItem");
			this.removeChildren(0, -1, true);
		}
	}
}
