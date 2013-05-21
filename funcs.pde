//CS3451 Project 5
//Neville-Minkowski morph
//
//Ruofeng Chen
//Shaoduo Xie
//
//Instructed by Jarek Rossignac
//2012 Nov

void demo(mesh m, int v) {
  int c_start = m.v2c[v];
  stroke(red);
  for (int c=c_start, cnt=0; c!=c_start || cnt==0; c=m.s(c), cnt++) {
    show(m.vtx[m.c2v[m.n(c)]], m.vtx[m.c2v[c]]);
  }
  noStroke();
}

void findMatch(float t)
{
  interimT12.clear();
  interimT21.clear();
  interimQ.clear();
  pairFaceVertex(meshes[0], 0, interimT12, t);
  pairFaceVertex(meshes[1], 1, interimT12, t);
  pairFaceVertex(meshes[2], 2, interimT12, t);
  pairFaceVertex(meshes[3], 3, interimT12, t);
  
  
  pairEdges(meshes[0], 0);
  pairEdges(meshes[1], 1);
  pairEdges(meshes[2], 2);
  pairEdges(meshes[3], 3);
}

void pairEdges(mesh m1, int curI)
{ 
  for (int c1 = 0; c1 < m1.numTgl * 3; ++c1) {
    if (m1.o(c1) < c1)  //avoid duplicate edge
      continue;
      
    if (!IsConvexEdge(m1.vtx[m1.c2v[c1]], m1.vtx[m1.c2v[m1.n(c1)]], m1.vtx[m1.c2v[m1.p(c1)]], m1.vtx[m1.c2v[m1.o(c1)]])) {
      continue;
    }
      
    int count = 0;
//    vec a0a1 = V(m1.vtx[m1.c2v[m1.n(c1)]], m1.vtx[m1.c2v[m1.p(c1)]]);
    vec a0a1 = V(m1.vtx[m1.c2v[m1.p(c1)]], m1.vtx[m1.c2v[m1.n(c1)]]);
    vec a0c1 = V(m1.vtx[m1.c2v[m1.p(c1)]], m1.vtx[m1.c2v[c1]]);
    vec Na1 = N(a0a1, a0c1).normalize();
    vec Ta1 = N(Na1, a0a1).normalize();
    vec a0co = V(m1.vtx[m1.c2v[m1.p(c1)]], m1.vtx[m1.c2v[m1.o(c1)]]);
    vec Na2 = N(a0co, a0a1).normalize();
    vec Ta2 = N(a0a1, Na2).normalize();
    
    pt tuples[][] = new pt[num_ctrl][num_ctrl];
    for (int m = 0; m < num_ctrl; ++m) {
      //println("m :" + m);
      if(m == curI)
        continue;
      mesh m2 = meshes[m];
      //println("m :" + m);
      
      boolean matched = false;
      for (int c2 = 0; c2 < m2.numTgl * 3; ++c2) {
        if (m2.o(c2) < c2)  //avoid duplicate edge
          continue;
          
        if (!IsConvexEdge(m2.vtx[m2.c2v[c2]], m2.vtx[m2.c2v[m2.n(c2)]], m2.vtx[m2.c2v[m2.p(c2)]], m2.vtx[m2.c2v[m2.o(c2)]])) {
          continue;
        }
          
        vec b0b1 = V(m2.vtx[m2.c2v[m2.p(c2)]], m2.vtx[m2.c2v[m2.n(c2)]]);
        vec b0c2 = V(m2.vtx[m2.c2v[m2.p(c2)]], m2.vtx[m2.c2v[c2]]);
        vec Nb = N(b0b1, b0c2).normalize();
        vec Tb1 = N(Nb, b0b1).normalize();
        vec b0co = V(m2.vtx[m2.c2v[m2.p(c2)]], m2.vtx[m2.c2v[m2.o(c2)]]);
        vec Nb2 = N(b0co, b0b1).normalize();
        vec Tb2 = N(b0b1, Nb2).normalize();
        
        vec N = N(a0a1, b0b1).normalize();
        if ((d(N, Ta1) < 0 && d(N, Tb1) < 0 && d(N, Ta2) < 0 && d(N, Tb2) < 0)||(d(N, Ta1) > 0 && d(N, Tb1) > 0 && d(N, Ta2) > 0 && d(N, Tb2) > 0)) {
          matched = true;
          
          tuples[m][0] = P(m2.vtx[m2.c2v[m2.p(c2)]]);
          tuples[m][1] = P(m2.vtx[m2.c2v[m2.p(c2)]]);
          tuples[m][2] = P(m2.vtx[m2.c2v[m2.n(c2)]]);
          tuples[m][3] = P(m2.vtx[m2.c2v[m2.n(c2)]]);
        }
      }
      
      if(matched == false) {
        //countM++;
        
        float maxS = 999999999;
        int maxC = -1;
        for (int c2 = 0; c2 < m2.numTgl * 3; ++c2) {
          if (m2.o(c2) < c2)  //avoid duplicate edge
            continue;
            
          if (!IsConvexEdge(m2.vtx[m2.c2v[c2]], m2.vtx[m2.c2v[m2.n(c2)]], m2.vtx[m2.c2v[m2.p(c2)]], m2.vtx[m2.c2v[m2.o(c2)]])) {
            continue;
          }
            
          vec b0b1 = V(m2.vtx[m2.c2v[m2.p(c2)]], m2.vtx[m2.c2v[m2.n(c2)]]);
          vec b0c2 = V(m2.vtx[m2.c2v[m2.p(c2)]], m2.vtx[m2.c2v[c2]]);
          vec Nb1 = N(b0b1, b0c2).normalize();
          vec Tb1 = N(Nb1, b0b1).normalize();
          vec b0co = V(m2.vtx[m2.c2v[m2.p(c2)]], m2.vtx[m2.c2v[m2.o(c2)]]);
          vec Nb2 = N(b0co, b0b1).normalize();
          vec Tb2 = N(b0b1, Nb2).normalize();
          
          vec N = N(a0a1, b0b1).normalize();
          float sum = d(N, Ta1) + d(N, Tb1) + d(N, Ta2) + d(N, Tb2);
          if (sum < maxS) {
            maxS = sum;
            maxC = c2;
          }
        }
        
        tuples[m][0] = P(m2.vtx[m2.c2v[m2.p(maxC)]]);
        tuples[m][1] = P(m2.vtx[m2.c2v[m2.p(maxC)]]);
        tuples[m][2] = P(m2.vtx[m2.c2v[m2.n(maxC)]]);
        tuples[m][3] = P(m2.vtx[m2.c2v[m2.n(maxC)]]);
      }
      
    }
    
    tuples[curI][0] = P(m1.vtx[m1.c2v[m1.p(c1)]]);
    tuples[curI][1] = P(m1.vtx[m1.c2v[m1.n(c1)]]);
    tuples[curI][2] = P(m1.vtx[m1.c2v[m1.n(c1)]]);
    tuples[curI][3] = P(m1.vtx[m1.c2v[m1.p(c1)]]);
    
    pt eachTuple [] = new pt[4];
    for(int e = 0; e < num_ctrl; ++e) {
      boolean haveNull = false;
      for(int i = 0; i < num_ctrl; ++i) {
        if(tuples[i][e] == null) {
          haveNull = true;

        }

        eachTuple[i] = tuples[i][e];
      }
      
      if (useB) {
        pt toAdd = P(P(eachTuple[0], t, eachTuple[2]), t, P(eachTuple[1], t, eachTuple[3]));
        interimQ.add(toAdd);
      }
      else if(useN) {
        reInitTable(eachTuple);
        NevilleInterp(0, num_ctrl - 1, t);
        interimQ.add(P(table[0][num_ctrl - 1]));
      }
    }
    
  }

}

