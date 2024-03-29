
import processing.video.*;
import controlP5.*;
// TODO: import Java class for controlling data labeling


// you can configure the app here
class CONFIG {
  static final int gestureDuration = 6 * 1000; // in milliseconds
}

// constants
float VIDEO_ASPECT_RATIO = 1.7777778;
int   BACKGROUND_COLOR   = 50;
int   BUTTON_HEIGHT      = 48;
float MARGIN_VERTICAL    = 48;
float MARGIN_HORIZONTAL  = 32;

// main class declaration
GestureTrainer gestureTrainer;

class Gesture {
   public String label;
   public int gestureId;
   public String videoPath;
   
   Gesture(String labelT, int gestureIdT, String videoPathT){
     label     = labelT;
     gestureId = gestureIdT;
     videoPath = videoPathT;
   }
}

class GestureTrainer {
   public Gesture currentGesture;
   public ArrayList<Gesture> gestures;
   public Movie gestureVideo;
   //public Movie[] gestureVideos;
   public ArrayList<Movie> gestureVideos;
   public ControlP5 cp5;
   public int gestureDuration;
   public int timerStartTime;
   public int currentIdx = 0;
   private PFont roboto;
   private PApplet ctx;
   private Button prevBtn;
   private Button recordBtn;
   private Button nextBtn;
   private Slider slider;
   
   
   GestureTrainer(PApplet ctxT, ArrayList<Gesture> gesturesT, int gestureDurationT) {
     ctx = ctxT;
     gestures = gesturesT;
     gestureDuration = gestureDurationT;
     cp5 = new ControlP5(ctx);
     currentGesture= gestures.get(currentIdx); // currentIdx = 0
     loadVideos();
     onGestureChange(-1);
     showButtons();
   }
   
   public void loadVideos() {
     int num = gestures.size();
     gestureVideos = new ArrayList<Movie>();
     for(int i = 0; i < num; i++) {
       String path = gestures.get(i).videoPath;
       gestureVideos.add(new Movie(ctx, path));
     }
   }
   
   public void stopVideo(int gestureIdx) {
     println("stopping video: " + gestureIdx);
      gestureVideos.get(gestureIdx).stop(); 
   }
   
   public void showVideo(int gestureIdx) {
     println("showing video: " + gestureIdx);
      gestureVideos.get(gestureIdx).loop();
   }
   
   public void prev() {
      if (currentIdx == 0) return;
      int oldIdx = currentIdx;
      currentIdx--;
      currentGesture= gestures.get(currentIdx);
      onGestureChange(oldIdx);
   }
   
   public void next() {
      if (currentIdx + 1 >= gestures.size()) return;
      int oldIdx = currentIdx;
      currentIdx++;
      currentGesture = gestures.get(currentIdx);
      onGestureChange(oldIdx);
   }
   
   public void onGestureChange(int oldGestureIdx) {
      if (oldGestureIdx != -1) stopVideo(oldGestureIdx);
      showVideo(gestures.indexOf(currentGesture));
      showGestureName();
   }
   
   public void showGestureName() {
      rectMode(CENTER);
      fill(BACKGROUND_COLOR);
      noStroke();
      rect(width/2, 32, width, 32);
      roboto = createFont("Roboto.ttf", 32);
      fill(240);
      textFont(roboto);
      textSize(16);
      textAlign(CENTER);
      text(currentGesture.label, width/2, 32);
   }
   
   public void showButtons() {
     int gutter = 16;
     int BUTTON_WIDTH = (int) ( (width - MARGIN_HORIZONTAL*2) / 3 - gutter/1.5 );
     
     prevBtn   = cp5.addButton("prev")
                .setPosition(MARGIN_HORIZONTAL, height - BUTTON_HEIGHT)
                .setSize(BUTTON_WIDTH, BUTTON_HEIGHT)
      ;
     
     recordBtn = cp5.addButton("record")
                .setPosition(MARGIN_HORIZONTAL + BUTTON_WIDTH + gutter, height - BUTTON_HEIGHT)
                .setSize(BUTTON_WIDTH, BUTTON_HEIGHT)
      ;
      
     nextBtn = cp5.addButton("next")
                .setPosition(MARGIN_HORIZONTAL + BUTTON_WIDTH*2 + gutter*2, height - BUTTON_HEIGHT)
                .setSize(BUTTON_WIDTH, BUTTON_HEIGHT)
      ;
   }
   
