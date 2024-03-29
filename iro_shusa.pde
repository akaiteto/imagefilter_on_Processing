PImage[] imgArr;

int blackout_cnt = (int)random(10);
int noise_cnt = (int)random(10);
int switchIMG_cnt = 0;
int subliminal_cnt = 0;

int updateDisp_cnt = 0;

//Filter - motion blur
int MOTIONBLUR_RANDOM_MOVE_X = 10;
int MOTIONBLUR_RANDOM_MOVE_Y = 15;

//Filter - iro shusa
int IROSHUSA_SHIFT_RED_X = 10;
int IROSHUSA_SHIFT_RED_Y = 10;
int IROSHUSA_SHIFT_GREEN_X = 5;
int IROSHUSA_SHIFT_GREEN_Y = 5;
int IROSHUSA_SHIFT_BLUE_X = 10;
int IROSHUSA_SHIFT_BLUE_Y = 10;

//Filter - cutslide filter
int CUTSLIDE_RANDOM_VERTICAL = 10;
int CUTSLIDE_RANDOM_HORIZON = 20;

//Filter - Subliminal 
int SUBLIMINAL_INTERVAL_FRAME = 40;

//Filter - ScanLine
int SCANLINE_BODER_WEIGHT = 1;
int SCANLINE_BODER_INTERVAL = 5;
int SCANLINE_STROKE_COLOR = 220;

class Position{
  int x;
  int y;
}

void setup() {
  imgArr = new  PImage[4];
  
  imgArr[0]=loadImage("test.jpg");
  imgArr[1]=loadImage("test.jpg");
  imgArr[2]=loadImage("test.jpg");
  imgArr[3]=loadImage("test.jpg");
  
  size(204,247);
}

void draw() {
    background(0);
    
   subliminal_cnt+=1;
   PImage src  ;

    if(subliminal_cnt >= SUBLIMINAL_INTERVAL_FRAME){
       src = loadImage("download.jpg");
      PImage dst_img = src;
      dst_img = add_Noise(dst_img);
      dst_img = addScanLine(dst_img);
      image(dst_img, 0, 0);
      subliminal_cnt=0;
      SUBLIMINAL_INTERVAL_FRAME-=1;
      
    }else{
       src = loadImage("test.jpg");
      PImage dst_img = src;
      dst_img = motion_blur(dst_img,false);
      dst_img = add_IroShusa(dst_img);
      dst_img = addScanLine(dst_img);
      image(dst_img, 0, 0);
    }
    
    addCutSlide(src);
   
//    saveFrame("image/####.png");
//    if(subliminal_cnt >= SUBLIMINAL_INTERVAL_FRAME){
//      PImage src = loadImage("download.jpg");
//      image(add_Noise(src), 0, 0);
//      subliminal_cnt=0;
//      
//      SUBLIMINAL_INTERVAL_FRAME-=1;
//      
//    }else{
//      PImage src = loadImage("test.jpg");
//      PImage dst_img = src;
//      dst_img = motion_blur(dst_img,false);
//      dst_img = add_IroShusa(dst_img);
//      image(dst_img, 0, 0);
//    }
    saveFrame("image/####.png");
}


PImage addScanLine(PImage _img) {

  PImage img = _img;
  int fill_cnt =0;
  int nonfill_cnt =0;
  String mode = "fill";
  loadPixels(); 
  img.loadPixels(); 
  for (int y = 0; y < height; y++) {
    println(mode);
    for (int x = 0; x < width; x++) {
      int loc = x + y*width;
      
      float r = red(img.pixels[loc]);
      float g = green(img.pixels[loc]);
      float b = blue(img.pixels[loc]);
       
      if(mode == "fill"){
        img.pixels[loc]  =  add_Jousan(r,g,b,color(SCANLINE_STROKE_COLOR,SCANLINE_STROKE_COLOR,SCANLINE_STROKE_COLOR)); // Switch colors
        //img.pixels[loc]  =    color(SCANLINE_STROKE_COLOR,SCANLINE_STROKE_COLOR,SCANLINE_STROKE_COLOR);
       }
    }
    
      if(mode == "fill"){
        fill_cnt += 1;
      }else{
        nonfill_cnt += 1;
      }
      
      if (fill_cnt >= SCANLINE_BODER_WEIGHT){
        mode = "nonfill";
        fill_cnt=0;
      }else if (nonfill_cnt >= SCANLINE_BODER_INTERVAL){
        mode = "fill";
        nonfill_cnt=0;
      }
  }
  
  return img;
  
//  for (int y = 0; y < height; y+=SCANLINE_BODER_WEIGHT*SCANLINE_BODER_INTERVAL) {
//    blendMode(MULTIPLY);
    //stroke(SCANLINE_STROKE_COLOR);
    //strokeWeight(SCANLINE_BODER_WEIGHT);
    //line(0, y, width, y);
  //}
}