void pairFaceVertex(mesh m1, int curI, ArrayList<pt> interimT, float t)
{
  for (int f = 0; f < m1.numTgl; ++f) {
    int count = 0;
    vec c0c1 = V(m1.vtx[m1.c2v[f*3]], m1.vtx[m1.c2v[f*3 + 1]]);
    vec c0c2 = V(m1.vtx[m1.c2v[f*3]], m1.vtx[m1.c2v[f*3 + 2]]);
    vec faceN = N(c0c1, c0c2).normalize();
    
    pt tuple[] = new pt[num_ctrl];
    for (int m = 0; m < num_ctrl; ++m) {
      if (m == curI)
        continue;
      mesh m2 = meshes[m];
      
      boolean matched = true;
      for(int i = 0; i < m2.numVtx; ++i) {
        //iterate over vertex, and in each vertax, iterate over each corner
        int curC = m2.v2c[i];
        matched = true;
        
        for (int c = curC, cnt = 0; c != curC || cnt == 0; c = m2.s(c), cnt++) {
          vec curOutV = V(m2.vtx[m2.c2v[c]], m2.vtx[m2.c2v[m2.n(c)]]);
          
          if (d(faceN, curOutV) > 0) {
            matched = false;
            break;
          }
        }
        
        if (!matched) {
          //not match, continue to the next vertex in m2
          continue;
        }
        
        //reach here means the vertex and the face match
        //calculate the points
        if (m < tuple.length)
          tuple[m] = P(m2.vtx[i]);
        else
          println("more than 3 points matched found");
        
      }
      
    }
        
    for(int cInM1 = 0; cInM1 < 3; ++cInM1) {
      tuple[curI] = P(m1.vtx[m1.c2v[f*3 + cInM1]]);
     
      if (useB) {
        pt toAdd = P(P(tuple[0], t, tuple[2]), t, P(tuple[1], t, tuple[3]));
        interimT.add(toAdd);
      }
      else if(useN) {
        reInitTable(tuple);
      
        NevilleInterp(0, num_ctrl - 1, t);  
        interimT.add(P(table[0][num_ctrl - 1]));
      }

    }
    
  }
}

