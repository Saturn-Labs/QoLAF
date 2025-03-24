package core.clan {
	import core.hud.components.dialogs.PopupConfirmMessage;
	import core.scene.Game;
	import data.DataLocator;
	import data.IDataManager;
	import generics.Localize;
	import playerio.Message;
	
	public class ClanApplicationCheck {
		private var g:Game;
		
		public function ClanApplicationCheck(g:Game) {
			super();
			this.g = g;
		}
		
		public function checkSpecific(clanObj:Object, success:Function = null, fail:Function = null) : Boolean {
			var haveApplied:Boolean;
			var aObj:Object;
			var confirmApplicationPopup:PopupConfirmMessage;
			if(g.me.clanId != "") {
				return false;
			}
			if(clanObj == null) {
				return false;
			}
			if(g.me.clanApplicationId != clanObj.key) {
				return false;
			}
			haveApplied = false;
			for each(aObj in clanObj.applications) {
				if(aObj.player == g.me.id) {
					haveApplied = true;
				}
				if(aObj.player == g.me.id && aObj.accepted) {
					confirmApplicationPopup = new PopupConfirmMessage(Localize.t("Great!"),Localize.t("No thanks"));
					confirmApplicationPopup.text = Localize.t("You application for [name] has been accepted!").replace("[name]",clanObj.name);
					confirmApplicationPopup.addEventListener("accept",function():void {
						var m:Message = g.createMessage("clanConfirmApplication");
						m.add(clanObj.key);
						g.blockHotkeys = true;
						g.rpcMessage(m,function(param1:Message):void {
							var _local2:Message = null;
							if(param1.getBoolean(0)) {
								g.me.clanId = clanObj.key;
								g.updateServiceRoom();
								_local2 = g.createMessage("clanJoin");
								g.sendMessageToServiceRoom(_local2);
								g.showErrorDialog(Localize.t("You have joined [name]!").replace("[name]",clanObj.name));
							} else {
								g.showErrorDialog(param1.getString(1));
							}
							if(success != null) {
								success();
							}
							g.removeChildFromOverlay(confirmApplicationPopup,true);
							g.blockHotkeys = false;
						});
					});
					confirmApplicationPopup.addEventListener("close",function():void {
						var m:Message = g.createMessage("clanDeclineApplication");
						m.add(g.me.id);
						m.add(clanObj.key);
						g.blockHotkeys = true;
						g.rpcMessage(m,function(param1:Message):void {
							if(param1.getBoolean(0)) {
								g.showErrorDialog(Localize.t("You have declined to join [name].").replace("[name]",clanObj.name));
							} else {
								g.showErrorDialog(param1.getString(1));
							}
							if(fail != null) {
								fail();
							}
							g.removeChildFromOverlay(confirmApplicationPopup,true);
							g.blockHotkeys = false;
						});
					});
					g.addChildToOverlay(confirmApplicationPopup);
				}
			}
			return haveApplied;
		}
		
		public function check() : void {
			var dataManager:IDataManager;
			if(g.me.clanApplicationId == "") {
				return;
			}
			dataManager = DataLocator.getService();
			dataManager.loadKeyFromBigDB("Clans",g.me.clanApplicationId,function(param1:Object):void {
				var _local2:ClanApplicationCheck = new ClanApplicationCheck(g);
				_local2.checkSpecific(param1);
			});
		}
	}
}

