// Copyright (c) 2012, John Evans
// http://www.buckshotui.org
// See LICENSE file for Apache 2.0 licensing information.

/**
 * Polly is the cross-browser & cross-platform rendering facility for Buckshot.
 *
 * She be a harsh mistress, but aye, she be worth it on a cold winter's night.
 */
class Polly {

  /// List of vendor prefixes.
  static final prefixes = const ['','-webkit-','-moz-','-o-','-ms-'];

  static BrowserInfo _browserInfo;

  //TODO move this into BrowserInfo class?
  static FlexModel _flexModel;

  /**
   * Gets a [BrowserInfo] object representing various data
   * about the current browser context.
   */
  static BrowserInfo get browserInfo() => _browserInfo;

  static void init(){
    _browserInfo = Browser.getBrowserInfo();

    if (browserInfo.browser == Browser.FIREFOX){
      _setFirefox();
    }

    var e = new DivElement();

    document.body.elements.add(e);

    makeFlexBox(e);

    _flexModel = FlexModel.getFlexModel(e);

    e.remove();
  }

  static void _setFirefox(){
    print('setting firefox specific');
    document.body.style.lineHeight = '125%';
  }


  /**
   * Returns true if the framework is known to be compatible with
   * the browser type/version it is running in.
   */
  static bool get browserOK() {

    if (browserInfo.browser == Browser.DARTIUM) return true;

    //Chrome(ium) v20+
    if (browserInfo.browser == Browser.CHROME){
      if (browserInfo.version >= 20) return true;
    }

    return false;
  }

  static Element _unwrap(FrameworkObject element) => element.rawElement;

  /**
   * Converts and element into a flexbox container.
   * Returns true if flexbox was created; false otherwise. */
  static bool makeFlexBox(Element element){

    element.style.display = 'box';
    element.style.display = 'flexbox';
    element.style.display = 'flex';

    element.style.display = '${Polly.browserInfo.vendorPrefix}box';
    element.style.display = '${Polly.browserInfo.vendorPrefix}flexbox';
    element.style.display = '${Polly.browserInfo.vendorPrefix}flex';

    if (element.style.display == null
        || !element.style.display.endsWith('x')){
      return false;
    }

    return true;
  }


  /** Returns a string representing a cross-browser CSS property assignment. */
  static String generateXPCSS(String declaration, String value){
    StringBuffer sb = new StringBuffer();

    sb.add('${declaration}: ${value};');
    sb.add('${Polly.browserInfo.vendorPrefix}${declaration}: ${value};');

    return sb.toString();
  }


  /** Returns true if the given property is supported. */
  static bool checkCSS3Support(Element e, String property, String value){

    var result = getCSS(e, property);

    if (result != null) return true;

    setCSS(e, property, value);

    result = getCSS(e, property);

    if (result != null){
      removeCSS(e, property);
      return true;
    }

    return false;
  }


  /**
   * Removes a given CSS property from an HTML element.
   *
   * Supports all common browser prefixes. */
  static void removeCSS(Element e, String property){

    e.style.removeProperty('${property}');
    e.style.removeProperty('${Polly.browserInfo.vendorPrefix}${property}');

  }


  /**
   * Assigns a value to a property of an element that ensures cross-browser
   * support.
   *
   * Supports all common browser prefixes.
   *
   * Returns true if property was successfully applied. */
  static bool setCSS(Element e, String property, String value){

    e.style.setProperty('${property}', value);
    e.style.setProperty('${Polly.browserInfo.vendorPrefix}${property}', value);

    return getCSS(e, property) != null;
  }


  /**
   * Gets a value from a given property.
   * Supports all common browser prefixes. */
  static String getCSS(Element e, String property){

    var result = e.style.getPropertyValue('${property}');

    if (result != null) return result;

    result = e.style.getPropertyValue('${Polly.browserInfo.vendorPrefix}${property}');

    return (result != null) ? result : null;
  }


  /**
   * Sets the flex [Orientation] of a flex box. */
  static void setFlexBoxOrientation(Element element, Orientation orientation){

    if (_flexModel == FlexModel.Box){
      setCSS(element, 'box-orient',
        orientation == Orientation.vertical ? 'vertical' : 'horizontal');
    }else{
      element.style.flexFlow =
      orientation == Orientation.vertical ? 'column' : 'row';
    }
  }


  /**
   * Gets the flex [Orientation] of a flex box. */
  static Orientation getFlexBoxOrientation(FrameworkElement element) =>
    element.rawElement.style.flexFlow == null
    || element.rawElement.style.flexFlow == 'column'
        ? Orientation.vertical
        : Orientation.horizontal;


