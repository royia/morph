//CS3451 Project 5
//Neville-Minkowski morph
//
//Ruofeng Chen
//Shaoduo Xie
//
//Instructed by Jarek Rossignac
//2012 Nov

import processing.opengl.*;                // load OpenGL libraries and utilities
import javax.media.opengl.*; 
import javax.media.opengl.glu.*; 
import java.nio.*;
GL gl; 
GLU glu;

float fr = 30.0;
float panel_scale = 10;
String instruction = "SPACE: rotate. z: zoom. mouse: move point. mouse+i on edge mid point:insert. mouse+d on point:delete. mouse+o: rotate solid. w: save.\n" 
                      +",&.:change sampling. m:show link/mesh. c:convexify. Please read the README first";

float t = 0.0;
float tMax = 1.0;
// state
boolean bShowMesh = true;
boolean bShowMeshSmooth = false;
boolean animate = true;
boolean showG = true;
boolean showR = true;
boolean showB = true;
boolean useN = false;
boolean useB = false;
boolean show12 = true;
boolean follow = false;

ArrayList<pt> interimT12 = new ArrayList<pt>();
ArrayList<pt> interimT21 = new ArrayList<pt>();
ArrayList<pt> interimQ = new ArrayList<pt>();

int sIndex = 0;

//solid s1 = new solid();
//solid s2 = new solid();
//mesh m1 = new mesh();
//mesh m2 = new mesh();

solid solids[] = new solid[4];
mesh meshes[] = new mesh[4];

void setup() {
  size(800, 800, OPENGL); // size(500, 500, OPENGL);  
  frameRate(int(fr));
  setColors(); 
  sphereDetail(12); 
  rectMode(CENTER);
  glu= ((PGraphicsOpenGL) g).glu;  
  PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;  
  gl = pgl.beginGL();  
  pgl.endGL();
  initm();
  
  initTable();

  for (int i = 0; i < 4; ++i) {
    solids[i] = new solid();
    meshes[i] = new mesh();
    solids[i].loadProfileFromFile("data/s" + str((i + 1)) + ".pfl");
    
  }
  solids[0].sampling_count = 4;
  solids[1].sampling_count = 4;
  solids[2].sampling_count = 5;
  solids[3].sampling_count = 4;
  //solids[0].loadProfileFromFile("data/s1.pfl");
  solids[0].location = P(0, 0, 100);
  solids[1].location = P(0, -66, 50);
  solids[2].location = P(0, -66, -50);
  solids[3].location = P(0, 0, -100);
  for (int i = 0; i < 4; ++i) {
    meshes[i].sweepFromProfile(solids[i].profile, solids[i].sampling_count, solids[i].location, solids[i].direction);
  }
  
}

