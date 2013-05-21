//CS3451 Project 5
//Neville-Minkowski morph
//
//Ruofeng Chen
//Shaoduo Xie
//
//Instructed by Jarek Rossignac
//2012 Nov

class mesh {
  pt vtx[];  // G
  int c2v[]; // corner to vertex, Jarek calls it V
  int v2c[]; // vertex to corner, Jarek calls it C
  int opp[];
  vec vn[];
  
  int numVtx;
  int numTgl;
  
  mesh() {
    reset();
  }
  
  void reset() {
    vtx = new pt[9999];
    c2v = new int[9999];
    opp = new int[9999];
    v2c = new int[9999];
    vn = new vec[9999];
    numVtx = 0;
    numTgl = 0;
  }
  
  // read a triangle mesh directly from a file
  void loadFromFile(String filename) {
    // read vertices
    String lines[] = loadStrings(filename+".vtx");
    numVtx = int(lines[0]);
    println(numVtx);
    for(int i=0; i<numVtx; i++) {
      String coordinate[] = split(lines[i+1], ',');
       if (coordinate.length == 3) {
         float x = float(coordinate[0]);
         float y = float(coordinate[1]);
         float z = float(coordinate[2]);
         vtx[i] = P(x, y, z);
       }
    }
    
    // read corners
    lines = loadStrings(filename+".c2v");
    numTgl = int(lines[0]);
    println(numTgl);
    for(int i=0; i<numTgl; i++) {
      String coordinate[] = split(lines[i+1], ',');
       if (coordinate.length == 3) {
         c2v[3*i] = int(coordinate[0]);
         c2v[3*i+1] = int(coordinate[1]);
         c2v[3*i+2] = int(coordinate[2]);
       }
    }
  }
  
  void sweepFromProfile(ArrayList<pt2d> profile, int numSampling, pt pLocation, vec vAxis) {
    reset();
    vec vOrtho = R90(vAxis); // this is mapped x
    vec vOrtho2 = N(vOrtho, vAxis);
    pt2d pCurr; pt2d pNext; pt pCurrMapped; pt pNextMapped; 
    
    // add a row of vertices in the profile first
    int vtxCnt = 0; // count vertices
    int c2vCnt = 0; // count corners
    pCurr = P2d(0., profile.get(0).y);
    pCurrMapped = P(pLocation, A(V(pCurr.x, vOrtho), V(pCurr.y, vAxis)));
    vtx[vtxCnt++] = pCurrMapped;
    pCurr = P2d(0., profile.get(profile.size()-1).y);
    pCurrMapped = P(pLocation, A(V(pCurr.x, vOrtho), V(pCurr.y, vAxis)));
    vtx[vtxCnt++] = pCurrMapped;
    for(int i=0; i<profile.size(); i++) {
      pCurr = profile.get(i);
      pCurrMapped = P(pLocation, A(V(pCurr.x, vOrtho), V(pCurr.y, vAxis)));
      vtx[vtxCnt++] = pCurrMapped;
    }
    
    // rotate and add another row
    for(int sweep=1; sweep<=numSampling; sweep++) {
      vOrtho = R(vOrtho, TWO_PI/numSampling, vOrtho, vOrtho2);
      vOrtho2 = N(vOrtho, vAxis);
  
      for(int i=0; i<profile.size(); i++) {
        pCurr = profile.get(i);
        pCurrMapped = P(pLocation, A(V(pCurr.x, vOrtho), V(pCurr.y, vAxis)));
        vtx[vtxCnt++] = pCurrMapped;
      }
      
      // add the first triangle
      c2v[c2vCnt++] = 0;
      c2v[c2vCnt++] = 2+(sweep-1)%numSampling*profile.size();
      c2v[c2vCnt++] = 2+sweep%numSampling*profile.size();
      
      // add the last triangle
      c2v[c2vCnt++] = 1;
      c2v[c2vCnt++] = sweep%numSampling*profile.size()+profile.size()+1;
      c2v[c2vCnt++] = (sweep-1)%numSampling*profile.size()+profile.size()+1;
      
      // add triangles in between - the quads
      for(int j=0; j<profile.size()-1; j++) {
        int c0 = 2+(sweep-1)%numSampling*profile.size()+j;
        int c1 = 2+sweep%numSampling*profile.size()+j;
        int c2 = 2+(sweep-1)%numSampling*profile.size()+j+1;
        int c3 = 2+sweep%numSampling*profile.size()+j+1;
        // two triangles here
        c2v[c2vCnt++] = c0;
        c2v[c2vCnt++] = c3;
        c2v[c2vCnt++] = c1;
        c2v[c2vCnt++] = c0;
        c2v[c2vCnt++] = c2;
        c2v[c2vCnt++] = c3;
      }
    }
    
    numVtx = vtxCnt;
    numTgl = c2vCnt/3;

    // good tables
    computeO();
    computeV2C();
    computeVertexNormals();
    
  }
  
