//   Copyright (c) 2012, John Evans & LUCA Studios LLC
//
//   http://www.lucastudios.com/contact
//   John: https://plus.google.com/u/0/115427174005651655317/about
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.

class FrameworkObjectTests extends TestGroupBase {

  registerTests(){
    this.testGroupName = "FrameworkObject Tests";
    
    testList["name property registration"] = namePropertyRegistration;
    testList["name property renaming"] = namePropertyRenaming;
    testList["name property unregister"] = namePropertyUnregister;
  }
  
  // Tests that assignment to the name property of a FrameworkObject
  // properly registers it with LucaSystem.namedElements
  void namePropertyRegistration(){
    var b = new Border();
    b.name = "hello";
    
    Expect.isTrue(LucaSystem.namedElements.containsKey("hello"));
  }
  
  // Tests that renaming the name property of a FrameworkObject
  // properly updates the registration in LucaSystem.namedElements
  void namePropertyRenaming(){
    var b = new Border();
    b.name = "hello";
    
    Expect.isTrue(LucaSystem.namedElements.containsKey("hello"));
    
    b.name = "world";
    
    Expect.isFalse(LucaSystem.namedElements.containsKey("hello"));
    Expect.isTrue(LucaSystem.namedElements.containsKey("world"));
    
  }
  
  // Tests that blanking the name property of a FrameworkObject
  // will properly unregister it from LucaSystem.namedElements
  void namePropertyUnregister(){
    var b = new Border();
    b.name = "hello";
    
    Expect.isTrue(LucaSystem.namedElements.containsKey("hello"));
    
    b.name = "";
    
    Expect.isFalse(LucaSystem.namedElements.containsKey("hello"), 'hello should not exist');
    Expect.isFalse(LucaSystem.namedElements.containsKey(""), 'blank should not exist');
  }
}
