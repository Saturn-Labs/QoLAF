package playerio {
	public class PlayerIORegistrationError extends PlayerIOError {
		public var usernameError:String;
		
		public var passwordError:String;
		
		public var emailError:String;
		
		public var captchaError:String;
		
		public function PlayerIORegistrationError(message:String, id:int, usernameError:String, passwordError:String, emailError:String, captchaError:String) {
			super(message,id);
			this.usernameError = usernameError;
			this.passwordError = passwordError;
			this.emailError = emailError;
			this.captchaError = captchaError;
		}
	}
}

