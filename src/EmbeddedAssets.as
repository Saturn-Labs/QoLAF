package
{
	
	public class EmbeddedAssets
	{
		[Embed(source = "/images/bg.jpg")]
		public static const astroflux_wide:Class;
		
		[Embed(source = "/images/fb_login.png")]
		public static const fb_login:Class;
		
		[Embed(source = "/images/logo.png")]
		public static const logo:Class;
		
		[Embed(source = "/images/logo_glow.png")]
		public static const logoGlow:Class;
		
		[Embed(source = "/images/fluff.png")]
		public static const fluff:Class;
		
		[Embed(source = "/images/star.png")]
		public static const star:Class;
		
		[Embed(source = "/texts/font13.fnt", mimeType = "application/octet-stream")]
		public static const font13_fnt:Class;
		
		[Embed(source = "/texts/font20.fnt", mimeType = "application/octet-stream")]
		public static const font20_fnt:Class;
		
		[Embed(source = "/texts/font26.fnt", mimeType = "application/octet-stream")]
		public static const font26_fnt:Class;
		
		[Embed(source = "/images/font13.png")]
		public static const font13:Class;
		
		[Embed(source = "/images/font20.png")]
		public static const font20:Class;
		
		[Embed(source = "/images/font26.png")]
		public static const font26:Class;
		
		[Embed(source = "/images/sale_sticker.png")]
		public static const sale_sticker:Class;
		
		[Embed(source = "/images/fb_sale_lg.png")]
		public static const fb_sale_lg:Class;
		
		[Embed(source = "/images/button_highlight.png")]
		public static const button_highlight:Class;
		
		[Embed(source = "/images/button_positive.png")]
		public static const button_positive:Class;
		
		[Embed(source = "/images/button_warning.png")]
		public static const button_warning:Class;
		
		[Embed(source = "/images/button_normal.png")]
		public static const button_normal:Class;
		
		[Embed(source = "/images/box_highlight.png")]
		public static const box_highlight:Class;
		
		[Embed(source = "/images/box_normal.png")]
		public static const box_normal:Class;
		
		[Embed(source = "/texts/lang.json", mimeType = "application/octet-stream")]
		public static const LanguageFile:Class;
		
		[Embed(source = "/texts/cache.json", mimeType = "application/octet-stream")]
		public static const CacheFile:Class;
		
		[Embed(source = "/images/buy_button.png")]
		public static const BuyButtonBitmap:Class;
		
		[Embed(source = "/images/get_flux_now_button.png")]
		public static const GetFluxNowButtonBitmap:Class;
		
		[Embed(source = "/images/text_input.jpg")]
		public static const TextInputBitmap:Class;
		
		[Embed(source = "/fonts/Russo_One.ttf", fontName = "DAIDRR", mimeType = "application/x-font", advancedAntiAliasing = "true", embedAsCFF = "false")]
		public static const RussoOneFont:Class;
		
		[Embed(source = "/fonts/Verdana.ttf", fontName = "Verdana", mimeType = "application/x-font", advancedAntiAliasing = "true", embedAsCFF = "false")]
		public static const VerdanaFont:Class;
		
		public function EmbeddedAssets()
		{
			super();
		}
	}
}