void findMatch(mesh m1, mesh m2, float t)
{
  interimT12.clear();
  interimT21.clear();
  interimQ.clear();
  pairFaceVertex(m1, m2, interimT12, t);
  pairFaceVertex(m2, m1, interimT21, 1 - t);
  pairEdges(m1, m2);
}

void pairEdges(mesh m1, mesh m2)
{ 
  int countM = 0;
  for (int c1 = 0; c1 < m1.numTgl * 3; ++c1) {
    if (m1.o(c1) < c1)  //avoid duplicate edge
      continue;
      
    if (!IsConvexEdge(m1.vtx[m1.c2v[c1]], m1.vtx[m1.c2v[m1.n(c1)]], m1.vtx[m1.c2v[m1.p(c1)]], m1.vtx[m1.c2v[m1.o(c1)]])) {
      continue;
    }
      
    int count = 0;
//    vec a0a1 = V(m1.vtx[m1.c2v[m1.p(c1)]], m1.vtx[m1.c2v[m1.n(c1)]]);
    vec a0a1 = V(m1.vtx[m1.c2v[m1.n(c1)]], m1.vtx[m1.c2v[m1.p(c1)]]);
    vec a0c1 = V(m1.vtx[m1.c2v[m1.p(c1)]], m1.vtx[m1.c2v[c1]]);
    vec Na1 = N(a0a1, a0c1).normalize();
    vec Ta1 = N(Na1, a0a1).normalize();
    vec a0co = V(m1.vtx[m1.c2v[m1.p(c1)]], m1.vtx[m1.c2v[m1.o(c1)]]);
    vec Na2 = N(a0co, a0a1).normalize();
    vec Ta2 = N(a0a1, Na2).normalize();
    
//    stroke(red);
//    pt bary = P(m1.vtx[m1.c2v[m1.p(c1)]], m1.vtx[m1.c2v[c1]], m1.vtx[m1.c2v[m1.n(c1)]]);
//    show(bary, V(10, Na1));
//    
//    stroke(black);
//    pt centerA0A1 = P(m1.vtx[m1.c2v[m1.p(c1)]], m1.vtx[m1.c2v[m1.n(c1)]]);
//    show(centerA0A1, V(6, Ta1));
//    
//    stroke(yellow);
//    show(m1.vtx[m1.c2v[m1.p(c1)]], m1.vtx[m1.c2v[m1.n(c1)]]);
////    show(m1.vtx[m1.c2v[m1.p(c1)]], m1.vtx[m1.c2v[c1]]);
////    show(m1.vtx[m1.c2v[m1.n(c1)]], m1.vtx[m1.c2v[c1]]);
//    
    
    boolean matched = false;
    for (int c2 = 0; c2 < m2.numTgl * 3; ++c2) {
      if (m2.o(c2) < c2)  //avoid duplicate edge
        continue;
        
      if (!IsConvexEdge(m2.vtx[m2.c2v[c2]], m2.vtx[m2.c2v[m2.n(c2)]], m2.vtx[m2.c2v[m2.p(c2)]], m2.vtx[m2.c2v[m2.o(c2)]])) {
        continue;
      }
        
      vec b0b1 = V(m2.vtx[m2.c2v[m2.p(c2)]], m2.vtx[m2.c2v[m2.n(c2)]]);
      vec b0c2 = V(m2.vtx[m2.c2v[m2.p(c2)]], m2.vtx[m2.c2v[c2]]);
      vec Nb1 = N(b0b1, b0c2).normalize();
      vec Tb1 = N(Nb1, b0b1).normalize();
      vec b0co = V(m2.vtx[m2.c2v[m2.p(c2)]], m2.vtx[m2.c2v[m2.o(c2)]]);
      vec Nb2 = N(b0co, b0b1).normalize();
      vec Tb2 = N(b0b1, Nb2).normalize();
      
      vec N = N(a0a1, b0b1).normalize();
      if ((d(N, Ta1) < 0 && d(N, Tb1) < 0 && d(N, Ta2) < 0 && d(N, Tb2) < 0)||(d(N, Ta1) > 0 && d(N, Tb1) > 0 && d(N, Ta2) > 0 && d(N, Tb2) > 0)) {
        matched = true;
        
        if (matched) {
          interimQ.add(P(1-t, m1.vtx[m1.c2v[m1.p(c1)]], t, m2.vtx[m2.c2v[m2.p(c2)]]));
          interimQ.add(P(1-t, m1.vtx[m1.c2v[m1.n(c1)]], t, m2.vtx[m2.c2v[m2.p(c2)]]));
          interimQ.add(P(1-t, m1.vtx[m1.c2v[m1.n(c1)]], t, m2.vtx[m2.c2v[m2.n(c2)]]));
          interimQ.add(P(1-t, m1.vtx[m1.c2v[m1.p(c1)]], t, m2.vtx[m2.c2v[m2.n(c2)]]));
          
        }
        
        //stroke(red);
        //pt bary2 = P(m2.vtx[m2.c2v[m2.p(c2)]], m2.vtx[m2.c2v[c2]], m2.vtx[m2.c2v[m2.n(c2)]]);
        //show(bary2, V(-10, Nb1));
        
        //pt centerB0B1 = P(m2.vtx[m2.c2v[m2.p(c2)]], m2.vtx[m2.c2v[m2.n(c2)]]);
        //stroke(yellow);
        //show(centerB0B1, V(6, Tb1));
        //show(m2.vtx[m2.c2v[m2.p(c2)]], m2.vtx[m2.c2v[m2.n(c2)]]);

        //noStroke();
      }
      
    }
    
    if(matched == false) {
//        println(c1 + " no match found");
        countM++;
        
        float maxS = -999999999;
        int maxC = -1;
        for (int c2 = 0; c2 < m2.numTgl * 3; ++c2) {
          if (m2.o(c2) < c2)  //avoid duplicate edge
            continue;
            
          if (!IsConvexEdge(m2.vtx[m2.c2v[c2]], m2.vtx[m2.c2v[m2.n(c2)]], m2.vtx[m2.c2v[m2.p(c2)]], m2.vtx[m2.c2v[m2.o(c2)]])) {
            continue;
          }
            
          vec b0b1 = V(m2.vtx[m2.c2v[m2.p(c2)]], m2.vtx[m2.c2v[m2.n(c2)]]);
          vec b0c2 = V(m2.vtx[m2.c2v[m2.p(c2)]], m2.vtx[m2.c2v[c2]]);
          vec Nb1 = N(b0b1, b0c2).normalize();
          vec Tb1 = N(Nb1, b0b1).normalize();
          vec b0co = V(m2.vtx[m2.c2v[m2.p(c2)]], m2.vtx[m2.c2v[m2.o(c2)]]);
          vec Nb2 = N(b0co, b0b1).normalize();
          vec Tb2 = N(b0b1, Nb2).normalize();
          
          vec N = N(a0a1, b0b1).normalize();
          float sum = d(N, Ta1) + d(N, Tb1) + d(N, Ta2) + d(N, Tb2);
          if (sum > maxS) {
            maxS = sum;
            maxC = c2;
          }
        }
        
        interimQ.add(P(1-t, m1.vtx[m1.c2v[m1.p(c1)]], t, m2.vtx[m2.c2v[m2.p(maxC)]]));
        interimQ.add(P(1-t, m1.vtx[m1.c2v[m1.n(c1)]], t, m2.vtx[m2.c2v[m2.p(maxC)]]));
        interimQ.add(P(1-t, m1.vtx[m1.c2v[m1.n(c1)]], t, m2.vtx[m2.c2v[m2.n(maxC)]]));
        interimQ.add(P(1-t, m1.vtx[m1.c2v[m1.p(c1)]], t, m2.vtx[m2.c2v[m2.n(maxC)]]));
    }
    
  }
  //println("NotMached: " + countM);
  noFill();
  noStroke();
}

