//import peasy.*;

//PeasyCam cam;

final int BLOCK_AIR = 0;
final int BLOCK_DIRT = 1;
final int BLOCK_STONE = 2;
final int BLOCK_GRASS_DIRT = 3;

final int GENERATE = 0;
final int PLAY = 1;

final int FIRST_PERSON = 0;
final int THIRD_PERSON = 1;

int chunkw = 16;
int chunkh = 16;
int worldw = 100;
int worldh = 100;
int vieww = 4;
int viewh = 4;
float playerX = 0;
float playerY = 0;
float playerZ = 0;
int maxheight = 16;
int state = GENERATE;

float offsetX = 0;
float offsetY = 0;

int genx = 0;
int geny = 0;
int geni = 1;

int viewmode = THIRD_PERSON;

Chunk chunks[][];

class Block {
  int ID = BLOCK_AIR;
  boolean hasDefaultName = true;
  String name = "";
  
  Block(int id) {
    ID = id;
  }
}

class Chunk {
  Block blocks[][][];
  boolean isGenerated = false;
  int chunkx = 0;
  int chunky = 0;
  
  Chunk(int cx, int cy) {
    chunkx = cx;
    chunky = cy;
  }
  
  void generate() {
    blocks = new Block[chunkw][chunkh][maxheight];
    for (int x = 0; x < chunkw; x++) {
      for (int z = 0; z < chunkh; z++) {
        float h = round(map(noise((float)x/chunkw + chunkx + offsetX, (float)z/chunkh + chunky + offsetY), 0, 1, 0, maxheight-1));
        for (int y = 0; y < maxheight; y++) {
          blocks[x][z][y] = new Block(h>y?(h-1>y?(h-4>y?BLOCK_STONE:BLOCK_DIRT):BLOCK_GRASS_DIRT):BLOCK_AIR);
        }
      }
    }
  }
  
  void render() {
    for (int x = 0; x < chunkw; x++) {
      for (int y = 0; y < maxheight; y++) {
        for (int z = 0; z < chunkh; z++) {
          pushMatrix();
          boolean sideA = blocks[constrain(x-1, 0, chunkw-1)][z][y].ID == BLOCK_AIR;
          boolean sideB = blocks[constrain(x+1, 0, chunkw-1)][z][y].ID == BLOCK_AIR;
          boolean sideC = blocks[x][constrain(z-1, 0, chunkh-1)][y].ID == BLOCK_AIR;
          boolean sideD = blocks[x][constrain(z+1, 0, chunkh-1)][y].ID == BLOCK_AIR;
          boolean sideE = blocks[x][z][constrain(y-1, 0, maxheight-1)].ID == BLOCK_AIR;
          boolean sideF = blocks[x][z][constrain(y+1, 0, maxheight-1)].ID == BLOCK_AIR;
          boolean visible = sideA || sideB || sideC || sideD || sideE || sideF;
          if (blocks[x][z][y].ID > 0 && visible) {
            if (blocks[x][z][y].ID == 1) {
              fill(127, 63, 0);
            } else if (blocks[x][z][y].ID == 2) {
              fill(127);
            } else if (blocks[x][z][y].ID == 3) {
              fill(0, 191, 0);
            }
            translate(x*50 - (chunkw/2)*50 + (chunkx*chunkw*50), (16*50) - y*50, z*50 - (chunkh/2)*50 + (chunky*chunkh*50));
            box(50);
          }
          popMatrix();
        }
      }
    }
  }
}

void setup() { 
  size(640, 400, P3D);
  noSmooth();
  //cam = new PeasyCam(this, 1000);
  //cam.setMinimumDistance(0);
  //cam.setMaximumDistance(50000);
  chunks = new Chunk[worldw][worldh];
  offsetX = random(-100, 100);
  offsetY = random(-100, 100);
} 

void beginHUD() {
  camera();
  hint(DISABLE_DEPTH_TEST);
  hint(DISABLE_DEPTH_MASK);
  noLights();
  textMode(MODEL);
}

void endHUD() {
  hint(ENABLE_DEPTH_TEST);
  hint(ENABLE_DEPTH_MASK);
}

void draw() {
  if (state == GENERATE) {
    beginHUD();
    background(51);
    for (int i = 0; i < 20; i++) {
      chunks[genx][geny] = new Chunk(genx - worldw/2, geny - worldh/2);
      //println("Generating chunk " + geni + " of " + worldw*worldh);
      chunks[genx][geny].generate();
      geni++;
      genx++;
      if (genx == worldw) {
        genx = 0;
        geny++;
      }
      if (geny == worldh) {
        state = PLAY;
        //println("Generation finished!");
      }
    }
    int sl = min(width, height);
    translate((width-sl)/2, (height-sl)/2);
    noStroke();
    fill(255);
    rect(0, 0, sl-1, map(max(geny, 0), 0, worldh, 0, 400));
    rect(0, map(max(geny, 0), 0, worldh, 0, 400), map(genx, 0, worldw, 0, 400), 400/worldh);
  } else if (state == PLAY) {
    perspective(PI/3, float(width)/float(height), 1, 500000);
    background(0);
    rotateX(PI/2);
    translate(-playerX*50 + width, -playerZ*50 + 100, -100);
    rotateX(PI + PI/2);
    strokeWeight(1);
    stroke(0);
    int plx = floor(playerX/16);
    int plz = floor(playerZ/16);
    for (int x = 0; x < vieww; x++) {
      for (int y = 0; y < viewh; y++) {
        if (x+plx+(worldw/2)-(vieww/2) < worldw && x+plx+(worldw/2)-(vieww/2) >= 0) {
          if (y+plz+(worldh/2)-(viewh/2) < worldh && y+plz+(worldh/2)-(viewh/2) >= 0) {
            chunks[x+plx+(worldw/2)-(vieww/2)][y+plz+(worldh/2)-(viewh/2)].render();
          }
        }
      }
    }
    fill(255, 0, 0);
    pushMatrix();
    translate((playerX - 8)*50, -50, (playerZ - 8)*50);
    box(50);
    popMatrix();
    if (keyPressed) {
      if (key == 'w') {
        playerZ -= 2;
      } else if (key == 'a') {
        playerX -= 2;
      } else if (key == 's') {
        playerZ += 2;
      } else if (key == 'd') {
        playerX += 2;
      }
    }
    playerX = constrain(playerX, (-chunkw*worldw)/2 + 1, (chunkw*worldw)/2 - 1);
    playerZ = constrain(playerZ, (-chunkh*worldh)/2 + 1, (chunkh*worldh)/2 - 1);
    beginHUD();
    fill(51, 51, 51, 95);
    noStroke();
    rect(0, 0, 120, 80);
    fill(255);
    text("FPS: " + round(frameRate), 20, 20);
    text("Player X: " + floor(playerX), 20, 30);
    text("Player Y: ~", 20, 40);
    text("Player Z: " + floor(playerZ), 20, 50);
    text("Chunk X: " + plx, 20, 60);
    text("Chunk Z: " + plz, 20, 70);
  }
  endHUD();
}