  /** For individual items within a flexbox, but only in the cross-axis. */
  static void setItemHorizontalCrossAxisAlignment(FrameworkElement element,
                        HorizontalAlignment alignment, [FlexModel flexModel]){

    void flexHandler(){
      //supporting the latest draft flex box spec

      Polly.setCSS(element.rawElement, 'flex', 'none');

      switch(alignment){
        case HorizontalAlignment.left:
          setCSS(element.rawElement, 'align-self', 'flex-start');
          break;
        case HorizontalAlignment.right:
          setCSS(element.rawElement, 'align-self', 'flex-end');
          break;
        case HorizontalAlignment.center:
          setCSS(element.rawElement, 'align-self', 'center');
          break;
        case HorizontalAlignment.stretch:
          setCSS(element.rawElement, 'align-self', 'stretch');
          break;
      }
    }

    void flexBoxHandler(){
      //supporting the current flex box spec
      element
        ._manualAlignmentHandler
        .enableManualHorizontalAlignment(alignment);
    }

    void boxHandler(){
//      element
//      ._manualAlignmentHandler
//      .enableManualHorizontalAlignment(alignment);
    }


    void noFlexHandler(){
      throw const NotImplementedException();
    }

    switch(_flexModel){
      case FlexModel.Flex:
        flexHandler();
        break;
      case FlexModel.FlexBox:
        flexBoxHandler();
        break;
      case FlexModel.Box:
        boxHandler();
        break;
      default:
        noFlexHandler();
        break;
    }
  }

  /** For individual items within a flexbox, but only in the cross-axis. */
  static void setItemVerticalCrossAxisAlignment(FrameworkElement element,
                                                VerticalAlignment alignment,
                                                [FlexModel flexModel]){

    void flexHandler(){
      Polly.setCSS(element.rawElement, 'flex', 'none');
      switch(alignment){
        case VerticalAlignment.top:
          setCSS(element.rawElement, 'align-self', 'flex-start');
          break;
        case VerticalAlignment.bottom:
          setCSS(element.rawElement, 'align-self', 'flex-end');
          break;
        case VerticalAlignment.center:
          setCSS(element.rawElement, 'align-self', 'center');
          break;
        case VerticalAlignment.stretch:
          setCSS(element.rawElement, 'align-self', 'stretch');
          break;
        }
    }

    void flexBoxHandler(){
      element
      ._manualAlignmentHandler
      .enableManualVerticalAlignment(alignment);
    }


    void boxHandler(){
//      element
//      ._manualAlignmentHandler
//      .enableManualVerticalAlignment(alignment);
    }

    void noFlexHandler(){
      throw const NotImplementedException();
    }

    switch(_flexModel){
      case FlexModel.Flex:
        flexHandler();
        break;
      case FlexModel.FlexBox:
        flexBoxHandler();
        break;
      case FlexModel.Box:
        boxHandler();
        break;
      default:
        noFlexHandler();
        break;

    }
  }

  /**
   * Sets the horizontal alignment of children within
   * a given flex box container [element]. */
  static void setHorizontalFlexBoxAlignment(FrameworkElement element,
                                            HorizontalAlignment alignment,
                                            [FlexModel flexModel]){

    void flexHandler(){
      switch(alignment){
        case HorizontalAlignment.left:
          setCSS(element.rawElement, 'justify-content', 'flex-start');
          break;
        case HorizontalAlignment.right:
          setCSS(element.rawElement, 'justify-content', 'flex-end');
          break;
        case HorizontalAlignment.center:
          setCSS(element.rawElement, 'justify-content', 'center');
          break;
        case HorizontalAlignment.stretch:
          setCSS(element.rawElement, 'justify-content', 'stretch');
          break;
      }
    }

    void flexBoxHandler(){
      switch(alignment){
        case HorizontalAlignment.left:
          element.rawElement.style.flexPack = 'start';
          break;
        case HorizontalAlignment.right:
          element.rawElement.style.flexPack = 'end';
          break;
        case HorizontalAlignment.center:
          element.rawElement.style.flexPack = 'center';
          break;
        case HorizontalAlignment.stretch:
          element.rawElement.style.flexPack = 'start';
          break;
      }
    }

    void boxHandler(){
      switch(alignment){
        case HorizontalAlignment.left:
          element.rawElement.style.boxAlign = 'start';
          //setCSS(element.rawElement, 'box-align', 'start');
          break;
        case HorizontalAlignment.right:
          element.rawElement.style.boxAlign = 'end';
          //setCSS(element.rawElement, 'box-align', 'end');
          break;
        case HorizontalAlignment.center:
          element.rawElement.style.boxAlign = 'center';
          //setCSS(element.rawElement, 'box-align', 'center');
          break;
        case HorizontalAlignment.stretch:
          element.rawElement.style.boxAlign = 'stretch';
          //setCSS(element.rawElement, 'box-align', 'stretch');
          break;
      }
    }

    void noFlexHandler(){
      print('called noFlexHandler()');
     // throw const NotImplementedException('Flex box model not yet supported.');
    }

    switch(_flexModel){
      case FlexModel.Flex:
        flexHandler();
        break;
      case FlexModel.FlexBox:
        flexBoxHandler();
        break;
      case FlexModel.Box:
        boxHandler();
        break;
      default:
        noFlexHandler();
        break;
    }
  }


