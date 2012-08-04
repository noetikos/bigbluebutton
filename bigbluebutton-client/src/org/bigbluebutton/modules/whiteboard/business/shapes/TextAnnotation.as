package org.bigbluebutton.modules.whiteboard.business.shapes
{
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import org.bigbluebutton.common.LogUtil;
	import org.bigbluebutton.modules.whiteboard.models.Annotation;

	public class TextAnnotation extends AnnotationObject
	{
		private var _origParentWidth:Number = 0;
		private var _origParentHeight:Number = 0;
		private var _tf:TextField = new TextField();
		
		public function TextAnnotation(id:String, type:String, status:String)
		{
			super(id, type, status);
			this.addChild(_tf);
		}
		
		public function get origParentWidth():Number {
			return _origParentWidth;
		}
		
		public function get origParentHeight():Number {
			return _origParentHeight;
		}
		
		// t.annotation.text, t.annotation.fontColor, t.annotation.backgroundColor, t.annotation.background, 
		// t.annotation.x, t.annotation.y, t.annotation.textBoxWidth, t.annotation.textBoxHeight, t.annotation.fontSize
			
		override public function draw(a:Annotation, parentWidth:Number, parentHeight:Number):void {
			LogUtil.debug("Drawing TEXT");
			this.x = denormalize(a.annotation.x, parentWidth);
			this.y = denormalize(a.annotation.y, parentHeight);
			
			var newFontSize:Number = a.annotation.fontSize;
			
			if (_origParentHeight == 0 && _origParentWidth == 0) {
				//                LogUtil.debug("Old parent dim [" + _origParentWidth + "," + _origParentHeight + "]");
				newFontSize = a.annotation.fontSize;
				_origParentHeight = parentHeight;
				_origParentWidth = parentWidth;               
			} else {
				newFontSize = (parentHeight/_origParentHeight) * a.annotation.fontSize;
				//                LogUtil.debug("2 Old parent dim [" + _origParentWidth + "," + _origParentHeight + "] newFontSize=" + newFontSize);
			}     
			
			_tf.text = a.annotation.text;
			_tf.antiAliasType = AntiAliasType.ADVANCED;
			var format:TextFormat = new TextFormat();
			format.size = newFontSize;
			format.font = "arial";
			_tf.defaultTextFormat = format;
			_tf.setTextFormat(format);
			
			this.width = denormalize(a.annotation.textBoxWidth, parentWidth);
			this.height = denormalize(a.annotation.textBoxHeight, parentHeight);
			
			LogUtil.debug("2 Old parent dim [" + _origParentWidth + "," + _origParentHeight + "][" + width + "," + height + "] newFontSize=" + newFontSize);
		}
		
		public function redrawText(a:Annotation, origParentWidth:Number, origParentHeight:Number, parentWidth:Number, parentHeight:Number):void {
			this.x = denormalize(a.annotation.x, parentWidth);
			this.y = denormalize(a.annotation.y, parentHeight);
						
			var newFontSize:Number = a.annotation.fontSize;
			newFontSize = (parentHeight/origParentHeight) * a.annotation.fontSize;
			
			/** Pass around the original parent width and height when this text was drawn. 
			 * We need this to redraw the the text to the proper size properly.
			 * **/
			_origParentHeight = origParentHeight;
			_origParentWidth = origParentWidth;               
			
			_tf.text = a.annotation.text;
			_tf.antiAliasType = AntiAliasType.ADVANCED;
			var format:TextFormat = new TextFormat();
			format.size = newFontSize;
			format.font = "arial";
			_tf.defaultTextFormat = format;
			_tf.setTextFormat(format);
			
			this.width = denormalize(a.annotation.textBoxWidth, parentWidth);
			this.height = denormalize(a.annotation.textBoxHeight, parentHeight);
			
			LogUtil.debug("Redraw dim [" + _origParentWidth + "," + _origParentHeight + "][" + width + "," + height + "] newFontSize=" + newFontSize);
			
			//           LogUtil.debug("Redraw 2 Old parent dim [" + this.width + "," + this.height + "] newFontSize=" + newFontSize);
		}
		
		public function displayForPresenter():void {
			_tf.multiline = true;
			_tf.wordWrap = true;
			_tf.type = TextFieldType.INPUT;
			_tf.border = true;
			_tf.background = true;
			_tf.backgroundColor = 0xFFFFFF;
		}

		public function displayNormally():void {
			_tf.multiline = true;
			_tf.wordWrap = true;
		}
	}
}