void pairFaceVertex(mesh m1, mesh m2, ArrayList<pt> interimT, float t)
{
  for (int f = 0; f < m1.numTgl; ++f) {
    int count = 0;
    vec c0c1 = V(m1.vtx[m1.c2v[f*3]], m1.vtx[m1.c2v[f*3 + 1]]);
    vec c0c2 = V(m1.vtx[m1.c2v[f*3]], m1.vtx[m1.c2v[f*3 + 2]]);
    vec faceN = N(c0c1, c0c2).normalize();
    
    boolean matched = true;
    for(int i = 0; i < m2.numVtx; ++i) {
      //iterate over vertex, and in each vertax, iterate over each corner
      int curC = m2.v2c[i];
      matched = true;
      
      for (int c = curC, cnt = 0; c != curC || cnt == 0; c = m2.s(c), cnt++) {
        vec curOutV = V(m2.vtx[m2.c2v[c]], m2.vtx[m2.c2v[m2.n(c)]]);
        
        if (d(faceN, curOutV) > 0) {
          matched = false;
          break;
        }
      }
      
      if (!matched) {
        //not match, continue to the next vertex in m2
        continue;
      }
      
      //reach here means the vertex and the face match
      //calculate the points
      interimT.add(P(1-t, m1.vtx[m1.c2v[f*3]], t, m2.vtx[i]));
      interimT.add(P(1-t, m1.vtx[m1.c2v[f*3 + 1]], t, m2.vtx[i]));
      interimT.add(P(1-t, m1.vtx[m1.c2v[f*3 + 2]], t, m2.vtx[i]));
      
      ++count;
    }
  }
  noFill();
  noStroke();
}