void addCutSlide(PImage _img){
  PImage img = _img;
  int x=0;
  int y=0;
  push();
  translate((width - img.width) / 2, (height - img.height) / 2);
  if (floor(random(100)) > 80) {
      x = floor(random(-width * 0.3, width * 0.7));
      y = floor(random(-height * 0.1, height));
      img = getRandomRectImg(_img);
  }
  image(img, x, y);
  pop();
  }
  
PImage getRandomRectImg(PImage srcImg) {
        int startX;
        int startY;
        int rectW;
        int rectH;
        PImage destImg;
        startX = floor(random(0, srcImg.width - 30));
        startY = floor(random(0, srcImg.height - 50));
        rectW = floor(random(30, srcImg.width - startX));
        rectH = floor(random(1, 50));
        destImg = srcImg.get(startX, startY, rectW, rectH);
        destImg.loadPixels();
        return destImg;
    }
  
PImage add_IroShusa(PImage _img){
  PImage img = _img;
  
  float[][] imgR = new float [width][height];
  float[][] imgG = new float [width][height];
  float[][] imgB = new float [width][height];
  
  loadPixels(); 
  img.loadPixels(); 
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      int loc = x + y*width;
      float r = red(img.pixels[loc]);
      float g = green(img.pixels[loc]);
      float b = blue(img.pixels[loc]);
      
      imgR[x][y] = red(add_Jousan(r,g,b,color(255,0,0)));
      imgG[x][y] = green(add_Jousan(r,g,b,color(0,255,0)));
      imgB[x][y] = blue(add_Jousan(r,g,b,color(0,0,255)));     
      }
  }
  
  //Shift pixel in imgR,G,B in order to pretend light dispersion
  //affine convert
  
  float[][] dstR  = new float [width][height];
  float[][] dstG  = new float [width][height];
  float[][] dstB  = new float [width][height];
  dstR = affineShiftConvert(imgR,width,height,(int)random(IROSHUSA_SHIFT_RED_X),(int)random(IROSHUSA_SHIFT_RED_Y));
  dstG = affineShiftConvert(imgG,width,height,(int)random(IROSHUSA_SHIFT_GREEN_X),(int)random(IROSHUSA_SHIFT_GREEN_Y));
  dstB = affineShiftConvert(imgB,width,height,(int)random(IROSHUSA_SHIFT_BLUE_X),(int)random(IROSHUSA_SHIFT_BLUE_Y));
  
  //merge Shifted R,G,Bimage 
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      int loc = x + y*width;
      float r = dstR[x][y];
      float g = dstG[x][y];
      float b = dstB[x][y];
      
      img.pixels[loc]  =  color(g,r,b); // Switch colors
    }
  }
  return img;
}

float[][] affineShiftConvert(float[][] src,int s_width,int s_height,int x_shift,int y_shift){
  
  float[][] dst = new float [s_width][s_height];
  int[][] affine =  {{1,0,x_shift},
                     {0,1,y_shift},
                     {0,0,1}};
  for (int y = 0; y < s_height; y++) {
    for (int x = 0; x < s_width; x++) {
      
    int[] dstPoint = {0,0,0}; 
    int[] srcPoint = {x,y,1};
      
      for (int r = 0; r < 3; r++) {
        int tmp = 0;
        for (int c = 0; c < 3; c++) {
          tmp += affine[r][c]*srcPoint[c];
          }
        dstPoint[r] = tmp;
      }  
      
      int x_move =0;
      int y_move =0;
      
      if (dstPoint[0] < s_width && dstPoint[1] < s_height) {
        
        x_move = dstPoint[0];
        y_move = dstPoint[1];
        dst[x_move][y_move] = src[x][y];
      }else{
        if(dstPoint[0] >= s_width || dstPoint[1] >= s_height){
          // if pixel shift for out of range,do nothing
        }else{
          dst[dstPoint[0]][dstPoint[1]] = 255;
        }
      }
    }
  }
  
  return dst;
}

