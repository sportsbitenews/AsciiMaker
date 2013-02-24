package  
{
	import com.headchant.asciipanel.AsciiPanel;
	import org.microrl.architecture.*;
	
	public class MainScreen extends BaseScreen
	{
		private var chars:Array;
		
		private var currentCharCode:int = 177;
		private var charGuiX:int = 83;
		private var charGuiY:int = 5;
		
		public function MainScreen() 
		{
			chars = [];
			for (var x:int = 0; x < 80; x++)
			{
				var row:Array = [];
				for (var y:int = 0; y < 80; y++)
					row.push(String.fromCharCode(250));
				chars.push(row);
			}
			
			display(function (terminal:AsciiPanel):void {
				terminal.clear();
				
				for (var x:int = 0; x < chars[0].length; x++)
				for (var y:int = 0; y < chars.length; y++)
					terminal.write(chars[x][y], x, y);
				
				for (var x:int = 0; x < 16; x++)
				for (var y:int = 0; y < 16; y++)
				{
					var char:int = x + y * 16;
					var bg = currentCharCode % 16 == x || Math.floor(currentCharCode / 16) == y ? 0xff666633 : 0xff000000;
					terminal.write(String.fromCharCode(char), charGuiX + x, charGuiY + y, 0xffffffff, bg);
				}
			});
			
			bind("MouseClick", "clicked", onClick);
			bind("MouseMove", "moved", onMove);
		}
		
		public function onMove():void
		{
			if (lastMouseEvent.buttonDown)
				onClick();
		}
		
		public function onClick():void
		{
			var x:int = lastMouseEvent.localX / 8;
			var y:int = lastMouseEvent.localY / 8;
			
			if (x >= 0 && y >= 0 && x < chars[0].length && y < chars.length)
				chars[x][y] = String.fromCharCode(currentCharCode);
			else if (x >= charGuiX && x < charGuiX + 16 && y >= charGuiY && y < charGuiY + 16)
				currentCharCode = x - charGuiX + ((y - charGuiY) * 16);
		}
	}
}