  void showMesh() {
    beginShape(TRIANGLES); // display a triangle mesh
    //fill(red);
    pt pTemp;
    for(int i=0; i<numTgl; i++) {
      pTemp = vtx[c2v[3*i]];
      vertex(pTemp.x, pTemp.y, pTemp.z);
      pTemp = vtx[c2v[3*i+1]];
      vertex(pTemp.x, pTemp.y, pTemp.z);
      pTemp = vtx[c2v[3*i+2]];
      vertex(pTemp.x, pTemp.y, pTemp.z);
    }
    noStroke();
    endShape();
  }
  
  void showMeshSmooth() {
  
    beginShape(TRIANGLES); // display a triangle mesh
    //fill(red);
    pt pTemp;
    for(int i=0; i<numTgl; i++) {
      pTemp = vtx[c2v[3*i]];
      normal(vn[c2v[3*i]].x, vn[c2v[3*i]].y, vn[c2v[3*i]].z);
      vertex(pTemp.x, pTemp.y, pTemp.z);
      pTemp = vtx[c2v[3*i+1]];
      normal(vn[c2v[3*i+1]].x, vn[c2v[3*i+1]].y, vn[c2v[3*i+1]].z);
      vertex(pTemp.x, pTemp.y, pTemp.z);
      pTemp = vtx[c2v[3*i+2]];
      normal(vn[c2v[3*i+2]].x, vn[c2v[3*i+2]].y, vn[c2v[3*i+2]].z);
      vertex(pTemp.x, pTemp.y, pTemp.z);
    }
    noStroke();
    endShape();
  }
  
  void showLinks() { // not sure what J means, so I just connect all vertices
    stroke(red);
    for(int i=0; i<numVtx-1; i++) {
      show(vtx[i], vtx[i+1]);
    }
    noStroke();
  }
  
  void computeO() {
    for (int c=0; c<3*numTgl; c++) {
      opp[c] = c; 
    }
    for (int c=0; c<3*numTgl; c++) {
      for (int b=c+1; b<3*numTgl; b++) {
        if (c2v[n(c)]==c2v[p(b)] && c2v[p(c)]==c2v[n(b)]) {
          opp[c] = b;
          opp[b] = c;
        }
      }
    }
  }
  
  void computeVertexNormals() {
    for (int i=0; i<numVtx; i++) {
      ArrayList<vec> faceNormals = new ArrayList<vec>();
      int curC = v2c[i];
      for (int c = curC, cnt = 0; c != curC || cnt == 0; c = s(c), cnt++) {
        pt pA = vtx[c2v[c]];
        pt pB = vtx[c2v[n(c)]];
        pt pC = vtx[c2v[p(c)]];
        vec faceN = N(V(pA, pC), V(pA, pB));
        faceNormals.add(faceN);
      }
      
      // calculate average normal for vertex
      vec vSum = V();
      for (int j=0; j<faceNormals.size(); j++) {
        vSum = A(vSum, faceNormals.get(j));
      }
  
      vn[i] = U(vSum);
    }
  }
  
  void computeV2C() {
    for (int c=0; c<3*numTgl; c++) {
      v2c[c2v[c]] = c;
    }
  }
  
  // mesh manipulation
  int t(int c) {
    return c/3;
  }
  int v(int c) {
    return c2v[c];
  }
  int n(int c) {
    return 3*t(c)+(c+1)%3;
  }
  int p(int c) {
    return n(n(c));
  }
  int o(int c) {
    return opp[c];
  }
  int l(int c) {
    return o(n(c));
  }
  int s(int c) {
    return n(l(c));
  }
  
