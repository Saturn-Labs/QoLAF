package starling.errors {
	public class AbstractMethodError extends Error {
		public function AbstractMethodError(message:* = "Method needs to be implemented in subclass", id:* = 0) {
			super(message,id);
		}
	}
}

