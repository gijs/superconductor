interface Root { 
  input w : int = 100;
  input h : int = 100;
}

interface Node { 
  var canvas : int;
  var render : int;
  var w : int;
  var h : int;
  var x : int;
  var relY : int;
  var absY : int;
  
  var lineH : int;
}

interface RowI {
  var x : int;
  var relY : int;
  var absY : int;
  var canvas : int;
  var render : int;
  var h : int;
  var w : int;

  var endY : int;  
}

class Row : RowI { 
  children {
    childs : [ Node ];
  }
  attributes {  var numCells : int; }
  actions {
    loop childs {
      numCells := fold 0 .. $-.numCells + 1;
      childs.x := fold x .. childs$-.x + childs$-.w + 5;
      childs.relY := 5;
      childs.absY := absY + childs$i.relY;
      childs.lineH := 0;
      childs.canvas := 0;
      h := fold 10 .. $-.h < (childs$i.h + 10) ? (childs$i.h + 10) : $-.h;
      w := fold numCells == 0 ? 10 : 5 .. $-.w + childs$i.w + 5;
    }
    render := canvas // canvas
     + paintLine (x, absY, x+w, absY, "#777") //top
      + paintLine (x+w, absY, x+w, absY+h, "#777") //right
      + paintLine (x+w, absY+h, x, absY+h, "#777") //bot
      + paintLine (x, absY+h, x, absY, "#777"); //left
  }
}


class Rows : Node {
  children {
    header : Node;
    footer : Node;
    rows : [ RowI ];
  }    
  attributes {
    var numRows : int;
    var lastRowY : int;
  }
  actions {
    header.x := x + 5;
    header.relY := 5;
    header.absY := absY + header.relY;
    
    loop rows {
      rows.x := x + 5;
      numRows := fold 0 .. $-.numRows + 1;
      h := fold 5 + header.h + 5 + footer.h + 10
        .. $-.h + rows$i.h + 10;
      w := fold 
        10 < (header.w + 10) ? 
          ((header.w + 10) < (footer.w + 10) ? (footer.w + 10) : (header.w + 10))
          : 10        
        .. (10 + rows$i.w > $-.w) ? (10 + rows$i.w) : $-.w;
      rows.endY := fold header.relY + header.h + 5 .. rows$-.endY + rows$i.h + 10;
      rows.relY := fold 0 .. rows$i.endY - rows$i.h - 5;
      rows.absY := fold 0 .. absY + rows$i.relY;
      rows.canvas := fold 0 .. 0;
      lastRowY := fold header.relY + header.h + 5 .. rows$i.endY;
    }

    footer.x := x + 5;
/*
    loop rows {
      footer.relY := fold header.relY + header.h + 5 .. rows$i.endY - rows$i.endY + rows$$.endY + 5; 
      footer.absY := fold absY + header.relY + header.h + 5 .. absY + rows$i.endY - rows$i.endY + rows$$.endY + 5;
    }
*/
    footer.relY := (numRows == 0) ? (header.relY + header.h + 10) : (lastRowY + 5);
    footer.absY := absY + footer.relY;
    
    loop rows {
        render := 
          fold canvas
              + paintLine (x, absY, x+w, absY, "#777") //top
              + paintLine (x+w, absY, x+w, absY+h, "#777") //right
              + paintLine (x+w, absY+h, x, absY+h, "#777") //bot
              + paintLine (x, absY+h, x, absY, "#777") //left
              + paintLine(x, absY + header.relY + header.h + 5,
                          x + w, absY + header.relY + header.h + 5, "#777")
            ..
            $-.render + paintLine(x, absY + rows$i.endY, x + w, absY + rows$i.endY, "#777");
    }
      
    header.canvas := render;
    loop rows { footer.canvas := fold 0 .. rows$i.render; }
    
    header.lineH := 0;
    footer.lineH := 0;
    
  }
}


class Top : Root {
  children { child : Node }
  actions {
    child.x := 0;
    child.relY := 0;
    child.absY := 0;
    child.canvas := paintStart(child.w, child.h);
    
    child.lineH := child.h;
  }
}

class Leaf : Node {
  actions {
    w := 10;
    h := 10;
    render := 
      canvas
      + paintLine (x, absY, x+w, absY, "#000") //top
      + paintLine (x+w, absY, x+w, absY+h, "#000") //right
      + paintLine (x+w, absY+h, x, absY+h, "#000") //bot
      + paintLine (x, absY+h, x, absY, "#000"); //left
  }
}

