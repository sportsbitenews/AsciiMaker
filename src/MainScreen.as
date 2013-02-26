package  
{
	import com.headchant.asciipanel.AsciiPanel;
	import org.microrl.architecture.*;
	
	public class MainScreen extends BaseScreen
	{
		private var chars:Array;
		private var fg:Array;
		private var bg:Array;
		
		private var charGuiX:int = 82;
		private var charGuiY:int = 5;
		private var charFgY:int = charGuiY + 16 + 5;
		private var charBgY:int = charFgY + 5;
		
		public var currentCharCode:int = 177;
		private var fgR:int = 255;
		private var fgG:int = 255;
		private var fgB:int = 255;
		private var bgR:int = 0;
		private var bgG:int = 0;
		private var bgB:int = 0;
		
		private var clickableBg:int = 0xff666666;
		
		public function MainScreen() 
		{
			init();
			
			bind("MouseClick", "clicked", onClick);
			bind("MouseMove", "moved", onMove);
			
			display(function (terminal:AsciiPanel):void {
				terminal.clear();
				
				for (var x:int = 0; x < chars[0].length; x++)
				for (var y:int = 0; y < chars.length; y++)
					terminal.write(chars[x][y], x, y, fg[x][y], bg[x][y]);
				
				terminal.write(" Ascii: " + String.fromCharCode(currentCharCode) + " (   )", charGuiX, charGuiY - 2);
				terminal.write(pad3(currentCharCode.toString()), charGuiX + 11, charGuiY - 2, 0xffffff, clickableBg);
				
				for (var x:int = 0; x < 16; x++)
				for (var y:int = 0; y < 16; y++)
				{
					var char:int = x + y * 16;
					var bg = currentCharCode % 16 == x || Math.floor(currentCharCode / 16) == y ? 0xff666633 : 0xff333333;
					terminal.write(String.fromCharCode(char), charGuiX + x, charGuiY + y, 0xffffffff, bg);
				}
				
				terminal.write(" Foreground:", charGuiX, charFgY);
				terminal.write(" ", charGuiX + 13, charFgY, 0xff000000, (0xff000000 | (fgR << 16) | (fgG << 8) | fgB));
				terminal.write("RGB:", charGuiX, charBgY + 2);
				terminal.write(pad3(fgR.toString()), charGuiX + 5, charFgY + 2, 0xffffff, clickableBg);
				terminal.write(pad3(fgG.toString()), charGuiX + 9, charFgY + 2, 0xffffff, clickableBg);
				terminal.write(pad3(fgB.toString()), charGuiX + 13, charFgY + 2, 0xffffff, clickableBg);
				
				
				terminal.write(" Background:", charGuiX, charBgY);
				terminal.write(" ", charGuiX + 13, charBgY, 0xff000000, (0xff000000 | (bgR << 16) | (bgG << 8) | bgB));
				terminal.write("RGB:", charGuiX, charFgY + 2);
				terminal.write(pad3(bgR.toString()), charGuiX + 5, charBgY + 2, 0xffffff, clickableBg);
				terminal.write(pad3(bgG.toString()), charGuiX + 9, charBgY + 2, 0xffffff, clickableBg);
				terminal.write(pad3(bgB.toString()), charGuiX + 13, charBgY + 2, 0xffffff, clickableBg);
			});
		}
		
		public function init():void
		{
			chars = [];
			fg = [];
			bg = [];
			for (var x:int = 0; x < 80; x++)
			{
				var row:Array = [];
				var fgRow:Array = [];
				var bgRow:Array = [];
				for (var y:int = 0; y < 80; y++)
				{
					row.push(String.fromCharCode(250));
					fgRow.push(0xffffffff);
					bgRow.push(0xff000000);
				}
				chars.push(row);
				fg.push(fgRow);
				bg.push(bgRow);
			}
		}
		
		public function pad3(text:String):String
		{
			return ("   " + text).substr(text.length, 3);
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
			{
				chars[x][y] = String.fromCharCode(currentCharCode);
				fg[x][y] = 0xff000000 | (fgR << 16) | (fgG << 8) | fgB;
				bg[x][y] = 0xff000000 | (bgR << 16) | (bgG << 8) | bgB;
			}
			else if (x >= charGuiX && x < charGuiX + 16 && y >= charGuiY && y < charGuiY + 16)
				currentCharCode = x - charGuiX + ((y - charGuiY) * 16);
				
			else if (x >= charGuiX + 11 && x < charGuiX + 11 + 3 && y == charGuiY - 2)
				enterScreen(new InputScreen("Ascii character code (0-255)", setCharCodeCallback));
				
			else if (x >= charGuiX + 5 && x < charGuiX + 5 + 3 && y == charFgY + 2)
				enterScreen(new InputScreen("Foreground red (0-255)", setForegroundRedCallback));
			else if (x >= charGuiX + 9 && x < charGuiX + 9 + 3 && y == charFgY + 2)
				enterScreen(new InputScreen("Foreground green (0-255)", setForegroundGreenCallback));
			else if (x >= charGuiX + 13 && x < charGuiX + 13 + 3 && y == charFgY + 2)
				enterScreen(new InputScreen("Foreground blue (0-255)", setForegroundBlueCallback));
				
			else if (x >= charGuiX + 5 && x < charGuiX + 5 + 3 && y == charBgY + 2)
				enterScreen(new InputScreen("Background red (0-255)", setBackgroundRedCallback));
			else if (x >= charGuiX + 9 && x < charGuiX + 9 + 3 && y == charBgY + 2)
				enterScreen(new InputScreen("Background green (0-255)", setBackgroundGreenCallback));
			else if (x >= charGuiX + 13 && x < charGuiX + 13 + 3 && y == charBgY + 2)
				enterScreen(new InputScreen("Background blue (0-255)", setBackgroundBlueCallback));
		}
		
		public function setCharCodeCallback(value:String):void
		{
			var i:int = parseInt("0" + value);
			
			if (isNaN(i) || i < 0 || i > 255)
				return;
			
			currentCharCode = i;
		}
		
		public function setForegroundRedCallback(value:String):void
		{
			var i:int = parseInt("0" + value);
			
			if (isNaN(i) || i < 0 || i > 255)
				return;
			
			fgR = i;
		}
		
		public function setForegroundGreenCallback(value:String):void
		{
			var i:int = parseInt("0" + value);
			
			if (isNaN(i) || i < 0 || i > 255)
				return;
			
			fgG = i;
		}
		
		public function setForegroundBlueCallback(value:String):void
		{
			var i:int = parseInt("0" + value);
			
			if (isNaN(i) || i < 0 || i > 255)
				return;
			
			fgB = i;
		}
		
		
		public function setBackgroundRedCallback(value:String):void
		{
			var i:int = parseInt("0" + value);
			
			if (isNaN(i) || i < 0 || i > 255)
				return;
			
			bgR = i;
		}
		
		public function setBackgroundGreenCallback(value:String):void
		{
			var i:int = parseInt("0" + value);
			
			if (isNaN(i) || i < 0 || i > 255)
				return;
			
			bgG = i;
		}
		
		public function setBackgroundBlueCallback(value:String):void
		{
			var i:int = parseInt("0" + value);
			
			if (isNaN(i) || i < 0 || i > 255)
				return;
			
			bgB = i;
		}
	}
}