#import('dart:html');
#import('../../lib/Buckshot.dart');

#source('Life.dart');
#source('View.dart');
#source('ViewModel.dart');
#source('GameState.dart');
#source('PlayfieldView.dart');
#source('PlayfieldViewModel.dart');

#resource('readme.txt');

// See readme.txt for information about this adaptation of Conway's Game Of Life

class GameOfLife {
final ViewModel vm;
  GameOfLife(): vm = new ViewModel()
  { }

}

void main() {
  //initialize the framework
  new Buckshot();
  
  new GameOfLife();
  
}
