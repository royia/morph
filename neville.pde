//CS3451 Project 5
//Neville-Minkowski morph
//
//Ruofeng Chen
//Shaoduo Xie
//
//Instructed by Jarek Rossignac
//2012 Nov

pt[][] table;

int num_ctrl = 4;

// in absolute time system, no more 0 - 1
pt LinearInterp(float tStart, pt pStart, float t, float tEnd, pt pEnd) {
  vec v = V(pStart, pEnd);
  return P(pStart, v.mul((t-tStart)/(tEnd-tStart)));
}

//interpolate the part from the s th point to e th point
void NevilleInterp(int s, int e, float t) {
  int num_pts = e - s + 1;
  if(num_pts > 2) {
    if(table[s][e-1] == null)
      NevilleInterp(s,       e - 1,  t);
    if(table[s+1][e] == null)
      NevilleInterp(s + 1,   e,      t);

    table[s][e] = LinearInterp(s, table[s][e-1], t, e, table[s+1][e]);
  }
  else if(num_pts == 2)
    table[s][e] = LinearInterp(s, table[s][s], t, e, table[e][e]);
}

void initTable()
{
  table = new pt[num_ctrl][num_ctrl];
  for(int i = 0; i < num_ctrl; ++i)
    for(int j = 0; j < num_ctrl; ++j) {
      if(i != j) {
        table[i][j] = null;
      }
      else {
        //table[i][i] = Vector(50*(i+1), 50*(i+1));
      }
    }
}

void reInitTable(pt tuple[])
{
  for(int i = 0; i < num_ctrl; ++i)
    for(int j = 0; j < num_ctrl; ++j) {
      if(i != j)
        table[i][j] = null;
      else {
        table[i][j] = P(tuple[i]);
      }
    }
}

//mesh LinearInterp(float tStart, mesh pStart, float t, float tEnd, mesh pEnd) {
//  findMatch(pStart, pEnd, (t-tStart)/(tEnd-tStart));
//  mesh ret = new mesh();
//  ret.interimToMesh(interimT12, interimT21, interimQ);
//  return ret;
////  PVector v = Vector(pStart, pEnd);
////  return PVector.add(pStart, PVector.mult(v, (t-tStart)/(tEnd-tStart)));
//}
//
//void initTable()
//{
//  table = new mesh[num_ctrl][num_ctrl];
//  for(int i = 0; i < num_ctrl; ++i)
//    for(int j = 0; j < num_ctrl; ++j) {
//      if(i != j) {
//        table[i][j] = null;
//      }
//    }
//}
//
//void clearTable()
//{
//  for(int i = 0; i < num_ctrl; ++i)
//    for(int j = 0; j < num_ctrl; ++j) {
//      if(i != j)
//        table[i][j] = null;
//    }
//}
