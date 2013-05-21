//CS3451 Project 5
//Neville-Minkowski morph
//
//Ruofeng Chen
//Shaoduo Xie
//
//Instructed by Jarek Rossignac
//2012 Nov

// 2D Point, for profile

class pt2d {
  float x;
  float y;

  pt2d(float x, float y) {
    this.x = x; 
    this.y = y;
  }
}

pt2d P2d(float x, float y) {return new pt2d(x, y);}
float D2d(pt2d p1, pt2d p2) {return (p1.x-p2.x)*(p1.x-p2.x)+(p1.y-p2.y)*(p1.y-p2.y);}
pt2d P2d(pt2d p1, pt2d p2) {return new pt2d((p1.x+p2.x)/2, (p1.y+p2.y)/2);}

// take them as vectors just for convenience
float sinangle(pt2d p1, pt2d p2) {return (p1.x*p2.y-p2.x*p1.y)/(sqrt(sq(p1.x)+sq(p1.y))*sqrt(sq(p2.x)+sq(p2.y)));} 

// Solid

class solid {
  ArrayList<pt2d> profile;
  pt location;
  vec direction; // a unit vector
  int sampling_count; // how many times the profile will be sweeped

  solid() { // need way to edit these params
    profile = new ArrayList<pt2d>();
    location = P(10, 10, 10);
    direction = V(0, 0, 1);
    float eps = 0.01;
    direction = U(A(direction, V(random(-eps, eps), random(-eps, eps), random(-eps, eps))));
    sampling_count = 3;
  }

  void dummy() { // test
    profile.add(new pt2d(10, 10));
    profile.add(new pt2d(20, 20));
    profile.add(new pt2d(10, 20));
    profile.add(new pt2d(10, 30));
  }
  
  void saveProfileToFile(String filename) {
    String str_out = "";
      for (int i=0; i<profile.size(); i++) {
        str_out += str(profile.get(i).x)+","+str(profile.get(i).y)+" ";
      }
      saveStrings(filename, split(str_out, ' '));
   }
   
   void loadProfileFromFile(String filename) {
     String lines[] = loadStrings(filename);
     for (int i=0; i<lines.length; i++) {
       String coordinate[] = split(lines[i], ',');
       if (coordinate.length == 2) {
         float x = float(coordinate[0]);
         float y = float(coordinate[1]);
         profile.add(new pt2d(x, y));
       }
     }
   }
  
  void showProfile() {
    if (profile.size() < 2) return;
    line(0, profile.get(0).y,profile.get(0).x, profile.get(0).y);
    for(int i=0; i<profile.size()-1; i++) {
      line(profile.get(i).x, profile.get(i).y,profile.get(i+1).x, profile.get(i+1).y);
    }
    line(profile.get(profile.size()-1).x, profile.get(profile.size()-1).y,0, profile.get(profile.size()-1).y);
    for(int i=0; i<profile.size(); i++) {
      rect(profile.get(i).x, profile.get(i).y,0.5,0.5);
    }
  }
  
  void setProfilePoint(int i, pt2d p) {
    profile.set(i, P2d(p.x, p.y));
  }
  
  void convexify() {
    stroke(green);
    
    // find the vertex with minimum y
    int minI = 0;
    int maxI = 0;
    float minY = 9999;
    float maxY = -9999;
    for (int i=0; i<profile.size(); i++) {
      if (profile.get(i).y < minY) {
        minY = profile.get(i).y;
        minI = i;
      }
      if (profile.get(i).y > maxY) {
        maxY = profile.get(i).y;
        maxI = i;
      }
    }

    ArrayList<pt2d> profileConvex = new ArrayList<pt2d>();

    int startI = minI;
    int endI = maxI;
    
    profileConvex.add(profile.get(startI));
    while (startI != endI) {
      // find a vector with max sin(angle)
      maxI = 0;
      float maxA = -9999;
      for (int i=0; i<profile.size(); i++) {
        if (startI != i) {
          float angle = sinangle(P2d(profile.get(i).x-profile.get(startI).x, profile.get(i).y-profile.get(startI).y), P2d(0,1));
          if (angle > maxA && profile.get(i).y > profile.get(startI).y) {
            maxA = angle;
            maxI = i;
          }
        }
      }
      startI = maxI;
      profileConvex.add(profile.get(startI));
    }
    
    profile = profileConvex;
    
    noStroke();
  }
}