  int getVertexIndex(pt p) {
    float eps = 0.00001;
    int minI = 0;
    float minD = 999999;
    for (int i=0; i<numVtx; i++) {
      float di = d(p, vtx[i]);
      if (di < minD) {
        minD = di;
        minI = i;
      }
    }
    if (minD > eps) return -1;
    else return minI;
  }
  
  void interimToMesh(ArrayList<pt> interim12, ArrayList<pt> interim21, ArrayList<pt> interimQ)
  {
    
    // problem is: number of vertex smaller than number of corner
    for (int i = 0; i < interimT12.size(); i++) {
      vtx[numVtx] = P(interimT12.get(i));
      c2v[numTgl] = numVtx;
      numVtx++;
      numTgl++;
    }

    for (int i = 0; i < interimT21.size(); i++) {
      int vtxId = getVertexIndex(P(interimT21.get(i)));
      if (vtxId == -1) {
        vtx[numVtx] = P(interimT21.get(i));
        c2v[numTgl] = numVtx;
        numVtx++;
        numTgl++;
      }
      else {
        c2v[numTgl] = vtxId;
        numTgl++;
      }
    }
    
    fill(blue);
    for (int i = 0; i < interimQ.size(); i+=4) {
//      show(interimQ.get(i), 1);
//      show(interimQ.get(i + 1), 1);
//      show(interimQ.get(i + 2), 1);
//      show(interimQ.get(i + 3), 1);
      
      int vi = getVertexIndex(interimQ.get(i));
      if (vi > 0) {
        c2v[numTgl] = vi;
        numTgl++;
      } else {
        vtx[numVtx] = P(interimQ.get(i));
        c2v[numTgl] = numVtx;
        numVtx++;
        numTgl++;
      }
      
//      show(vtx[vi], 1);
//      println("0 "+vi);
      vi = getVertexIndex(interimQ.get(i + 3));
      if (vi > 0) {
        c2v[numTgl] = vi;
        numTgl++;
      } else {
        vtx[numVtx] = P(interimQ.get(i + 3));
        c2v[numTgl] = numVtx;
        numVtx++;
        numTgl++;
      }
//      show(vtx[vi], 1);
//      println("1 "+vi);
      vi = getVertexIndex(interimQ.get(i + 1));
      if (vi > 0) {
        c2v[numTgl] = vi;
        numTgl++;
      } else {
        vtx[numVtx] = P(interimQ.get(i + 1));
        c2v[numTgl] = numVtx;
        numVtx++;
        numTgl++;
      }
//      show(vtx[vi], 1);
//      println("2 "+vi);
      vi = getVertexIndex(interimQ.get(i + 3));
      if (vi > 0) {
        c2v[numTgl] = vi;
        numTgl++;
      } else {
        vtx[numVtx] = P(interimQ.get(i + 3));
        c2v[numTgl] = numVtx;
        numVtx++;
        numTgl++;
      }
//      show(vtx[vi], 1);
//      println("3 "+vi);
      vi = getVertexIndex(interimQ.get(i + 2));
      if (vi > 0) {
        c2v[numTgl] = vi;
        numTgl++;
      } else {
        vtx[numVtx] = P(interimQ.get(i + 2));
        c2v[numTgl] = numVtx;
        numVtx++;
        numTgl++;
      }
//      show(vtx[vi], 1);
//      println("4 "+vi);
      vi = getVertexIndex(interimQ.get(i + 1));
      if (vi > 0) {
        c2v[numTgl] = vi;
        numTgl++;
      } else {
        vtx[numVtx] = P(interimQ.get(i + 1));
        c2v[numTgl] = numVtx;
        numVtx++;
        numTgl++;
      }
//      show(vtx[vi], 1);
//      println("5 "+vi);
    }
    noFill();
    
    numTgl /= 3;
    
    // good tables
    computeO();
    computeV2C();
    int cnt = 0;
    for (int i = 0; i < numTgl * 3; ++i) {
      
      if (i == o(i)) {
        println("i: " + i + "oi: " + o(i));
        cnt ++;
      }
        
    }
    println("has not opposite: "+cnt + " out of "+ numTgl * 3);
    fill(black);
//    show(vtx[c2v[p(677)]], 1);
//    show(vtx[c2v[n(677)]], 1);
//    println(c2v[p(677)]+" "+c2v[n(677)]);
    noFill();
    //println("a");
    //computeVertexNormals();
    //println("b");
  }
}