   public void showSlider() {
      int sliderWidth  = (int) (width - MARGIN_HORIZONTAL*2);
      int sliderHeight = 40;
      
      slider = cp5.addSlider("slider")
                 .setSize(sliderWidth, sliderHeight)
                 .setPosition(MARGIN_HORIZONTAL, height - sliderHeight)
                 .setRange(gestureDuration / 1000, 0)
                 .setCaptionLabel("")
                 .lock();
   }
   
   public void removeButtons() {
     removeButton(prevBtn);
     removeButton(recordBtn);
     removeButton(nextBtn);
   }
   
   public void record() {
     println("Started '" + currentGesture.label + "' gesture recording...");
     timerStartTime = millis();
     removeButtons();
     showSlider();
     // TODO: call Java function to start labelling as gesture
     // e.g.
     // EMG_API.startGestureLabeling(currentGesture.name);
   }
   
   public void stopRecord() {
      println("Gesture '" + currentGesture.label + "' was successfully recorded.");
      // TODO: call Java function to stop labelling as gesture
      // e.g.
      // EMG_API.finishGestureLabeling();
      removeSlider(slider);
      showButtons();
   }
   
}


void setup() {
  //fullScreen();
  size(375, 666);
  background(BACKGROUND_COLOR);
  
  ArrayList<Gesture> gestures = new ArrayList<Gesture>();
  gestures.add(new Gesture("Resting",         1, "trimmed/resting.mp4"));
  gestures.add(new Gesture("Index extension", 2, "trimmed/index_extension.mp4"));
  gestures.add(new Gesture("Thumb abduction", 3, "trimmed/thumb_abduction.mp4"));
  gestures.add(new Gesture("Thumb extension", 4, "trimmed/swipe_right.mp4"));
  gestures.add(new Gesture("Pinky extension", 5, "trimmed/pinky_extension.mp4"));
  gestures.add(new Gesture("Hand open",       6, "trimmed/hand_open.mp4"));
  gestures.add(new Gesture("Wrist extension", 7, "trimmed/wrist_extension.mp4"));
  
  // initialize gesture trainer
  gestureTrainer = new GestureTrainer(this, gestures, CONFIG.gestureDuration);
}

void record() {
  gestureTrainer.record();
}

void prev() {
  gestureTrainer.prev();
}

void next() {
  gestureTrainer.next();
}

void draw() {
  if (gestureTrainer.gestureVideos != null) {   
    float videoWidth  = width - MARGIN_HORIZONTAL*2;
    float videoHeight = videoWidth * VIDEO_ASPECT_RATIO;
    float videoXPos   = MARGIN_HORIZONTAL;
    float videoYPos   = MARGIN_VERTICAL;
  
    image(gestureTrainer.gestureVideos.get(gestureTrainer.currentIdx), videoXPos, videoYPos, videoWidth, videoHeight);
  }
  if (gestureTrainer.slider != null) {
    int gestureDuration = gestureTrainer.gestureDuration;
    int timer = millis();
    float timeLeft = (float) (gestureDuration - (timer - gestureTrainer.timerStartTime)) / 1000;
    float sliderValue = (float) Math.floor(timeLeft);
    gestureTrainer.slider.setValue(sliderValue);
    if (timeLeft <= 0) {
      gestureTrainer.stopRecord();
    }
  }
}

void movieEvent(Movie m) {
  m.read();
}

void removeSlider(Slider slider) {
   float sliderWidth = slider.getWidth();
   float sliderHeight = slider.getHeight();
   float[] sliderPosition = slider.getPosition();
   slider.remove();
   gestureTrainer.slider = null;
   rectMode(CORNER);
   noStroke();
   fill(BACKGROUND_COLOR);
   rect(sliderPosition[0], sliderPosition[1], sliderWidth, sliderHeight);
}


void removeButton(Button button) {
   float btnWidth = button.getWidth();
   float btnHeight = button.getHeight();
   float[] btnPosition = button.getPosition();
   button.remove();
   rectMode(CORNER);
   noStroke();
   fill(BACKGROUND_COLOR);
   rect(btnPosition[0], btnPosition[1], btnWidth, btnHeight);
}
