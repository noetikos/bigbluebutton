package org.bigbluebutton.modules.whiteboard
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	import mx.collections.ArrayCollection;
	import mx.controls.TextInput;
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.managers.CursorManager;
	
	import org.bigbluebutton.common.IBbbCanvas;
	import org.bigbluebutton.common.LogUtil;
	import org.bigbluebutton.core.managers.UserManager;
	import org.bigbluebutton.main.events.MadePresenterEvent;
	import org.bigbluebutton.modules.whiteboard.business.shapes.AnnotationObject;
	import org.bigbluebutton.modules.whiteboard.business.shapes.DrawGrid;
	import org.bigbluebutton.modules.whiteboard.business.shapes.DrawObject;
	import org.bigbluebutton.modules.whiteboard.business.shapes.DrawObjectFactory;
	import org.bigbluebutton.modules.whiteboard.business.shapes.GraphicFactory;
	import org.bigbluebutton.modules.whiteboard.business.shapes.GraphicObject;
	import org.bigbluebutton.modules.whiteboard.business.shapes.Pencil;
	import org.bigbluebutton.modules.whiteboard.business.shapes.ShapeFactory;
	import org.bigbluebutton.modules.whiteboard.business.shapes.TextAnnotation;
	import org.bigbluebutton.modules.whiteboard.business.shapes.TextBox;
	import org.bigbluebutton.modules.whiteboard.business.shapes.TextFactory;
	import org.bigbluebutton.modules.whiteboard.business.shapes.TextObject;
	import org.bigbluebutton.modules.whiteboard.business.shapes.WhiteboardConstants;
	import org.bigbluebutton.modules.whiteboard.events.GraphicObjectFocusEvent;
	import org.bigbluebutton.modules.whiteboard.events.PageEvent;
	import org.bigbluebutton.modules.whiteboard.events.ToggleGridEvent;
	import org.bigbluebutton.modules.whiteboard.events.WhiteboardDrawEvent;
	import org.bigbluebutton.modules.whiteboard.events.WhiteboardSettingResetEvent;
	import org.bigbluebutton.modules.whiteboard.events.WhiteboardUpdate;
	import org.bigbluebutton.modules.whiteboard.models.Annotation;
	import org.bigbluebutton.modules.whiteboard.models.WhiteboardModel;
	import org.bigbluebutton.modules.whiteboard.views.WhiteboardCanvas;
	
    /**
    * Class to handle displaying of received annotations from the server.
    */
	public class WhiteboardCanvasDisplayModel {
        public var whiteboardModel:WhiteboardModel;
		public var wbCanvas:WhiteboardCanvas;	
		private var graphicList:Array = new Array();
		private var _annotationsList:Array = new Array();
		
		private var shapeFactory:ShapeFactory = new ShapeFactory();

        private var currentlySelectedTextObject:TextObject;
        
		private var bbbCanvas:IBbbCanvas;
		private var width:Number;
		private var height:Number;
		private var drawFactory:DrawObjectFactory = new DrawObjectFactory();

		public function drawGraphic(event:WhiteboardUpdate):void{
			var o:Annotation = event.annotation;
			var recvdShapes:Boolean = event.recvdShapes;
			LogUtil.debug("**** Drawing graphic [" + o.type + "] *****");
			if(o.type != DrawObject.TEXT) {		
				var dobj:AnnotationObject;
				switch (o.status) {
					case DrawObject.DRAW_START:
						dobj = drawFactory.createAnnotationObject(o, whiteboardModel);	
						if (dobj != null) {
							dobj.draw(o, shapeFactory.parentWidth, shapeFactory.parentHeight);
							wbCanvas.addGraphic(dobj);
							_annotationsList.push(dobj);							
						}
						break;
					case DrawObject.DRAW_UPDATE:
					case DrawObject.DRAW_END:
						var gobj:AnnotationObject = _annotationsList.pop();	
						wbCanvas.removeGraphic(gobj as DisplayObject);			
						dobj = drawFactory.createAnnotationObject(o, whiteboardModel);	
						if (dobj != null) {
							dobj.draw(o, shapeFactory.parentWidth, shapeFactory.parentHeight);
							wbCanvas.addGraphic(dobj);
							_annotationsList.push(dobj);							
						}
						break;
				} 									
			} else { 
				drawText(o, recvdShapes);	
			}
		}

		// Draws a TextObject when/if it is received from the server
		private function drawText(o:Annotation, recvdShapes:Boolean):void {					
			var dobj:TextAnnotation;
			switch (o.status) {
				case TextObject.TEXT_CREATED:
					dobj = drawFactory.createAnnotationObject(o, whiteboardModel) as TextAnnotation;	
					if (dobj != null) {
						dobj.draw(o, shapeFactory.parentWidth, shapeFactory.parentHeight);
						if (isPresenter) {
							dobj.displayForPresenter();
							wbCanvas.stage.focus = dobj.setFocus();
						} else {
							dobj.displayNormally();
						}
						wbCanvas.addGraphic(dobj);
						_annotationsList.push(dobj);							
					}													
					break;
				case TextObject.TEXT_UPDATED:
					var gobj1:AnnotationObject = _annotationsList.pop();	
					wbCanvas.removeGraphic(gobj1 as DisplayObject);
					dobj = drawFactory.createAnnotationObject(o, whiteboardModel) as TextAnnotation;	
					if (dobj != null) {
						dobj.draw(o, shapeFactory.parentWidth, shapeFactory.parentHeight);
						if (isPresenter) {
							dobj.displayForPresenter();
							wbCanvas.stage.focus = dobj.setFocus();
						} else {
							dobj.displayNormally();
						}
						wbCanvas.addGraphic(dobj);
						_annotationsList.push(dobj);							
					}					
					break;
				case TextObject.TEXT_PUBLISHED:
					var gobj:AnnotationObject = _annotationsList.pop();	
					wbCanvas.removeGraphic(gobj as DisplayObject);			
					dobj = drawFactory.createAnnotationObject(o, whiteboardModel) as TextAnnotation;	
					if (dobj != null) {
						dobj.draw(o, shapeFactory.parentWidth, shapeFactory.parentHeight);
						dobj.displayNormally();
						wbCanvas.addGraphic(dobj);
						_annotationsList.push(dobj);							
					}
					break;
			}        
		}
			
		/* the following three methods are used to remove any GraphicObjects (and its subclasses) if the id of the object to remove is specified. The latter
			two are convenience methods, the main one is the first of the three.
		*/
		private function removeGraphic(id:String):void {
			var gobjData:Array = getGobjInfoWithID(id);
			var removeIndex:int = gobjData[0];
			var gobjToRemove:GraphicObject = gobjData[1] as GraphicObject;
			wbCanvas.removeGraphic(gobjToRemove as DisplayObject);
			graphicList.splice(removeIndex, 1);
		}	
	
		private function removeShape(id:String):void {
			var dobjData:Array = getGobjInfoWithID(id);
			var removeIndex:int = dobjData[0];
			var dobjToRemove:DrawObject = dobjData[1] as DrawObject;
			wbCanvas.removeGraphic(dobjToRemove);
			graphicList.splice(removeIndex, 1);
		}
	
		private function removeText(id:String):void {
			var tobjData:Array = getGobjInfoWithID(id);
			var removeIndex:int = tobjData[0];
			var tobjToRemove:TextObject = tobjData[1] as TextObject;
			wbCanvas.removeGraphic(tobjToRemove);
			graphicList.splice(removeIndex, 1);
		}	
		
		/* returns an array of the GraphicObject that has the specified id,
		 and the index of that GraphicObject (if it exists, of course) 
		*/
		private function getGobjInfoWithID(id:String):Array {	
			var data:Array = new Array();
			for(var i:int = 0; i < graphicList.length; i++) {
				var currObj:GraphicObject = graphicList[i] as GraphicObject;
				if(currObj.getGraphicID() == id) {
					data.push(i);
					data.push(currObj);
					return data;
				}
			}
			return null;
		}

		private function removeLastGraphic():void {
			var gobj:GraphicObject = graphicList.pop();
			if(gobj.getGraphicType() == WhiteboardConstants.TYPE_TEXT) {
				(gobj as TextObject).makeEditable(false);
//				(gobj as TextObject).deregisterListeners(textObjGainedFocusListener, textObjLostFocusListener, textObjTextListener, textObjSpecialListener);
			}	
			wbCanvas.removeGraphic(gobj as DisplayObject);
		}

		// returns all DrawObjects in graphicList
		private function getAllShapes():Array {
			var shapes:Array = new Array();
			for(var i:int = 0; i < graphicList.length; i++) {
				var currGobj:GraphicObject = graphicList[i];
				if(currGobj.getGraphicType() == WhiteboardConstants.TYPE_SHAPE) {
					shapes.push(currGobj as DrawObject);
				}
			}
			return shapes;
		}
		
		// returns all TextObjects in graphicList
		private function getAllTexts():Array {
			var texts:Array = new Array();
			for(var i:int = 0; i < graphicList.length; i++) {
				var currGobj:GraphicObject = graphicList[i];
				if(currGobj.getGraphicType() == WhiteboardConstants.TYPE_TEXT) {
					texts.push(currGobj as TextObject)
				}
			}
			return texts;
		}
		
		public function clearBoard(event:WhiteboardUpdate = null):void {
			var numGraphics:int = this.graphicList.length;
			for (var i:Number = 0; i < numGraphics; i++){
				removeLastGraphic();
			}
		}
		
		public function undoAnnotation(id:String):void {
            /** We'll just remove the last annotation for now **/
			if (this.graphicList.length > 0) {
				removeLastGraphic();
			}
		}
        
        public function receivedAnnotationsHistory():void {
//            LogUtil.debug("**** CanvasDisplay receivedAnnotationsHistory *****");
            var annotations:Array = whiteboardModel.getAnnotations();
//            LogUtil.debug("**** CanvasDisplay receivedAnnotationsHistory [" + annotations.length + "] *****");
            for (var i:int = 0; i < annotations.length; i++) {
                var an:Annotation = annotations[i] as Annotation;
//                LogUtil.debug("**** Drawing graphic from history [" + an.type + "] *****");
                if(an.type != DrawObject.TEXT) {
					var dobj:AnnotationObject = drawFactory.createAnnotationObject(an, whiteboardModel);	
					if (dobj != null) {
						dobj.draw(an, shapeFactory.parentWidth, shapeFactory.parentHeight);
						wbCanvas.addGraphic(dobj);
						_annotationsList.push(dobj);							
					}				
                } else { 
                    drawText(an, true);	
                }                
            }
        }

		public function changePage():void{
//            LogUtil.debug("**** CanvasDisplay changePage. Cearing page *****");
            clearBoard();
            var annotations:Array = whiteboardModel.getAnnotations();
 //           LogUtil.debug("**** CanvasDisplay changePage [" + annotations.length + "] *****");
            if (annotations.length == 0) {
                wbCanvas.queryForAnnotationHistory();
            } else {
                for (var i:int = 0; i < annotations.length; i++) {
                    var an:Annotation = annotations[i] as Annotation;
                    // LogUtil.debug("**** Drawing graphic from changePage [" + an.type + "] *****");
                    if(an.type != DrawObject.TEXT) {
						var dobj:AnnotationObject = drawFactory.createAnnotationObject(an, whiteboardModel);	
						if (dobj != null) {
							dobj.draw(an, shapeFactory.parentWidth, shapeFactory.parentHeight);
							wbCanvas.addGraphic(dobj);
							_annotationsList.push(dobj);							
						}			
                    } else { 
                        drawText(an, true);	
                    }                
                }                
            }
        }
		
		public function zoomCanvas(width:Number, height:Number):void{
			shapeFactory.setParentDim(width, height);	
			this.width = width;
			this.height = height;

			for (var i:int = 0; i < this._annotationsList.length; i++){
				redrawGraphic(this._annotationsList[i] as AnnotationObject, i);
			}	
		}
				
		/* called when a user is made presenter, automatically make all the textfields currently on the page editable, so that they can edit it. */
		public function makeTextObjectsEditable(e:MadePresenterEvent):void {
//			var texts:Array = getAllTexts();
//			for(var i:int = 0; i < texts.length; i++) {
//				(texts[i] as TextObject).makeEditable(true);
//				(texts[i] as TextObject).registerListeners(textObjGainedFocusListener, textObjLostFocusListener, textObjTextListener, textObjSpecialListener);
//			}
		}
		
		/* when a user is made viewer, automatically make all the textfields currently on the page uneditable, so that they cannot edit it any
		   further and so that only the presenter can edit it.
		*/
		public function makeTextObjectsUneditable(e:MadePresenterEvent):void {
			LogUtil.debug("MADE PRESENTER IS PRESENTER FALSE");
//			var texts:Array = getAllTexts();
//			for(var i:int = 0; i < texts.length; i++) {
//				(texts[i] as TextObject).makeEditable(false);
//				(texts[i] as TextObject).deregisterListeners(textObjGainedFocusListener, textObjLostFocusListener, textObjTextListener, textObjSpecialListener);
//			}
		}

		private function redrawGraphic(gobj:AnnotationObject, objIndex:int):void {
			var o:Annotation;
			if (gobj.type != DrawObject.TEXT) {
				wbCanvas.removeGraphic(gobj);
				o = whiteboardModel.getAnnotation(gobj.id);
				
				if (o != null) {
					var dobj:AnnotationObject = drawFactory.createAnnotationObject(o, whiteboardModel);	
					if (dobj != null) {
						dobj.draw(o, shapeFactory.parentWidth, shapeFactory.parentHeight);
						wbCanvas.addGraphic(dobj);
						_annotationsList[objIndex] = dobj;							
					}					
				}
			} else {
				wbCanvas.removeGraphic(gobj);
				o = whiteboardModel.getAnnotation(gobj.id);
				
				if (o != null) {
					var tobj:TextAnnotation = drawFactory.createAnnotationObject(o, whiteboardModel) as TextAnnotation;	
					if (tobj != null) {
						tobj.redrawText(o, (gobj as TextAnnotation).origParentWidth, (gobj as TextAnnotation).origParentHeight, shapeFactory.parentWidth, shapeFactory.parentHeight);
						wbCanvas.addGraphic(tobj);
						if (isPresenter) tobj.displayForPresenter();
						_annotationsList[objIndex] = tobj;							
					}
				}
			}
		}
		
		public function isPageEmpty():Boolean {
			return graphicList.length == 0;
		}
		
        /** Helper method to test whether this user is the presenter */
        private function get isPresenter():Boolean {
            return UserManager.getInstance().getConference().amIPresenter();
        }
	}
}