  /**
   * Sets the vertical alignment of children within
   * a given flex box container [element]. */
  static void setVerticalFlexBoxAlignment(FrameworkElement element,
                                          VerticalAlignment alignment,
                                          [FlexModel flexModel]){

    void flexHandler(){
      switch(alignment){
        case VerticalAlignment.top:
          setCSS(element.rawElement, 'align-items', 'flex-start');
          break;
        case VerticalAlignment.bottom:
          setCSS(element.rawElement, 'align-items', 'flex-end');
          break;
        case VerticalAlignment.center:
          setCSS(element.rawElement, 'align-items', 'center');
          break;
        case VerticalAlignment.stretch:
          setCSS(element.rawElement, 'align-items', 'stretch');
          break;
      }
    }

    void flexBoxHandler(){
      switch(alignment){
        case VerticalAlignment.top:
          element.rawElement.style.flexAlign = 'start';
          break;
        case VerticalAlignment.bottom:
          element.rawElement.style.flexAlign = 'end';
          break;
        case VerticalAlignment.center:
          element.rawElement.style.flexAlign = 'center';
          break;
        case VerticalAlignment.stretch:
          element.rawElement.style.flexAlign = 'stretch';
          break;
      }
    }

    void boxHandler(){
      switch(alignment){
        case VerticalAlignment.top:
          element.rawElement.style.boxAlign = 'start';
//          setCSS(element.rawElement, 'box-pack', 'start');
          break;
        case VerticalAlignment.bottom:
          element.rawElement.style.boxAlign = 'end';
//          setCSS(element.rawElement, 'box-pack', 'end');
          break;
        case VerticalAlignment.center:
          element.rawElement.style.boxAlign = 'center';
//          setCSS(element.rawElement, 'box-pack', 'center');
          break;
        case VerticalAlignment.stretch:
          element.rawElement.style.boxAlign = 'stretch';
//          setCSS(element.rawElement, 'box-pack', 'stretch');
          break;
      }
    }

    void noFlexHandler(){
      print('horizontal called noFlexHandler()');
     // throw const NotImplementedException('Flex box model not yet supported.');
    }

    switch(_flexModel){
      case FlexModel.Flex:
        flexHandler();
        break;
      case FlexModel.FlexBox:
        flexBoxHandler();
        break;
      case FlexModel.Box:
        boxHandler();
        break;
      default:
        noFlexHandler();
        break;
    }
  }

  /**
   * Sets the alignment of a given [element] within it's parent
   * [FrameworkElement].
   *
   * This function assumes that the parent element is already flexbox.
   *
   * This function is suitable for flex containers with a single child
   * element.
   */
  static void setFlexboxAlignment(FrameworkElement element){

    void flexHandler(){
      // browser supports the latest draft flexbox spec

      if (element.hAlign != null){
        Polly.setCSS(element.rawElement, 'flex', 'none');

        if(element.hAlign == HorizontalAlignment.stretch){
          Polly.setCSS(element.rawElement, 'flex', '1 1 auto');
        }

        setHorizontalFlexBoxAlignment(element.parent, element.hAlign,
          FlexModel.Flex);
      }

      if (element.vAlign != null){
        setVerticalFlexBoxAlignment(element.parent, element.vAlign,
          FlexModel.Flex);
      }
    }

    void flexBoxHandler(){
      //browser supports the current flexbox spec

      if (element.hAlign != null){
        if (element.hAlign == HorizontalAlignment.stretch){
          element
            ._manualAlignmentHandler
            .enableManualHorizontalAlignment(HorizontalAlignment.stretch);
        }else{
          //something else besides stretch
          element._manualAlignmentHandler.disableManualHorizontalAlignment();

          setHorizontalFlexBoxAlignment(element.parent, element.hAlign,
            FlexModel.FlexBox);
        }
      }

      if (element.vAlign != null){
        setVerticalFlexBoxAlignment(element.parent, element.vAlign,
          FlexModel.FlexBox);
      }
    }

    void boxHandler(){
      if (element.hAlign != null){
        if (element.hAlign == HorizontalAlignment.stretch){
          element
            ._manualAlignmentHandler
            .enableManualHorizontalAlignment(HorizontalAlignment.stretch);
        }else{
          //something else besides stretch
          element._manualAlignmentHandler.disableManualHorizontalAlignment();

          setHorizontalFlexBoxAlignment(element.parent, element.hAlign,
            FlexModel.Box);
        }
      }

      if (element.vAlign != null){
        setVerticalFlexBoxAlignment(element.parent, element.vAlign,
          FlexModel.Box);
      }
    }

    void noFlexHandler(){
      // TODO: handle all flex layouts manually...
      print('called noFlexHandler()');
   //   throw const NotImplementedException('Flex box model not yet supported.');
    }

    switch(_flexModel){
      case FlexModel.Flex:
        flexHandler();
        break;
      case FlexModel.FlexBox:
        flexBoxHandler();
        break;
      case FlexModel.Box:
        boxHandler();
        break;
      default:
        noFlexHandler();
    }
  }

  // Don't dump Polly!  She's a nice old gal.
  static void dump(){
    print('');
    print('Dear Polly,');
    print('${Polly.browserInfo}');
    print('Vendor Prefix: ${Polly.browserInfo.vendorPrefix}');
    print('Box Model Type: ${Polly._flexModel}');
    print('window width/height: ${buckshot.windowWidth} ${buckshot.windowHeight}');
    print('');
  }
}