float[][] affineShiftConvert(float[][] src,int s_width,int s_height,int x_shift,int y_shift,int range_x_L,int range_x_R,int range_y_L,int range_y_R){
  
  float[][] dst = new float [s_width][s_height];
  int[][] affine =  {{1,0,x_shift},
                     {0,1,y_shift},
                     {0,0,1}};
  for (int y = 0; y < s_height; y++) {
    for (int x = 0; x < s_width; x++) {
      
    int[] dstPoint = {0,0,0}; 
    int[] srcPoint = {x,y,1};
      
      for (int r = 0; r < 3; r++) {
        int tmp = 0;
        for (int c = 0; c < 3; c++) {
          tmp += affine[r][c]*srcPoint[c];
          }
        dstPoint[r] = tmp;
      }  
      
      int x_move =0;
      int y_move =0;
      
      
            
      if ((x >= range_x_L && x <= range_x_R ) && 
          (y >= range_y_L && y <= range_y_R )) {
            if (dstPoint[0] < s_width && dstPoint[1] < s_height) {
                x_move = dstPoint[0];
                y_move = dstPoint[1];
                dst[x_move][y_move] += src[x][y];
            }else{
                if(dstPoint[0] >= s_width || dstPoint[1] >= s_height){
                  // if pixel shift for out of range,do nothing
          
                }else{
                  dst[dstPoint[0]][dstPoint[1]] = 0;
                }
            }
      }else{
        dst[x][y] += src[x][y];
      }
    }
  }
  
  return dst;
}

color add_Jousan(float r, float g,float b,color cJousan){
  
  float r_onR = (r*(red(cJousan)/255) > 255 ? 255 : r*(red(cJousan)/255));
  float g_onR = (g*(green(cJousan)/255) > 255 ? 255 : g*(green(cJousan)/255));
  float b_onR = (b*(blue(cJousan)/255) > 255 ? 255 : b*(blue(cJousan)/255));
  
   return color(r_onR,g_onR,b_onR); // Set the display pixel to the image pixel   
}


PImage add_Noise(PImage _img){
  PImage img = _img;
  loadPixels(); 
  img.loadPixels(); 
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      
      int loc = x + y*width;
      
      float noise = randomGaussian()*200.0;
       
      float r = red(img.pixels[loc]);
      float g = green(img.pixels[loc]);
      float b = blue(img.pixels[loc]);
            
      float r_val = (r-noise > 255 ? 255 : r < 0 ? 0 : r-noise);
      float g_val = (g-noise > 255 ? 255 : g < 0 ? 0 : g-noise);
      float b_val = (b-noise > 255 ? 255 : b < 0 ? 0 : b-noise);
   
      img.pixels[loc]  =  color(r_val,g_val,b_val);        
    }
  }
  return img;
}

color add_Noise(float r, float g,float b){
   float noise = randomGaussian()*500.0;
       
   float r_val = (r+noise > 255 ? 255 : r < 0 ? 0 : r);
   float g_val = (g+noise > 255 ? 255 : g < 0 ? 0 : g);
   float b_val = (b+noise > 255 ? 255 : b < 0 ? 0 : b);
     
   return color(r_val,g_val,b_val); // Set the display pixel to the image pixel    
}

PImage motion_blur(PImage _img,Boolean addedNoise){
  
  PImage img = _img;
  
  int MOTION_X;
  int MOTION_Y;

  MOTION_X = (int)random(MOTIONBLUR_RANDOM_MOVE_X);
  MOTION_Y = (int)random(MOTIONBLUR_RANDOM_MOVE_Y);
 
  loadPixels(); 
  img.loadPixels(); 
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      int loc = x + y*width;
      
          float R_val=0.0f;
          float G_val=0.0f;
          float B_val=0.0f;
          float R_wh=0.0f;
          float G_wh=0.0f;
          float B_wh=0.0f;
            
          for(int iy = myMin(y + MOTION_Y, height -1) ; iy > y; iy--) {

            int locM = x +iy*width;
            
            float r = red(img.pixels[locM]);
            float g = green(img.pixels[locM]);
            float b = blue(img.pixels[locM]);
      
            R_val += r*2;
            G_val += g*2;
            B_val += b*2;

            R_wh += 2;
            G_wh += 2;
            B_wh += 2;
          }
          
          for(int ix = myMin(x + MOTION_X, width-1); ix > x; ix--) {
            int locM = ix + y*width;
            float r = red(img.pixels[locM]);
            float g = green(img.pixels[locM]);
            float b = blue(img.pixels[locM]);
      
            R_val += r;
            G_val += g;
            B_val += b;

            R_wh += 1;
            G_wh += 1;
            B_wh += 1;
          }
          
          loc = x + y*width;
          float R_res_val=0.0f;
          float G_res_val=0.0f;
          float B_res_val=0.0f;
           
          R_res_val = R_val/R_wh;
          G_res_val = G_val/G_wh;
          B_res_val = B_val/B_wh;
          
          color cval;
          
          //add noise 
          if (addedNoise){
            cval = add_Noise(R_res_val,G_res_val,B_res_val);
          }else{
            cval = color(R_res_val,G_res_val,B_res_val);
          }
          img.pixels[loc]  =  cval;         // Set the display pixel to the image pixel  
    }
  }
  
  return img;
  
}
int myMin(int a, int b) {
    return a < b ? a : b;
}
