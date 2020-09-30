String imageUrl1 = "https://devstickers.com/assets/img/pro/t8gc.png"; //https://imgur.com/a/JM1mUz6
String imageUrl2 = "https://lh4.ggpht.com/UCVPiGGHrs3zNel6ya16OvJozyI6x0SnXHTm7dK1SoM74M1dFmQ2v53jd-DT3MJgOOWE";
String imageUrl3 = "https://i.imgur.com/hPN0qxt.png";
PImage DinoImage = loadImage(imageUrl1);
PImage CactusImage = loadImage(imageUrl2);
PImage BirdImage = loadImage(imageUrl3);

float y = 250; // dino Y position
float vy = 0; // dino y velocity
float groundY = 250; // lowest dino Y position
float dinoX = 200; // dino X position
float obsSpeed = 3; // speed of obstacles
float gravity = 1; 

boolean start = false;
boolean ducking = false;

int time = 0;
int bestTime = 0;
int numObs = 0; // # obstacles so far
int lastObs = 0; // seconds since last obstacle

class Obstacle{
    float x;
    float y;
    int type;
    boolean exist = false;
}

Obstacle[] obstacles = new Obstacle[6];

Obstacle makeObs(int t) {
    Obstacle obs = new Obstacle();
    obs.type = t; // 1 for cactus, 0 for bird
    obs.exist = true;
    obs.x = 800;
    if (t == 1) {
        obs.y = 260;
    } else if (t == 0) {
        obs.y = 220;
    }
    
    return obs;
}

void setup() {
    size(800, 400);
    reset();
   
}

void draw() {
    background(200);
    fill(150);
    rect(0, 260, 800, 140);
    imageMode(CENTER);
    if (!ducking) {
        image(DinoImage, dinoX, y, 50, 50);
    } else {
        image(DinoImage, dinoX, y + 10, 30, 30);
    }
    
    
    y -= vy;
    vy -= gravity;
    if (y >= groundY) {
        y = groundY;
        vy = 0;
    }
    
    textSize(20);
    textAlign(LEFT);
    fill(0);
    text("Time: " + time, 50, 50);
    text("Best time: " + bestTime, 50, 70);
    textSize(15);
    text("Controls:\nJUMP - Space or Up Arrow \nDUCK - Down Arrow", 50, 100);
    
    
    if (!start) {
        textSize(20);
        textAlign(CENTER);
        if ((frameCount / 60) % 2 == 0) {
            text("Press space to play.", 400, 150);
        }
    }
    
    if (start) {
        if (frameCount % 60 == 0) {
            time++;
            obsSpeed = 3 + sqrt(time) / 4; // obstacle speed increases as time increases
        }

        lastObs++;
        for (Obstacle obs : obstacles) {
            if (obs.exist) {
                if (obs.type == 1) {
                    image(CactusImage, obs.x, obs.y, 50, 50);
                } else if (obs.type == 0) {
                    image(BirdImage, obs.x, obs.y, 50, 50);
                }
                
                obs.x -= obsSpeed;
                if (obs.x < 0) {
                    obs.exist = false;
                }
                
                if (!ducking) {
                    if (collision(dinoX, y, 30, 30, obs.x, obs.y, 30, 30)) {
                        reset();
                    }
                } else {
                    if (collision(dinoX, y + 10, 30, 30, obs.x, obs.y, 30, 30)) {
                        reset();
                    }
                }
                
            }
        }
        
        // new obstacle has a chance of appearing - increases as time increases
        float r = random(60 * 100);
        if (r < 50 + time && lastObs > max(40 - sqrt(time) * 2, 25)) {
            obstacles[numObs % 6] = makeObs((int)r % 2);
            lastObs = 0;
            numObs++;
        }
    }
    
    
    
}

void keyPressed() {
    if (keyCode == UP || key == ' ') {
        if (!start) {
            start = true;
            time = 0;
        }
        
        if (y >= groundY) {
            vy = 10;
            gravity = 0.5;
        }
    }
    
    if (keyCode == DOWN) {
        gravity = 2;
        ducking = true;
    }
}

void keyReleased() {
    gravity = 1;
    ducking = false;
}

boolean collision(float ax,float ay, float aw, float ah, float bx, float by, float bw, float bh){
    return Math.abs(ax-bx) <= aw/2+bw/2 && Math.abs(ay-by) <= bh/2+ah/2;
}

void reset() {
    start = false;
    for (int i = 0; i < obstacles.length; i++) {
        obstacles[i] = new Obstacle();
    }
    if (time > bestTime) {
        bestTime = time;
    }
}