class HBox : Node {
  children { childs : [ Node ]; }  
  attributes { var numChilds : int; }
  actions {
    loop childs {
        numChilds := fold 0 .. 1 + $-.numChilds;
        w := fold 5 + ($$.numChilds == 0 ? 5 : 0) .. $-.w + childs$i.w + 5;
        h := fold 10 .. $-.h < (10 + childs$i.h) ? (10 + childs$i.h) : $-.h;
        childs.relY := fold 5 .. 5;
        childs.absY := absY + childs$i.relY;
        childs.x := fold x .. childs$-.x + childs$-.w + 5;  
        childs.canvas := fold render .. childs$-.canvas;
        
        childs.lineH := fold 0 .. 0;
    }
    render := 
      canvas
      + paintLine (x, absY, x+w, absY, "#FF0000") //top
      + paintLine (x+w, absY, x+w, absY+h, "#FF0000") //right
      + paintLine (x+w, absY+h, x, absY+h, "#FF0000") //bot
      + paintLine (x, absY+h, x, absY, "#FF0000"); //left
  }
}


class VBox : Node {
  children { childs : [ Node ]; }  
  attributes { var numChilds : int; }
  actions {
    loop childs {
        numChilds := fold 0 .. 1 + $-.numChilds;
        h := fold 5 + ($$.numChilds == 0 ? 5 : 0) .. $-.h + childs$i.h + 5;
        w := fold 10 .. $-.w < (10 + childs$i.w) ? (10 + childs$i.w) : $-.w;
        childs.x := x + 5;
        
        childs.relY := fold 0 .. childs$-.relY + childs$-.h + 5;  
        childs.absY := absY + childs$i.relY;
        childs.canvas := fold render .. childs$-.canvas;
        
        childs.lineH := fold 0 .. 0;
    }
    render := 
      canvas
      + paintLine (x, absY, x+w, absY, "#00FF00") //top
      + paintLine (x+w, absY, x+w, absY+h, "#00FF00") //right
      + paintLine (x+w, absY+h, x, absY+h, "#00FF00") //bot
      + paintLine (x, absY+h, x, absY, "#00FF00"); //left
  }
}


class WrapBox : Node {
  children { childs : [ Node ]; }
  attributes {
    input width : int = 100;
//    var lineH : int;
  }
  actions {
    w := width;
    loop childs {
      childs.x := fold x
          .. childs$-.x + childs$-.w + 5 + childs$i.w >= (x + w) ?
            (x + 5) : (childs$-.x + childs$-.w + 5);
      childs.lineH := fold 0 
          .. childs$i.x == x + 5 ? 
            childs$i.h 
            : (childs$i.h > childs$-.lineH ? childs$i.h : childs$-.lineH);         
      childs.relY := fold 0
          .. childs$-.relY + (childs$i.x == x + 5 ? childs$-.lineH + 5 : 0);
      childs.absY := absY + childs$i.relY;
      childs.canvas := fold render .. childs$-.canvas;      
      h := fold 10 .. childs$i.relY + childs$i.lineH + 5;      
    }
    render := 
      canvas
      + paintLine (x, absY, x+w, absY, "#0000FF") //top
      + paintLine (x+w, absY, x+w, absY+h, "#0000FF") //right
      + paintLine (x+w, absY+h, x, absY+h, "#0000FF") //bot
      + paintLine (x, absY+h, x, absY, "#0000FF"); //left
  }
}

class ListBox : Node {
  children { childs : [ Node ]; }
  actions {
    loop childs {
      w := fold 10 ..
        $-.w < (5 + 10 + 5 + childs$i.w + 5) ? 
          (5 + 10 + 5 + childs$i.w + 5) : $-.w;
      h := fold 10 ..
        $-.h + childs$i.h + 5;        
      childs.x := x + 15;
      childs.relY := fold 5 .. childs$-.relY + childs$-.h + 5;
      childs.absY := absY + childs$i.relY;      
    }
 
    loop childs {
      childs.lineH := 0;
      childs.canvas := fold render .. childs$-.canvas;
      render := 
        fold 
          canvas
          + paintLine (x, absY, x+w, absY, "#F0F") //top
          + paintLine (x+w, absY, x+w, absY+h, "#F0F") //right
          + paintLine (x+w, absY+h, x, absY+h, "#F0F") //bot
          + paintLine (x, absY+h, x, absY, "#F0F") //left
        ..
          paintLine (x + 5, childs$i.absY, x + 10, childs$i.absY, "#F0F") //top
          + paintLine (x + 10, childs$i.absY, x + 10, childs$i.absY + 5, "#F0F") //right
          + paintLine (x + 10, childs$i.absY + 5, x + 5, childs$i.absY + 5, "#F0F") //bot
          + paintLine (x + 5, childs$i.absY + + 5, x + 5, childs$i.absY, "#F0F"); //left
        

    }
  }
}