void drawTriangleOfCorner(mesh m, int c) {
beginShape(TRIANGLES);
vertex(m.vtx[c].x, m.vtx[c].y, m.vtx[c].z);
vertex(m.vtx[m.c2v[m.n(m.v2c[c])]].x, m.vtx[m.c2v[m.n(m.v2c[c])]].y, m.vtx[m.c2v[m.n(m.v2c[c])]].z);
vertex(m.vtx[m.c2v[m.p(m.v2c[c])]].x, m.vtx[m.c2v[m.p(m.v2c[c])]].y, m.vtx[m.c2v[m.p(m.v2c[c])]].z);
endShape();
}

boolean IsConvexEdge(pt A, pt B, pt C, pt D) {
  // see if BC is convex edge
  vec NN = N(V(B, C), V(B, D));
  if (d(V(B, A), NN) > 0) return true;
  else return false;
}

//void pairEdges(mesh m1, mesh m2)
//{ 
//  for (int c1 = 0; c1 < m1.numTgl * 3; ++c1) {
//    if (m1.o(c1) < c1)  //avoid duplicate edge
//      continue;
//      
//    int count = 0;
//    //vec a0a1 = V(m1.vtx[m1.c2v[m1.p(c1)]], m1.vtx[m1.c2v[m1.n(c1)]]);
//    vec a0a1 = V(m1.vtx[m1.c2v[m1.n(c1)]], m1.vtx[m1.c2v[m1.p(c1)]]);
//    vec a0c1 = V(m1.vtx[m1.c2v[m1.p(c1)]], m1.vtx[m1.c2v[c1]]);
//    vec Na1 = N(a0a1, a0c1).normalize();
//    vec Ta1 = N(Na1, a0a1).normalize();
//    vec a0co = V(m1.vtx[m1.c2v[m1.p(c1)]], m1.vtx[m1.c2v[m1.o(c1)]]);
//    vec Na2 = N(a0co, a0a1).normalize();
//    vec Ta2 = N(a0a1, Na2).normalize();
//    
////    stroke(red);
////    pt bary = P(m1.vtx[m1.c2v[m1.p(c1)]], m1.vtx[m1.c2v[c1]], m1.vtx[m1.c2v[m1.n(c1)]]);
////    show(bary, V(10, Na1));
////    
////    stroke(black);
////    pt centerA0A1 = P(m1.vtx[m1.c2v[m1.p(c1)]], m1.vtx[m1.c2v[m1.n(c1)]]);
////    show(centerA0A1, V(6, Ta1));
////    
////    stroke(yellow);
////    show(m1.vtx[m1.c2v[m1.p(c1)]], m1.vtx[m1.c2v[m1.n(c1)]]);
////    show(m1.vtx[m1.c2v[m1.p(c1)]], m1.vtx[m1.c2v[c1]]);
////    show(m1.vtx[m1.c2v[m1.n(c1)]], m1.vtx[m1.c2v[c1]]);
//    
//    boolean matched = false;
//    for (int c2 = 0; c2 < m2.numTgl * 3; ++c2) {
//      vec b0b1 = V(m2.vtx[m2.c2v[m2.p(c2)]], m2.vtx[m2.c2v[m2.n(c2)]]);
//      vec b0c2 = V(m2.vtx[m2.c2v[m2.p(c2)]], m2.vtx[m2.c2v[c2]]);
//      vec Nb = N(b0b1, b0c2).normalize();
//      vec Tb1 = N(Nb, b0b1).normalize();
//      vec b0co = V(m2.vtx[m2.c2v[m2.p(c2)]], m2.vtx[m2.c2v[m2.o(c2)]]);
//      vec Nb2 = N(b0co, b0b1).normalize();
//      vec Tb2 = N(b0b1, Nb2).normalize();
//      
//      vec N = N(a0a1, b0b1).normalize();
//      if ((d(N, Ta1) < 0 && d(N, Tb1) < 0 && d(N, Ta2) < 0 && d(N, Tb2) < 0)||(d(N, Ta1) > 0 && d(N, Tb1) > 0 && d(N, Ta2) > 0 && d(N, Tb2) > 0)) {
//        matched = true;
//        
//        if (matched) {
//          interimQ.add(P(1-t, m1.vtx[m1.c2v[m1.p(c1)]], t, m2.vtx[m2.c2v[m2.p(c2)]]));
//          interimQ.add(P(1-t, m1.vtx[m1.c2v[m1.n(c1)]], t, m2.vtx[m2.c2v[m2.p(c2)]]));
//          interimQ.add(P(1-t, m1.vtx[m1.c2v[m1.n(c1)]], t, m2.vtx[m2.c2v[m2.n(c2)]]));
//          interimQ.add(P(1-t, m1.vtx[m1.c2v[m1.p(c1)]], t, m2.vtx[m2.c2v[m2.n(c2)]]));
//          
//        }
//        
//        stroke(red);
//        pt bary2 = P(m2.vtx[m2.c2v[m2.p(c2)]], m2.vtx[m2.c2v[c2]], m2.vtx[m2.c2v[m2.n(c2)]]);
//        show(bary2, V(-10, Nb));
//        
//        pt centerB0B1 = P(m2.vtx[m2.c2v[m2.p(c2)]], m2.vtx[m2.c2v[m2.n(c2)]]);
//        stroke(yellow);
//        show(centerB0B1, V(6, Tb1));
//        show(m2.vtx[m2.c2v[m2.p(c2)]], m2.vtx[m2.c2v[m2.n(c2)]]);
//        show(m2.vtx[m2.c2v[m2.p(c2)]], m2.vtx[m2.c2v[c2]]);
//        show(m2.vtx[m2.c2v[m2.n(c2)]], m2.vtx[m2.c2v[c2]]);
//        noStroke();
//        //only to find at most one for now
//        //if (++count > 10)
//          //break;
//      }
//    }
//    
//    if(matched == false)
//        println(c1 + " no match found");
//    
//  }
//  noFill();
//  noStroke();
//}