void draw() {
  background(white);
  showAxes(100);
  
  beginCamera(); // the screen is zoomed in by ten times
  camera(width/2.0/panel_scale, height/2.0/panel_scale, (height/2.0/panel_scale) / tan(PI*30.0 / 180.0), width/2.0/panel_scale, height/2.0/panel_scale, 0, 0, 1, 0);
  stroke(black);
  //s1.showProfile();
  solids[sIndex].showProfile();
  fill(black);
  textSize(1);
  text(instruction, 1, 1);
  noFill();noStroke();
  endCamera();
  
  changeViewAndFrame();
  
  if (bShowMesh) {
    if(!bShowMeshSmooth) {
      fill(green);
      meshes[0].showMesh();
      fill(red);
      meshes[1].showMesh();
      fill(yellow);
      meshes[2].showMesh();
      meshes[3].showMesh();
      noFill();
    }
    else {
      fill(green);
      meshes[0].showMeshSmooth();
      fill(red);
      meshes[1].showMeshSmooth();
      fill(yellow);
      meshes[2].showMeshSmooth();
      meshes[3].showMeshSmooth();
      noFill();    
    }
    
  }
  else 
    meshes[0].showLinks();
  
  //interpolate
  if(show12) {
    //show part B of the project
    findMatch(meshes[0], meshes[1], t);
  }
  else
    findMatch(t);
  
  if (showG) {
    fill(green);
    //stroke(green);
    beginShape(TRIANGLES);
    for(int s = 0; s < interimT12.size(); s += 3) {
      vertex(interimT12.get(s).x, interimT12.get(s).y, interimT12.get(s).z);
      vertex(interimT12.get(s+1).x, interimT12.get(s+1).y, interimT12.get(s+1).z);
      vertex(interimT12.get(s+2).x, interimT12.get(s+2).y, interimT12.get(s+2).z);
    }
    endShape();
  }

  if (showR) { 
    fill(red);
    //stroke(red);
    beginShape(TRIANGLES);
    for(int s = 0; s < interimT21.size(); s += 3) {
      vertex(interimT21.get(s).x, interimT21.get(s).y, interimT21.get(s).z);
      vertex(interimT21.get(s+1).x, interimT21.get(s+1).y, interimT21.get(s+1).z);
      vertex(interimT21.get(s+2).x, interimT21.get(s+2).y, interimT21.get(s+2).z);
    }
    endShape();
  }
  
  if (showB) {
    fill(blue);
    //stroke(blue);
    beginShape(QUADS);
    for(int s = 0; s < interimQ.size(); s += 4) {
      vertex(interimQ.get(s).x, interimQ.get(s).y, interimQ.get(s).z);
      vertex(interimQ.get(s+1).x, interimQ.get(s+1).y, interimQ.get(s+1).z);
      vertex(interimQ.get(s+2).x, interimQ.get(s+2).y, interimQ.get(s+2).z);
      vertex(interimQ.get(s+3).x, interimQ.get(s+3).y, interimQ.get(s+3).z);
    }
    endShape();
    noFill();
  }
  
  if (follow) {
    if(interimT12.size() > 0)
      L = P(interimT12.get(0));
  }

  if(animate) {
    t += 0.01;
    if(t >= tMax)
      t = 0;
  }
  // keyboard control
  if (keyPressed&&key==' ') { 
    // rotate
    a-=PI*(mouseY-pmouseY)/height; 
    a=max(-PI/2+0.1, a); 
    a=min(PI/2-0.1, a);  
    b+=PI*(mouseX-pmouseX)/width;
  } 
  
  else if (keyPressed && key == 't') {
    animate = false;
    t += (mouseX - pmouseX) / (float)width;
    //println("t: " + t);
    if (t >= tMax)
      t = tMax;
    else if (t <= 0)
      t = 0;
  }
}

void mouseDragged() {
  pt2d pMouse = new pt2d(mouseX/panel_scale, mouseY/panel_scale);
  // move a point on profile
  int minI = -1;
  float minD = 999999;
  for(int i=0; i<solids[sIndex].profile.size(); i++) {
    float di = D2d(pMouse, solids[sIndex].profile.get(i));
    if(di < 1 && di < minD) {
      minI = i;
      minD = di;
    }
  }
  if (minI>=0) {
    solids[sIndex].setProfilePoint(minI, pMouse);
    meshes[sIndex].sweepFromProfile(solids[sIndex].profile, solids[sIndex].sampling_count, solids[sIndex].location, solids[sIndex].direction);
  }
  
  // change axis direction
  if (keyPressed&&key=='o') {
    vec vDirection = solids[sIndex].direction;
    float psi=PI*(mouseY-pmouseY)/height;  
    float theta=PI*(mouseX-pmouseX)/width;
    
    solids[sIndex].direction = U(R(vDirection, psi, vDirection, V(0,1,0)));
    solids[sIndex].direction = U(R(solids[sIndex].direction, theta, solids[sIndex].direction, V(1,0,0)));
    
    meshes[sIndex].sweepFromProfile(solids[sIndex].profile, solids[sIndex].sampling_count, solids[sIndex].location, solids[sIndex].direction);
  }
  
}


