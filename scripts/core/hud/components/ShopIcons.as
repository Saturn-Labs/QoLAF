package core.hud.components {
	import core.hud.components.dialogs.PopupConfirmMessage;
	import core.scene.Game;
	import core.states.gameStates.ShopState;
	import generics.Localize;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.events.TouchEvent;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class ShopIcons extends DisplayObjectContainer {
		private var g:Game;
		
		private var xpBoostActive:Boolean = false;
		
		private var tractorBeamActive:Boolean = false;
		
		private var xpProtectionActive:Boolean = false;
		
		private var cargoProtectionActive:Boolean = false;
		
		private var supporterActive:Boolean = false;
		
		private var confirmBox:PopupConfirmMessage = null;
		
		private var textureManager:ITextureManager = TextureLocator.getService();
		
		public function ShopIcons(g:Game) {
			super();
			this.g = g;
		}
		
		public function load() : void {
			var tractorBeamIcon:Image;
			var xpProtectionIcon:Image;
			var cargoProtectionIcon:Image;
			var supporterIcon:Image;
			xpBoostActive = g.me.hasExpBoost;
			var textureName:String = xpBoostActive ? "ti_xp_boost" : "ti_xp_boost_inactive";
			var toolTipText:String = Localize.t("<FONT COLOR=\'#ffffff\'>100%</FONT> more experience for each enemy kill and <FONT COLOR=\'#ffffff\'>30%</FONT> more on missions and PvP. Active:") + " " + (xpBoostActive ? "<FONT COLOR=\'#ffffff\'>true</FONT>" : "<FONT COLOR=\'#ffffff\'>false</FONT>");
			var xpBoostIcon:Image = new Image(textureManager.getTextureGUIByTextureName(textureName));
			xpBoostIcon.scaleX = xpBoostIcon.scaleY = 0.5;
			xpBoostIcon.useHandCursor = true;
			xpBoostIcon.addEventListener("touch",function(param1:TouchEvent):void {
				if(param1.getTouch(xpBoostIcon,"ended")) {
					g.enterState(new ShopState(g,"xpBoost"));
				}
			});
			addChild(xpBoostIcon);
			new ToolTip(g,xpBoostIcon,toolTipText,null,"shopIcons");
			tractorBeamActive = g.me.isTractorBeamActive();
			textureName = tractorBeamActive ? "ti_tractor_beam" : "ti_tractor_beam_inactive";
			toolTipText = Localize.t("Tractor beam will help you collect drops and crates faster. Active:") + " " + (tractorBeamActive ? "<FONT COLOR=\'#ffffff\'>true</FONT>" : "<FONT COLOR=\'#ffffff\'>false</FONT>");
			tractorBeamIcon = new Image(textureManager.getTextureGUIByTextureName(textureName));
			tractorBeamIcon.scaleX = tractorBeamIcon.scaleY = 0.5;
			tractorBeamIcon.x = xpBoostIcon.x + xpBoostIcon.width + 4;
			tractorBeamIcon.useHandCursor = true;
			tractorBeamIcon.addEventListener("touch",function(param1:TouchEvent):void {
				if(param1.getTouch(tractorBeamIcon,"ended")) {
					if(g.me.hasTractorBeam()) {
						g.me.toggleTractorBeam();
						g.hud.update();
						g.send("toggleTractorBeam");
						return;
					}
					g.enterState(new ShopState(g,"tractorBeam"));
				}
			});
			addChild(tractorBeamIcon);
			new ToolTip(g,tractorBeamIcon,toolTipText,null,"shopIcons");
			xpProtectionActive = g.me.hasXpProtection();
			textureName = xpProtectionActive ? "ti_xp_protection" : "ti_xp_protection_inactive";
			toolTipText = Localize.t("Prevents you from losing xp when you are killed. Active:") + " " + (xpProtectionActive ? "<FONT COLOR=\'#ffffff\'>true</FONT>" : "<FONT COLOR=\'#ffffff\'>false</FONT>");
			xpProtectionIcon = new Image(textureManager.getTextureGUIByTextureName(textureName));
			xpProtectionIcon.scaleX = xpProtectionIcon.scaleY = 0.5;
			xpProtectionIcon.x = tractorBeamIcon.x + tractorBeamIcon.width + 4;
			xpProtectionIcon.useHandCursor = true;
			xpProtectionIcon.addEventListener("touch",function(param1:TouchEvent):void {
				if(param1.getTouch(xpProtectionIcon,"ended")) {
					g.enterState(new ShopState(g,"xpProtection"));
				}
			});
			addChild(xpProtectionIcon);
			new ToolTip(g,xpProtectionIcon,toolTipText,null,"shopIcons");
			cargoProtectionActive = g.me.isCargoProtectionActive();
			textureName = cargoProtectionActive ? "ti_cargo_protection" : "ti_cargo_protection_inactive";
			toolTipText = Localize.t("All junk remains in cargo when you get killed. Active:") + " " + (cargoProtectionActive ? "<FONT COLOR=\'#ffffff\'>true</FONT>" : "<FONT COLOR=\'#ffffff\'>false</FONT>");
			cargoProtectionIcon = new Image(textureManager.getTextureGUIByTextureName(textureName));
			cargoProtectionIcon.scaleX = cargoProtectionIcon.scaleY = 0.5;
			cargoProtectionIcon.x = xpProtectionIcon.x + xpProtectionIcon.width + 4;
			cargoProtectionIcon.useHandCursor = true;
			cargoProtectionIcon.addEventListener("touch",function(param1:TouchEvent):void {
				if(param1.getTouch(cargoProtectionIcon,"ended")) {
					g.enterState(new ShopState(g,"cargoProtection"));
				}
			});
			addChild(cargoProtectionIcon);
			new ToolTip(g,cargoProtectionIcon,toolTipText,null,"shopIcons");
			supporterActive = g.me.hasSupporter();
			textureName = supporterActive ? "ti_supporter" : "ti_supporter_inactive";
			toolTipText = Localize.t("Supporter package:") + " " + (supporterActive ? "<FONT COLOR=\'#ffffff\'>" + Localize.t("active") + "</FONT>" : "<FONT COLOR=\'#ffffff\'>" + Localize.t("not active") + "</FONT>");
			supporterIcon = new Image(textureManager.getTextureGUIByTextureName(textureName));
			supporterIcon.scaleX = supporterIcon.scaleY = 0.5;
			supporterIcon.x = cargoProtectionIcon.x + cargoProtectionIcon.width + 4;
			supporterIcon.useHandCursor = true;
			supporterIcon.addEventListener("touch",function(param1:TouchEvent):void {
				if(param1.getTouch(supporterIcon,"ended")) {
					g.enterState(new ShopState(g,"supporterPackage"));
				}
			});
			addChild(supporterIcon);
			new ToolTip(g,supporterIcon,toolTipText,null,"shopIcons");
			visible = !g.me.guest;
		}
		
		public function update() : void {
			if(xpBoostActive != g.me.hasExpBoost || tractorBeamActive != g.me.isTractorBeamActive() || xpProtectionActive != g.me.hasXpProtection() || cargoProtectionActive != g.me.isCargoProtectionActive() || supporterActive != g.me.hasSupporter()) {
				ToolTip.disposeType("shopIcons");
				removeChildren();
				load();
			}
		}
	}
}