void mousePressed() {
  
  pt2d pMouse = new pt2d(mouseX/panel_scale, mouseY/panel_scale);
  // remove a point from profile
  if (keyPressed&&key=='d') {
    if (solids[sIndex].profile.size() > 2) {
      int minI = -1;
      float minD = 999999;
      for(int i=0; i<solids[sIndex].profile.size(); i++) {
        float di = D2d(pMouse, solids[sIndex].profile.get(i));
        if(di < 1 && di < minD) {
          minI = i;
          minD = di;
        }
      }
      if (minI>=0) {
        solids[sIndex].profile.remove(minI);
        meshes[sIndex].sweepFromProfile(solids[sIndex].profile, solids[sIndex].sampling_count, solids[sIndex].location, solids[sIndex].direction);
      }
    }  
  }
  
  // insert
  else if (keyPressed&&key=='i') {
    int minI = -1;
    float minD = 999999;
    for(int i=0; i<solids[sIndex].profile.size()-1; i++) {
      float di = D2d(pMouse, P2d(solids[sIndex].profile.get(i), solids[sIndex].profile.get(i+1)));
      if(di < 1 && di < minD) {
        minI = i;
        minD = di;
        
      }
    }

    if (minI>=0) {
      solids[sIndex].profile.add(minI+1, P2d(pMouse.x, pMouse.y));
      meshes[sIndex].sweepFromProfile(solids[sIndex].profile, solids[sIndex].sampling_count, solids[sIndex].location, solids[sIndex].direction);
    }
  }
}

void keyPressed() {
  // change number of sampling
  if (key==',') {
    if (solids[sIndex].sampling_count > 3) {
      solids[sIndex].sampling_count--;
      meshes[sIndex].sweepFromProfile(solids[sIndex].profile, solids[sIndex].sampling_count, solids[sIndex].location, solids[sIndex].direction);
    }
  }
  if (key=='.') {
    if (solids[sIndex].sampling_count < 40) {
      solids[sIndex].sampling_count++;
      meshes[sIndex].sweepFromProfile(solids[sIndex].profile, solids[sIndex].sampling_count, solids[sIndex].location, solids[sIndex].direction);
    }
  }
  
  if (key=='m') {
    bShowMesh = !bShowMesh;
  }
  
  if (key=='c') {
    solids[sIndex].convexify();
    meshes[sIndex].sweepFromProfile(solids[sIndex].profile, solids[sIndex].sampling_count, solids[sIndex].location, solids[sIndex].direction);
  }
  
  if (key=='w') {
    solids[sIndex].saveProfileToFile("data/s"+str(sIndex+1)+".pfl");
  }
  
  if (key=='q') {
    demo(meshes[0], 3);
  }
  
  if (key== 'a') {
    animate = !animate;
  }
  
  if (key== 'e') {
    float eps = 0.01;
    solids[sIndex].direction = U(A(solids[sIndex].direction, V(random(-eps, eps), random(-eps, eps), random(-eps, eps))));
    meshes[sIndex].sweepFromProfile(solids[sIndex].profile, solids[sIndex].sampling_count, solids[sIndex].location, solids[sIndex].direction);
  }
  
  if (key=='g') {
    bShowMeshSmooth = !bShowMeshSmooth;
  }
  
  if (key == '1' || key == '2' || key == '3' || key == '4') {
    //E = P(solids[key - '0' - 1].location.x * 1.1, solids[key - '0' - 1].location.y * 1.1, solids[key - '0' - 1].location.z * 1.1);
    L = P(solids[key - '0' - 1].location);
    sIndex = key - '0' - 1;
  }
  
  if (key == 'j')
    showR = !showR;
  if (key == 'k')
    showB = !showB;
  if (key == 'h')
    showG = !showG;
  if (key == 'b') {
    show12 = false;
    useN = false;
    useB = !useB;
    tMax = 1.0;
    t = 0;
  }
  if (key == 'n') {
    show12 = false;
    useB = false;
    useN = !useN;
    tMax = num_ctrl - 1;
    t = 0;
  }
  if(key == 'B') {
    show12 = !show12;
    if(show12) {
      tMax = 1;
    }
    else {
      tMax = 1;
      useB = true;
      useN = false;
    }
    t = 0;
  }
  
  if(key == 'f')
    follow = !follow;
}
